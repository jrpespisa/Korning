# Use this file to import the sales information into the
# the database.

require "pg"
require 'csv'
require 'pry'
require_relative 'helper'

system 'psql korning < schema.sql'

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

@sales_hash = CSV.readlines("sales.csv", headers: true)

@sales_array = []
CSV.foreach("sales.csv", headers: true, header_converters: :symbol) do |row|
  sale = row.to_hash
  @sales_array << sale
end

helper = Helper.new("korning")

def seed_employees(helper)
  insert_sql = "INSERT INTO employees (employee) VALUES ($1);"
  @sales_hash.each do |key, value|
    read_sql = "SELECT employee FROM employees WHERE employee = $1"
    data = [key["employee"]]
    @employees_id = helper.insert("SELECT id FROM employees WHERE employee = $1", data)
    employees_in_db = helper.insert(read_sql, data)
    if employees_in_db.count == 0
      helper.insert(insert_sql, data)
    end
  end
end

def seed_customers(helper)
  insert_sql = "INSERT INTO customers (customer) VALUES ($1);"
  @sales_hash.each do |key, value|
    read_sql = "SELECT customer FROM customers WHERE customer = $1"
    data = [key["customer_and_account_no"]]
    customers_in_db = helper.insert(read_sql, data)
    if customers_in_db.count == 0
      helper.insert(insert_sql, data)
    end
  end
end

def seed_products(helper)
  insert_sql = "INSERT INTO products (product) VALUES ($1);"
  @sales_hash.each do |key, value|
    read_sql = "SELECT product FROM products WHERE product = $1"
    data = [key["product_name"]]
    products_in_db = helper.insert(read_sql, data)
    if products_in_db.count == 0
      helper.insert(insert_sql, data)
    end
  end
end


def seed_sales(helper)
  insert_sql = "INSERT INTO sales (sale_date, sale_amount, units_sold, invoice_no, invoice_freq) VALUES ($1, $2, $3, $4, $5);"
  @sales_hash.each do |key, value|
    data = [key["sale_date"], key["sale_amount"], key["units_sold"], key["invoice_no"], key["invoice_frequency"]]
    helper.insert(insert_sql, data)
  end
end


# def foreign_keys
#   insert_sql = "INSERT INTO sales (employees_id, customers_id, products_id) VALUES ($1, $2, $3);"
#   @sales_hash.each do |key, value|
#     data = [@employees_id, @customers_id, @products_id]
#     helper.insert(insert_sql, data)
#   end
# end


seed_employees(helper)
seed_customers(helper)
seed_products(helper)
seed_sales(helper)

@sales_array.each do |sale|
  db_connection do |conn|
    employees_id = conn.exec_params("SELECT id FROM employees WHERE ($1) = employees.employee", ["#{sale[:employee]}"])
    products_id = conn.exec_params("SELECT id FROM products WHERE ($1) = products.product", ["#{sale[:product_name]}"])
    customers_id = conn.exec_params("SELECT id FROM customers WHERE ($1) = customers.customer", ["#{sale[:customer_and_account_no]}"])

    conn.exec_params("INSERT INTO sales (employees_id, customers_id, products_id, invoice_no, sale_date, sale_amount, units_sold) VALUES ($1, $2, $3, $4, $5, $6, $7);", ["#{employees_id[0]["id"]}","#{products_id[0]["id"]}","#{customers_id[0]["id"]}", "#{sale[:invoice_no]}", "#{sale[:sale_date]}", "#{sale[:sale_amount]}", "#{sale[:units_sold]}"])
  end
end

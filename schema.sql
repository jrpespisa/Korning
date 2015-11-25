DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS sales CASCADE;

CREATE TABLE employees (
  id SERIAL PRIMARY KEY,
  employee VARCHAR(255)
);

CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  customer VARCHAR(255)
);

CREATE TABLE products (
  id SERIAL PRIMARY KEY,
  product VARCHAR(255)
);

CREATE TABLE sales (
  id SERIAL PRIMARY KEY,
  employees_id INT REFERENCES employees(id),
  customers_id INT REFERENCES customers(id),
  products_id INT REFERENCES products(id),
  sale_date VARCHAR(50),
  sale_amount VARCHAR(50),
  units_sold VARCHAR(50),
  invoice_no VARCHAR(50),
  invoice_freq VARCHAR(50)
);

-- SELECT sales.employees_id, employees.employee FROM sales JOIN employees ON employees.id = sales.employees_id

class Helper
  def initialize(database)
    @database = database
  end

  def read(sql_command)
    db_connection { |conn| conn.exec(sql_command) }
  end

  def insert(sql_command, data)
    db_connection { |conn| conn.exec_params(sql_command, data) }
  end
end

# Use this file to import the sales information into the
# the database.

require 'CSV'
require "pg"
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  rescue PG::UniqueViolation
  ensure
    connection.close
  end
end

employees = []
customers = []
products = []
frequencies = []
sales = []

properties = [
  employees,
  customers,
  products,
  frequencies
]

CSV.foreach('sales.csv', headers: true, header_converters: :symbol) do |row|
  sale = row.to_hash
  sales << sale
end

sales.each do |sale|
  employees << sale[:employee]
  customers << sale[:customer_and_account_no]
  products << sale[:product_name]
  frequencies << sale[:invoice_frequency]
end

properties.each do |attribute|
  attribute.uniq!
end

employees.each do |employee|
  # result = db_connection do |conn|
  #   conn.exec_params("SELECT name FROM employees WHERE name = ($1)",[employee[]])
  # end
  # if result.first.empty?
  db_connection do |conn|
    conn.exec_params("INSERT INTO employees (name) VALUES ($1)", [employee])
  end
end

customers.each do |customer|
  db_connection do |conn|
    conn.exec_params("INSERT INTO customers (name) VALUES ($1)", [customer])
  end
end

products.each do |product|
  db_connection do |conn|
    conn.exec_params("INSERT INTO products (name) VALUES ($1)", [product])
  end
end

frequencies.each do |frequency|
  db_connection do |conn|
    conn.exec_params("INSERT INTO frequencies (name) VALUES ($1)", [frequency])
  end
end


sales.each do |sale|
    db_connection do |conn|
      emp_id = conn.exec("SELECT emp_id FROM employees WHERE name = ($1)", [sale[:employee]]).first["emp_id"]

      customer_id = conn.exec("SELECT cust_id FROM customers WHERE name = '#{sale[:customer_and_account_no]}'").to_a
      cust_id = customer_id[0]["cust_id"].to_i

      product_id = conn.exec("SELECT prod_id FROM products WHERE name = '#{sale[:product_name]}'").to_a
      prod_id = product_id[0]["prod_id"].to_i

      frequency_id = conn.exec("SELECT freq_id FROM frequencies WHERE name = '#{sale[:invoice_frequency]}'").to_a
      freq_id = frequency_id[0]["freq_id"].to_i

      # emp_id = conn.exec("SELECT emp_id FROM employees WHERE email = ($1)", [name_array[2]]).first["emp_id"]
      # cust_id = conn.exec("SELECT cust_id FROM customers WHERE account_num = ($1)", [co_array[1]]).first["cust_id"]
      # prod_id = conn.exec("SELECT prod_id FROM products WHERE name = ($1)", [sale[:product_name]]).first["prod_id"]
      # freq_id = conn.exec("SELECT freq_id FROM frequencies WHERE name = ($1)",[sale[:invoice_frequency]]).first["freq_id"]


      sale_date = sale[:sale_date]
      sale_amount = sale[:sale_amount]
      sale_units = sale[:units_sold]
      sale_invoice_no = sale[:invoice_no]

      conn.exec("INSERT INTO sales (employee_id, customer_id, product_id, frequency_id, sale_date, sale_amount, units_sold, invoice_num)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8)", [emp_id, cust_id,prod_id,freq_id,sale_date,sale_amount,sale_units,sale_invoice_no])
    end
end
# customer_id = conn.exec("SELECT cut_id FROM employees WHERE name = sale[:employee]}'")

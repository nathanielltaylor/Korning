-- DEFINE YOUR DATABASE SCHEMA HERE
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS frequencies CASCADE;
DROP TABLE IF EXISTS sales CASCADE;

CREATE TABLE employees (
  emp_id SERIAL PRIMARY KEY,
  name varchar(200)
);
CREATE UNIQUE INDEX employee_index ON employees (emp_id);

CREATE TABLE customers (
  cust_id SERIAL PRIMARY KEY,
  name varchar(200)
);
CREATE UNIQUE INDEX customer_index ON customers (cust_id);

CREATE TABLE products (
  prod_id SERIAL PRIMARY KEY,
  name varchar(200)
);
CREATE UNIQUE INDEX product_index ON products (prod_id);

CREATE TABLE frequencies (
  freq_id SERIAL PRIMARY KEY,
  name varchar(200)
);
CREATE UNIQUE INDEX frequency_index ON frequencies (freq_id);

-- join table
CREATE TABLE sales (
  invoice_id SERIAL PRIMARY KEY,
  employee_id SERIAL references employees(emp_id),
  customer_id SERIAL references customers(cust_id),
  product_id SERIAL references products(prod_id),
  frequency_id SERIAL references frequencies(freq_id),
  sale_date varchar(200),
  sale_amount varchar(200),
  units_sold int,
  invoice_num int
);
CREATE UNIQUE INDEX invoice_index ON sales (customer_id, sale_date, sale_amount, units_sold, invoice_num);

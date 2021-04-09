CREATE DATABASE testdb;
CREATE USER 'test'@'localhost';
SET password FOR 'test'@'localhost' = password('password');
GRANT ALL ON testdb.* TO 'test'@'localhost' IDENTIFIED BY 'password' WITH GRANT OPTION;
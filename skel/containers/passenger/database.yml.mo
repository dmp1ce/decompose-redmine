# Default setup is given for MySQL with ruby1.9. If you're running Redmine
# with MySQL and ruby1.8, replace the adapter name with `mysql`.
# Examples for PostgreSQL, SQLite3 and SQL Server can be found at the end.
# Line indentation must be 2 spaces (no tabs).

production: &default
  adapter: mysql2
  database: "{{PROJECT_DB_DATABASE}}"
  host: <%= ENV.fetch('MARIADB_1_PORT_3306_TCP_ADDR', 'localhost') %>
  port: <%= ENV.fetch('MARIADB_1_PORT_3306_TCP_PORT', '3306') %>
  username: "{{PROJECT_DB_USER}}"
  password: "{{PROJECT_DB_PASSWORD}}"
  encoding: utf8

development:
  <<: *default
  database: redmine_development

# Warning: The database defined as "test" will be erased and
# re-generated from your development database when you run "rake".
# Do not set this db to the same as development or production.
test:
  <<: *default
  database: redmine_test

# PostgreSQL configuration example
#production:
#  adapter: postgresql
#  database: redmine
#  host: localhost
#  username: postgres
#  password: "postgres"

# SQLite3 configuration example
#production:
#  adapter: sqlite3
#  database: db/redmine.sqlite3

# SQL Server configuration example
#production:
#  adapter: sqlserver
#  database: redmine
#  host: localhost
#  username: jenkins
#  password: jenkins

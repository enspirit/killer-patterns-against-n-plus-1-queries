require_relative 'helpers'

# Drop tables if they exist (for re-runs)
SEQUEL_DB.drop_table?(:employees)
SEQUEL_DB.drop_table?(:departments)

# Create departments table
SEQUEL_DB.create_table :departments do
  primary_key :id
  String :name, null: false
end

# Create employees table
SEQUEL_DB.create_table :employees do
  primary_key :id
  String :first_name, null: false
  String :last_name, null: false
  String :email, null: false, unique: true
  foreign_key :department_id, :departments
end

# Define model classes
class Department < Sequel::Model; end
class Employee < Sequel::Model; end

# Seed departments
puts "Seeding 100 departments..."
(N_SIZE/10).to_i.times do
  Department.create(name: Faker::Company.unique.industry)
end

# Get all department IDs
department_ids = Department.select_map(:id)

# Seed employees
puts "Seeding 1000 employees..."
N_SIZE.times do
  first_name = Faker::Name.first_name
  last_name  = Faker::Name.last_name
  email      = Faker::Internet.unique.email(name: "#{first_name} #{last_name}")

  Employee.create(
    first_name: first_name,
    last_name: last_name,
    email: email,
    department_id: department_ids.sample
  )
end

puts "Done! Database 'company.db' created with departments and employees."

### What should be written instead, correct SQL
require_relative '../example/helpers'

class Software

  def caller
    # The caller -> callee relation is a JOIN, use it
    records = DB[<<~SQL, N_SIZE]
      SELECT
        e.email,
        d.name AS department_name
      FROM
        employees e
      JOIN
        departments d
      ON
        e.department_id = d.id
      LIMIT
        ?
    SQL

    records.map do |record|
      # lots of complicated
      # logic
      #
      # actually hard to refactor
      #
      # and somewhere, possibly under conditions,
      # a single call to the database for each id
      dept_name = record[:department_name]
      # and the logic is continued
      # using the result of course
      "Employee #{record[:email]} works for #{dept_name}"
    end
  end

end

puts Software.new.caller

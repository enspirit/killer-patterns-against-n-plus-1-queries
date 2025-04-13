### Original code, with N+1 queries
require_relative '../example/helpers'

class Software

  def caller
    # 1 query fetching some parent records
    employees = DB["SELECT * FROM employees LIMIT ?", N_SIZE]

    ############################## START/ WE DO NOT WANT TO TOUCH ALL CODE BELOW
    # N queries within a loop in the host language
    results = []
    employees.each do |employee|
      # lots of complicated
      # logic
      #
      # actually hard to refactor
      #
      # and somewhere, possibly under conditions,
      # a single call to the database for each id
      dept_name = callee(employee[:department_id])
      # and the logic is continued
      # using the result of course
      results.push("Employee #{employee[:email]} works for #{dept_name}")
    end

    results
    # END/ #####################################################################
  end

  def callee(dept_id)
    dept = DB["SELECT * FROM departments WHERE id=?", dept_id].first

    return dept[:name]
  end

end

puts Software.new.caller

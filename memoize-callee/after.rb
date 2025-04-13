### Refactored code, less queries actually sent
require_relative '../example/helpers'

class Software

  def caller
    # 1 query fetching some parent records
    employees = DB["SELECT * FROM employees LIMIT ?", N_SIZE]

    cache = {}

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
      dept_name = memoized_callee(employee[:department_id], cache)
      # and the logic is continued
      # using the result of course
      results.push("Employee #{employee[:email]} works for #{dept_name}")
    end

    results
    # END/ #####################################################################
  end

  # Memoized version of `callee`
  def memoized_callee(dept_id, cache)
    cache[dept_id] ||= callee(dept_id)
  end

  # 100% untouched
  def callee(dept_id)
    dept = DB["SELECT * FROM departments WHERE id=?", dept_id].first

    return dept[:name]
  end

end

puts Software.new.caller

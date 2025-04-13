### Refactored code, with 2 queries only
### Play with lines 13 and 26 to see the results with and without cache.
require_relative '../example/helpers'

class Software

  def caller
    # 1 query fetching some parent records
    employees = DB["SELECT * FROM employees LIMIT ?", N_SIZE]

    ## PREFETCH by simply calling the refactored method
    ## with all ids at once.
    ## The cache is opaque to the caller, and will just be passed back to callee below
    cache = callee(employees.map{|r| r[:department_id] })

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
      dept_name = callee(employee[:department_id], cache)
      # and the logic is continued
      # using the result of course
      results.push("Employee #{employee[:email]} works for #{dept_name}")
    end

    results
    # END/ #####################################################################
  end

  def callee(id, cache = nil)
    if id.is_a?(Array)
      ### START/ code refactored to use a collective query, we just put results
      ### in a cache that is returned
      raise "Cache should not be received when prefetching" unless cache.nil?
      records = DB["SELECT * FROM departments WHERE id IN ?", id]
      cache = records.each_with_object({}) do |dept, h|
        h[dept[:id]] = dept
      end
      ### END/
    elsif cache && cache.has_key?(id)
      ### START/ code refactored as little as possible to use the CACHE instead
      ### of the database. Minimal changes are welcome. Not moving logic in the
      ### caching mechanism above is more risky than keeping it here.
      cache[id][:name]
      ### END/
    else
      ### START/ we may want to keep the code absolutely equivalent to what
      ### we had before
      puts "WARN: callee(#{id}) should be prefetched"
      cache = callee([id])
      callee(id, cache)
      ### END/
    end
  end

end

puts Software.new.caller

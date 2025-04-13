### What if callee(i) can still be called on an individual basis from other
### place of the code ?
###
### You can play with lines 15 and 28 to see the results.

class Software

  def caller
    # 1 query fetching some parent records
    records = Database.query("parents", Array.new(10){|i| i })

    ## PREFETCH by simply calling the refactored method
    ## with all ids at once.
    ## The cache is opaque to the caller, and will just be passed back to callee below
    cache = callee(records.map{|r| r[:id] })

    ############################## START/ WE DO NOT WANT TO TOUCH ALL CODE BELOW
    # N queries within a loop in the host language
    results = []
    records.each do |record|
      # lots of complicated
      # logic
      #
      # actually hard to refactor
      #
      # and somewhere, possibly under conditions,
      # a single call to the database for each id
      result = callee(record[:id], cache)
      # and the logic is continued
      # using the result of course
      results.push(result)
    end

    results
    # END/ #####################################################################
  end

  def callee(id, cache = nil)
    if id.is_a?(Array)
      ### START/ code refactored to use a collective query, we just put results
      ### in a cache that is returned
      raise "Cache should not be received when prefetching" unless cache.nil?
      children = Database.query("child", id)
      cache = {}
      children.each do |child|
        cache[child[:id]] = child
      end
      cache
      ### END/
    elsif cache && cache.has_key?(id)
      ### START/ code refactored as little as possible to use the CACHE instead
      ### of the database. Minimal changes are welcome. Not moving logic in the
      ### caching mechanism above is more risky than keeping it here.
      result = cache[id]

      return "Some result with #{id} => #{result}"
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

class Database

  # The following method simulates a call to a database,
  # returning a result with `n` records depending on `arg`
  def self.query(table, arg)
    puts "SELECT ... FROM #{table} WHERE #{arg}"
    Array(arg).map{|i| { table: table, id: i } }
  end

end

puts Software.new.caller

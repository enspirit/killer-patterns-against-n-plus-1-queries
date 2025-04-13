### Original code, with N+1 queries

class Software

  def caller
    # 1 query fetching some parent records
    records = Database.query("parents", Array.new(10){|i| i })

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
      result = callee(record[:id])
      # and the logic is continued
      # using the result of course
      results.push(result)
    end

    results
    # END/ #####################################################################
  end

  def callee(id)
    result = Database.query("child", id)

    return "Some result with #{id} => #{result}"
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

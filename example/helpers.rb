require 'sequel'
require 'sqlite3'
require 'faker'
require 'path'
require 'logger'

# Connect to (or create) SQLite database
DB_FILE = (Path.dir/'company.db').to_s
SEQUEL_DB = Sequel.sqlite(DB_FILE, logger: Logger.new($stdout))

# Size of the N problem we want to execute
N_SIZE = ENV['N']&.to_i || 10

SLOW = ENV['SLOW']&.to_f || 0.01

$stderr.puts "Running example with N=#{N_SIZE}, SLOW=#{SLOW}"

class HackedDb
  def initialize(sequel_db)
    @sequel_db = sequel_db
  end

  def [](*args)
    @sequel_db[*args].to_a.tap{ sleep(SLOW) }
  end
end
DB = HackedDb.new(SEQUEL_DB)

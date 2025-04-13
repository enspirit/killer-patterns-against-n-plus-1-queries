install: example/company.db

clean:
	rm -rf example/company.db Gemfile.lock

run: example/company.db run_prefetch_and_cache run_memoized_callee

run_prefetch_and_cache:
	time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/before.rb > /dev/null
	time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/after.rb > /dev/null
	time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/ideal.rb > /dev/null

run_memoized_callee:
	time N=1000 SLOW=0.005 bundle exec ruby memoize-callee/before.rb > /dev/null
	time N=1000 SLOW=0.005 bundle exec ruby memoize-callee/after.rb > /dev/null
	time N=1000 SLOW=0.005 bundle exec ruby memoize-callee/ideal.rb > /dev/null

Gemfile.lock: Gemfile
	bundle install

example/company.db: Gemfile.lock example/*.rb
	N=1000 bundle exec ruby example/build.rb

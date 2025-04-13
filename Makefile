install: example/company.db

clean:
	rm -rf example/company.db Gemfile.lock

run: example/company.db
	time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/before.rb > /dev/null
	time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/after.rb > /dev/null
	time N=1000 SLOW=0.005 bundle exec ruby prefetch-and-cache/ideal.rb > /dev/null

Gemfile.lock: Gemfile
	bundle install

example/company.db: Gemfile.lock example/*.rb
	N=1000 bundle exec ruby example/build.rb

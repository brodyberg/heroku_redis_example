# Redis and Resque on Heroku

This is an extremely basic [Ruby on Rails](http://rubyonrails.org/) Application that demonstrates how a Rails 2.3 application hosted on [Heroku](http://heroku.com) can use [Resque](http://github.com/defunkt/resque) with [Redis](http://code.google.com/p/redis/).

Adapted from [Resque with Redis To Go by James R. Bracy](http://blog.redistogo.com/2010/07/26/resque-with-redis-to-go/) and [Defunkt's Resque](http://github.com/defunkt/resque)

The main difference is that this application runs on Rails 2.3x rather than Rails 3 and this application has no database dependency. Mr. Bracy has [a Rails 3.x version of this example](http://github.com/waratuman/cookie-monster).

## Create the basic Rails application

* New Rails app: `rails heroku_redis_example`
* `cd heroku_redis_example`

## Remove the database dependency

* Uncomment this line from `environment.rb`: `config.frameworks -= [ :active_record, :active_resource, :action_mailer ]`
* `rm RAILS_ROOT/config/database.yml`

## Configure Gems with Bundler

* Create and add this to `Gemfile`

      source 'http://rubygems.org'

      gem "rails", ">=2.3.8"
      gem 'resque'
      gem 'SystemTimer'

* `bundle install`
* `bundle lock`
* Add a preinitializer file to work around Bundler issues: (From: [http://stackoverflow.com/questions/2170697/bundler-isnt-loading-gems](http://stackoverflow.com/questions/2170697/bundler-isnt-loading-gems))

      begin
        # Require the preresolved locked set of gems.
        require File.expand_path('../.bundle/environment', __FILE__)
      rescue LoadError
        # Fallback on doing the resolve at runtime.
        require "rubygems"
        require "bundler"

        Bundler.setup
      end

      # Auto-require all bundled libraries.
      Bundler.require

## Configure Resque

* create `RAILS_ROOT/config/resque.rb` and add: 

      ENV["REDISTOGO_URL"] ||= "redis://username:password@host:1234/"

      uri = URI.parse(ENV["REDISTOGO_URL"])
      Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

      Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }

## Configure Resque-web for debugging

* Create `RAILS_ROOT/config.ru`

      # A mix of the config.ru at Defunkt's Resque and the original help
      # file mentioned above

      require "config/environment"
      require 'resque/server'
      require 'logger'

      use Rails::Rack::LogTailer
      use Rails::Rack::Static
      use Rack::ShowExceptions

      # Set the AUTH env variable to your basic auth password to protect Resque.
      AUTH_PASSWORD = 'secret'
      if AUTH_PASSWORD
        Resque::Server.use Rack::Auth::Basic do |username, password|
          password == AUTH_PASSWORD
        end
      end

      run Rack::URLMap.new \
        "/"       => ActionController::Dispatcher.new,
        "/resque" => Resque::Server.new

## Add Resque Worker Class

* Create a job in `app/jobs/trogdor.rb`

      class Trogdor
        @queue = :terrorize
  
        def self.perform(target)
          puts "Burninating the #{target}!"
        end
      end

## Create Controller which will initiate Resque worker

In this step we write the code that will be initiated by a web request and itself initiate a worker. 

* `RAILS_ROOT/script/generate controller trogdor`
* Create this method in the controller:

      def burninate
        Resque.enqueue(Trogdor, params[:target])
        render :text => "Telling Trogdor to burninate #{params[:target]}."
      end

## Configure the route to our controller

Here we tell Rails how to handle a certain web request in order to invoke the `burninate` method in `TrogdorController`

* Set `RAILS_ROOT/config/routes.rb` to: 

      ActionController::Routing::Routes.draw do |map|
        map.trogdor 'trogdor/burninate/:target', :controller => 'trogdor', :action => 'burninate'
      end
 
## Add Resque task to Rake

* In `lib/tasks/resque.rake`:

      require 'resque/tasks'

      task "resque:setup" => :environment do
        ENV['QUEUE'] = '*'
      end

      desc "Alias for resque:work (To run workers on Heroku)"
      task "jobs:work" => "resque:work"
 
## Add project to Git
 
* Add application to Git: `git init`
* Add all files to Git: `git add .`
* Commit to your Git repository: `git commit -m 'Initial commit'`

## Add project to Heroku

* Create the application with Heroku: `heroku create`
* Add the Redis Heroku addon: `heroku addons:add redistogo`
* Push your code to heroku: `git push heroku master`

## Test the application

Verify Resque-web works:

* Open [http://young-sunrise-78.heroku.com/resque](http://young-sunrise-78.heroku.com/resque) (any username, password 'secret')

Verify the application works: 

* Open [http://young-sunrise-78.heroku.com/trogdor/burninate/countryside](http://young-sunrise-78.heroku.com/trogdor/burninate/countryside)

Kickoff the worker using [Heroku rake command](http://docs.heroku.com/rake) syntax:

* Start Resque worker: `heroku rake resque:work --app young-sunrise-78 --trace`

## Observe for Maximum Win

* Observe the output of the console command to heroku rake: 

      ~/heroku_redis_example(master) $ heroku rake resque:work --app young-sunrise-78 --trace
      (in /disk1/home/slugs/258287_149fab6_faff/mnt)
      ** Invoke resque:work (first_time)
      ** Invoke resque:setup (first_time)
      ** Invoke environment (first_time)
      ** Execute environment
      ** Execute resque:setup
      ** Execute resque:work
      Burninating the countryside!
      

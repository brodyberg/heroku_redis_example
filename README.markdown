# Redis and Resque on Heroku

Adapted from http://blog.redistogo.com/2010/07/26/resque-with-redis-to-go/ and http://github.com/defunkt/resque

* `rails heroku_redis_example`
* `cd heroku_redis_example`
* Create and add this to `Gemfile`

    source 'http://rubygems.org'

    gem "rails", ">=2.3.8"
    gem 'resque'
    gem 'SystemTimer'

* `bundle install`
* `bundle lock`
* `git add Gemfile Gemfile.lock`

* create `RAILS_ROOT/config/resque.rb` and add: 

    ENV["REDISTOGO_URL"] ||= "redis://username:password@host:1234/"

    uri = URI.parse(ENV["REDISTOGO_URL"])
    Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

* Create a job in `app/jobs/trogdor.rb`

    class Trogdor
      @queue = :terrorize
  
      def perform(target)
        puts "Burninating the #{target}!"
      end
    end

* Add a preinitializer file to work around Bundler issues: (From: http://stackoverflow.com/questions/2170697/bundler-isnt-loading-gems)

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

* Create a controller that will respond to http requests and create our background job
* `RAILS_ROOT/script/generate controller trogdor`
* Set `RAILS_ROOT/config/routes.rb` to: 

    ActionController::Routing::Routes.draw do |map|
      map.trogdor 'trogdor/burninate/:target', :controller => 'trogdor', :action => 'burninate'
    end

* Uncomment this line from `environment.rb`

`config.frameworks -= [ :active_record, :active_resource, :action_mailer ]`

* `git rm RAILS_ROOT/config/database.yml`

* Update TrogdorController: 

    def burninate
      Resque.enqueue(Trogdor, params[:target])
      render :text => "Telling Trogdor to burninate #{params[:target]}."
    end

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
 
* `heroku create`
* `heroku addons:add redistogo`
* `git push heroku master`
* Open http://young-sunrise-78.heroku.com/resque (any username, password 'secret')
* Open http://young-sunrise-78.heroku.com/trogdor/burninate/countryside
* `heroku rake resque:work --app young-sunrise-78 --trace`

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


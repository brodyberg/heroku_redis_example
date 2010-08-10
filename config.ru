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

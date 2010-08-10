# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_heroku_redis_example_session',
  :secret      => '556e0b0291061421db163a21e84643bdc58f36baa4a39a591bf3350c700d97a3224ccda3284395d1e216f04ad670c3c916ac578ba8f7c111c501e112bef669f7'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

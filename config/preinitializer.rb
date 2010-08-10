# From: http://stackoverflow.com/questions/2170697/bundler-isnt-loading-gems

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
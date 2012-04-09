# Disable Rake legacy compatibility monkey-patching
module Rake; REDUCE_COMPAT = true; end

require 'rubygems'

# Set up gems listed in the Gemfile.
gemfile = File.expand_path('../../Gemfile', __FILE__)
begin
  ENV['BUNDLE_GEMFILE'] = gemfile
  require 'bundler'
  Bundler.setup
rescue Bundler::GemNotFound => e
  STDERR.puts e.message
  STDERR.puts "Try running `bundle install`."
  exit!
end if File.exist?(gemfile)

ENV["RAILS_ENV"] = ENV["RACK_ENV"] = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "production"

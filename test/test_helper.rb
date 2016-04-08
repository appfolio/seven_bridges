require 'rubygems'
require 'bundler'

begin
  Bundler.require(:default, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'active_support/all'
require 'minitest/autorun'

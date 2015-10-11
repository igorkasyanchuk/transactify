$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'active_record'
require 'sequel'
require 'pry'
require 'simplecov'

SimpleCov.start

require 'transactify'

require_relative 'app.rb'

def clean_db
  User.delete_all
  Comment.delete_all
  Db::Account.delete_all
end

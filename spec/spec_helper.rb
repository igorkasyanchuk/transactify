$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'active_record'
require 'sequel'
require 'pry'
require 'simplecov'

SimpleCov.start

require 'transactify'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :users, :force => true do |t|
    t.string :name
  end

  create_table :comments, :force => true do |t|
    t.integer :user_id
    t.string :comment
  end
end

class User < ActiveRecord::Base
  include Transactify

  has_many :comments

  def self.create_user_and_comments
    user = User.create(:name => 'John Smith')
    user.comments.create(:comment => 'This is Comment #1')
    user.comments.create(:comment => 'This is Comment #2')
    user.comments.create(:comment => 'This is Comment #3')
    user
  end

  [nil, '!', '?'].each do |sufix|
    define_singleton_method "create_user_correct_and_comments_error#{sufix}" do
      user = User.create(:name => 'John Smith')
      user.comments.undefined_method(:comment => 'This is Comment #1')
    end

    define_singleton_method "create_user_correct_and_comments_error_but_for_gem#{sufix}" do
      user = User.create(:name => 'John Smith')
      user.comments.undefined_method(:comment => 'This is Comment #1')
    end

    define_method("process#{sufix}") do
      User.create(:name => 'Friend')
      comments.undefined_method(:comment => 'This is Nested Comment')
    end

    define_method("process_for_gem#{sufix}") do
      User.create(:name => 'Friend')
      comments.undefined_method(:comment => 'This is Nested Comment')
    end
  end

  ctransactify :create_user_correct_and_comments_error_but_for_gem,
               :create_user_correct_and_comments_error_but_for_gem!,
               :create_user_correct_and_comments_error_but_for_gem?

  transactify :process_for_gem,
              :process_for_gem!,
              :process_for_gem?
end

class Comment < ActiveRecord::Base
  include Transactify

  belongs_to :user
end

def clean_db
  User.delete_all
  Comment.delete_all
end

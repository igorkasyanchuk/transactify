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

  def self.sample_class_method
    User.create(:name => 'Bob Marley')
  end

  def sample_intance_method
    User.create(:name => 'Bob Marley')
  end

  def self.sample_class_method_nested
    sample_class_method
    User.create(:name => 'Bob Marley')
    1/0
  end

  def sample_intance_method_nested
    sample_intance_method
    User.create(:name => 'Bob Marley')
    1/0
  end

  [nil, '!', '?'].each do |sufix|
    define_singleton_method "create_user_correct_and_comments_error#{sufix}" do
      user = User.create(:name => 'John Smith')
      user.comments.undefined_method(:comment => 'This is Comment #1')
    end

    define_singleton_method "create_user_correct_and_comments_error_in_method#{sufix}" do
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
               :create_user_correct_and_comments_error_but_for_gem?,
               :sample_class_method_nested

  transactify :process_for_gem,
              :process_for_gem!,
              :process_for_gem?,
              :sample_intance_method_nested

end

class Comment < ActiveRecord::Base
  include Transactify

  belongs_to :user
end
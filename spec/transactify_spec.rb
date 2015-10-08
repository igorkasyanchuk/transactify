require 'spec_helper'

describe Transactify do

  before :each do
    clean_db
  end

  it 'has a version number' do
    expect(Transactify::VERSION).not_to be nil
  end

  it 'specs configured' do
    expect(User.count).to eq(0)
    expect(Comment.count).to eq(0)
    User.create_user_and_comments
    expect(User.count).to eq(1)
    expect(Comment.count).to eq(3)
  end

  [nil, '!', '?'].each do |sufix|
    it "can verify bad conditions (class method) #{sufix}" do
      expect(User.count).to eq(0)
      expect(Comment.count).to eq(0)
      expect{User.send("create_user_correct_and_comments_error#{sufix}")}.to raise_error(NoMethodError)
      expect(User.count).to eq(1)
      expect(Comment.count).to eq(0)
    end

    it "can verify bad conditions but not create records (class method) #{sufix}" do
      expect(User.count).to eq(0)
      expect(Comment.count).to eq(0)
      expect{User.send("create_user_correct_and_comments_error_but_for_gem#{sufix}")}.to raise_error(NoMethodError)
      expect(User.count).to eq(0)
      expect(Comment.count).to eq(0)
    end

    it "can verify bad conditions (instance method) #{sufix}" do
      expect(User.count).to eq(0)
      expect(Comment.count).to eq(0)
      expect{User.create_user_and_comments.send("process#{sufix}")}.to raise_error(NoMethodError)
      expect(User.count).to eq(2)
      expect(Comment.count).to eq(3)
    end

    it "can verify bad conditions but not create records (instance method) #{sufix}" do
      expect(User.count).to eq(0)
      expect(Comment.count).to eq(0)
      expect{User.create_user_and_comments.send("process_for_gem#{sufix}")}.to raise_error(NoMethodError)
      expect(User.count).to eq(1)
      expect(Comment.count).to eq(3)
    end

  end

end

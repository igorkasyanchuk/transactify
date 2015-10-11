require 'spec_helper'

describe Transactify do

  before :each do
    clean_db
  end

  it 'has a version number' do
    expect(Transactify::VERSION).not_to be_nil
  end

  it 'specs configured' do
    verify_zeros
    User.create_user_and_comments
    expect(User.count).to eq(1)
    expect(Comment.count).to eq(3)
  end

  [nil, '!', '?'].each do |sufix|
    it "can verify bad conditions (class method) #{sufix}" do
      verify_zeros
      expect{User.send("create_user_correct_and_comments_error#{sufix}")}.to raise_error(NoMethodError)
      expect(User.count).to eq(1)
      expect(Comment.count).to eq(0)
    end

    it "can verify bad conditions but not create records (class method) #{sufix}" do
      verify_zeros
      expect{User.send("create_user_correct_and_comments_error_but_for_gem#{sufix}")}.to raise_error(NoMethodError)
      verify_zeros
    end

    it "can verify bad conditions (instance method) #{sufix}" do
      verify_zeros
      expect{User.create_user_and_comments.send("process#{sufix}")}.to raise_error(NoMethodError)
      expect(User.count).to eq(2)
      expect(Comment.count).to eq(3)
    end

    it "can verify bad conditions but not create records (instance method) #{sufix}" do
      verify_zeros
      expect{User.create_user_and_comments.send("process_for_gem#{sufix}")}.to raise_error(NoMethodError)
      expect(User.count).to eq(1)
      expect(Comment.count).to eq(3)
    end
  end

  it 'works with nested class method' do
    verify_zeros
    expect{User.sample_class_method_nested}.to raise_error(ZeroDivisionError)
    verify_zeros
  end

  it 'works with nested instance methods' do
    verify_zeros
    expect{User.new.sample_intance_method_nested}.to raise_error(ZeroDivisionError)
    verify_zeros
  end

  it 'works for instance modules(OK)' do
    verify_zeros
    account = Db::Account.new
    account.sample_intance_method
    expect(Db::Account.count).to eq(1)
  end

  it 'works for instance modules(BAD)' do
    verify_zeros
    account = Db::Account.new
    expect{account.sample_intance_method_nested}.to raise_error(ZeroDivisionError)
    expect(Db::Account.count).to eq(0)
  end

  it 'works for class modules(OK)' do
    verify_zeros
    Db::Account.sample_class_method
    expect(Db::Account.count).to eq(1)
  end

  it 'works for class modules(BAD)' do
    verify_zeros
    expect{Db::Account.sample_class_method_nested}.to raise_error(ZeroDivisionError)
    expect(Db::Account.count).to eq(0)
  end

  private

  def verify_zeros
    expect(User.count).to eq(0)
    expect(Comment.count).to eq(0)
    expect(Db::Account.count).to eq(0)
  end

end

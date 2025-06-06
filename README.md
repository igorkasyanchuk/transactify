# Transactify

[![Code Climate](https://codeclimate.com/github/igorkasyanchuk/transactify/badges/gpa.svg)](https://codeclimate.com/github/igorkasyanchuk/transactify)
[![Build Status](https://travis-ci.org/igorkasyanchuk/transactify.svg?branch=master)](https://travis-ci.org/igorkasyanchuk/transactify)
[![Gem Version](https://badge.fury.io/rb/transactify.svg)](https://badge.fury.io/rb/transactify)
[![RailsJazz](https://github.com/igorkasyanchuk/rails_time_travel/blob/main/docs/my_other.svg?raw=true)](https://www.railsjazz.com)
[![https://www.patreon.com/igorkasyanchuk](https://github.com/igorkasyanchuk/rails_time_travel/blob/main/docs/patron.svg?raw=true)](https://www.patreon.com/igorkasyanchuk)

[!["Buy Me A Coffee"](https://github.com/igorkasyanchuk/get-smart/blob/main/docs/snapshot-bmc-button-small.png?raw=true)](https://buymeacoffee.com/igorkasyanchuk)

[![Sample](https://raw.githubusercontent.com/igorkasyanchuk/transactify/master/transactify.png)](https://github.com/igorkasyanchuk/transactify)

Transactify gem can run your methods in database transaction. Previously you had to wrap you code in `ActiveRecord::Base.transaction do .. end` but now it can be done in much more simpler way.

Sample or usage: https://github.com/igorkasyanchuk/transactify/blob/master/spec/app.rb#L20

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'transactify'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install transactify


**Note: works only for Ruby 2+**

## Usage

Let's say you have model `Question` with method `reject!`.


```ruby
  def reject!(comment_text = nil)
    assignment_log = question_logs.where(action_type: ASSIGNED_STATUS).last
    owner.rejected_questions << self
    owner.update_attribute(average_assigned_questions_count: question_count/total_questions)
    log = question_logs.create(assignee: assignment_log.assigner, assigner: assignment_log.assignee, action_type: REJECTED_STATUS)
    QuestionMailer.update(self, log).deliver_later
  end
```

Now imagine that `total_questions` returns 0. And you will have an exception (dividing by zero), but one operation (`owner.rejected_questions << self`) will be performed to the DB. This is wrong, and normally you can avoid this by adding Transactions:


```ruby
  def reject!(comment_text = nil)
    ActiveRecord::Base.transaction do
      assignment_log = question_logs.where(action_type: ASSIGNED_STATUS).last
      owner.rejected_questions << self
      owner.update_attribute(average_assigned_questions_count: question_count/total_questions)
      log = question_logs.create(assignee: assignment_log.assigner, assigner: assignment_log.assignee, action_type: REJECTED_STATUS)
      QuestionMailer.update(self, log).deliver_later
    end
  end
```

But what if you have many-many such methods? This is where **transactify** gem can help. You can speficy which methods you want to run in transaction. So final code will looks like:

```ruby
  def reject!(comment_text = nil)
    assignment_log = question_logs.where(action_type: ASSIGNED_STATUS).last
    owner.rejected_questions << self
    owner.update_attribute(average_assigned_questions_count: question_count/total_questions)
    log = question_logs.create(assignee: assignment_log.assigner, assigner: assignment_log.assignee, action_type: REJECTED_STATUS)
    QuestionMailer.update(self, log).deliver_later
  end

  transactify :reject!  # With this line you can specify which methods you want to make safe for DB
```

Main benefit of this gem is that you don't need to edit all your methods and add transaction blocks. So without any existing code modification you can add support for transaction for whole methods.


Gem allows to **transactify** instance and class methods.

### Functionality

`include Transactify` - put in your classes, models to add support for transactions

`transactify :method_name` - transactify your insatance method.

`ctransactify :method_name` - transactify your class method.

## Samples of Usage

```ruby
class Question < ActiveRecord::Base
  include Transactify

  transactify :reject!, :save_question
  ctransactify :generate_report

  def reject!(comment_text = nil)
    assignment_log = question_logs.where(action_type: ASSIGNED_STATUS).last
    owner.rejected_questions << self
    owner.update_attribute(average_assigned_questions_count: question_count/total_questions)
    log = question_logs.create(assignee: assignment_log.assigner, assigner: assignment_log.assignee, action_type: REJECTED_STATUS)
    QuestionMailer.update(self, log).deliver_later
  end

  def save_question(user, answer, comment_content = nil)
    update_attributes(owner_id: user.id)
    question_logs.create(assignee: user, assigner: user, action_type: SAVE_STATUS, answers: answer)
    save_comment(user, comment_content)
  end

  def self.generate_report
    report = Report.create_new_report
    report.create_schema
    report.populate_users
    report.populate_questions
    report
  end

end
```

## Plans

* Add support for Sequel gem
* Add more specs

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/transactify/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[<img src="https://github.com/igorkasyanchuk/rails_time_travel/blob/main/docs/more_gems.png?raw=true"
/>](https://www.railsjazz.com/?utm_source=github&utm_medium=bottom&utm_campaign=transactify)

[!["Buy Me A Coffee"](https://github.com/igorkasyanchuk/get-smart/blob/main/docs/snapshot-bmc-button.png?raw=true)](https://buymeacoffee.com/igorkasyanchuk)

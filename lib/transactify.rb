require "transactify/version"

module Transactify

  def self.included(base)
    base.send(:extend, ForClassMethods)
    base.send(:extend, ForInstanceMethods)
  end

  # Class Methods
  module ForClassMethods
    def ctransactify(*args)
      make_ctransactify_method(:safe, *args)
    end

    def make_ctransactify_method(sufix, *args)
      args.each do |method_name|
        new_method_name = Transactify::fix_method_name("#{method_name}_with_#{sufix}")
        old_method_name = Transactify::fix_method_name("#{method_name}_without_#{sufix}")
        define_singleton_method new_method_name do |*args|
          ActiveRecord::Base.transaction do
            send(old_method_name, *args)
          end
        end
        (class << self; self; end).instance_eval do
          alias_method_chain(method_name, sufix)
        end
      end
    end
  end

  # Instance Methods
  module ForInstanceMethods

    def transactify(*args)
      make_transactify_method(:safe, *args)
    end

    def make_transactify_method(sufix, *args)
      args.each do |method_name|
        new_method_name = Transactify::fix_method_name("#{method_name}_with_#{sufix}")
        old_method_name = Transactify::fix_method_name("#{method_name}_without_#{sufix}")
        define_method new_method_name do |*args|
          ActiveRecord::Base.transaction do
            send(old_method_name, *args)
          end
        end
        alias_method_chain(method_name, sufix)
      end
    end
  end

  private

  # Util Methods

  def self.fix_method_name(method_name)
    name = method_name.to_s
    if name.include?('!')
      "#{name.delete('!')}!"
    elsif name.include?('?')
      "#{name.delete('?')}?"
    else
      name
    end
  end

end

# Include Functionality Automatically to Gems

if Object.const_defined?('ActiveRecord')
  ActiveRecord::Base.send(:include, Transactify)
end

# TODO Future
# if Object.const_defined?('Sequel')
#   Sequel.send(:include, Transactify)
# end

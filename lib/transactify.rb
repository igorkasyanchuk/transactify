require 'securerandom'
require 'transactify/version'

module Transactify

  def self.included(base_klass)
    base_klass.extend(ClassMethods)
    unless Object.const_defined?("#{base_klass.name.demodulize}Interceptor")
      interceptor = const_set("#{base_klass.name.demodulize}Interceptor", Module.new)
      base_klass.send(:prepend, interceptor)
    end
  end

  module ClassMethods

    def ctransactify(*cmethods)
      interceptor = const_get("#{name.demodulize}Interceptor")
      klass = const_get(name)
      helper = const_set("Transactify#{SecureRandom.hex}Helper", Module.new)
      cmethods.each do |method_name|
        interceptor.module_eval do
          helper.send :define_singleton_method, :prepended do |base|
            define_method(method_name) do |*args, &block|
              ActiveRecord::Base.transaction do
                super(*args, &block)
              end
            end
          end
          (class << klass; self; end).module_eval do
            prepend(helper)
          end
        end
      end
    end

    def transactify(*cmethods)
      interceptor = const_get("#{name.demodulize}Interceptor")
      cmethods.each do |method_name|
        interceptor.module_eval do
          define_method(method_name) do |*args, &block|
            ActiveRecord::Base.transaction do
              super(*args, &block)
            end
          end
        end
      end
    end

  end
end
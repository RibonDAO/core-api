require 'simple_command/errors'

module SimpleCommand
  attr_reader :result

  module ClassMethods
    def call(*args, **kwargs)
      new(*args, **kwargs).call
    end
  end

  def self.prepended(base)
    base.extend ClassMethods
  end

  def call
    raise NotImplementedError unless defined?(super)

    @called = true
    @result = super

    self
  end

  def success?
    called? && !failure?
  end
  alias successful? success?

  def failure?
    called? && errors.any?
  end

  def errors
    return super if defined?(super)

    @errors ||= Errors.new
  end

  private

  def called?
    @called ||= false
  end
end

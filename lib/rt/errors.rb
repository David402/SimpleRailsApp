module RT
module Errors

  class BaseError < StandardError
    attr_accessor :info

    # Allow error attributes to be set in the initializer
    def initialize(arg=nil)
      if Hash === arg
        hash = arg.clone
        super hash.delete(:message)
        hash.each do |k, v|
          send "#{k}=", v
        end
      else
        super arg
      end
    end
  end

  # Only put here *general* error classes. Domain specific subclasses can
  # be in their respective classes.
  #
  class ObjectNotFoundError         < BaseError; end
  class ForbiddenError              < BaseError; end
  class UnauthorizedError           < BaseError; end
  class InvalidRequestParameters    < BaseError; end
  class UnexpectedVendorData        < BaseError; end
  class ObjectInvalidOperation      < BaseError; end

end
end
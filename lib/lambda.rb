module BusScheme
  class Lambda
    @@current_environment = nil
    
    # create new lambda object
    def initialize(arg_names, body)
      @arg_names, @body, @environment = [arg_names, body, LOCAL_SCOPES] # do we really want them all?
    end
    
    # execute lambda with given arg_values
    def call(*arg_values)
      raise BusScheme::ArgumentError if @arg_names.length != arg_values.length
      with_local_scope(@arg_names.zip(arg_values).to_hash) { BusScheme[:begin].call(*@body) }
    end

    def self.environment
      @@current_environment or []
    end
    
    # execute a block with a given local scope
    def with_local_scope(scope, &block)
      BusScheme::LOCAL_SCOPES << scope
      @@current_environment = @environment
      block.call.affect do
        BusScheme::LOCAL_SCOPES.delete(scope)
        @@current_environment = nil
      end
    end
  end
end

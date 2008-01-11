module BusScheme
  class Lambda
    @@current = nil
    
    # create new lambda object
    def initialize(arg_names, body)
      @arg_names, @body, @environment = [arg_names, body, LOCAL_SCOPES]
    end

    attr_reader :environment
    
    # execute lambda with given arg_values
    def call(*arg_values)
      raise BusScheme::ArgumentError if @arg_names.length != arg_values.length
      with_local_scope(@arg_names.zip(arg_values).to_hash) { BusScheme[:begin].call(*@body) }
    end

    def self.environment
      @@current ? @@current.environment : []
    end
    
    # execute a block with a given local scope
    def with_local_scope(scope, &block)
      BusScheme::LOCAL_SCOPES << scope
      @@current = self
      block.call.affect do
        BusScheme::LOCAL_SCOPES.delete(scope)
        @@current = nil
      end
    end
  end
end

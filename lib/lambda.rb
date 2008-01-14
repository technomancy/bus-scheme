module BusScheme
  class Lambda
    @@environments = []
    
    # create new lambda object
    def initialize(arg_names, body)
      @arg_names, @body, @environment = [arg_names, body, (Lambda.environment or {})]
    end
    
    # execute lambda with given arg_values
    def call(*arg_values)
      raise BusScheme::ArgumentError if @arg_names.length != arg_values.length
      with_local_scope(@arg_names.zip(arg_values).to_hash) { BusScheme[:begin].call(*@body) }
    end

    def self.environment
      @@environments.last
    end
    
    # execute a block with a given local scope
    def with_local_scope(scope, &block)
      # BUG: here a change in @@environments.last will NOT affect
      # the original environment.
      @@environments << @environment.merge(scope)
      block.call.affect { @@environments.pop }
    end
  end
end

module BusScheme
  class Lambda
    def initialize(arg_names, body)
      @arg_names, @body, @environment = [arg_names, body, SCOPES]
    end

    def call(*arg_values)
      raise BusScheme::ArgumentError if @arg_names.length != arg_values.length
      with_local_scope(@arg_names.zip(arg_values).to_hash) { return BusScheme[:begin].call(@body) }
    end

    def with_local_scope(scope, &block)
      SCOPES << scope
      block.call
      SCOPES.delete(scope)
    end
  end
end

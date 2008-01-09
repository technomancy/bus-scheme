module BusScheme
  class Lambda
    def initialize(arg_names, body)
      @arg_names, @body, @environment = [arg_names, body, SCOPES.last]
    end

    def call(*arg_values)
      raise BusScheme::ArgumentError if @arg_names.length != arg_values.length

      # TODO: changes to variables in the environment must affect their original scope!
      SCOPES << @environment.merge(@arg_names.zip(arg_values).to_hash)
      BusScheme[:begin].call(@body).affect { SCOPES.pop }
    end
  end
end

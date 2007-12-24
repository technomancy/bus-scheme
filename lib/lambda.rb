module BusScheme
  class Lambda
    def initialize(args, body)
      @scope = nil # scope
      @args = args
      @body = body
    end

    def call(*args)
      raise BusScheme::ArgumentError if args.length != @args.length

      SCOPES << {} # new scope
      args.zip(@args).each do |value, symbol|
        BusScheme[symbol] = value
      end

      # using affect as a non-return-value-affecting callback
      BusScheme[:begin].call(@body).affect { SCOPES.pop }
    end

    def lambda?; true end
  end
end

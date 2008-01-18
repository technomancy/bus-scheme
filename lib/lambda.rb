module BusScheme
  class Scope < Hash
    def initialize(table, parent)
      @parent = parent
      table.each { |k, v| self[k] = v }
    end

    alias_method :old_has_key?, :has_key?
    def has_key?(symbol)
      old_has_key?(symbol) or @parent && @parent.has_key?(symbol)
    end

    alias_method :lookup, :[]
    def [](symbol)
      lookup(symbol) or @parent && @parent[symbol]
    end

    alias_method :old_set, :[]=
    def []=(symbol, value)
      if !old_has_key?(symbol) and @parent and @parent.has_key?(symbol)
        @parent[symbol] = value
      else
        old_set symbol, value
      end
    end
  end

  class Lambda
    @@stack = []

    attr_reader :scope
    
    # create new lambda object
    def initialize(arg_names, body)
      @arg_names, @body, @enclosing_scope = [arg_names, body, Lambda.scope]
    end
    
    # execute lambda with given arg_values
    def call(*arg_values)
      raise BusScheme::ArgumentError if @arg_names.length != arg_values.length
      @scope = Scope.new(@arg_names.zip(arg_values).to_hash, @enclosing_scope)
      @@stack << self
      BusScheme[:begin].call(*@body).affect { @@stack.pop }
    end

    def self.scope
      @@stack.empty? ? nil : @@stack.last.scope
    end
  end
end

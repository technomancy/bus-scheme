module BusScheme
  class RecursiveHash < Hash
    # takes a hash and a parent
    def initialize(hash, parent)
      @parent = parent
      hash.each { |k, v| self[k] = v }
    end

    alias_method :immediate_has_key?, :has_key?
    alias_method :immediate_set, :[]=
    alias_method :immediate_lookup, :[]

    def has_key?(symbol)
      immediate_has_key?(symbol) or @parent && @parent.has_key?(symbol)
    end

    def [](symbol)
      immediate_lookup(symbol) or @parent && @parent[symbol]
    end

    def []=(symbol, value)
      if !immediate_has_key?(symbol) and @parent and @parent.has_key?(symbol)
        @parent[symbol] = value
      else
        immediate_set symbol, value
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
      @scope = RecursiveHash.new(@arg_names.zip(arg_values).to_hash, @enclosing_scope)
      @@stack << self
      BusScheme.eval_form(@body.unshift(:begin)).affect { @@stack.pop }
    end

    def self.scope
      @@stack.empty? ? SYMBOL_TABLE : @@stack.last.scope
    end
  end
end

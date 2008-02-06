module BusScheme
  # RecursiveHash is needed to store Lambda environments
  class RecursiveHash < Hash
    # takes a hash and a parent
    def initialize(hash, parent)
      @parent = parent
      hash.each { |k, v| self[k] = v }
    end

    alias_method :immediate_has_key?, :has_key?
    alias_method :immediate_set, :[]=
    alias_method :immediate_lookup, :[]

    # Just your regular has stuff, only it takes the parent into account
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

  # Lambdas are closures.
  class Lambda
    @@stack = []

    attr_reader :scope
    attr_accessor :defined_in
    
    # create new lambda object
    def initialize(formals, body)
      @formals, @body, @enclosing_scope = [formals, body, Lambda.scope]
    end
    
    # execute lambda with given arg_values
    def call(*args)
      locals = if @formals.is_a? Symbol # rest args
                 { @formals => args.to_list }
               else # regular arg list
                 raise BusScheme::ArgumentError if @formals.length != args.length
                 @formals.zip(args).to_hash
               end

      @scope = RecursiveHash.new(locals, @enclosing_scope)
      @@stack << self
      BusScheme.eval_form(@body.unshift(:begin)).affect { @@stack.pop }
    end

    # What's the current scope?
    def self.scope
      @@stack.empty? ? SYMBOL_TABLE : @@stack.last.scope
    end
  end
end

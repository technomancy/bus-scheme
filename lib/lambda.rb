module BusScheme
  # Lambdas are closures.
  class Lambda
    include Traceable
    @@stack = []

    attr_reader :scope
    
    # create new Lambda object
    def initialize(formals, body)
      @formals, @body, @enclosing_scope = [formals, body, Lambda.scope]
    end
    
    # execute Lambda with given arg_values
    def call(*args)
      locals = if @formals.is_a? Sym # rest args
                 { @formals => args.to_list }
               else # regular arg list
                 raise BusScheme::ArgumentError if @formals.length != args.length
                 @formals.zip(args).to_hash
               end

      @scope = RecursiveHash.new(locals, @enclosing_scope)
      @@stack << self
      BusScheme.eval(@body.unshift(:begin.sym)).affect { @@stack.pop }
    end

    # What's the current scope?
    def self.scope
      @@stack.empty? ? SYMBOL_TABLE : @@stack.last.scope
    end

    # is the symbol in scope?
    def self.in_scope?(symbol)
      self.scope.has_key?(symbol) or SYMBOL_TABLE.has_key?(symbol)
    end
    
    # shorthand for lookup in the currently relevant scope
    def self.[](symbol)
      return self.scope[symbol]
    end

    # shorthand for assignment in the currently relevant scope
    def self.[]=(symbol, val)
      val.defined_as(symbol, val.file, val.line) if val.respond_to?(:defined_as)
      self.scope[symbol] = val
    end

    # where were we called from?
    def self.trace
      @@stack.reverse.map { |fn| [fn.symbol, fn.file, fn.line] }
    end
  end
end

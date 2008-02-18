module BusScheme
  # Lambdas are closures.
  class Lambda < Cons
    include Traceable
    @@stack = []

    attr_reader :scope
    
    # create new Lambda object
    def initialize(formals, body)
      @formals, @body, @enclosing_scope = [formals, body, Lambda.scope]
      @car = :lambda.sym
      @cdr = Cons.new(@formals, Cons.new(@body))
    end
    
    # execute Lambda with given arg_values
    def call(*args)
      locals = if @formals.is_a? Sym # rest args
                 { @formals => args.to_list }
               else # regular arg list
                 raise BusScheme::ArgumentError, "Wrong number of args passed to #{@symbol}.
  expected #{@formals.size}, got #{args.size}
  in #{@file}:#{@line}" if @formals.length != args.length
                 @formals.zip(args).to_hash
               end

      @scope = RecursiveHash.new(locals, @enclosing_scope)
      # we dupe the lambda so that @scope is unique for each call of the function
      @@stack << self.dup
      
      begin
        return BusScheme.eval(@body.unshift(:begin.sym))
      ensure
        @@stack.pop
      end
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
      val.defined_as(symbol, symbol.file, symbol.line) if val.respond_to?(:defined_as)
      self.scope[symbol] = val
    end

    # where were we called from?
    def self.stacktrace
      @@stack.reverse.map { |fn| [fn.file, fn.line, fn.symbol] }
    end
  end
end

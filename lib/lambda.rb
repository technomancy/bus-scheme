module BusScheme
  # Lambdas are closures.
  class Lambda < Cons
    @@stack = []

    attr_reader :scope, :called_as
    attr_accessor :special_form
    
    # create new Lambda object
    def initialize(formals, body)
      @formals, @body, @enclosing_scope = [formals, body, Lambda.scope]
      @car = :lambda.sym
      @cdr = Cons.new(@formals.sexp, Cons.new(@body.sexp))
    end

    # call the function with given args
    def call_as(called_as, *args)
      @called_as = called_as
      call(*args)
    end

    # execute Lambda with given arg_values
    def call(*args)
      locals = if @formals.is_a? Sym # rest args
                 { @formals => args.to_list }
               else # regular arg list
                 # TODO: include stacktrace here
                 raise BusScheme::ArgumentError, "Wrong number of args:
  expected #{@formals.size}, got #{args.size}" if @formals.length != args.length
                 @formals.zip(args).to_hash
               end

      @scope = RecursiveHash.new(locals, @enclosing_scope)
      # we dupe the lambda so that @scope is unique for each call of the function
      @@stack << self.dup
      @called_as = nil # the dup we pushed to the stack has @called_as set
      
      begin
        return @body.map{ |form| BusScheme.eval(form) }.last
      ensure
        @@stack.pop
      end
    end

    def trace
      [@called_as.file, @called_as.line, @called_as]
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
    def self.[]=(sym, val)
      # val.defined_as(sym) if val.respond_to?(:defined_as)
      self.scope[sym] = val
    end

    # where were we called from?
    def self.stacktrace
      @@stack.reverse.map { |fn| fn.trace }
    end
  end
end

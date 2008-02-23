module BusScheme
  # Lambdas are closures.
  class Lambda < Cons
    attr_reader :scope
    attr_accessor :special_form
    
    # create new Lambda object
    def initialize(formals, body)
      @formals, @body, @enclosing_scope = [formals, body, BusScheme.current_scope]
      @car = :lambda.sym
      @cdr = Cons.new(@formals.sexp, @body.sexp)
    end

    # execute body with args bound to formals
    def call(*args)
      locals = if @formals.is_a? Sym # rest args
                 { @formals => args.to_list }
               else # regular arg list
                 raise BusScheme::ArgumentError, "Wrong number of args:
  expected #{@formals.size}, got #{args.size}
  #{BusScheme.stacktrace.join("\n")}" if @formals.length != args.length
                 @formals.zip(args).to_hash
               end

      @scope = RecursiveHash.new(locals, @enclosing_scope)
      BusScheme.stack.push self.dup
      
      val = @body.map{ |form| BusScheme.eval(form) }.last
      BusScheme.stack.pop
      return val
    end
  end

  class Primitive < Lambda
    def initialize body
      @body = body
      @enclosing_scope = BusScheme.current_scope
    end

    def call(*args)
      # TODO: define needs to be smart enough not to put things in its own scope!
      @scope = RecursiveHash.new({}, @enclosing_scope)
      BusScheme.stack.push self
      
      val = @body.call(*args)
      BusScheme.stack.pop
      return val
    end
  end
end

module BusScheme
  # Lambdas are closures.
  class Lambda < Cons
    attr_reader :scope
    attr_accessor :special_form
    
    # create new Lambda object
    def initialize(formals, body)
      @special_form = false
      @formals, @body, @enclosing_scope = [formals, body, BusScheme.current_scope]
      @car = :lambda.sym
      @cdr = Cons.new(@formals.sexp, @body.sexp)
      @called_as = nil # avoid warnings
    end

    # execute body with args bound to formals
    def call(args)
      locals = if @formals.is_a? Sym # rest args
                 { @formals => args }
               else # regular arg list
                 raise BusScheme::ArgumentError, "Wrong number of args: #{@called_as.inspect}
  expected #{@formals.size}, got #{args.size}
  #{BusScheme.stacktrace.join("\n")}" if @formals.length != args.length
                 # TODO: don't convert to an array first
                 @formals.to_a.zip(args.to_a).to_hash
               end

      @frame = StackFrame.new(locals, @enclosing_scope, @called_as)
      
      BusScheme.stack.push @frame
      begin
        val = @body.map{ |form| BusScheme.eval(form) }.last
      rescue => e # TODO: ensure?
        raise e
        BusScheme.stack.pop
      end
      BusScheme.stack.pop
      return val
    end

    def call_as(called_as, *args)
      @called_as = called_as
      call(*args)
    end
  end

  class Primitive < Lambda
    def initialize(body)
      @car = @cdr = nil # avoid "Not initialized" warnings
      @body = body
    end

    def call(args)
      BusScheme.stack.push StackFrame.new({}, BusScheme.current_scope, @called_as)
      begin
        val = @body.call(*args)
      rescue => e
        BusScheme.stack.pop
        raise e
      end
      BusScheme.stack.pop
      return val
    end
  end
  
  def self.primitive(&block)
    Primitive.new(block)
  end
end


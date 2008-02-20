module BusScheme
  class << self
    @trace = false
    
    # Parse a string, then eval the result
    def eval_string(string)
      eval(parse("(begin #{string})"))
    end

    # Eval a form passed in as an array
    def eval(form)
      # puts "evaling #{form.inspect}"
      if (form.is_a?(Cons) or form.is_a?(Array)) and form.first
        puts form.inspect if @trace
        apply(form.first, form.rest)
      elsif form.is_a? Sym or form.is_a? Symbol
        form = form.sym if form.is_a? Symbol
        raise EvalError.new("Undefined symbol: #{form.inspect}") unless Lambda.in_scope?(form)
        Lambda[form]
      else # well it must be a literal then
        form
      end
    end

    # Call a function with given args
    def apply(function_sym, args)
      args = args.to_a
      args.map!{ |arg| eval(arg) } unless function_sym.special_form?
      function = eval(function_sym)

      # named functions (non-literal lambdas) need this info for tracing
      if function.respond_to?(:call_as) and function_sym.is_a?(Sym)
        function.call_as(function_sym, *args)
      else
        function.call(*args)
      end
    end
  end
end

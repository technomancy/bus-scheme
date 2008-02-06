module BusScheme
  class << self
    # Parse a string, then eval the result
    def eval_string(string)
      eval_form(parse(string))
    end

    # Eval a form passed in as an array
    def eval_form(form)
      # puts "evaling #{form.inspect}"
      if form.respond_to?(:first) and form.first
        apply(form.first, form.rest)
      elsif form.is_a? Symbol
        raise EvalError.new("Undefined symbol: #{form}") unless Lambda.scope.has_key?(form)
        Lambda.scope[form]
      else # well it must be a literal then
        form
      end
    end

    # Call a function with given args
    def apply(function, args)
      # puts "applying #{function.inspect} with #{args.inspect}"
      args = args.to_a
      args.map!{ |arg| eval_form(arg) } unless special_form?(function)
      eval_form(function).call(*args)
    end
  end
end

module BusScheme
  class << self
    # Parse a string, then eval the result
    def eval_string(string)
      eval(parse("(begin #{string})"))
    end

    # Eval a form passed in as an array
    def eval(form)
      # puts "evaling #{form.inspect}"
      if (form.is_a?(Cons) or form.is_a?(Array)) and form.first
        apply(form.first, form.rest)
        # TODO: should we still allow symbols?
      elsif form.is_a? Sym or form.is_a? Symbol
        form = form.sym if form.is_a? Symbol
        raise EvalError.new("Undefined symbol: #{form.inspect}") unless Lambda.in_scope?(form)
        Lambda[form]
      else # well it must be a literal then
        form
      end
    end

    # Call a function with given args
    def apply(function, args)
      # puts "applying #{function.inspect} with #{args.inspect}"
      args = args.to_a
      args.map!{ |arg| eval(arg) } unless function.special_form?
      eval(function).call(*args)
    end
  end
end

module BusScheme
  class << self
    # Parse a string, then eval the result
    def eval_string(string)
      eval_form(parse(string))
    end

    # Eval a form passed in as an array
    def eval_form(form)
      if form == []
        nil
      elsif form.is_a? Array
        apply(form.first, *form.rest)
      elsif form.is_a? Symbol
        raise "Undefined symbol: #{form}" unless in_scope?(form)
        BusScheme[form]
      else
        form
      end
    end

    # Call a function with given args
    def apply(function, *args)
      args.map!{ |arg| eval_form(arg) } unless special_form?(function)

      # refactor me
      if function.is_a?(Array) and function.lambda?
        function.call(*args)
      else
        raise "Undefined symbol: #{function}" unless in_scope?(function)
        BusScheme[function].call(*args)
      end
    end

    # All the super lambda magic happens (or fails to happen) here
    def eval_lambda(lambda, args)
      raise BusScheme::EvalError unless lambda.shift == :lambda

      arg_list = lambda.shift
      raise BusScheme::ArgumentError if !arg_list.is_a?(Array) or arg_list.length != args.length

      SCOPES << {} # new scope
      until arg_list.empty?
        BusScheme[arg_list.shift] = args.shift
      end

      # using affect as a non-return-value-affecting callback
      BusScheme[:begin].call(*lambda).affect { SCOPES.pop }
    end
  end
end

module BusScheme
  class << self
    def eval_string(string)
      eval_form(parse(string))
    end

    def eval_form(form)
      if form == []
        nil
      elsif form.is_a? Array
        apply(form.first, *form.rest)
      elsif form.is_a? Symbol
        raise "Undefined symbol: #{form}" unless SYMBOL_TABLE.has_key?(form)
        SYMBOL_TABLE[form]
      else
        form
      end
    end

    def apply(function, *args)
      args.map!{ |arg| eval_form(arg) } unless SPECIAL_FORMS.has_key?(function)

      # refactor me
      if function.is_a?(Array) and function.lambda?
        function.call(*args)
      else
        raise "Undefined symbol: #{function}" unless SYMBOL_TABLE.has_key?(function)
        SYMBOL_TABLE[function].call(*args)
      end
    end

    def eval_lambda(lambda, args)
      raise BusScheme::EvalError unless lambda.shift == :lambda

      # lexical scope scares me!
      arg_list = lambda.shift
      raise BusScheme::ArgumentError if !arg_list.is_a?(Array) or arg_list.length != args.length

      until arg_list.empty?
        BusScheme::SYMBOL_TABLE[arg_list.shift] = args.shift
      end

      BusScheme::SYMBOL_TABLE[:begin].call(*lambda)
    end
  end
end

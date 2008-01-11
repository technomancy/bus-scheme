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
        BusScheme[form]
      else # well it must be a literal then
        form
      end
    end

    # Call a function with given args
    def apply(function, *args)
      args.map!{ |arg| eval_form(arg) } unless special_form?(function)
      eval_form(function).call(*args)
    end
  end
end

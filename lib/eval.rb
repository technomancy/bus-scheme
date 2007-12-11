module BusScheme
  class << self
    # todo: clean up confusion between eval_string and eval
    def eval_string(string)
      eval(parse(string))
    end

    def eval(form)
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
      args.map!{ |arg| eval(arg) } unless SPECIAL_FORMS.include?(function)
      SYMBOL_TABLE[function].call(*args)
    end
  end
end
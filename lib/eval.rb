module BusScheme
  class << self
    def eval(form)
      form = parse(form) if form.is_a? String # accept a string or an s-expression
      if form == []
        nil
      elsif form.is_a? Array
        apply(form.first, *form.rest)
      elsif form.is_a? Symbol
        SYMBOL_TABLE[form]
      else
        form
      end
    end

    def apply(function, *args)
      SYMBOL_TABLE[function].call(*args)
    end
  end
end

class Array
  # Lisp-style list access
  def rest
    self[1 .. -1]
  end

  alias_method :car, :first
  alias_method :cdr, :rest

  def to_list(recursive = false)
    self[0] = first.sexp(recursive) if recursive

    if self.cdr.nil? or self.cdr.empty?
      BusScheme::Cons.new(car, nil)
    else
      BusScheme::Cons.new(car, self.cdr.sexp(recursive))
    end
  end

  def to_hash
    Hash[*self.flatten_non_recursive]
  end

  def flatten_non_recursive
    [].affect { |flat| each{ |elt| elt.each{ |e| flat << e } } } 
  end
  
  alias_method :sexp, :to_list
  include Callable
end

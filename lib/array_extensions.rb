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

  alias_method :sexp, :to_list
  include Callable
end

# TODO: Use Hash[*a] instead
module Enumerable # for 1.9, zip is defined on Enumerable
  def to_hash
    {}.affect do |hash|
      self.each { |pair| hash[pair.first] = pair.last }
    end
  end
end

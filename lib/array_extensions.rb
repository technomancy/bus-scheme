class Array
  # Lisp-style list access
  def rest
    self[1 .. -1]
  end

  alias_method :car, :first
  alias_method :cdr, :rest

  def to_list
    if self.cdr.empty?
      BusScheme::Cons.new(self.car, nil)
    else
      BusScheme::Cons.new(self.car, self.cdr.to_list)
    end
  end

  alias_method :to_sexp, :to_list
end

module Enumerable # for 1.9, zip is defined on Enumerable
  def to_hash
    {}.affect do |hash|
      self.each { |pair| hash[pair.first] = pair.last }
    end
  end
end

class Array
  # Lisp-style list access
  def rest
    self[1 .. -1]
  end

  alias_method :car, :first
  alias_method :cdr, :rest

  # Treat the array as a lambda and call it with given args
  def call(*args)
    BusScheme::eval_lambda(self, args)
  end

  # Simple predicate for convenience
  def lambda?
    first == :lambda
  end
end

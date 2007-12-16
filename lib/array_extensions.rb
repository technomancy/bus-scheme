class Array
  def rest
    self[1 .. -1]
  end

  alias_method :car, :first
  alias_method :cdr, :rest

  def call(*args)
    BusScheme::eval_lambda(self, args)
  end

  def lambda?
    first == :lambda
  end
end

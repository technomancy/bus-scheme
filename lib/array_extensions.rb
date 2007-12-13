class Array
  def rest
    self[1 .. -1]
  end

  alias_method :car, :first
  alias_method :cdr, :rest
end

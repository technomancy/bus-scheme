class Array
  # Lisp-style list access
  def rest
    self[1 .. -1]
  end

  alias_method :car, :first
  alias_method :cdr, :rest
end

module Enumerable # for 1.9, zip is defined on Enumerable
  def to_hash
    {}.affect do |hash|
      self.each { |pair| hash[pair.first] = pair.last }
    end
  end
end

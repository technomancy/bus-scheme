# The Sym class represents a Lisp symbol. You would think, "why not
# just use Ruby symbols for that?" And that would be a great idea,
# except for the fact that each instance of a Lisp symbol has to have
# metadata associated with where it was defined. This doesn't work
# with Ruby symbols since they're immediate values, so changing one
# instance of :foo changes them all.
class Sym < String
  attr_accessor :file, :line

  def special_form
    BusScheme[self].special_form
  end

  def to_s
    self
  end
  alias_method :inspect, :to_s
  alias_method :sym, :to_s
end

class Symbol
  def sym
    Sym.new(self.to_s)
  end
end

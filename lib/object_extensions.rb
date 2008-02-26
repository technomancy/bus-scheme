class Sym < String
  attr_accessor :file, :line

  # TODO: refactor?
  def special_form
    BusScheme[self].special_form
  end
  
  def inspect
    self
  end

  def to_s
    self
  end

  def sym
    self
  end
end


class Object
  # Return self after evaling block
  # see http://www.ruby-forum.com/topic/131340
  def affect
    yield self
    return self
  end

  def sexp
    self
  end
  
  def special_form
    false
  end
end

module Callable
  # allows for (mylist 4) => mylist[4]
  def call_as(sym, *args)
    self.call(*args)
  end
  def call(*args)
    self.[](*args)
  end
end

class String
  include Callable
  def sym
    Sym.new(self)
  end
end

class Symbol
  def sym
    Sym.new(self.to_s)
  end
end

class Hash
  include Callable
end

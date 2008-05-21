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


class Object
  # Return self after evaling block
  # see http://www.ruby-forum.com/topic/131340
  def affect
    yield self
    return self
  end

  def sexp(r = false)
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

  def to_html
    self
  end
  
  def rest
    return nil if self.length == 1
    self[1, self.length]
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

class Time
  def to_s
    strftime('%y-%m-%d %H:%M')
  end
end

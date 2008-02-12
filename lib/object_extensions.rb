module Traceable
  attr_reader :symbol, :file, :line

  def defined_as(symbol, file, line)
    @symbol, @file, @line = [symbol, file, line]
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

  def special_form?
    false
  end
end

class String
  def sym
    Sym.new(self)
  end
end

class Symbol
  def sym
    Sym.new(self.to_s)
  end

  def file
    "(primitive)"
  end
end

class Proc
  include Traceable
  attr_accessor :'special_form'
  
  def special_form?
    @special_form ||= false
    @special_form
  end

  def file
    "(primitive)"
  end

  def line
    nil
  end
end

class Sym < String
  attr_accessor :file, :line

  # TODO: refactor
  def special_form?
    BusScheme::Lambda[self].special_form?
  end
  
  def inspect
    ";#{self}"
  end

  def to_s
    self.intern.to_s
  end
end

class Hash
  alias_method :call, :[]
end

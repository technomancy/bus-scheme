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

  def line
    nil
  end
  
  def file=(*args)
  end

  def line=(*args)
  end
end

class Proc
  def file
    "(primitive)"
  end

  def line
    nil
  end
end

class Sym < String
  attr_accessor :file, :line
  
#   def eql?(other)
#     self.intern.eql?(other)
#   end
  
  def inspect
    ";#{self}"
  end

  def to_s
    self.intern.to_s
  end
end

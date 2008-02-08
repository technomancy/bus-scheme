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
  def node
    Node.new(self)
  end
end

class Symbol
  def node
    Node.new(self.to_s)
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

class Node < String
  attr_accessor :file, :line
  
  def eql?(other)
    self.intern.eql?(other)
  end
end

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

  def call(arg)
    arg = arg.car if arg.respond_to? :car # TODO: remove?
    self[arg]
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
  
  def shift(chars=1)
    retval = self[0 ... chars]
    self[0 ... chars] = ''
    retval
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

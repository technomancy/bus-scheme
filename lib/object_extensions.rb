class Object
  # Return self after evaling block
  # see http://www.ruby-forum.com/topic/131340
  def affect
    yield self
    return self
  end
end

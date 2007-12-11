class Object
  def returning
    yield self
    self
  end
end

module Kernel
  def returning(x)
    yield x
    return x
  end
end

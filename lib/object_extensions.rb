module Kernel
  def returning(x)
    yield x
    x
  end
end

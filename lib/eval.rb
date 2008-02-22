module BusScheme
  module_function # did not know about this until seeing it in Rubinius; handy!
  SYMBOL_TABLE = {} # top-level scope
  @@stack = []
  
  # Parse a string, then eval the result
  def eval_string(string)
    eval(parse("(begin #{string})"))
  end

  # Eval a form passed in as an array
  def eval(form)
    if (form.is_a?(Cons) or form.is_a?(Array)) and form.first
      puts ' ' * stack.length + form.inspect if (@trace ||= false)
      apply(form.first, form.rest)
    elsif form.is_a? Sym or form.is_a? Symbol # TODO: can we remove Symbol here?
      self[form.sym]
    else # well it must be a literal then
      form
    end
  end

  # Call a function with given args
  def apply(function_sym, args)
    args = args.to_a
    args.map!{ |arg| eval(arg) } unless function_sym.special_form?
    function = eval(function_sym)

    function.call(*args)
  end

  def current_scope
    @@stack.empty? ? SYMBOL_TABLE : @@stack.last.scope
  end

  def in_scope?(sym)
    current_scope.has_key?(sym) or SYMBOL_TABLE.has_key?(sym)
  end
  
  def [](sym)
    raise EvalError.new("Undefined symbol: #{sym.inspect}") unless in_scope?(sym)
    current_scope[sym]
  end

  def []=(sym, val)
    current_scope[sym] = val
  end

  def stacktrace
    @@stack.reverse.map{ |frame| frame }
  end

  def stack
    @@stack
  end
end

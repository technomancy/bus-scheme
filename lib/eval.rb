module BusScheme
  module_function # did not know about this until seeing it in Rubinius; handy!
  SYMBOL_TABLE = {} # top-level scope
  @@stack = []
  
  # Parse a string, then eval the result
  def eval_string(string)
    eval(parse("(top-level #{string})"))
  end

  # Eval a form passed in as an array
  def eval(form)
    if (form.is_a?(Cons) or form.is_a?(Array)) and form.first
      apply(form.first, form.rest)
    elsif form.is_a? Sym
      self[form.sym]
    else # well it must be a literal then
      form
    end
  end

  # Call a function with given args
  def apply(function_sym, args)
    args = args.to_a
    function = eval(function_sym)
    args.map!{ |arg| eval(arg) } unless function.special_form
    puts ' ' * stack.length + Cons.new(function_sym, args.sexp).inspect if (@trace ||= false)

    function.call_as(function_sym, *args)
  end

  # Scoping methods:
  def current_scope
    @@stack.empty? ? SYMBOL_TABLE : @@stack.last
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

  # Tracing methods:
  def stacktrace
    # TODO: notrace is super-duper-hacky!
    @@stack.reverse.map{ |frame| frame.trace if frame.respond_to? :trace }.compact
  end

  def stack
    @@stack
  end
end

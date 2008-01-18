module BusScheme
  class BusSchemeError < StandardError; end
  class ParseError < BusSchemeError; end
  class EvalError < BusSchemeError; end
  class ArgumentError < BusSchemeError; end

  PRIMITIVES = {
    '#t'.intern => true, # :'#t' screws up emacs' ruby parser
    '#f'.intern => false,

    :+ => lambda { |*args| args.inject(0) { |sum, i| sum + i } },
    :- => lambda { |x, y| x - y },
    :* => lambda { |*args| args.inject(1) { |product, i| product * i } },
    '/'.intern => lambda { |x, y| x / y },

    :> => lambda { |x, y| x > y },
    :< => lambda { |x, y| x < y },
    :'=' => lambda { |x, y| x == y }, # may not honor scheme's equality notions
    :null? => lambda { |x| x.nil? },
    
    :intern => lambda { |x| x.intern },
    :substring => lambda { |x, from, to| x[from .. to] },

    :car => lambda { |list| list.car },
    :cdr => lambda { |list| list.cdr },

    :ruby => lambda { |code| eval(code) },
    :load => lambda { |filename| eval_string(File.read(filename)) },
    :exit => lambda { exit }, :quit => lambda { exit },
  }

  # if we add in macros, can some of these be defined in scheme?
  SPECIAL_FORMS = {
    :quote => lambda { |arg| arg },
    # TODO: check that nil, () and #f all behave according to spec
    :if => lambda { |q, yes, *no| eval_form(q) ? eval_form(yes) : eval_form([:begin] + no) },
    :begin => lambda { |*args| args.map{ |arg| eval_form(arg) }.last },
    :set! => lambda { |sym, value| raise EvalError.new unless Lambda.scope.has_key?(sym) and 
      Lambda.scope[sym] = eval_form(value); sym },
    :lambda => lambda { |args, *form| Lambda.new(args, form) },
    :define => lambda { |sym, definition| Lambda.scope[sym] = eval_form(definition); sym },
  }
end

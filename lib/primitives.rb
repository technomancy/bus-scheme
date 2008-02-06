module BusScheme
  class BusSchemeError < StandardError; end
  class ParseError < BusSchemeError; end
  class EvalError < BusSchemeError; end
  class ArgumentError < BusSchemeError; end
  class AssertionFailed < BusSchemeError; end
  
  PRIMITIVES = {
    # right now I believe there are as few things implemented primitively as possible
    # except for functions that require splat args. do we need something like &rest?
    
    '#t'.intern => true, # :'#t' screws up emacs' ruby parser
    '#f'.intern => false,

    :+ => lambda { |*args| args.inject { |sum, i| sum + i } },
    :- => lambda { |x, y| x - y },
    :* => lambda { |*args| args.inject { |product, i| product * i } },
    '/'.intern => lambda { |x, y| x / y },

    :concat => lambda { |*args| args.join('') },
    :cons => lambda { |car, cdr| Cons.new(car, cdr) },
    :list => lambda { |*members| members.to_list },
    :vector => lambda { |*members| members },
    
    :ruby => lambda { |*code| Kernel.eval code.join('') },
    :eval => lambda { |code| eval(code) },
    :send => lambda { |obj, *message| obj.send(*message) },
    :assert => lambda { |cond| raise AssertionFailed unless cond },
    :load => lambda { |filename| BusScheme.load filename },
    :exit => lambda { exit }, :quit => lambda { exit },
  }

  # if we add in macros, can some of these be defined in scheme?
  SPECIAL_FORMS = {
    # TODO: hacky to coerce everything to sexps... won't work once we start using vectors
    :quote => lambda { |arg| arg.sexp },
    :if => lambda { |q, yes, *no| eval(q) ? eval(yes) : eval([:begin] + no) },
    :begin => lambda { |*args| args.map{ |arg| eval(arg) }.last },
    :set! => lambda { |sym, value| raise EvalError.new unless Lambda.scope.has_key?(sym) and 
      Lambda[sym] = eval(value); sym },
    :lambda => lambda { |args, *form| Lambda.new(args, form) },
    :define => lambda { |sym, definition| Lambda[sym] = eval(definition); sym },

    # once we have macros, this can be defined in scheme
    :and => lambda { |*args| args.all? { |x| eval(x) } },
    :or => lambda { |*args| args.any? { |x| eval(x) } },
    :let => lambda { |defs, *body| Lambda.new(defs.map{ |d| d.car }, body).call(*defs.map{ |d| eval d.last }) },
  }
end

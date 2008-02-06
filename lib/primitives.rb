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
    
    :ruby => lambda { |*code| eval(code.join('')) },
    :eval => lambda { |code| eval_form(code) },
    :send => lambda { |obj, *message| obj.send(*message) },
    :assert => lambda { |cond| raise AssertionFailed unless cond },
    :load => lambda { |filename| BusScheme.load filename },
    :exit => lambda { exit }, :quit => lambda { exit },
  }

  # if we add in macros, can some of these be defined in scheme?
  SPECIAL_FORMS = {
    # TODO: hacky to coerce everything to sexps... won't work once we start using vectors
    :quote => lambda { |arg| arg.sexp },
    :if => lambda { |q, yes, *no| eval_form(q) ? eval_form(yes) : eval_form([:begin] + no) },
    :begin => lambda { |*args| args.map{ |arg| eval_form(arg) }.last },
    :set! => lambda { |sym, value| raise EvalError.new unless Lambda.scope.has_key?(sym) and 
      Lambda.scope[sym] = eval_form(value); sym },
    :lambda => lambda { |args, *form| Lambda.new(args, form) },
    :define => lambda do |sym, definition|
      Lambda.scope[sym] = eval_form(definition)
      Lambda.scope[sym].defined_in = sym.defined_in if Lambda[sym].respond_to?(:defined_in)
      sym
    end,

    # once we have macros, this can be defined in scheme
    :and => lambda { |*args| args.all? { |x| eval_form(x) } },
    :or => lambda { |*args| args.any? { |x| eval_form(x) } },
    :let => lambda { |defs, *body| Lambda.new(defs.map{ |d| d.car }, body).call(*defs.map{ |d| eval_form d.last }) },
  }
end

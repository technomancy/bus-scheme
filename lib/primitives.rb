module BusScheme
  class BusSchemeError < StandardError; end
  class ParseError < BusSchemeError; end
  class EvalError < BusSchemeError; end
  class ArgumentError < BusSchemeError; end
  class AssertionFailed < BusSchemeError; end
  
  PRIMITIVES = {
    # right now I believe there are as few things implemented primitively as possible
    # except for functions that require splat args. do we need something like &rest?
    
    '#t'.sym => true, # :'#t' screws up emacs' ruby parser
    '#f'.sym => false,

    :+.sym => lambda { |*args| args.inject { |sum, i| sum + i } },
    :-.sym => lambda { |x, y| x - y },
    :*.sym => lambda { |*args| args.inject { |product, i| product * i } },
    '/'.sym => lambda { |x, y| x / y },

    :concat.sym => lambda { |*args| args.join('') },
    :cons.sym => lambda { |car, cdr| Cons.new(car, cdr) },
    :list.sym => lambda { |*members| members.to_list },
    :vector.sym => lambda { |*members| members },
    
    :ruby.sym => lambda { |*code| Kernel.eval code.join('') },
    :eval.sym => lambda { |code| eval(code) },
    :send.sym => lambda { |obj, *message| obj.send(*message) },
    :assert.sym => lambda { |cond| raise AssertionFailed unless cond },
    :load.sym => lambda { |filename| BusScheme.load filename },
    :exit.sym => lambda { exit }, :quit.sym => lambda { exit },
  }

  # if we add in macros, can some of these be defined in scheme?
  SPECIAL_FORMS = {
    # TODO: hacky to coerce everything to sexps... won't work once we start using vectors
    :quote.sym => lambda { |arg| arg.sexp },
    :if.sym => lambda { |q, yes, *no| eval(q) ? eval(yes) : eval([:begin] + no) },
    :begin.sym => lambda { |*args| args.map{ |arg| eval(arg) }.last },
    :set!.sym => lambda { |sym, value| raise EvalError.new unless Lambda.in_scope?(sym)
      Lambda[sym] = eval(value); sym },
    :lambda.sym => lambda { |args, *form| Lambda.new(args, form) },
    :define.sym => lambda { |sym, definition| Lambda[sym] = eval(definition); sym },

    # once we have macros, this can be defined in scheme
    :and.sym => lambda { |*args| args.all? { |x| eval(x) } },
    :or.sym => lambda { |*args| args.any? { |x| eval(x) } },
    :let.sym => lambda { |defs, *body| Lambda.new(defs.map{ |d| d.car }, body).call(*defs.map{ |d| eval d.last }) },
    :hash.sym => lambda { |*args| args.to_hash }, # accepts an alist
  }
end

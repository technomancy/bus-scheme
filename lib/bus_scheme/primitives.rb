module BusScheme
  def self.define(identifier, value)
    BusScheme[identifier.sym] = value
  end

  def self.special_form(identifier, value)
    value.special_form = true
    BusScheme[identifier.sym] = value
  end

  define '#t', true
  define '#f', false

  define '+', primitive { |*args| args.inject { |sum, i| sum + i } }
  define '-', primitive { |x, y| x - y }
  define '*', primitive { |*args| args.inject { |product, i| product * i } }
  define '/', primitive { |x, y| x / y }

  define 'concat', primitive { |*args| args.join('') }
  define 'cons', primitive { |car, cdr| Cons.new(car, cdr) }
  define 'list', primitive { |*members| members.to_list }
  define 'vector', primitive { |*members| members.to_a }
  define 'map', primitive { |fn, list| list.map(lambda { |n| fn.call(cons(n)) }).sexp }
    
  # TODO: test these
  define 'now', primitive { Time.now }
  define 'regex', primitive { |r| Regexp.new(Regexp.escape(r)) }

  define 'read', primitive {|*args| args.empty? ? gets : File.read(args.first) }
  # TODO: give read and write the same interface
  define 'write', primitive { |obj| puts obj.inspect; 0 }
  define 'display', primitive { |obj| puts obj }
  
  define 'eval', primitive { |code| eval(code) }
  define 'stacktrace', primitive { BusScheme.stacktrace }
  define 'trace', primitive { @trace = !@trace }
  define 'fail', primitive { |message| raise AssertionFailed, "#{message}\n  #{BusScheme.stacktrace.join("\n  ")}" }
  
  define 'ruby', primitive { |*code| Kernel.eval code.join('') }
  define 'send', primitive { |obj, message, *args| obj.send(message.to_sym, *args) }

  define 'load', primitive { |filename| BusScheme.load filename }
  define 'exit', primitive { exit }
  define 'quit', BusScheme['exit'.sym]


  # TODO: write
  special_form 'quasiquote', primitive { }
  special_form 'unquote', primitive { }
  special_form 'unquote-splicing', primitive { }

  # Primitives that can't be defined in terms of other forms:
  special_form 'quote', primitive { |arg| arg }
  special_form 'if', primitive { |q, yes, *no| eval(eval(q) ? yes : cons(:begin.sym, no.sexp)) }
  special_form 'begin', primitive { |*args| args.map{ |arg| eval(arg) }.last }
  special_form 'top-level', BusScheme[:begin.sym]
  special_form 'lambda', primitive { |args, *form| Lambda.new(args, form) }
  # TODO: define doesn't always create a top-level binding
  special_form 'define', primitive { |sym, value| BusScheme::SYMBOL_TABLE[sym] = eval(value); sym }
  special_form 'set!', primitive { |sym, value| raise EvalError unless BusScheme.in_scope?(sym)
    BusScheme[sym.sym] = value }

  # TODO: once we have macros, this can be defined in scheme
  special_form 'and', primitive { |*args| args.all? { |x| eval(x) } }
  special_form 'or', primitive { |*args| args.any? { |x| eval(x) } }
  special_form 'let', primitive { |defs, *body| Lambda.new(defs.map{ |d| d.car }, body).call(*defs.map{ |d| eval d.last }) }
  special_form 'hash', primitive { |*args| args.to_hash } # accepts an alist
end

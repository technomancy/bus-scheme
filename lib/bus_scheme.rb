require 'readline'
require 'yaml' rescue nil # not a deal-killer; this is just for debug

$LOAD_PATH << File.dirname(__FILE__)
require 'object_extensions'
require 'array_extensions'
require 'parser'
require 'eval'

module BusScheme
  class ParseError < StandardError; end

  PRIMITIVES = {
    :'#t' => true,
    :'#f' => false,

    :add1 => lambda { |x| x + 1 },
    :sub1 => lambda { |x| x - 1 },

    :+ => lambda { |*args| args.inject(0) { |sum, i| sum + i } },
    :- => lambda { |x, y| x - y },
    :'/' => lambda { |x, y| x / y },
    :* => lambda { |*args| args.inject(1) { |product, i| product * i } },

    :> => lambda { |x, y| x > y },
    :< => lambda { |x, y| x < y },

    :intern => lambda { |x| x.intern },
    :concat => lambda { |x, y| x + y },
    :substring => lambda { |x, from, to| x[from .. to] },

    :exit => lambda { exit }, :quit => lambda { exit },
  }

  SPECIAL_FORMS = {
    :quote => lambda { |arg| arg },
    :if => lambda { |condition, yes, *no| eval(condition) ? eval(yes) : eval([:begin] + no) },
    :begin => lambda { |*args| args.map{ |arg| eval(arg) }.last },
    :set! => lambda { },
    :lambda => lambda { |args, *form| [:lambda, args] + form },
    :define => lambda { |sym, definition| SYMBOL_TABLE[sym] = BusScheme.eval(definition); sym },
  }

  SYMBOL_TABLE = {}.merge(PRIMITIVES).merge(SPECIAL_FORMS)
  PROMPT = '> '

  def self.repl
    loop do
      begin
        puts BusScheme.eval(Readline.readline(PROMPT))
      rescue Interrupt
      end
    end
  end
end

BusScheme.repl if $0 == __FILE__

require 'readline'

$LOAD_PATH << File.dirname(__FILE__)
require 'object_extensions'
require 'array_extensions'
require 'parser'
require 'eval'

module BusScheme
  class ParseError < StandardError; end

  PRIMITIVES = {
    :add1 => lambda { |x| x + 1 },
    :sub1 => lambda { |x| x - 1 },
    :define => lambda { |sym, definition| SYMBOL_TABLE[sym] = BusScheme.eval(definition) },
    :quote => lambda { |arg| arg },

    :+ => lambda { |*args| args.inject(0) { |sum, i| sum + i } },
    :- => lambda { |x, y| x - y },
    :'/' => lambda { |x, y| x / y },
    :* => lambda { |*args| args.inject(1) { |product, i| product * i } },

    :intern => lambda { |x| x.intern },
    :concat => lambda { |x, y| x + y },
    :substring => lambda { |x, from, to| x[from .. to] },

    :lambda => lambda { |args, *form| } # ???
  }

  SPECIAL_FORMS = [:quote, :define] # don't apply args for calls to these
  SYMBOL_TABLE = {}.merge(PRIMITIVES)
end

# REPL-tastic
loop { print "> "; puts BusScheme.eval(Readline.readline) } if $0 == __FILE__

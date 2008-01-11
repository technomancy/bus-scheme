#!/usr/bin/env ruby

begin
  require 'readline'
  require 'yaml'
rescue LoadError
end

$LOAD_PATH << File.dirname(__FILE__)
require 'object_extensions'
require 'array_extensions'
require 'parser'
require 'eval'
require 'lambda'

module BusScheme
  class BusSchemeError < StandardError; end
  class ParseError < BusSchemeError; end
  class EvalError < BusSchemeError; end
  class ArgumentError < BusSchemeError; end

  VERSION = "0.6"

  PRIMITIVES = {
    '#t'.intern => true, # :'#t' screws up emacs' ruby parser
    '#f'.intern => false,

    :+ => lambda { |*args| args.inject(0) { |sum, i| sum + i } },
    :- => lambda { |x, y| x - y },
    :* => lambda { |*args| args.inject(1) { |product, i| product * i } },
    '/'.intern => lambda { |x, y| x / y },

    :> => lambda { |x, y| x > y },
    :< => lambda { |x, y| x < y },

    :intern => lambda { |x| x.intern },
    :concat => lambda { |x, y| x + y },
    :substring => lambda { |x, from, to| x[from .. to] },

    :load => lambda { |filename| eval_string(File.read(filename)) },
    :exit => lambda { exit }, :quit => lambda { exit },
  }

  # if we add in macros, can some of these be defined in scheme?
  SPECIAL_FORMS = {
    :quote => lambda { |arg| arg },
    # TODO: check that nil, () and #f all behave according to spec
    :if => lambda { |q, yes, *no| eval_form(q) ? eval_form(yes) : eval_form([:begin] + no) },
    :begin => lambda { |*args| args.map{ |arg| eval_form(arg) }.last },
    :set! => lambda { |sym, value| raise ArgumentError unless in_scope?(sym)
      BusScheme[sym] = eval_form(value); sym },
    :lambda => lambda { |args, *form| Lambda.new(args, *form) },
    :define => lambda { |sym, definition| BusScheme[sym] = eval_form(definition); sym },
  }

  SYMBOL_TABLE = {}.merge(PRIMITIVES).merge(SPECIAL_FORMS)
  SCOPES = [SYMBOL_TABLE]
  PROMPT = '> '

  # symbol existence predicate
  def self.in_scope?(symbol)
    SCOPES.last.has_key?(symbol) or SCOPES.first.has_key?(symbol)
  end

  # symbol lookup
  def self.[](symbol)
    raise EvalError.new("Undefined symbol: #{symbol}") if not in_scope?(symbol)
    SCOPES.last[symbol] or SCOPES.first[symbol]
  end

  # symbol assignment to value
  def self.[]=(symbol, value)
    SCOPES.last[symbol] = value
  end

  # symbol special form predicate
  def self.special_form?(symbol)
    SPECIAL_FORMS.has_key?(symbol)
  end

  # Read-Eval-Print-Loop
  def self.repl
    loop do
      begin
        puts BusScheme.eval_string(Readline.readline(PROMPT))
      rescue Interrupt
        puts 'Type "(quit)" to leave Bus Scheme.'
      rescue BusSchemeError => e
        puts "Error: #{e}"
      rescue StandardError => e
        puts "You found a bug in Bus Scheme!"
        puts "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
      end
    end
  end
end

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

module BusScheme
  class ParseError < StandardError; end

  PRIMITIVES = {
    '#t'.intern => true, # :'#t' screws up emacs' ruby parser
    '#f'.intern => false,

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
    :if => lambda { |condition, yes, *no| eval_form(condition) ? eval_form(yes) : eval_form([:begin] + no) },
    :begin => lambda { |*args| args.map{ |arg| eval_form(arg) }.last },
    :set! => lambda { },
    :lambda => lambda { |args, *form| [:lambda, args] + form },
    :define => lambda { |sym, definition| SYMBOL_TABLE[sym] = eval_form(definition); sym },
  }

  SYMBOL_TABLE = {}.merge(PRIMITIVES).merge(SPECIAL_FORMS)
  PROMPT = '> '

  def self.repl
    loop do
      begin
        puts BusScheme.eval_string(Readline.readline(PROMPT))
      rescue Interrupt
        puts 'Type "(quit)" to leave Bus Scheme.'
      end
    end
  end
end

BusScheme.repl if $0 == __FILE__

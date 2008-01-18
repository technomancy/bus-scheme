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
require 'definitions'
require 'lambda'

module BusScheme
  VERSION = "0.7"

  SYMBOL_TABLE = {}.merge(PRIMITIVES).merge(SPECIAL_FORMS)
  PROMPT = '> '

  # what scope is appropraite for this symbol
  def self.scope_of(symbol)
    [Lambda.scope, SYMBOL_TABLE].compact.detect { |scope| scope.has_key?(symbol) }
  end
  
  # symbol lookup
  def self.[](symbol)
    scope = scope_of(symbol)
    raise EvalError.new("Undefined symbol: #{symbol}") unless scope
    scope && scope[symbol]
  end

  # symbol assignment to value
  def self.[]=(symbol, value)
    (scope_of(symbol) || Lambda.scope || SYMBOL_TABLE)[symbol] = value
  end

  # symbol special form predicate
  def self.special_form?(symbol)
    SPECIAL_FORMS.has_key?(symbol)
  end
  
  # Read-Eval-Print-Loop
  def self.repl
    loop do
      puts begin
             BusScheme.eval_string(Readline.readline(PROMPT))
           rescue Interrupt
             'Type "(quit)" to leave Bus Scheme.'
           rescue BusSchemeError => e
             "Error: #{e}"
           rescue StandardError => e
             "You found a bug in Bus Scheme!\n" +
               "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
           end
    end
  end
end

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
  VERSION = "0.6"

  SYMBOL_TABLE = {}.merge(PRIMITIVES).merge(SPECIAL_FORMS)
  LOCAL_SCOPES = []
  PROMPT = '> '

  # what scope is appropraite for this symbol
  def self.scope_of(symbol)
    ([LOCAL_SCOPES.last] + Lambda.environment + [SYMBOL_TABLE]).compact.detect { |scope| scope.has_key?(symbol) }
  end
  
  # symbol lookup
  def self.[](symbol)
    scope = scope_of(symbol)
    raise EvalError.new("Undefined symbol: #{symbol}") if scope.nil?
    scope[symbol]
  end

  # symbol assignment to value
  def self.[]=(symbol, value)
    (scope_of(symbol) || SYMBOL_TABLE)[symbol] = value
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

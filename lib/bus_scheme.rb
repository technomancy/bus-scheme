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
require 'primitives'
require 'cons'
require 'lambda'

module BusScheme
  VERSION = "0.7.5"

  SYMBOL_TABLE = {}.merge(PRIMITIVES).merge(SPECIAL_FORMS)
  PROMPT = '> '

  # symbol special form predicate
  def self.special_form?(symbol)
    SPECIAL_FORMS.has_key?(symbol)
  end
  
  # Read-Eval-Print-Loop
  def self.repl
    loop do
      puts begin
             input = Readline.readline(PROMPT)
             exit if input.nil? # only Ctrl-D produces nil here it seems
             BusScheme.eval_string input
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

  ['core'].each { |file| SYMBOL_TABLE[:load].call("#{File.dirname(__FILE__)}/scheme/#{file}.scm") }
end

#!/usr/bin/env ruby

begin
  require 'readline'
  require 'yaml'
rescue LoadError
end

$LOAD_PATH << File.dirname(__FILE__)
require 'object_extensions'
require 'array_extensions'
require 'hash_extensions'
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
  def self.special_form?(form)
    form.is_a? Symbol or form.is_a? Node and
      SPECIAL_FORMS.has_key?(form)
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

  def self.load(filename)
    loaded_files.push filename
    eval_string File.read(filename)
    loaded_files.pop
  end

  def self.loaded_files
    (@loaded_files ||= ["(eval)"])
  end
  
  ['core'].each { |file| load("#{File.dirname(__FILE__)}/scheme/#{file}.scm") }
end

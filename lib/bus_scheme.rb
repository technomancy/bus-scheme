#!/usr/bin/env ruby

begin
  require 'readline'
rescue LoadError
end

$LOAD_PATH << File.dirname(__FILE__)
require 'object_extensions'
require 'array_extensions'
require 'recursive_hash'

require 'parser'
require 'eval'
require 'primitives'
require 'cons'
require 'lambda'

module BusScheme
  VERSION = "0.7.5"

  PROMPT = '> '
  INCOMPLETE_PROMPT = ' ... '
  LOAD_PATH = ["#{File.dirname(__FILE__)}/scheme/", File.expand_path('.')]
  
  class BusSchemeError < StandardError; end
  class ParseError < BusSchemeError; end
  class EvalError < BusSchemeError; end
  class LoadError < BusSchemeError; end
  class IncompleteError < BusSchemeError; end
  class ArgumentError < BusSchemeError; end
  class AssertionFailed < BusSchemeError; end

  # Read-Eval-Print-Loop
  def self.repl
    loop do
      puts begin
             input = Readline.readline(PROMPT)
             exit if input.nil? # only Ctrl-D produces nil here it seems
             begin # allow for multiline input
               result = BusScheme.eval_string(input).inspect
             rescue IncompleteError
               input += "\n" + Readline.readline(INCOMPLETE_PROMPT)
               retry
             end
             Readline::HISTORY.push(input)
             result
           rescue Interrupt
             'Type "(quit)" or press Ctrl-D to leave Bus Scheme.'
           rescue BusSchemeError => e
             "Error: #{e}"
           rescue StandardError => e
             "You found a bug in Bus Scheme!\n" +
               "#{e.class}: #{e}\n#{e.backtrace.join("\n")}"
           end
    end
  end

  # Load a file if on the load path or absolute
  def self.load(filename)
    loaded_files.push filename
    eval_string File.read(add_load_path(filename))
    loaded_files.pop
  end

  # TODO: expose load path in scheme
  def self.add_load_path(filename)
    return filename if filename.match(/^\//) or File.exist? filename
    LOAD_PATH.map { |path| return path + filename if File.exist? path + filename }
    raise LoadError, "File not found: #{filename}"
  end

  # For stack traces
  def self.loaded_files
    (@loaded_files ||= ["(eval)"])
  end

  ['core.scm', 'test.scm', 'list.scm'].each { |file| load(file) }
end

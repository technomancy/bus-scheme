#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__)
require 'readline'

require 'bus_scheme/sym'
require 'bus_scheme/object_extensions'
require 'bus_scheme/array_extensions'

require 'bus_scheme/parser'
require 'bus_scheme/eval'
require 'bus_scheme/cons'
require 'bus_scheme/lambda'
require 'bus_scheme/stack_frame'
require 'bus_scheme/primitives'

module BusScheme
  VERSION = "0.7.7"

  PROMPT = '> '
  INCOMPLETE_PROMPT = ' ... '
  BusScheme['load-path'.sym] = Cons.new("#{File.dirname(__FILE__)}/bus_scheme/scheme/",
                                        Cons.new(File.expand_path('.'), nil))
  
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
    begin
      loaded_files.push filename
      eval_string File.read(add_load_path(filename))
      loaded_files.pop
    rescue
      loaded_files.pop
      raise
    end
  end

  def self.add_load_path(filename, load_path = BusScheme['load-path'.sym])
    return filename if filename.match(/^\//) or File.exist? filename
    raise LoadError, "File not found: #{filename}" if load_path.nil?
    return load_path.car + '/' + filename if File.exist? load_path.car + '/' + filename
    return add_load_path(filename, load_path.cdr)
  end

  # For stack traces
  def self.loaded_files
    (@loaded_files ||= ["(eval)"])
  end

  ['core.scm', 'test.scm', 'list.scm', 'predicates.scm'
  ].each { |f| load(f) }
end

begin
  require 'bus_scheme/web'
  require 'bus_scheme/xml'
rescue LoadError
  STDERR.puts "Could not load web functionality. Missing Mongrel/Rack/Builder?"
end

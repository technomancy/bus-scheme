#!/usr/bin/env ruby

begin
  require 'readline'
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

  PROMPT = '> '
  LOAD_PATH = ["#{File.dirname(__FILE__)}/scheme/"]
  
  # Read-Eval-Print-Loop
  def self.repl
    loop do
      puts begin
             input = Readline.readline(PROMPT)
             exit if input.nil? # only Ctrl-D produces nil here it seems
             BusScheme.eval_string input
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

  def self.load(filename)
    loaded_files.push filename
    filename = add_load_path(filename)
    eval_string File.read(filename)
    loaded_files.pop
  end

  def self.add_load_path(filename)
    return filename if filename.match(/^\//) or File.exist? filename
    LOAD_PATH.map { |path| return path + filename if File.exist? path + filename }
    raise LoadError, "File not found: #{filename}"
  end
  
  def self.loaded_files
    (@loaded_files ||= ["(eval)"])
  end

  ['core.scm', 'test.scm'].each { |file| load(file) }
end

# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/bus_scheme.rb'

Hoe.new('bus-scheme', BusScheme::VERSION) do |p|
  p.author = 'Phil Hagelberg'
  p.email = 'technomancy@gmail.com'
  p.summary = 'Bus Scheme is a Scheme in Ruby, imlemented on the bus.'
  p.description = p.paragraphs_of('README.rdoc', 2..5).join("\n\n")
  p.url = 'http://bus-scheme.rubyforge.org'
  p.remote_rdoc_dir = ''
  # p.extra_rdoc_files = ["README.rdoc"]
end

desc "Code statistics"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(['lib'], ['Unit tests', 'test']).to_s
end

desc "Complexity statistics"
task :flog do
  system "flog lib/**/*rb"
end

desc "Show todo items"
task :todo do
  puts File.read('README.txt').match(/== Todo(.*)== Requirements/m)[1].split("\n").grep(/^(\*|===)/).join("\n")
  puts "Within the code:"
  system "grep -r TODO lib"
end

desc "Show tests that have been commented out"
task :commented_tests do
  Dir.glob('test/test_*.rb').each do |file|
    puts File.read(file).grep(/^\s*#+\s*def (test_[^ ]*)/)
  end

  Dir.glob('test/test_*.scm').each do |file|
    puts File.read(file).grep(/^\s*;+\s*\(assert/)
  end
end

# TODO: use multiruby, duh
desc "Run ruby tests in Rubinius"
task :rbx_test do
  BIN = ENV['bin'] || "~/src/rubinius/shotgun/rubinius"
  if ENV['test']
    system "#{BIN} test/test_#{ENV['test']}.rb"
  else
    system "#{BIN} -w -Ilib:test -e '#{Dir.glob('test/test_*.rb').map{ |f| "require \"" + f + "\" "}.join('; ')}'"
  end
end

desc 'Run tests written in Scheme'
task :scheme_test do
  Dir.glob('test/test_*.scm').each do |file|
    begin
      BusScheme.load(file)
    rescue => e
      puts "Error: #{e.message} in #{file}"
    end
  end
end

# can never keep these straight
task :test_scheme => :scheme_test
task :scheme => :scheme_test

task :default => [:test, :scheme_test]

# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/bus_scheme.rb'
require 'rake/testtask'

BIN = ENV['bin'] || "~/src/rubinius/shotgun/rubinius"

Hoe.new('bus-scheme', BusScheme::VERSION) do |p|
  p.rubyforge_name = 'bus-scheme'
  p.author = 'Phil Hagelberg'
  p.email = 'technomancy@gmail.com'
  p.summary = 'Bus Scheme is a Scheme in Ruby, imlemented on the bus.'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.remote_rdoc_dir = ''
end

desc "Code statistics"
task :stats do
  require 'code_statistics'
  CodeStatistics.new(['lib'], ['Unit tests', 'test']).to_s
end

desc "Complexity statistics"
task :flog do
  system "flog lib/*rb"
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
    puts File.read(file).grep(/^\s*#\s*def (test_[^ ]*)/)
  end
end

# TODO: use multiruby, duh
desc "Run tests in Rubinius"
task :rbx_test do
  if ENV['test']
    system "#{BIN} test/test_#{ENV['test']}.rb"
  else
    system "#{BIN} -w -Ilib:test -e '#{Dir.glob('test/test_*.rb').map{ |f| "require \"" + f + "\" "}.join('; ')}'"
  end
end

desc 'Run scheme tests in bus scheme'
task :scheme_test do
  require 'bus_scheme'
  Dir.glob('test/test_*.scm').each do |file|
    BusScheme.eval_string("(load \"#{file}\")")
  end
end

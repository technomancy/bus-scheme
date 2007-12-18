# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/bus_scheme.rb'
require 'rake/testtask'

Hoe.new('bus-scheme', BusScheme::VERSION) do |p|
  p.rubyforge_name = 'bus-scheme'
  p.author = 'Phil Hagelberg'
  p.email = 'technomancy@gmail.com'
  p.summary = 'Bus Scheme is a Scheme in Ruby, imlemented on the bus.'
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.remote_rdoc_dir = ''
end

task :stats do
  require 'code_statistics'
  CodeStatistics.new(['lib'], ['Unit tests', 'test']).to_s
end

task :flog do
  system "flog lib/*rb"
end

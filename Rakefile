require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/test_*.rb'
  t.verbose = true
end

task :stats do
  require 'code_statistics'
  CodeStatistics.new(['lib'], ['Unit tests', 'test']).to_s
end

task :flog do
  system "flog lib/*rb"
end

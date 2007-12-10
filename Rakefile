task :default => [:test]

task :test do
  ruby FileList['test/test_*.rb']
end

task :stats do
  require 'code_statistics'
  CodeStatistics.new(['lib'], ['Unit tests', 'test']).to_s
end

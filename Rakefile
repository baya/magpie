require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_*.rb']
end

task :dir_files do
  files = Dir["{bin/*,lib/*,lib/magpie/**/*,lib/models/*,lib/middles/*,lib/views/**/*,test/**/*}"] -
  %w(lib/magpie.yml lib/mag) +
  %w(COPYING magpie.gemspec README.md Rakefile )
  puts files.join("\n")
end

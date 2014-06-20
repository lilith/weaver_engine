require "bundler/gem_tasks"
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.pattern = "test/**/*.rb"
end

Rake::TestTask.new (name="benchmark") do |t|
  t.verbose =true
  t.pattern = "benchmarks/**/*.rb"
end





task :default => ['test']
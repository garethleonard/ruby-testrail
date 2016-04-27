# encoding: utf-8
require 'rubygems'
require 'bundler'
require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

desc "Run tests"
task :default => :features

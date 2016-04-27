Gem::Specification.new do |spec|
  spec.name        = 'cucumber-testrail'
  spec.version     = '1.0.0'
  spec.date        = '2016-04-26'
  spec.summary     = 'Cucumber TestRail integration'
  spec.description = 'Library to integrate Test Suite with TestRail'
  spec.authors     = ['Javier Durante', 'Will Gauvin', 'Nathan Jones']
  spec.email       = 'mercury@findly.com'
  spec.license     = 'Apache-2.0'
  spec.files       = `git ls-files`.split("\n").reject {|path| path =~ /\.gitignore$/ }
  spec.homepage    = 'https://github.com/Findly-Inc/cucumber-testrail'
  spec.add_development_dependency 'rspec', '>= 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec-core'
  spec.add_development_dependency 'rspec-expectations'
  spec.add_development_dependency 'rspec-mocks'
  spec.add_development_dependency 'rspec-support'
  spec.add_development_dependency 'require_all'
end

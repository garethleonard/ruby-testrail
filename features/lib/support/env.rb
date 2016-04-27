require 'require_all'
require 'rspec'
require 'rspec/core'
require 'rspec/expectations'
require 'rspec/mocks'
require 'rspec/support'

require_all('lib')

World(RSpec::Mocks::ExampleMethods)

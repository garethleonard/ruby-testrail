### Status
[![Build Status](https://travis-ci.org/Findly-Inc/ruby-testrail.png)](https://travis-ci.org/Findly-Inc/ruby-testrail)

### Supported Ruby Version
2.2

TestRail Integration Adaptor
============================

The tool provides a way to integrate Cucumber/RSpec test suites with
TestRail using it's API. 

The adaptor gets all the tests results in a cache so it doesn't make
https for each test. Instead, it sends a single API call with all the
results together. This avoid problems with the server throttling enforced
by the server.

### Installation

Just include the gem in your Gemfile

```ruby
gem 'ruby-testrail'
```

### Usage

Create a Test Adaptor with the required configuration. In this case a [CucumberAdaptor](lib/testrail/cucumber_adaptor.rb)
is used ([RSpecAdaptor](lib/testrail/rspec_adaptor.rb) is also available)

```ruby
testrail_adaptor = TestRail::CucumberAdaptor.new(
  enabled: flag,          # Enable or Disable the TestRail runner(default: true)
  url: url,               # URL for custom TestRail Integration
  username: username,     # Authentication Username
  password: password,     # Authentication Password
  project_id: project_id, # TestRail Project ID
  suite_id: suite_id      # TestRail Suite ID
)
```

When the test suite is ready, start a test run

```ruby
testrail_adaptor.start_test_run
```

As an example, a Cucumber test suite is used to send results to the adaptor
Each scenario is being sent using the **submit** method:

```ruby
After do |scenario|
  ...
  testrail_adaptor.submit(scenario)
  ...
end

at_exit do
  testrail_adaptor.end_test_run
end
```

At the end of the test suite the adaptor needs to be finished to send the results
to TestRail. This is done with the **end_test_run** method.


Custom Adaptor
==============

A cusom adaptor could be created. It just needs to extend the base TestRail adaptor
and determine the data that is going to be sent to TestRail:

  - section_name: The name of the section to group test cases in TestRail
  - test_name:    The name of the particular test case
  - success:      The result of the test
  - comment:      A comment describing the test

For example implementations check [CucumberAdaptor](lib/testrail/cucumber_adaptor.rb)
or [RSpecAdaptor](lib/testrail/rspec_adaptor.rb)

TODO
====

 - Unit test for all classes
 - Configurable test run start and end
 - Functional Test again a real TestRail integration project

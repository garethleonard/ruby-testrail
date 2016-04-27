###Status
[![Build Status](https://travis-ci.org/Findly-Inc/cucumber-testrail.png)](https://travis-ci.org/Findly-Inc/cucumber-testrail)

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
gem 'cucumber-testrail'
```

### Usage

Create a Test Adaptor with the required configuration

```ruby
testrail_adaptor = TestRail::Adaptor.new(
  enabled: flag,          # Enable or Disable the TestRail runner(default: false)
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

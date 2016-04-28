Feature: Test suite adaptor

  Scenario: Start test run actually starts a test suite run
    Given a Cucumber Adaptor
    When a test run is started
    Then the test suite starts a test run

  Scenario: End test run finishes a successful run
    Given a Cucumber Adaptor
    And a test run is started
    When the rest run is ended
    Then the test suite submit the results
    And the test suite is closed

  Scenario: End test run doesn't close a run with failures
    Given a Cucumber Adaptor
    And a test run is started
    And an invalid test result is submitted
    When the rest run is ended
    Then the test suite submit the results
    And the test suite is not closed

  Scenario: Disabled adaptor does not perform any operations
    Given a disabled Cucumber Adaptor
    And a test run is started
    When the rest run is ended
    Then no interactions are made to the test suite

  Scenario Outline: Submit supports Cucumber scenarios types
    Given a Cucumber Adaptor
    And a test run is started
    When a result of type "<Result Type>" is submitted
    And the rest run is ended
    Then the submitted results contains the provided details
    Examples:
      | Result Type               |
      | Cucumber Scenario Outline |
      | Cucumber Simple Scenario  |

  Scenario: Submit supports RSpec examples
    Given a RSpec Adaptor
    And a test run is started
    When a result of type "RSpec Example" is submitted
    And the rest run is ended
    Then the submitted results contains the provided details

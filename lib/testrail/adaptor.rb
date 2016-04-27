require 'testrail/api_client'
require 'testrail/testrail_client'

module TestRail

  class Adaptor

    def initialize(
      enabled: false,
      url:,
      username:,
      password:,
      project_id:,
      suite_id:
    )
      @enabled = enabled
      return unless @enabled
      testrail_client = TestRail::APIClient.new(url)
      testrail_client.user = username
      testrail_client.password = password
      @test_suite = TestRail::TestRailClient.new(testrail_client).get_suite(
        project_id: project_id,
        suite_id: suite_id
      )
    end

    # Submits an example test results
    # If the test case exists, it will reuse the id, otherwise it will create a new Test Case in TestRails
    # @param example [Example] A test case example after execution
    def submit(example)
      return unless @enabled
      case example.class.name
      when 'Cucumber::RunningTestCase::ScenarioOutlineExample'
        test_case_section = example.scenario_outline.feature.name
        test_case_section.strip!

        test_case_name = example.scenario_outline.name
        test_case_name.strip!

        test_result = !example.failed?
        test_comment = example.exception
      when 'Cucumber::RunningTestCase::Scenario'
        test_case_section = example.feature.name
        test_case_section.strip!

        test_case_name = example.name
        test_case_name.strip!

        test_result = !example.failed?
        test_comment = example.exception
      when 'RSpec::Core::Example'
        test_case_section = example.example_group.description
        test_case_section.strip!

        test_case_name = example.description
        test_case_name.strip!

        test_result = example.exception.nil?
        test_comment = example.exception
      end

      @test_run.add_test_result(
        section_name: test_case_section,
        test_name: test_case_name,
        success: test_result,
        comment: test_comment)
    end

    # This method initiates a test run against a project, and specified testsuite.
    # ruby functional test file (.rb) containing a range of rspec test cases.
    # Each rspec test case (in the ruby functional test file) will have a corresponding Test Case in TestRail.
    # These Test Rail test cases will belong to a test suite that has the title of the corresponding
    # ruby functional test file.
    def start_test_run
      return unless @enabled
      @test_run = @test_suite.start_test_run
    end

    # Checks to see if any of the tests in a particular test run have failed, if they have then the
    # it will leave the run opened. If there are no failed tests then it will call close the particular run.
    def end_test_run
      return if !@enabled || @test_run.nil?
      @test_run.submit_results
      @test_run.close unless @test_run.failure_count > 0
    end

  end

end

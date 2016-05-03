# Copyright 2016 Findly Inc. NZ
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def setup_adaptor(enabled: true, type: 'Cucumber')
  @test_suite = spy('test_suite')
  @enabled = enabled
  options = {
    enabled: @enabled,
    url: 'fakeurl',
    username: 'username',
    password: 'password',
    project_id: 'project_id',
    suite_id: 'suite_id',
    test_suite: @test_suite
  }
  @adaptor = case type
             when 'RSpec'
               TestRail::RSpecAdaptor.new(options)
             else
               TestRail::CucumberAdaptor.new(options)
             end
end

def create_test_result(type, test_case_result: true)
  result_class = double('result_class')
  test_result = double('test_result')

  @test_case_section = 'test_case_section'
  @test_case_name = 'test_case_name'
  @test_case_comment = 'test_case_comment'
  @example_name = nil

  case type
  when 'Cucumber Scenario Outline'
    class_name = 'Cucumber::RunningTestCase::ScenarioOutlineExample'
    scenario_outline = double('scenario_outline')
    feature = double('feature')
    @example_name = 'example_name'

    allow(test_result).to receive(:scenario_outline) { scenario_outline }
    allow(test_result).to receive(:name) { @example_name }
    allow(test_result).to receive(:failed?) { !test_case_result }
    allow(test_result).to receive(:exception) { @test_case_comment }
    allow(scenario_outline).to receive(:feature) { feature }
    allow(scenario_outline).to receive(:name) { @test_case_name }
    allow(feature).to receive(:name) { @test_case_section }
  when 'Cucumber Simple Scenario'
    class_name = 'Cucumber::RunningTestCase::Scenario'
    feature = double('feature')

    allow(test_result).to receive(:feature) { feature }
    allow(test_result).to receive(:name) { @test_case_name }
    allow(test_result).to receive(:failed?) { !test_case_result }
    allow(test_result).to receive(:exception) { @test_case_comment }
    allow(feature).to receive(:name) { @test_case_section }
  when 'RSpec Example'
    example_group = double('example_group')

    allow(test_result).to receive(:example_group) { example_group }
    allow(test_result).to receive(:description) { @test_case_name }
    if test_case_result
      allow(test_result).to receive(:exception) { nil }
      @test_case_comment = nil
    else
      allow(test_result).to receive(:exception) { @test_case_comment }
    end
    allow(example_group).to receive(:description) { @test_case_section }
  end

  unless result_class.nil?
    allow(test_result).to receive(:class) { result_class }
    allow(result_class).to receive(:name) { class_name }
  end
  test_result
end

Given(/^a Cucumber Adaptor$/) do
  setup_adaptor
end

Given(/^a RSpec Adaptor$/) do
  setup_adaptor(type: 'RSpec')
end

When(/^a test run is started$/) do
  @test_run = spy('test_run')
  allow(@test_suite).to receive(:start_test_run) { @test_run } if @enabled
  @adaptor.start_test_run
end

Then(/^the test suite starts a test run$/) do
  expect(@test_suite).to have_received(:start_test_run) if @enabled
end

When(/^the rest run is ended$/) do
  if @enabled
    @failure_count = @failure_count ||= 0
    allow(@test_run).to receive(:submit_results)
    allow(@test_run).to receive(:failure_count) { @failure_count }
  end
  @adaptor.end_test_run
end

Then(/^the test suite submit the results$/) do
  expect(@test_run).to have_received(:submit_results)
end

Then(/^the test suite is closed$/) do
  expect(@test_run).to have_received(:close)
end

Given(/^an invalid test result is submitted$/) do
  @failure_count = 1
end

Then(/^the test suite is not closed$/) do
  expect(@test_run).to_not have_received(:close)
end

Given(/^a disabled Cucumber Adaptor$/) do
  setup_adaptor(enabled: false)
end

Then(/^no interactions are made to the test suite$/) do
  expect(@test_run).to_not have_received(:submit_results)
  expect(@test_run).to_not have_received(:failure_count)
  expect(@test_run).to_not have_received(:close)
end

When(/^a result of type "([^"]*)" is submitted$/) do |result_type|
  @test_result = create_test_result(result_type)
  allow(@test_run).to receive(:add_test_result)
  @adaptor.submit(@test_result)
end

Then(/^the submitted results contains the provided details/) do
  expect(@test_run).to have_received(:submit_results)

  expect(@test_run).to have_received(:add_test_result).with({
    section_name: @test_case_section,
    test_name: if @example_name.nil? then @test_case_name else "#{@test_case_name} #{@example_name}" end,
    success: true,
    comment: @test_case_comment
  })
end

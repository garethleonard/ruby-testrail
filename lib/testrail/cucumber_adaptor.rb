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
require 'testrail/adaptor'

module TestRail

  class CucumberAdaptor < Adaptor

    # Submits an scenario test results
    # If the test case exists, it will reuse the id, otherwise it will create a new Test Case in TestRails
    # @param scenario [Cucumber Scenario|Cucumber Scenario Outline] A test case scenario after execution
    # @param elapsed Execution Time of Scenario
    def submit(scenario:, elapsed:)
      return unless @enabled
      case scenario.class.name
      when 'Cucumber::RunningTestCase::ScenarioOutlineExample'
        test_results = resolve_from_scenario_outline(scenario, elapsed)
      when 'Cucumber::Ast::OutlineTable::ExampleRow'
        test_results = resolve_from_scenario_outline(scenario, elapsed)
      when 'Cucumber::RunningTestCase::Scenario'
        test_results = resolve_from_simple_scenario(scenario, elapsed)
      when 'Cucumber::Ast::Scenario'
        test_results = resolve_from_simple_scenario(scenario, elapsed)
      end
      submit_test_result(test_results)
    end

    def resolve_from_scenario_outline(scenario, elapsed)
      {
        section_name: scenario.scenario_outline.feature.name.strip,
        test_name: "#{scenario.scenario_outline.name.strip} #{scenario.name.strip}",
        success: !scenario.failed?,
        comment: scenario.exception,
        elapsed: elapsed
      }
    end

    def resolve_from_simple_scenario(scenario, elapsed)
      {
        section_name: scenario.feature.name.strip,
        test_name: scenario.name.strip,
        success: !scenario.failed?,
        comment: scenario.exception,
        elapsed: elapsed
      }
    end

  end

end

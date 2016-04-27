require 'testrail/test_suite'

module TestRail

  class TestRailClient

    def initialize(testrail_http_client)
      @testrail_http_client = testrail_http_client
    end

    def get_suite(project_id:, suite_id:)
      TestSuite.new(
        project_id: project_id,
        suite_id: suite_id,
        testrail_client: self)
    end

    def start_test_run(project_id:, suite_id:)
      @testrail_http_client.send_post("add_run/#{project_id}",
                                      suite_id: suite_id)
    end

    def close_test_run(run_id)
      @testrail_http_client.send_post("close_run/#{run_id}", {})
    end

    def create_test_case(section_id:, name:)
      @testrail_http_client.send_post("add_case/#{section_id}",
                                      title: name)
    end

    def create_section(project_id:, suite_id:, section_name:)
      @testrail_http_client.send_post("add_section/#{project_id}",
                                      suite_id: suite_id,
                                      name: section_name)
    end

    def get_sections(project_id:, suite_id:)
      @testrail_http_client.send_get("get_sections/#{project_id}\&suite_id=#{suite_id}")
    end

    def get_test_cases(project_id:, suite_id:)
      @testrail_http_client.send_get("get_cases/#{project_id}&suite_id=#{suite_id}")
    end

    def submit_test_result(run_id:, test_case_id:, status_id:, comment: nil)
      @testrail_http_client.send_post("add_result_for_case/#{run_id}/#{test_case_id}",
                                      status_id: status_id,
                                      comment: comment)
    end

    def submit_test_results(run_id:, results:)
      @testrail_http_client.send_post("add_results_for_cases/#{run_id}", { results: results })
    end

  end

end

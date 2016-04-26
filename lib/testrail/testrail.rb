module TestRail

  class TestResult

    STATUS_SUCCESS = 1
    STATUS_ERROR = 5

    attr_reader :comment
    attr_reader :success
    alias_method :success?, :success

    def initialize(test_case:, success:, comment:)
      @test_case = test_case
      @success = success
      @comment = comment
    end

    def status_id
      success? ? STATUS_SUCCESS : STATUS_ERROR
    end

    def to_hash
      {
        'case_id': @test_case.id,
        'status_id': status_id,
        'comment': comment
      }
    end

  end

  class TestRun

    def initialize(suite:, id:)
      @suite = suite
      @id = id
      @results = []
    end

    def add_test_result(section_name:, test_name:, success:, comment: nil)
      @results << @suite
        .get_or_create_section(section_name)
        .get_or_create_test_case(test_name)
        .create_result(success: success, comment: comment)
    end

    def submit_results
      @suite.submit_test_results(run_id: @id, results: @results)
    end

    def close
      @suite.close_test_run(@id)
    end

    def failure_count
      @results.count { |r| !r.success? }
    end

  end

  class TestCase

    attr_reader :id, :name, :section

    def initialize(id:, name:, section:, testrail_client:)
      fail(ArgumentError, 'test case id nil') if id.nil?
      fail(ArgumentError, 'test case name nil') if name.nil?
      @id = id
      @name = name
      @section = section
      @testrail_client = testrail_client
    end

    def create_result(success:, comment:)
      TestResult.new(test_case: self, success: success, comment: comment)
    end

  end

  class TestSection

    attr_reader :id, :name

    def initialize(id:, name:, test_suite:)
      fail(ArgumentError, 'section id nil') if id.nil?
      fail(ArgumentError, 'section name nil') if name.nil?
      @id = id
      @name = name
      @test_suite = test_suite
    end

    def get_or_create_test_case(name)
      @test_suite.get_or_create_test_case(section_id: @id, name: name)
    end

  end

  class TestSuite

    def initialize(project_id:, suite_id:, testrail_client:)
      @project_id = project_id
      @suite_id = suite_id
      @testrail_client = testrail_client
      sections = testrail_client.get_sections(project_id: project_id, suite_id: suite_id)
                 .map { |s| new_test_section(s) }
      @sections_by_name = Hash[sections.map { |s| [s.name, s] }]
      @sections_by_id = Hash[sections.map { |s| [s.id, s] }]
      @test_cases = Hash[testrail_client.get_test_cases(project_id: project_id, suite_id: suite_id)
                         .lazy
                         .map { |t| new_test_case(t) }
                         .map { |t| [test_case_key(t.section.id, t.name), t] }
                         .to_a]
    end

    def start_test_run
      run = @testrail_client.start_test_run(project_id: @project_id, suite_id: @suite_id)
      TestRun.new(suite: self, id: run['id'])
    end

    def submit_test_results(run_id:, results:)
      @testrail_client.submit_test_results(run_id: run_id, results: results.map(&:to_hash))
    end

    def close_test_run(run_id)
      @testrail_client.close_test_run(run_id)
    end

    def get_or_create_section(section_name)
      @sections_by_name[section_name] || create_section(section_name)
    end

    def get_or_create_test_case(section_id:, name:)
      @test_cases[test_case_key(section_id, name)] || create_test_case(section_id: section_id, name: name)
    end

    def create_section(section_name)
      section = new_test_section(@testrail_client.create_section(
                                   project_id: @project_id,
                                   suite_id: @suite_id,
                                   section_name: section_name))
      @sections_by_name[section_name] = section
      @sections_by_id[section.id] = section
    end

    def create_test_case(section_id:, name:)
      test_case = new_test_case(@testrail_client.create_test_case(
                                  section_id: section_id,
                                  name: name))
      @test_cases[test_case_key(test_case.section.id, test_case.name)] = test_case
    end

    private

    def test_case_key(section_id, name)
      { s: section_id, n: name }
    end

    def new_test_section(section)
      TestSection.new(
        id: section['id'],
        name: section['name'],
        test_suite: self)
    end

    def new_test_case(test_case)
      TestCase.new(
        id: test_case['id'],
        name: test_case['title'],
        section: @sections_by_id[test_case['section_id']],
        testrail_client: @testrail_client)
    end

  end

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

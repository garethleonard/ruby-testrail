module TestRail

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

end

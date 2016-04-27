module TestRail

  class TestResult

    STATUS_SUCCESS = 1
    STATUS_ERROR = 5

    attr_reader :comment
    attr_reader :success
    alias success? success

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

end

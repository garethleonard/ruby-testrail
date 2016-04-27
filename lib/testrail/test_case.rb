require 'testrail/test_result'

module TestRail

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

end

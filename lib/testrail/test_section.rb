module TestRail

  class TestSection

    attr_reader :id, :name

    def initialize(id:, name:, test_suite:)
      raise(ArgumentError, 'section id nil') if id.nil?
      raise(ArgumentError, 'section name nil') if name.nil?
      @id = id
      @name = name
      @test_suite = test_suite
    end

    def get_or_create_test_case(name)
      @test_suite.get_or_create_test_case(section_id: @id, name: name)
    end

  end

end

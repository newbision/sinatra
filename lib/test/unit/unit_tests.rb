require_relative '../helpers/unit_helper'

class UnitTests < Minitest::Test
    def setup
     	#none
    end

    def test_tests
    	assert_equal "Test","Test"
    end
end
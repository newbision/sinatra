require_relative '../helpers/acceptance_helper' # require the helper

class AcceptanceTests < Minitest::Test
  include Capybara::DSL # gives you access to visit, etc.

  def test_status_page_displays
    visit '/status'
    assert page.has_content?("HTML")
  end

end
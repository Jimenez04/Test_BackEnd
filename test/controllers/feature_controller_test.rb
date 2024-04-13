require "test_helper"

class FeatureControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get feature_index_url
    assert_response :success
  end

  test "should get get" do
    get feature_get_url
    assert_response :success
  end
end

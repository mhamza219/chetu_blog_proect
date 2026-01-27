require "test_helper"

class PaymentStatusPageControllerTest < ActionDispatch::IntegrationTest
  test "should get success" do
    get payment_status_page_success_url
    assert_response :success
  end

  test "should get cancel" do
    get payment_status_page_cancel_url
    assert_response :success
  end
end

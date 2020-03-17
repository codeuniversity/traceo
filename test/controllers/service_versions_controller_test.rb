require "test_helper"

class ServiceVersionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @service_version = service_versions(:one)
  end

  test "should get index" do
    get service_versions_url, as: :json
    assert_response :success
  end

  test "should create service_version" do
    assert_difference("ServiceVersion.count") do
      post service_versions_url, params: { service_version: { service_id: @service_version.service_id, version: @service_version.version } }, as: :json
    end

    assert_response 201
  end

  test "should show service_version" do
    get service_version_url(@service_version), as: :json
    assert_response :success
  end

  test "should update service_version" do
    patch service_version_url(@service_version), params: { service_version: { service_id: @service_version.service_id, version: @service_version.version } }, as: :json
    assert_response 200
  end

  test "should destroy service_version" do
    assert_difference("ServiceVersion.count", -1) do
      delete service_version_url(@service_version), as: :json
    end

    assert_response 204
  end
end

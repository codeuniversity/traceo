require 'test_helper'

class TracesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @trace = traces(:one)
  end

  test "should get index" do
    get traces_url, as: :json
    assert_response :success
  end

  test "should create trace" do
    assert_difference('Trace.count') do
      post traces_url, params: { trace: { request: @trace.request, response: @trace.response, response_ts: @trace.response_ts, resquest_ts: @trace.resquest_ts, service_version_id: @trace.service_version_id } }, as: :json
    end

    assert_response 201
  end

  test "should show trace" do
    get trace_url(@trace), as: :json
    assert_response :success
  end

  test "should update trace" do
    patch trace_url(@trace), params: { trace: { request: @trace.request, response: @trace.response, response_ts: @trace.response_ts, resquest_ts: @trace.resquest_ts, service_version_id: @trace.service_version_id } }, as: :json
    assert_response 200
  end

  test "should destroy trace" do
    assert_difference('Trace.count', -1) do
      delete trace_url(@trace), as: :json
    end

    assert_response 204
  end
end

require "rails_helper"

RSpec.describe "Traces", type: :request do
  describe "GET /traces" do
    context "with no traces in the DB"
    it "returns an empty traces list" do
      get traces_path
      expect(response).to have_http_status(200)
      json_body = JSON.parse(response.body)
      expect(json_body).to match({ "data" => [] })
    end
  end

  describe "POST /traces" do
    context "given all required parameters" do
      let(:trace_body) do
        {
          service: "test_service",
          service_version: "0.0.1",
          request: {
            some_key: "some_value",
          },
          response: {
            good_key: 123456,
          },
          request_ts: 123456789.5,
          response_ts: 123456791.5,
        }
      end
      it "creates the trace" do
        post traces_path, params: trace_body, as: :json
        expect(response).to have_http_status(201)
      end
    end

    context "with missing attributes" do
      let(:trace_body) do
        {
          service: "test_service",
          service_version: "0.0.1",
        }
      end

      it "returns 422 with the validation errors" do
        post traces_path, params: trace_body, as: :json
        expect(response).to have_http_status(422)
        json_body = JSON.parse(response.body)
        expect(json_body).to match({
          "request_ts" => ["can't be blank"],
          "response_ts" => ["can't be blank"],
          "request" => ["can't be blank"],
          "response" => ["can't be blank"],
        })
      end
    end

    context "with missing service" do
      let(:trace_body) do
        {
          service_version: "0.0.1",
          request: {
            some_key: "some_value",
          },
          response: {
            good_key: 123456,
          },
          request_ts: 123456789.5,
          response_ts: 123456791.5,
        }
      end

      it "returns 422 with the validation errors" do
        post traces_path, params: trace_body, as: :json
        expect(response).to have_http_status(422)
        json_body = JSON.parse(response.body)
        expect(json_body).to match({
          "service" => ["can't be blank"],
          "service_version" => ["must exist"],
        })
      end
    end

    context "with missing service_version" do
      let(:trace_body) do
        {
          service: "test_service",
          request: {
            some_key: "some_value",
          },
          response: {
            good_key: 123456,
          },
          request_ts: 123456789.5,
          response_ts: 123456791.5,
        }
      end

      it "returns 422 with the validation errors" do
        post traces_path, params: trace_body, as: :json
        expect(response).to have_http_status(422)
        json_body = JSON.parse(response.body)
        expect(json_body).to match({ "service_version" => ["must exist"] })
      end
    end
  end
end

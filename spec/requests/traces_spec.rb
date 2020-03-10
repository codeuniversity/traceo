require "rails_helper"

RSpec.describe "Traces", type: :request do
  def construct_trace(attributes)
    default_attributes = { request: { some_key: "foo" }, response: { some_other_key: "bar" }, request_ts: Time.zone.now, response_ts: Time.zone.now + 10.seconds }
    Trace.create(default_attributes.merge(attributes))
  end

  describe "GET /traces" do
    let(:service) { Service.create(name: "test_service_name") }
    let(:service_version) { ServiceVersion.create(service: service, version: "0.0.1") }

    context "with no traces in the DB" do
      it "returns an empty traces list" do
        get traces_path
        expect(response).to have_http_status(200)
        json_body = JSON.parse(response.body)
        expect(json_body).to match({ "data" => [] })
      end
    end

    context "given a ?limit param" do
      let(:limit) { 2 }

      context "when there are more than limit traces" do
        before do
          3.times do
            construct_trace(service_version: service_version)
          end
        end

        it "returns limit traces" do
          get traces_path, params: { limit: limit }
          expect(response).to have_http_status(200)
          json_body = JSON.parse(response.body)

          expect(json_body["data"].length).to eq(2)
        end
      end

      context "when there are less than limit traces" do
        before do
          construct_trace(service_version: service_version)
        end

        it "returns all traces" do
          get traces_path, params: { limit: limit }
          expect(response).to have_http_status(200)
          json_body = JSON.parse(response.body)
          expect(json_body["data"].length).to eq(1)
        end
      end
    end

    context "given a ?newer_than param" do
      let (:newer_than) { Time.zone.parse("2020-02-14 12:31") }

      context "when some traces have a newer request_ts than the newer_than" do
        before do
          2.times { |i| construct_trace(service_version: service_version, request_ts: newer_than - 10.seconds - i * 1.seconds) }
          2.times { |i| construct_trace(service_version: service_version, request_ts: newer_than + 10.seconds + i * 1.seconds) }
        end

        it "returns the traces that have a newer request_ts ordered by request_ts" do
          get traces_path, params: { newer_than: newer_than }
          expect(response).to have_http_status(200)
          json_body = JSON.parse(response.body)
          expect(json_body["data"].length).to eq(2)
          expect(json_body["data"][1]["attributes"]["request_ts"]).to eq((newer_than + 11.seconds).as_json)
        end
      end

      context "when all traces have a newer request_ts than the newer_than" do
        before do
          4.times { |i| construct_trace(service_version: service_version, request_ts: newer_than + 10.seconds + i * 1.seconds) }
        end

        it "returns all traces ordered by request_ts" do
          get traces_path, params: { newer_than: newer_than }
          expect(response).to have_http_status(200)
          json_body = JSON.parse(response.body)
          expect(json_body["data"].length).to eq(4)
          expect(json_body["data"][3]["attributes"]["request_ts"]).to eq((newer_than + 13.seconds).as_json)
        end
      end

      context "when no traces have a newer request_ts than the newer_than" do
        it "returns no traces" do
          get traces_path, params: { newer_than: newer_than }
          expect(response).to have_http_status(200)
          json_body = JSON.parse(response.body)
          expect(json_body["data"].length).to eq(0)
        end
      end
    end

    describe "filter query params" do
      let(:service_version2) { ServiceVersion.create(service: service, version: "0.0.2") }
      let(:other_service) { Service.create(name: "other_service_name") }
      let(:other_service_version) { ServiceVersion.create(service: other_service, version: "0.0.11") }

      before do
        2.times { |i| construct_trace(service_version: service_version) }
        3.times { |i| construct_trace(service_version: service_version2) }
        3.times { |i| construct_trace(service_version: other_service_version) }
      end

      context "given a ?service param" do
        it "returns the traces belonging to the given service" do
          get traces_path, params: { service: "test_service_name" }
          expect(response).to have_http_status(200)
          json_body = JSON.parse(response.body)
          expect(json_body["data"].length).to eq(5)

          json_body["data"].each do |trace|
            expect(trace["relationships"]["service"]["data"]["id"]).to eq(service.id.to_s)
          end
        end
      end

      context "given a ?service_version param without a ?service param" do
        it "returns all traces ignoring the ?service_version param " do
          get traces_path, params: { service_version: "0.0.2" }
          expect(response).to have_http_status(200)
          json_body = JSON.parse(response.body)
          expect(json_body["data"].length).to eq(8)
        end
      end

      context "given a ?service and a ?service_version param" do
        it "returns the traces belonging to the specified service and version" do
          get traces_path, params: { service: "test_service_name", service_version: "0.0.2" }
          expect(response).to have_http_status(200)
          json_body = JSON.parse(response.body)
          expect(json_body["data"].length).to eq(3)

          json_body["data"].each do |trace|
            expect(trace["relationships"]["service"]["data"]["id"]).to eq(service.id.to_s)
            expect(trace["relationships"]["service_version"]["data"]["id"]).to eq(service_version2.id.to_s)
          end
        end
      end
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

class TraceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :request, :response, :request_ts, :response_ts, :created_at
  belongs_to :service_version
  belongs_to :service
end

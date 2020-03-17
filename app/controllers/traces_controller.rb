class TracesController < ApplicationController
  before_action :set_trace, only: [:show]

  # GET /traces
  def index
    @traces = add_query_filter(
      Trace
        .includes(:service_version, :service)
        .order(request_ts: :asc)
        .where("request_ts > ?", newer_than)
    )
      .limit(limit)

    render json: serializable_hash(@traces)
  end

  # GET /traces/1
  def show
    render json: serializable_hash(@trace)
  end

  # POST /traces
  def create
    @trace = construct_trace

    if @trace.save
      render json: serializable_hash(@trace), status: :created, location: @trace
    else
      render json: @trace.errors, status: :unprocessable_entity
    end
  end

  private

  def limit
    params[:limit].present? && params[:limit].to_i > 0 ? params[:limit].to_i : 1000
  end

  def newer_than
    params[:newer_than].present? ? Time.zone.parse(params[:newer_than]) : Time.zone.at(0)
  rescue ArgumentError
    Time.zone.at(0)
  end

  def add_query_filter(original_query)
    service = params[:service]
    service_version = params[:service_version]

    if service.present?
      version_filter = { services: { name: service } }
      version_filter.merge!(version: service_version) if service_version.present?

      original_query
        .joins(service_version: :service)
        .where(service_versions: version_filter)
    else
      original_query
    end
  end

  def construct_trace
    @service = Service.find_or_create_by(name: trace_params[:service]) if trace_params[:service].present?

    @service_version = ServiceVersion.find_or_create_by(service: @service, version: trace_params[:service_version]) if @service.present? && trace_params[:service_version].present?

    request_ts = Time.zone.at(trace_params[:request_ts]) unless trace_params[:request_ts].nil?
    response_ts = Time.zone.at(trace_params[:response_ts]) unless trace_params[:response_ts].nil?

    Trace.new(trace_params.merge({
      service: @service,
      service_version: @service_version,
      request_ts: request_ts,
      response_ts: response_ts,
    }))
  end

  def serializable_hash(resource)
    TraceSerializer.new(resource).serializable_hash
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_trace
    @trace = Trace.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def trace_params
    params.permit(:request_ts, :response_ts, :service, :service_version, request: {}, response: {})
  end
end

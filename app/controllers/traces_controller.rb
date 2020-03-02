class TracesController < ApplicationController
  before_action :set_trace, only: [:show, :update, :destroy]

  # GET /traces
  def index
    @traces = Trace.all.includes(:service_version, :service)

    render json: serializable_hash(@traces)
  end

  # GET /traces/1
  def show
    render json: @trace
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

  # PATCH/PUT /traces/1
  def update
    if @trace.update(trace_params)
      render json: serializable_hash(@trace)
    else
      render json: @trace.errors, status: :unprocessable_entity
    end
  end

  # DELETE /traces/1
  def destroy
    @trace.destroy
  end

  private

  def construct_trace
    @service = Service.find_or_create_by(name: trace_params[:service])

    @service_version = ServiceVersion.find_or_create_by(service: @service, version: trace_params[:service_version])

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

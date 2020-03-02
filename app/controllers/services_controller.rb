class ServicesController < ApplicationController
  before_action :set_service, only: [:show]

  # GET /services
  def index
    @services = Service.all

    render json: serializable_hash(@services)
  end

  # GET /services/1
  def show
    render json: serializable_hash(@service)
  end

  # POST /services
  def create
    @service = Service.new(service_params)

    if @service.save
      render json: serializable_hash(@service), status: :created, location: @service
    else
      render json: @service.errors, status: :unprocessable_entity
    end
  end

  private

  def serializable_hash(resource)
    ServiceSerializer.new(resource).serializable_hash
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_service
    @service = Service.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def service_params
    params.require(:service).permit(:name)
  end
end

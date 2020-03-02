class ServiceVersionsController < ApplicationController
  before_action :set_service_version, only: [:show]

  # GET /service_versions
  def index
    @service_versions = ServiceVersion.all

    render json: @service_versions
  end

  # GET /service_versions/1
  def show
    render json: @service_version
  end

  # POST /service_versions
  def create
    @service_version = ServiceVersion.new(service_version_params)

    if @service_version.save
      render json: @service_version, status: :created, location: @service_version
    else
      render json: @service_version.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_service_version
    @service_version = ServiceVersion.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def service_version_params
    params.require(:service_version).permit(:version, :service_id)
  end
end

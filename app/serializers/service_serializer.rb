class ServiceSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :created_at
  has_many :service_versions
end

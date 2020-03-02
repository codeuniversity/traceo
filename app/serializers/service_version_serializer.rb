class ServiceVersionSerializer
  include FastJsonapi::ObjectSerializer
  attributes :version, :created_at
  belongs_to :service
end

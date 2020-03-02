class Trace < ApplicationRecord
  belongs_to :service_version
  has_one :service, through: :service_version

  validates :request, presence: true
  validates :response, presence: true
  validates :request_ts, presence: true
  validates :response_ts, presence: true
end

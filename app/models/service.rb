class Service < ApplicationRecord
  has_many :service_versions

  validates :name, presence: true, uniqueness: true
end

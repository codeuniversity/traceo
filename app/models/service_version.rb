class ServiceVersion < ApplicationRecord
  belongs_to :service

  validates :version, presence: true, uniqueness: true
end

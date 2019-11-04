class ProviderLocation < ApplicationRecord
  belongs_to :provider
  belongs_to :location
end

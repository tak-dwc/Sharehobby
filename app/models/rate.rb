class Rate < ApplicationRecord
  belongs_to :member
  belongs_to :request
end

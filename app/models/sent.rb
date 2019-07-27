class Sent < ApplicationRecord
  belongs_to :user
  belongs_to :fixture
end

class Player < ApplicationRecord
  belongs_to :league
  belongs_to :user

  validates_uniqueness_of :user_id, scope: :league_id
  validates :user_id, :league_id, presence: true
  validates :request_state, inclusion: %w[requested accepted rejected baned]
  validates :access, inclusion: %w[admin player primary]
end

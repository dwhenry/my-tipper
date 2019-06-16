require 'securerandom'

class League < ActiveRecord::Base
  ALL_PLAYERS = 'All players'.freeze

  has_many :players
  has_many :users, through: :players
  has_many :fixtures, foreign_key: :event, primary_key: :name

  validates_uniqueness_of :name

  def create(current_user)
    League.transaction do
      self.code = SecureRandom.hex
      save || raise(ActiveRecord::Rollback)
      players.create(user_id: current_user.id) || raise(ActiveRecord::Rollback)
      return true
    end
    return false
  end
end

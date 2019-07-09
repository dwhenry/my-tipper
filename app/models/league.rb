require 'securerandom'

class League < ActiveRecord::Base
  ALL_PLAYERS = 'All players'.freeze

  has_many :players
  has_many :users, through: :players
  has_many :fixtures, foreign_key: :event, primary_key: :name

  validates :name, uniqueness: { if: -> { self.name.present? } }, presence: true
  validates :prize, absence: { if: -> { self.public }, message: 'can only be set for private leagues' }
  validates :requirements, absence: { if: -> { self.public }, message: 'can only be set for private leagues' }
  validates :confirmation_required, absence: { if: -> { self.requirements.blank? }, message: 'can only be set for leagues with requirements' }

  def create(current_user)
    League.transaction do
      self.code = SecureRandom.hex
      save || raise(ActiveRecord::Rollback)
      players.create(user_id: current_user.id, request_state: 'accepted', access: 'primary') || raise(ActiveRecord::Rollback)
      return true
    end
    return false
  end
end

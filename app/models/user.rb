class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :name

  has_many :picks
  has_many :players
  has_many :non_event_leagues, -> { where(leagues: {event: false}) }, through: :players, source: :league
  has_many :leagues, through: :players
end

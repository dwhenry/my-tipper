class Fixture < ApplicationRecord
  belongs_to :home, class_name: 'TeamWrapper'
  belongs_to :away, class_name: 'TeamWrapper'
  has_many :picks

  validate :allowed_to_edit_result_value?
  def self.last_fixture(event)
    where(['at < ?', Time.now])
    .order('at desc')
    .where(event: event)
      .where.not(result: nil)
    .first
  end

  def pick(user)
    picks.detect{ |p| p.user_id == user.id } || Pick.new
  end

  def next
    Fixture.where(['at > ?', at]).where(event: event).order(:at).first
  end

  def previous
    Fixture.where(['at < ?', at]).where(event: event).order('at DESC').first
  end

  def update_result(result)
    Fixture.transaction do
      self.result = result
      self.save!

      users_without_picks = User.pluck(:id) - User.joins(picks: :fixture).where(fixtures: {id: id}).pluck(:id)
      users_without_picks.each {|u| picks.create!(user_id: u, pick: 0, force_write: true)}

      picks.reload.each do |pick|
        pick.score = score_for(pick.pick, result)
        pick.save!
      end
    end
  end

  private

  def allowed_to_edit_result_value?
    if at >= Time.now.utc && changed.include?('result')
      errors.add(:result, 'can not yet be edited')
    end
  end

  def score_for(pick, result)
    if pick == 0 # player must pick a score
      result.abs + 20
    elsif pick == result
      return -10
    elsif result == 0 # player must pick a score
      pick.abs
    elsif (pick / pick.abs) == (result / result.abs)
      (pick - result).abs
    else
      pick.abs + result.abs + 5
    end
  end
end

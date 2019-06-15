class TeamWrapper < ActiveRecord::Base
  belongs_to :team
  delegate :short_name, to: :team, allow_nil: true

  scope :for_event, ->(event) {
    joins(%{
      JOIN fixtures
        ON fixtures.home_id = team_wrappers.id OR fixtures.away_id = team_wrappers.id
    }).where(['fixtures.event = ?', event])
  }

  def name
    names = [
      attributes["name"],
      team.try(:name)
    ].compact
    if names.length > 1
      %{
      <div style='display: inline-block'>
        #{names.join('<br>')}
      </div>
      }.html_safe
    else
      names.first
    end
  end

  def real_name
    team.try(:name) || attributes["name"]
  end

  def wrapper_name
    attributes["name"]
  end

  def fixture
    Fixture.where(['home_id = ? or away_id = ?', id, id]).first
  end

  def image
    team.try(:image) || attributes["image"]
  end
end

class Fixtures2019 < ActiveRecord::Migration
  def up
    League.find_or_create_by!(name: '2019', event: true)

    data = File.read(Rails.root.join('db/migrate/data/2019-fixtures'))
    data.split("\n").each do |line|
      next if line.blank?
      if line =~ /POOL (.)/
        pool = $1
        next
      end
      if m = line.match(/(...) (\d\d) (...) (.*) v (.*) \((.*)\), (.*)/)
        home = get_wrap(m[4])
        away = get_wrap(m[5])
        time = Time.parse("#{m[2]}-#{m[3]}-2019 #{m[7].tr('.', ':')}")
        Fixture.find_or_create_by!(event: '2019', home_id: home.id, away_id: away.id, venue: m[6], at: time, round: '1')
      end
    end

    home = get_wrap('Runner-up SF1')
    away = get_wrap('Runner-up SF2')
    time = Time.parse("1-Nov-2019 9am")
    Fixture.find_or_create_by!(event: '2019', home_id: home.id, away_id: away.id, venue: 'Tokyo', at: time, round: '1')

    home = get_wrap('Winner SF1')
    away = get_wrap('Winner SF2')
    time = Time.parse("2-Nov-2019 9am")
    Fixture.find_or_create_by!(event: '2019', home_id: home.id, away_id: away.id, venue: 'Yokohama', at: time, round: '1')
  end

  def down
    Fixture.where(event: '2019').delete_all
    TeamWrapper.where.not(id: Fixture.pluck(:home_id) | Fixture.pluck(:away_id)).delete_all
  end

  def get_wrap(name)
    if name =~ /^(QF\d |Runner-|Winner)/
      name.gsub!(/^QF\d /, '')
      TeamWrapper.find_or_create_by!(name: name)
    else
      home = Team.find_or_create_by!(name: name)
      TeamWrapper.find_or_create_by!(team_id: home.id, name: nil)
    end
  end
end


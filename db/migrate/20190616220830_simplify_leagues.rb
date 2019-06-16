class SimplifyLeagues < ActiveRecord::Migration
  def change
    leagues = League.where(event: true).to_a

    league = leagues.shift
    users = leagues.map(&:users).flatten.uniq

    leagues.each do |l|
      next if l == league
      l.players.delete_all
      l.delete
    end

    league.update!(name: League::ALL_PLAYERS)
    users -= league.users
    users.each do |user|
      Player.create!(user: user, league: league)
    end
  end
end

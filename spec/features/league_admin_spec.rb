require 'rails_helper'

RSpec.describe 'League admin' do
  let(:user) { create(:user) }
  let(:league) { create(:league, :confirmation_required) }
  let(:admin) { league.players.where(access: 'primary').first.user }

  it 'I can create a new league' do
    logged_in_as(user) do
      visit new_league_path

      fill_in 'league_name', with: 'Test League'
      click_on 'Create league'
    end

    expect(League.last).to have_attributes(name: 'Test League')
  end

  context 'when confirmation required' do
    it 'request and approval to joining a league' do
      logged_in_as(user) do
        visit join_league_path(id: league.code)
      end

      player_request = Player.find_by(user_id: user.id)

      expect(player_request.request_state).to eq('requested')

      logged_in_as(admin) do
        visit view_league_path(league)

        within '.player--requested', text: user.name do
          click_on 'Approve'
        end
      end

      player_request.reload

      expect(player_request.request_state).to eq('accepted')
    end

    it 'request and reject to joining a league - can request again' do
      logged_in_as(user) do
        visit join_league_path(id: league.code)
      end

      player_request = Player.find_by(user_id: user.id)

      expect(player_request.request_state).to eq('requested')

      logged_in_as(admin) do
        visit view_league_path(league)

        within '.player--requested', text: user.name do
          click_on 'Reject'
        end
      end

      player_request.reload

      expect(player_request.request_state).to eq('rejected')

      logged_in_as(user) do
        visit join_league_path(id: league.code)
      end

      player_request.reload

      expect(player_request.request_state).to eq('requested')
    end

    it 'can not see leagues you have been baned from' do
      logged_in_as(user) do
        visit join_league_path(id: league.code)
      end

      player_request = Player.find_by(user_id: user.id)

      expect(player_request.request_state).to eq('requested')

      logged_in_as(admin) do
        visit view_league_path(league)

        within '.player--requested', text: user.name do
          click_on 'Bane'
        end
      end

      player_request.reload

      expect(player_request.request_state).to eq('baned')

      logged_in_as(user) do
        visit join_league_path(id: league.code)
      end

      player_request.reload

      expect(player_request.request_state).to eq('baned')

      logged_in_as(user) do
        visit leagues_path

        expect(page).to have_no_content(league.name)
      end
    end

    it 'can be removed from the league they have previously been accepted into' do
      player_request = Player.create!(user_id: user.id, league_id: league.id, request_state: 'accepted', access: 'player')

      logged_in_as(admin) do
        visit view_league_path(league)

        within '.player', text: user.name do
          click_on 'Remove'
        end
      end

      player_request.reload

      expect(player_request.request_state).to eq('rejected')
    end

    it 'can be baned from the league they have previously been accepted into' do
      player_request = Player.create!(user_id: user.id, league_id: league.id, request_state: 'accepted', access: 'player')

      logged_in_as(admin) do
        visit view_league_path(league)

        within '.player', text: user.name do
          click_on 'Bane'
        end
      end

      player_request.reload

      expect(player_request.request_state).to eq('baned')
    end
  end

  context 'when confirmation not required' do
    let(:league) { create(:league) }

    it 'can join the league'
    it 'can not be removed from league'
    it 'can not be baned from league'
  end

  it 'can be made admin of a league' do
    player_request = Player.create!(user_id: user.id, league_id: league.id, request_state: 'accepted', access: 'player')

    logged_in_as(admin) do
      visit view_league_path(league)

      within '.player', text: user.name do
        click_on 'Make Admin'
      end
    end

    player_request.reload

    expect(player_request.access).to eq('admin')
  end
end

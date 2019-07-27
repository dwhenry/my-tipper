require 'rails_helper'

RSpec.describe 'League admin' do
  let(:user) { create(:user) }

  it 'I can create a new league' do
    logged_in_as(user) do
      visit new_league_path

      fill_in 'league_name', with: 'Test League'
      click_on 'Create league'
    end

    expect(League.last).to have_attributes(name: 'Test League')
  end

  context 'when confirmation required' do
    let!(:league) { create(:league, :confirmation_required) }
    let(:admin) { league.players.where(access: 'primary').first.user }

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

    it 'request and reject to joining a league'
    it 'can not see leagues you have been baned from'
  end

  context 'when confirmation required' do
    it 'can join the league'
    it 'can be removed from the league'
  end

  it 'can be made admin of a league'
end

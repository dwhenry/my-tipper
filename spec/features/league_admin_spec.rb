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
    it 'request and approval to joining a league'
    it 'request and reject to joining a league'
  end

  context 'when confirmation required' do
    it 'can join the league'
    it 'can be removed from the league'
  end

  it 'can be made admin of a league'
end

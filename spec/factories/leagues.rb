FactoryBot.define do
  factory :league do
    sequence(:name) { |n| "League_#{n}" }
    code { SecureRandom.uuid }

    trait :confirmation_required do
      add_attribute(:public) { false }
      requirements { 'Do something nice' }
      confirmation_required { true }

      after(:create) do |league, _evaluator|
        league.players.create!(user: FactoryBot.create(:user), access: 'primary')
      end
    end
  end
end

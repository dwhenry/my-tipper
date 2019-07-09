class BetterLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :prize, :text
    add_column :leagues, :requirements, :text

    add_column :leagues, :confirmation_required, :boolean, default: false
    add_column :players, :request_state, :text, default: 'accepted' # [requested accepted rejected banned]
    add_column :players, :access, :text, default: :player # [primary admin player]

    League.reset_column_information
    League.all.each { |l| l.players.order(:id).first.try(:update, access: 'primary') } # set the first player to be admin
  end
end

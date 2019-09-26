class AddResultsSetterToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :result_setter, :boolean, default: false
    User.reset_column_information

    User.where(email: ['dw_henry@yahoo.com.au', 'robinharrison@me.com', 'moorak2@bigpond.com']).update_all(result_setter: true)
  end
end

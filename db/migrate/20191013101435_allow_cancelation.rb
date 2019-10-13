class AllowCancelation < ActiveRecord::Migration[5.2]
  def change
    add_column :fixtures, :cancelled, :boolean, default: false
  end
end

class AddYear < ActiveRecord::Migration
  def self.up
    add_column :tracks, :trackYear, :integer
  end

  def self.down
    remove_column :tracks, :trackYear
  end
end

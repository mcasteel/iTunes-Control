class AddCompilation < ActiveRecord::Migration
  def self.up
    add_column :artists, :compilation, :boolean
    add_column :albums, :compilation, :boolean
    add_column :tracks, :compilation, :boolean
  end

  def self.down
    remove_column :artists, :compilation
    remove_column :albums, :compilation
    remove_column :tracks, :compilation
  end
end

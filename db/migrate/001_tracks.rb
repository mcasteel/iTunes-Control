class Tracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |table|
      table.column :artist_id, :integer
      table.column :album_id, :integer
      table.column :genre_id, :integer
      table.column :trackID, :integer
      table.column :trackName, :string
      table.column :trackDuration, :integer
      table.column :trackLocation, :string, :limit => 2048
      table.column :trackSize, :integer
      table.column :trackNumber, :integer
    end
    
    add_index :tracks, :trackID
    
  end

  def self.down
    drop_table :tracks
  end
end

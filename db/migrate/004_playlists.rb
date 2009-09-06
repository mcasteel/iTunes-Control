class Playlists < ActiveRecord::Migration
  def self.up
    create_table :playlists do |table|
      table.column :playlistName, :string
    end
    create_table :playlists_tracks, :id => false do |table|
      table.column :playlist_id, :integer
      table.column :track_id, :integer
    end
    
    add_index :playlists_tracks, :playlist_id
  end

  def self.down
    drop_table :playlists
    drop_table :playlists_tracks
  end
end

class GenreAlbumDateAdded < ActiveRecord::Migration
  def self.up
    add_column :tracks, :trackAdded, :datetime
    add_column :albums, :albumAdded, :datetime
    add_column :albums, :artist_id, :integer
    add_column :albums, :genre_id, :integer
  end

  def self.down
    remove_column :tracks, :trackAdded
    remove_column :albums, :albumAdded
    remove_column :albums, :artist_id
    remove_column :albums, :genre_id
  end
end

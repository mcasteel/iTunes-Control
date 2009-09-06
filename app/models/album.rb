# This class models the albums table and implements a cache so that successive
# references to an album do not involve more than one database access.
class Album < ActiveRecord::Base
  has_many :tracks, :order => "trackNumber"
  belongs_to :artist
  belongs_to :genre
  
  def self.create(*args)
    @myAlbum = super
  end
  
  def self.find_album(name)
    if @myAlbum.nil? || @myAlbum.albumName != name 
      @myAlbum = self.find_by_albumName(name)
    end
    @myAlbum
  end
end

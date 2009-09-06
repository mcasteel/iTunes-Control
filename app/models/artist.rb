# This class representing the artists table caches the latest row in an 
# attempt to optimize the database load from the iTunes music library, which
# tends to store tracks from a given CD together

class Artist < ActiveRecord::Base
  has_many :tracks
  has_many :albums, :through => :tracks, :uniq => true

  def self.create(*args)
    @myArtist = super
  end
  
  def self.find_artist(name)
    if @myArtist.nil? || @myArtist.artistName != name 
      @myArtist = self.find_by_artistName(name)
    end
    @myArtist
  end
end

# This class models the tracks from the iTunes music library, creating and 
# linking artist, genre and album entries accordingly.

class Track < ActiveRecord::Base
  belongs_to :album
  belongs_to :artist
  belongs_to :genre
  has_and_belongs_to_many :playlists
  
  # This method uses a hash of track properties as assembled in the music library
  # xml parser to create database rows for artist, album, genre and track.
  
  def self.newTrack(properties)
    albumName = properties['Album']
    artistName = properties['Artist']
    genreName = properties['Genre']
    addDate = properties['Date Added']
    compilation = properties['Compilation'] || false
    compilation |= genreName == 'Soundtrack'
    
    theArtist = unless artistName.blank?
      Artist.find_artist(artistName) || Artist.create(:artistName => artistName,
                                                      :compilation => compilation)
    end
    theGenre = unless genreName.blank?
      Genre.find_genre(genreName) || Genre.create(:genreName => genreName)
    end
    unless albumName.blank?
      theAlbum = Album.find_album(albumName)
      if theAlbum.nil?
        theAlbum = Album.new
        theAlbum.albumName = albumName
        theAlbum.compilation = false
        theAlbum.albumAdded = addDate
        theAlbum.artist = theArtist
        theAlbum.genre = theGenre
        theAlbum.save
      elsif theAlbum.artist != theArtist
        theAlbum.compilation = true
        theAlbum.save
      end
    end
    unless compilation
      if theArtist && theArtist.compilation
        theArtist.compilation = false
        theArtist.save
      end
    end
    theTrack = Track.new
    theTrack.album = theAlbum
    theTrack.artist = theArtist
    theTrack.genre = theGenre
    theTrack.trackName = properties["Name"]
    theTrack.trackDuration = properties["Total Time"]
    theTrack.trackLocation = properties["Location"]
    theTrack.trackSize = properties["Size"]
    theTrack.trackNumber = properties["Track Number"]
    theTrack.trackID = properties["Track ID"]
    theTrack.compilation = compilation
    theTrack.trackYear = properties["Year"]
    theTrack.trackAdded = addDate
    theTrack.save
  end

end

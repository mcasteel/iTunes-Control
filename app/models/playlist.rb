# This class models the playlists table, populating it using a filter to
# leave out specified playlists, e.g. 'Movies'

class Playlist < ActiveRecord::Base
  has_and_belongs_to_many :tracks
  
  EXCLUSIONS=['Library', 'Music', 'Front Row Playlist', 'Movies', 'Music Videos',
    'TempList', 'TV Shows']
  
  # This method accepts a hash of playlist properties and an array of track
  # numbers as assembled by the parser. If the playlist has not been excluded
  # by name, and there are tracks in the playlist, it populates the database
  # accordingly
    
  def self.newPlaylist(properties, tracks)
    theName = properties['Name']
    if !EXCLUSIONS.include?(theName) && !tracks.empty?
      thePlaylist = Playlist.create(:playlistName => theName)
      tracks.each do |trackNum|
        theTrack = Track.find_by_trackID(trackNum)
        thePlaylist.tracks << theTrack unless theTrack.nil?
      end
    end
  end
  
end

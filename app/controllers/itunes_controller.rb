# This is the controller class for the iTunes control application.

require 'itc'
require 'itcmonitor'

class ItunesController < ApplicationController

# The index method, the default URL, handles display of all artists who appear in
# any track which is NOT part of a compilation. Thus, an artist who appears only
# in a track or tracks from a soundtrack album will not be listed.
  
  def index
    @artists = Artist.find(:all, :conditions => 'compilation = false', :order => "artistName").map {|a| [a.artistName, a.id]}
    @state = currentState
    render :action => 'artists'
  end

# This method displays all artists, regardless of whether they only appear in
# compilations.

  def allartists
    @artists = Artist.find(:all, :order => "artistName").map {|a| [a.artistName, a.id]}
    @state = currentState
  end

# This method displays all albums which are not compilations.

  def albums
    @albums = Album.find(:all, :conditions => 'compilation = false', :order => "albumName").map {|a| [a.albumName, a.id]}
    @state = currentState
  end

# This method displays all albums which are compilations.
  
  def compilations
    @albums = Album.find(:all, :conditions => 'compilation = true', :order => "albumName").map {|a| [a.albumName, a.id]}
    @state = currentState
  end

# This method displays the 25 albums most recently added.

  def recent
    @recent = Album.find(:all, :order => "albumAdded DESC", :limit => '25').map {|a| [a.albumName, a.id]}
    @state = currentState
  end

# This method displays all playlists which appear in the database.
  
  def playlists
    @playlists = Playlist.find(:all, :order => "playlistName").map {|a| [a.playlistName, a.id]}
    @state = currentState
  end

# This method displays all genres which appear in the database.
  
  def genres
    @genres = Genre.find(:all, :order => "genreName").map {|a| [a.genreName, a.id]}
    @state = currentState
  end

  # This method handles a click on a link to play a track, album or playlist. As
  # an AJAX function, on completion it updates only the status display.
  
  def play
    case params[:type]
    when 'B'  # album
      # logger.info('Finding album')
      album = Album.find(params[:id])
      # logger.info('Playing album '+album.albumName)
      album.tracks.each {|trk| playTrack(trk)}
      # logger.info('Played album')
    when 'P'
      playlist = Playlist.find(params[:id])
      playlist.tracks.each {|trk| playTrack(trk)}
    else  # track
      # logger.info('Finding track')
      track = Track.find(params[:id])
      # logger.info('Playing track '+track.trackName)
      playTrack(track)
      # logger.info('Played track')
    end
    ITCMonitor.start
    updateStatus
  end

  # This method handles supplying details for the 'help balloon' where
  # provided for albums or tracks
  
  def details
    @details = {}
    case params[:type]
    when 'B' #album
      album = Album.find(params[:id])
      fillAlbumDetails(album, @details)
      genre = album.tracks[0].genre
      @details[:genre] = genre.nil? ? '' : genre.genreName
      if album.compilation
        @details[:artistName] = 'Various Artists'
      else
        @details[:artistName] = album.tracks[0].artist.artistName
      end
    else # track
      track = Track.find(params[:id])
      @details[:trackName] = track.trackName
      @details[:duration] = track.trackDuration / 1000
      fillAlbumDetails(track.album, @details)
      genre = track.genre
      @details[:genre] = genre.nil? ? '' : genre.genreName
      @details[:artistName] = track.artist.artistName
    end
    render :partial => 'details'
  end
  
  # This method handles the 'skip backwards' function. As an AJAX function, on 
  # completion it updates only the status display.
  
  def prevTrack
    ITC.backTrack
    updateStatus
  end
  
  # This method handles the 'skip forwards' function. As an AJAX function, on
  # completion it updates only the status display.
  
  def nextTrack
    ITC.nextTrack
    updateStatus
  end
  
  # This method handles the 'play' and 'pause' functions. If playing when the
  # player state is 'Stopped', it (re)starts the Monitor. As an AJAX function,
  # on completion it updates only the status display.
  
  def playPause
    curstate = ITC.getStatusText
    ITC.playPause
    ITCMonitor.start if curstate == 'Stopped'
    updateStatus
  end
  
  # This method handles the 'Clear' button. As an AJAX function, on completion
  # it updates only the status display.
  
  def clear
    cuelist = ITC.clearCueList
    updateStatus
  end
  
  # This method handles 'opening' the disclosure triangle by an artist, album,
  # genre or playlist and displaying the list of subsidiary items.
  
  def open
    case params[:type]
    when 'A'
      theArtist = Artist.find(params[:id])
      artists = Artist.find(:all, :conditions => "artistName like \"#{theArtist.artistName}%\"")
      albums = []
      artists.each do |artist|
        albs = artist.albums.map {|alb| [alb.albumName, alb.id]}
        albums.concat(albs)
      end
      albums.uniq!
      albums.sort! {|x,y| x[0] <=> y[0] }
      @sublist = {:title => [theArtist.artistName, theArtist.id], :type => 'A',
                    :list => albums, :subtype => 'B'}
    when 'B'
      album = Album.find(params[:id])
      tracks = album.tracks.map {|trk| [trk.trackName, trk.id, trk.trackNumber]}
      tracks.sort! {|x,y| x[2] <=> y[2]}
      @sublist = {:title => [album.albumName, album.id], :type => 'B',
                    :list => tracks, :subtype => 'T'}
    when 'G'
      genre = Genre.find(params[:id])
      albums = genre.albums.map {|alb| [alb.albumName, alb.id]}
      albums.sort! {|x,y| x[0] <=> y[0]}
      @sublist = {:title => [genre.genreName, genre.id], :type => 'G',
                    :list => albums, :subtype => 'B'}
    when 'P'
      playlist = Playlist.find(params[:id])
      tracks = playlist.tracks.map {|trk| [trk.trackName, trk.id]}
      @sublist = {:title => [playlist.playlistName, playlist.id], :type => 'P',
                    :list => tracks}
    end
    render :partial => 'sublist'
  end
  
  # This method handles 'closing' the disclosure triangle by an artist, album,
  # genre or playlist and hiding the list of subsidiary items.
  
  def close
    case params[:type]
    when 'A'
      artist = Artist.find(params[:id])
      @sublist = {:title => [artist.artistName, artist.id], :type => 'A'}
    when 'B'
      album = Album.find(params[:id])
      @sublist = {:title => [album.albumName, album.id], :type=> 'B'}
    when 'G'
      genre = Genre.find(params[:id])
      @sublist = {:title => [genre.genreName, genre.id], :type=> 'G'}
    when 'P'
      playlist = Playlist.find(params[:id])
      @sublist = {:title => [playlist.playlistName, playlist.id], :type=> 'P'}
    end
    render :partial => 'sublist'
  end
  
  def powerOn
    logger.info(ITC.powerON)
    updateStatus
  end
  
  def powerOff
    logger.info(ITC.powerOFF)
    updateStatus
  end
  
  def updateStatus
    @status = currentState
    render :partial => 'status'
  end
  
private
  def playTrack(trk)
    begin
      ITC.playTrack(trk.trackLocation)
    rescue
      logger.error("Error playing track #{trk.trackLocation}")
    end
  end
  
  def currentState
    theState = {:state => ITC.getStatusText}
    theState[:current] = ITC.getCurrent
    theState[:cuelist] = ITC.cueList
    theState[:timeleft] = ITC.getTimeLeft
    theState
  end
  
  def fillAlbumDetails(album, details)
    details[:albumName] = album.albumName
    details[:albumTracks] = album.tracks.length
    duration = 0
    album.tracks.each {|t| duration += t.trackDuration}
    details[:albumDuration] = duration / 1000
    details[:albumYear] = album.tracks[0].trackYear
  end
  
end

#!/usr/bin/env ruby
#
#  Created by Michael Casteel on 2007-07-26.
#  Copyright (c) 2007. All rights reserved.

require 'rubygems'
require 'appscript'
require 'uri'

class ITC
  @@iTunes = Appscript.app('iTunes')
  begin
    @@mylist = @@iTunes.sources[1].user_playlists['TempList'].get
  rescue Appscript::CommandError
    @@mylist = @@iTunes.make(:new => :playlist,
                             :with_properties => {:name => 'TempList'})
  end
  target = @@iTunes.sources[1].user_playlists['TempList']
  if @@mylist.tracks.get.length > 0 && 
      @@iTunes.player_state == 'stopped'
    target = target.tracks[1]
  end
  @@iTunes.reveal(target)
  
  @@iRed = Appscript.app('iRed')
  @@avp = @@iRed.RCs['AVP']
  @@powerOn = @@avp.Codes['On']
  @@setRemote = @@avp.Codes['Remote']
  @@setiTunes = @@avp.Codes['iTunes']
  @@set12vOn = @@avp.Codes['12v2+']
  @@set12vOff = @@avp.Codes['12v2-']
  @@powerOff = @@avp.Codes['Off']
 
  # This method returns an array of hashes describing the contents of the
  # 'cue list', which is the playlist 'TempList'. A sequence of tracks belonging
  # to the same album is condensed to a single entry with no track name but a
  # count of tracks in the sequence.
 
  def self.cueList
    cueList = []
    tracks = @@mylist.tracks.get
    tracks.each do |t|
      if cueList.last && cueList.last[:album] == t.album.get
        cueList.last.delete(:name)
        cueList.last[:artist] = 'Compilation' if cueList.last[:artist] != t.artist.get
        cueList.last[:artist] = 'Soundtrack' if t.genre.get == 'Soundtrack' &&
          cueList.last[:artist] == 'Compilation'
        cueList.last[:count] += 1
        cueList.last[:duration] += t.duration.get.floor
      else
        cueList << {:name => t.name.get, :album => t.album.get, :artist => t.artist.get,
                    :duration => t.duration.get.floor, :count => 1}
      end
    end
    cueList
  end
  
  # This method clears the cue list by deleting all the tracks in the
  # playlist 'TempList'
    
  def self.clearCueList
    cuelist = @@mylist.tracks.get
    cuelist.each do |track|
      @@iTunes.delete(track)
      #cuelist[0].delete
    end
  end
  
  # This method cues a track up to play by adding it to the playlist 'TempList'.
  # If iTunes is stopped, it is sent a 'play' command to start playback.
    
  def self.playTrack(track_location)
    uri = URI.parse(track_location)
    @@iTunes.add(MacTypes::Alias.path(URI::unescape(uri.path)), :to => @@mylist)
    if self.getStatusText == 'Stopped'
      @@iTunes.play
    end
  end
  
  # This method tells iTunes to go back to the beginning of the current track,
  # or to the previous track if it is already at the beginning.
  
  def self.backTrack
    @@iTunes.back_track
  end
  
  # This method tells iTunes to skip forward to the next track.
  
  def self.nextTrack
    @@iTunes.next_track
  end
  
  # This method tells iTunes to pause if playing, or resume playing if paused.
  
  def self.playPause
    @@iTunes.playpause
  end
  
  # This method returns the state of iTunes' playback as a text string.
  
  def self.getStatusText
    theState = @@iTunes.player_state.get
    case theState
    when :playing
      return 'Playing'
    when :paused
      return 'Paused'
    else
      return 'Stopped'
    end
  end
  
  # This method returns details of iTunes' current track.
  
  def self.getCurrent
    return '' if ITC.getStatusText == 'Stopped'
    currentTrack = @@iTunes.current_track
    return {:name => currentTrack.name.get, :artist => currentTrack.artist.get,
      :album => currentTrack.album.get}
  end
 
  # This method executes a script to power on the stereo gear.
  # in Leopard, @@iRed.fire(<code>) seems to work

  def ITC.powerON
    # RAILS_DEFAULT_LOGGER.info('Powering on')
    begin
      @@powerOn.fire
      sleep(1)
      @@setRemote.fire
      @@setRemote.fire
      sleep(1)
      @@setiTunes.fire
      @@setiTunes.fire
      sleep(1)
      @@set12vOn.fire
      @@set12vOn.fire
    end
    # RAILS_DEFAULT_LOGGER.info('Powered on')
  end
  
  # This method executes a script to power off the stereo gear.
  
  def ITC.powerOFF
    begin
      @@set12vOff.fire
      @@set12vOff.fire
      sleep(1)
      @@powerOff.fire
      @@powerOff.fire
    end
  end
  
  # This method returns the number of seconds remaining in playback of the 
  # current track.
  
  def ITC.getTimeLeft
    return 0 if ITC.getStatusText == 'Stopped'
    currentTrack = @@iTunes.current_track
    return currentTrack.duration.get - @@iTunes.player_position.get
  end
end

#ITC.playTrack("file://localhost/Users/mac/Music/iTunes/iTunes%20Music/10,000%20Maniacs/MTV%20Unplugged/Eat%20For%20Two.m4a")
#puts ITC.cueList[0].name.get
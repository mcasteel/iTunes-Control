#!/usr/bin/env ruby
#
#  Created by Michael Casteel on 2007-07-26.
#  Copyright (c) 2007. All rights reserved.
require 'rubygems'
require 'rbosa'

# This class uses Applescript to communicate with iTunes, obtaining status and
# controlling operation. Because rubyosa doesn't function unless its target app
# is running. iTunes is opened when the class is loaded.
#
# ITC creates a playlist named 'TempList' which serves to hold the tracks which
# have been 'cued up' to play. Choosing a track (album, etc) to play results in
# calling ITC to add that track (or all the tracks in the album, etc) to this
# playlist.

class ITC
  def ITC.initApp(appName)
    procs = OSA.app('System Events').processes.map {|p| p.name}
    i = procs.detect {|n| n == appName}
    system("open /Applications/#{appName}.app") if i.nil?
    return OSA.app(appName)
  end
  
  OSA.utf8_strings = true
  @@iTunes = ITC.initApp('iTunes')
  @@lib = @@iTunes.sources.detect {|source| source.name=="Library"}
  @@mylist = @@lib.playlists.detect {|list| list.name=="TempList"}
  if @@mylist.nil?
    @@mylist = @@iTunes.make(OSA::ITunes::Playlist, nil, {:name => 'TempList'})
  end
  @@mylist.reveal
  
  @@iRed = ITC.initApp('iRed')
  @@avp = @@iRed.rcs.detect {|rc| rc.name=='AVP'}
  @@powerOn = @@avp.codes.detect {|cd| cd.name=='On'}
  @@setRemote = @@avp.codes.detect {|cd| cd.name=='Remote'}
  @@setiTunes = @@avp.codes.detect {|cd| cd.name=='iTunes'}
  @@set12vOn = @@avp.codes.detect {|cd| cd.name=='12v2+'}
  @@set12vOff = @@avp.codes.detect {|cd| cd.name=='12v2-'}
  @@powerOff = @@avp.codes.detect {|cd| cd.name=='Off'}

  # This method returns an array of hashes describing the contents of the
  # 'cue list', which is the playlist 'TempList'. A sequence of tracks belonging
  # to the same album is condensed to a single entry with no track name but a
  # count of tracks in the sequence.
  
  def ITC.cueList
    cueList = []
    tracks = @@mylist.tracks
    tracks.each do |t|
      if cueList.last && cueList.last[:album] == t.album
        cueList.last.delete(:name)
        cueList.last[:artist] = 'Compilation' if cueList.last[:artist] != t.artist
        cueList.last[:artist] = 'Soundtrack' if t.genre == 'Soundtrack' &&
          cueList.last[:artist] == 'Compilation'
        cueList.last[:count] += 1
        cueList.last[:duration] += t.duration.floor
      else
        cueList << {:name => t.name, :album => t.album, :artist => t.artist,
                    :duration => t.duration.floor, :count => 1}
      end
    end
    cueList
  end
  
  # This method clears the cue list by deleting all the tracks in the
  # playlist 'TempList'
  
  def ITC.clearCueList
    cuelist = @@mylist.tracks
    until cuelist.empty?
      @@iTunes.delete(cuelist[0])
      #cuelist[0].delete
    end
  end
  
  # This method cues a track up to play by adding it to the playlist 'TempList'.
  # If iTunes is stopped, it is sent a 'play' command to start playback.
    
  def ITC.playTrack(track_location)
    # RAILS_DEFAULT_LOGGER.info('Adding track '+track_location)
    @@iTunes.add(track_location, @@mylist)
    # RAILS_DEFAULT_LOGGER.info('Added track ')
    if @@iTunes.player_state == OSA::ITunes::EPLS::STOPPED
      @@iTunes.play
    end
  end
  
  # This method tells iTunes to go back to the beginning of the current track,
  # or to the previous track if it is already at the beginning.
  
  def ITC.backTrack
    @@iTunes.back_track
  end
  
  # This method tells iTunes to skip forward to the next track.
  
  def ITC.nextTrack
    @@iTunes.next_track
  end
  
  # This method tells iTunes to pause if playing, or resume playing if paused.
  
  def ITC.playPause
    @@iTunes.playpause
  end
  
  # This method returns the state of iTunes' playback as a text string.
  
  def ITC.getStatusText
    theState = @@iTunes.player_state
    case theState
    when OSA::ITunes::EPLS::PLAYING
      return 'Playing'
    when OSA::ITunes::EPLS::PAUSED
      return 'Paused'
    else
      return 'Stopped'
    end
  end
  
  # This method returns details of iTunes' current track.
  
  def ITC.getCurrent
    return '' if ITC.getStatusText == 'Stopped'
    currentTrack = @@iTunes.current_track
    return {:name => currentTrack.name, :artist => currentTrack.artist,
      :album => currentTrack.album}
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
    rescue NoMethodError
      @@iRed.fire(@@powerOn)
      sleep(1)
      @@iRed.fire(@@setRemote)
      @@iRed.fire(@@setRemote)
      sleep(1)
      @@iRed.fire(@@setiTunes)
      @@iRed.fire(@@setiTunes)
      sleep(1)
      @@iRed.fire(@@set12vOn)
      @@iRed.fire(@@set12vOn)
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
    rescue NoMethodError
      @@iRed.fire(@@set12vOff)
      @@iRed.fire(@@set12vOff)
      sleep(1)
      @@iRed.fire(@@powerOff)
      @@iRed.fire(@@powerOff)
    end
  end
  
  # This method returns the number of seconds remaining in playback of the 
  # current track.
  
  def ITC.getTimeLeft
    return 0 if ITC.getStatusText == 'Stopped'
    currentTrack = @@iTunes.current_track
    return currentTrack.duration - @@iTunes.player_position
  end
end
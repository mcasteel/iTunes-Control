#!/usr/bin/env ruby
#
#  Created by Michael Casteel on 2007-07-26.
#  Copyright (c) 2007. All rights reserved.

require 'rubygems'
require 'appscript'

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
  Appscript.app('itunes').reveal(target)
  
  @@iRed = Appscript.app('iRed')
  @@avp = @@iRed.RCs['AVP']
  @@powerOn = @@avp.Codes['On']
  @@setRemote = @@avp.Codes['Remote']
  @@setiTunes = @@avp.Codes['iTunes']
  @@set12vOn = @@avp.Codes['12v2+']
  @@set12vOff = @@avp.Codes['12v2-']
  @@powerOff = @@avp.Codes['Off']
  
  def self.cueList
    return @@mylist.tracks.get
  end
    
  def self.playTrack(track_location)
    uri = URI.parse(track_location)
    @@iTunes.add(MacTypes::Alias.path(URI::unescape(uri.path)), :to => @@mylist)
    if @@iTunes.player_state == 'stopped'
      @@iTunes.play
    end
  end
  
  def self.backTrack
    @@iTunes.back_track
  end
  
  def self.nextTrack
    @@iTunes.next_track
  end
  
  def self.playPause
    @@iTunes.playpause
  end
  
  def self.getStatusText
    theState = @@iTunes.player_state
    case theState
    when 'playing'
      return 'Playing'
    when 'paused'
      return 'Paused'
    else
      return 'Stopped'
    end
  end
  
  def self.getCurrent
    return '' if ITC.getStatusText == 'Stopped'
    currentTrack = @@iTunes.current_track
    return {:name => currentTrack.name, :artist => currentTrack.artist,
      :album => currentTrack.album}
  end
end

#ITC.playTrack("file://localhost/Users/mac/Music/iTunes/iTunes%20Music/10,000%20Maniacs/MTV%20Unplugged/Eat%20For%20Two.m4a")
#puts ITC.cueList[0].name.get
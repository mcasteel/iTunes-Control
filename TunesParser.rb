#!/usr/bin/env ruby
#
#  Created by Michael Casteel on 2007-07-17.
#  Copyright (c) 2007. All rights reserved.
require "rexml/document"
require "rexml/streamlistener"
require "tunesDB"

class TunesParser
  include REXML::StreamListener 
    IDLE=0
    TRACKSPENDING=1
    NEXTTRACK=2
    THISTRACK=3
    TRACKINFO=4
    PLAYLISTSPENDING=5
    NEXTPLAYLIST=6
    THISPLAYLIST=7
    ITEMSPENDING=8
    NEXTITEM=9
    THISITEM=10
  
  def initialize()
    @curState=IDLE
    @numTracks=0
    @numPlaylists=0
    @curElement=''
    @curTrackID=''
    @curKey=''
  end
  def tag_start  (name, attributes)
    case @curState
    when IDLE
      puts "Start Tunes" if name=='plist'
    when TRACKSPENDING
      @curState = NEXTTRACK if name.casecmp('dict') == 0
    when THISTRACK
      @curState = TRACKINFO if name.casecmp('dict') == 0
    when PLAYLISTSPENDING
      @curState = NEXTPLAYLIST if name.casecmp('array') == 0
    when NEXTPLAYLIST
      if name.casecmp('dict') == 0
        @thisPlaylist = {}
        @playlistItems = []
        @curState = THISPLAYLIST
      end
    when THISPLAYLIST
      @curState = ITEMSPENDING if name.casecmp('playlist items') == 0
    when ITEMSPENDING
      @curState = NEXTITEM if name.casecmp('array') == 0
    when NEXTITEM
      @curState = THISITEM if name.casecmp('dict') == 0
    end
  end
  
  def tag_end(name)
    case @curState
    when IDLE
      if name.casecmp('key') == 0
        case
        when @curValue.casecmp('Tracks') == 0
          @curState = TRACKSPENDING
        when @curValue.casecmp('Playlists') == 0
          @curState = PLAYLISTSPENDING
        end
      elsif name.casecmp('plist') == 0
          puts("Found #{@numTracks} Tracks, #{@numPlaylists} Playlists")
      end      
    when NEXTTRACK
      case
      when name.casecmp('key') == 0
        @thisTrack = {'Track' => @curValue}
        @curTrackID = @curValue
        @curState = THISTRACK
      when name.casecmp('dict') == 0
        @curState = IDLE
      end
    when TRACKINFO
      case
      when name.casecmp('dict') == 0
        if (@thisTrack['Track Type'] == 'File') && 
              !(@thisTrack['Location'] =~ %r{\/\.Trash\/}) &&
              !(@thisTrack['Disabled']) &&
              !(@thisTrack['Podcast'])
          @numTracks += 1
          Track.newTrack(@thisTrack)
        end
        @curState = NEXTTRACK
      when name.casecmp('key') == 0
        @curKey = @curValue
      when name.casecmp('integer') == 0
        thisInt = @curValue
        @thisTrack[@curKey] = thisInt
      when name.casecmp('string') == 0
        @thisTrack[@curKey] = @curValue
      when name.casecmp('true') == 0
        @thisTrack[@curKey] = true
      when name.casecmp('false') == 0
        @thisTrack[@curKey] = false
      when name.casecmp('date') == 0
        @thisTrack[@curKey] = @curValue
      else
        puts("Found unexpected end #{name}")
        @thisTrack[@curKey] = @curValue
        @curKey = ''
      end
    when NEXTPLAYLIST
      if name.casecmp('array') == 0
        @curState = IDLE
      end
    when THISPLAYLIST
      case
      when name.casecmp('dict') == 0
        @numPlaylists += 1
        Playlist.newPlaylist(@thisPlaylist, @playlistItems)
        @curState = NEXTPLAYLIST
      when name.casecmp('key') == 0
        if @curValue.casecmp('playlist items') == 0
          @curState = ITEMSPENDING
        else
          @curKey = @curValue
        end
      when name.casecmp('integer') == 0
        @thisPlaylist[@curKey] = @curValue
      when name.casecmp('string') == 0
        @thisPlaylist[@curKey] = @curValue
      when name.casecmp('true') == 0
        @thisPlaylist[@curKey] = true
      when name.casecmp('false') == 0
        @thisPlaylist[@curKey] = false
      when name.casecmp('data') == 0
        @thisPlaylist[@curKey] = @curValue
      else
        puts("Found unexpected end #{name}")
        @thisPlaylist[@curKey] = @curValue
        @curKey = ''
      end
    when NEXTITEM
      @curState = THISPLAYLIST if name.casecmp('array') == 0
    when THISITEM
      case
      when name.casecmp('dict') == 0
        @curState = NEXTITEM
      when name.casecmp('key') == 0
        @curKey = @curValue
      when name.casecmp('integer') == 0
        @playlistItems << @curValue
      else
        puts("Found unexpected end #{name}")
        @curKey = ''
      end
    end
  end
 def text (theText)
   @curValue = theText
 end
  
  
end

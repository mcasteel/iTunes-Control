#!/usr/bin/env ruby
#
#  Created by Michael Casteel on 2007-08-28.
#  Copyright (c) 2007. All rights reserved.
require 'lib/itc'

# This class powers up the stereo gear and then watches as iTunes plays the
# music which has been cued up. When iTunes stops playing (presumably at the end),
# it clears the cue list and powers the stereo gear down.
#
# To use this class, call ITCMonitor.start when you have begun playback.

class ITCMonitor
  @@playing = false
  
  # Called when iTunes play is started, this method powers up the stereo gear,
  # then launches another process to watch iTunes until it stops.
  
  def self.start
    return if @@playing
    @@playing = true
    theIO = IO.popen('ruby -e"require \'lib/itcmonitor\';ITCMonitor.doMonitor"')
    Thread.new(theIO) do |io|
      begin
        puts(ITC.powerON)
        while theLine = io.readline
          puts theLine
        end
      rescue EOFError
        io.close
        @@playing = false
      end
    end
  end
  
  # This method is run in a subsidiary process to watch iTunes. When playback
  # stops, it clears the cue list and powers down the stereo gear.
  
  def self.doMonitor
    @@playing = true
    while @@playing
      timeLeft = ITC.getTimeLeft
      if timeLeft == 0
        @@playing = false
      else
        sleep(timeLeft + 0.5)
      end
    end
    ITC.clearCueList
    ITC.powerOFF
    sleep(2)
    ITC.powerOFF
  end
end

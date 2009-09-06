#!/usr/bin/env ruby
#
#  Created by Michael Casteel on 2007-07-19.
#  Copyright (c) 2007. All rights reserved.
require 'rubygems'
require 'active_record'
require "TunesDB"
require "TunesParser"
$KCODE='UTF8'

runmode = if ARGV[0] then 'production' else 'development' end

dbconfig = YAML::load_file('config/database.yml')[runmode]
ActiveRecord::Base.establish_connection(dbconfig)

puts('Starting load using '+dbconfig['adapter'])
puts('Deleting old data...')
Playlist.destroy_all
Track.delete_all
Album.delete_all
Artist.delete_all
Genre.delete_all
puts('...Deleted')

parser = TunesParser.new
file = File.new('/Volumes/Schwarzbuch HD/Users/mac/Music/iTunes/iTunes Music Library.xml')
#file = File.new('/Users/mac/Music/iTunes/iTunes Music Library.xml')
#file = File.new('test.xml')
puts('Parsing xml file...')
REXML::Document.parse_stream(file, parser)

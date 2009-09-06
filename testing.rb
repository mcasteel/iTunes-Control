#!/usr/bin/env ruby
#
#  Created by Michael Casteel on 2007-08-28.
#  Copyright (c) 2007. All rights reserved.
require 'lib/itc'

puts `pwd`
puts ITC.getStatusText
puts ITC.getCurrent
puts ITC.getTimeLeft
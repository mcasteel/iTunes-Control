module ItunesHelper
  def whatsPlaying(status)
    status[:current][:artist] + ':' + status[:current][:name] unless status[:current][:artist].blank?
  end
  
  def linkIfUpdatable(element)
    if element[:type] && element[:type] != 'T'
      link_to('&#9654; ', '#')  +
    						goIfType(element)
    else
      '  ' + goIfType(element)
    end
  end
  
  def liIfTyped(type, id)
    if type
      tag('li', {:id => type+id.to_s}, true)
    else
      tag('li', {:id => id.to_s}, true)
    end
  end
  
  def goIfType(element)
    if element[:type] == 'A' || element[:type] == 'G'
      element[:title][0]
    else
      link_to(element[:title][0], '#')
		end
  end
  
  def mmss(duration)
    return (duration/60).to_s + ':' + sprintf('%02d', duration%60)
  end
  
  def yearIf(theYear)
    if theYear
      return ' ('+theYear.to_s+')'
    else
      return ''
    end
  end
  
  def trackDetails(details)
    return '' if details[:trackName].nil?
    return '<i>'+details[:trackName]+' ('+mmss(details[:duration])+')</i><br>'
  end

  def setupRefresh(time)
    time = 10 if time <= 0
    'setTimeout("'+
    "new Ajax.Updater('status', '/itunes/updateStatus', "+
    "{asynchronous:true, evalScripts:true, method:'GET'})\", #{time}*1000+100);"
  end
  
  def makeTab(theTab, theAction, curTab)
    info = '<li'
    info += ' id=curtab' if theTab == curTab
    return info + '>' + link_to(theTab, :action=>theAction)+ '</li>'
  end
end

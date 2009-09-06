// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var theBalloon = null;
var balloonTarget = null;
var balloonTimer = null;
function Toggle(button, how) {
    obj = button;
    while (obj.id == '') {
		obj = obj.parentNode;
    }
	theID = obj.id;
	theNum = theID;
	theType = theID.charAt(0);
	if (theType >= 'A' && theType <= 'Z') {
		theNum = theID.slice(1);
	}
	new Ajax.Updater(theID, '/itunes/'+how+'/'+theNum+'?type='+theType,
				{asynchronous:true, evalScripts:true});
	return false;
}
function Play(type, track) {
	url = '/itunes/play/'+track;
	if (type) {
		url += '?type='+type
	}
	new Ajax.Updater('status', url,
				{asynchronous:true, evalScripts:true});
	return false;
}
// Handler for bubbling mouseover in list
// Based on Prototype event observing so maybe it will work in IE
// Sets a timer to display the balloon if the mouse hovers within the
// help region for a period of time
function handleOver(event) {
	theTarget = Event.element(event);
	if ((theTarget.tagName == 'SPAN') && (theBalloon == null) && (balloonTimer == null)) {
		balloonTarget = theTarget;
		balloonTimer = setTimeout('clickedList();', 350);
	};
}

// Handler for bubbling mouseout in list
// Based on Prototype event observing so maybe it will work in IE
// Hides the help balloon if there is one, else resets the hover timer if
// it is running.
// Odd: There appear to be no mouseouts from the SPAN in Safari, thus the LI

function handleOut(event) {
	theTarget = Event.element(event);
	if ((theTarget.tagName=='SPAN') || (theTarget.tagName=='LI')) {
	 	if (theBalloon != null) {
			theBalloon.hide();
			theBalloon = null;
		}
		else if (balloonTimer != null){
			clearTimeout(balloonTimer);
			balloonTimer = null;
		}
	};
}

// Handler for bubbling clicks on expand/contract arrows in list
// Based on Prototype event observing so maybe it will work in IE
function handleClick(event) {
	theTarget = Event.element(event);
	if (theTarget.tagName == 'A') {clickedLink(event, theTarget)}
	else if (theTarget.tagName == 'SPAN') {
		balloonTarget = theTarget;
		clickedList();
	};
}

function clickedList() {
	balloonTimer = null;
	theTarget = balloonTarget;
    obj = theTarget;
    while (obj.id == '') {
		obj = obj.parentNode;
    }
	theID = obj.id;
	theNum = theID;
	theType = theID.charAt(0);
	if (theType >= 'A' && theType <= 'Z') {
		theNum = theID.slice(1);
	}
	url = '/itunes/details/'+theNum+'?type='+theType;
	theBalloon = new HelpBalloon({
					returnElement: true,
					imagePath: '/images/',
					dataURL: url
					});
	theBalloon._elements.icon = theTarget;
	theTarget.width = theTarget.offsetWidth;
	theTarget.height = theTarget.offsetHeight;
	theBalloon.show();
}

function clickedLink(event, theTarget) {
	if (theTarget.innerHTML.length == 2 && theTarget.innerHTML.charAt(1) == ' ') {
		if (theTarget.className) {
			Toggle(theTarget, 'close');
		} else {
			Toggle(theTarget, 'open');
		}
	} else {
	    obj = theTarget;
	    while (obj.id == '') {
			obj = obj.parentNode;
	    }
		theID = obj.id;
		theNum = theID;
		theType = theID.charAt(0);
		if (theType >= 'A' && theType <= 'Z') {
			theNum = theID.slice(1);
		}
		Play(theType, theNum);
	}
	Event.stop(event);
}
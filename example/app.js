// ****************************************************************************************************************
// require lib

var keyboardListener = require('net.iamyellow.tikeyboardlistener');

// ****************************************************************************************************************
// GUI setup

// window
var win = Ti.UI.createWindow({
});

// the container view which should be resized
var container = keyboardListener.createView({
	backgroundColor: '#fff'
});
win.add(container);

// add a scroll view
var scroll = Ti.UI.createScrollView({
	width: Ti.UI.FILL, height: Ti.UI.FILL,
	bottom: 40, left: 0,
	contentHeight: 800,
	showVerticalScrollIndicator: true
});
container.add(scroll);

// a bottom cointaner view
var toolbar = Ti.UI.createView({
	width: Ti.UI.FILL, height: 40,
	backgroundColor: '#ccc',
	bottom: 0
}),
trigger = Ti.UI.createTextField({
	height: 20,
	top: 10, left: 10, right: 70,
	backgroundColor: '#fff'
}),
blurBtn = Ti.UI.createButton({
	width: 50, height: 20,
	top: 10,
	right: 10,
	title: 'blur'
});
toolbar.add(trigger);
toolbar.add(blurBtn);
container.add(toolbar);

// ****************************************************************************************************************
// keyboard listener stuff

container.addEventListener('keyboard:show', function (ev) {
	Ti.API.info('* keyboard height is ' + ev.keyboardHeight + ', and my height is now ' + ev.height);
});
container.addEventListener('keyboard:hide', function (ev) {
	Ti.API.info('* keyboard height was ' + ev.keyboardHeight + ', and my height is now ' + ev.height);
});

blurBtn.addEventListener('click', function () {
	trigger.blur();
});

// ****************************************************************************************************************
// start the show

win.open();
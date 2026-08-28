var win = Ti.UI.createWindow();
var label = Ti.UI.createLabel();
var rootCheck = require('ti.rootcheck');
win.add(label);
win.open();

win.addEventListener("open", function() {
	label.text = "Is rooted: " + rootCheck.rooted
});

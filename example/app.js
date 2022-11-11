var win = Ti.UI.createWindow();
var label = Ti.UI.createLabel();
win.add(label);
win.open();

var rootCheck = require('ti.rootcheck');
label.text = "Is rooted: " + rootCheck.isRooted;

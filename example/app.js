var win = Ti.UI.createWindow();
var label = Ti.UI.createLabel();
win.add(label);
win.open();

var rootCheck = require('ti.rootcheck');
if (OS_ANDROID) {
    label.text = "Is rooted: " + rootCheck.isRooted()
} else {
    label.text = "Is rooted: " + rootCheck.isRooted
}

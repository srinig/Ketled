
win = window.frames['unitFrame'].window;
doc = win.document;

win.processCellFocus(doc.getElementById('hrs#{accountIndex}_#{dayIndex}'));
doc.getElementById('editor').value = '#{hours}';
win.saveClicked();


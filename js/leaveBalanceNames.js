win = window.frames['unitFrame'].window.frames['modalFrame'].window;
leaveTypeSelect = win.document.getElementById('leave_type');
leaveNames = [];
for (var i = 0; i < leaveTypeSelect.length; i++) { 
    leaveNames.push(leaveTypeSelect[i].innerHTML); 
}

result = leaveNames.length == 0 ? '' : JSON.stringify(leaveNames);

result;

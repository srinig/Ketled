win = window.frames['unitFrame'].window.frames['modalFrame'].window;
leaveTypeSelect = win.document.getElementById('leave_type');
leaveNames = [];
reloadNeeded = true;


for (var i = 0; i < leaveTypeSelect.length; i++) { 
    text = leaveTypeSelect[i].innerHTML;
    if (text == '#{balanceName}') {
        if (i === leaveTypeSelect.selectedIndex) {
            reloadNeeded = false;
            break;
        } else {
            leaveTypeSelect.options[i].selected = 'selected';
            win.submitForm();
            break;
        }
    }
}

result = '';

if (!reloadNeeded) {
    result = window.frames['unitFrame'].window.frames['modalFrame'].window.document.getElementById('balance').value
}

result;
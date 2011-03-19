
win = window.frames['unitFrame'].window;
iframe = win.document.getElementById('modalFrame');
fDoc = iframe.contentWindow.document;
msgTable = fDoc.getElementById('msgTable');
errorWarningForm = fDoc.getElementById('saveValidationForm');
warningMessage = ''
errorMessage = ''
success = false;

if (msgTable && msgTable.innerText.indexOf('Timesheet Saved') >= 0) {
    success = true;
} else if (errorWarningForm) {
    
    modalWarningFrameText = errorWarningForm.innerText;
    parsingRegex = /Warnings\s+(.+)\s*Errors\s*([^:]*).*/
    
    match = modalWarningFrameText.match(parsingRegex)
    
    if (match) {
        warningMessage = match[1];
        errorMessage = match[2];
        if (errorMessage.match(/^\s*$/)) {
            success = true;
        }
    }
}

result = '';

if ((msgTable && msgTable.innerText.length > 0) || (errorWarningForm && errorWarningForm.innerText.length > 0)) {
    result = JSON.stringify({ 
        success: success,
        message: errorMessage || warningMessage || '' 
    });
}


result;

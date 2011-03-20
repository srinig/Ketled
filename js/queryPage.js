
doc = window.frames['unitFrame'].window.document;
a = doc.getElementById('udtColumn0').getElementsByTagName('div');
codes = doc.getElementById('udtColumn1').getElementsByTagName('div');

days = doc.getElementById('hrsBody').getElementsByTagName('div');

accounts = [];
cumm_total = 0;
required = 0;
daysInPeriod = 0;
for (var i = 0; i < a.length; i++) {  

    day = 0;
    hours = [];
    totalhours = 0;
    
    do {
        hourEl = doc.getElementById('hrs'+i+'_'+day);
        if (hourEl && hourEl.parentNode.style.display != 'none') {
            num = +hourEl.innerHTML;
            hours.push(num);
            totalhours += num;
            
            if (i == 0 && hourEl.style.backgroundColor == '' && hourEl.parentNode.style.display != 'none') {
                required += 8;
            }
            if (i == 0)
                daysInPeriod++;
        }
        day++;
    } while (hourEl && hourEl.parentNode.style.display != 'none');
        
    if (a[i].innerHTML) {
        accounts.push({
                      name: a[i].innerHTML,
                      code: codes[i].innerHTML,
                      hours: hours,
                      total: totalhours
                      });        
    }
    cumm_total += totalhours;
}

firstDate = doc.getElementById('hrsHeaderText0').innerHTML.replace(/.*<br\/?>/,'');
firstDateMatch = firstDate.match(/(\d+)\/(\d+)/);
month = +firstDateMatch[1];
dayOfMonth = +firstDateMatch[2];
today = new Date().getDate();
year = new Date().getFullYear()
if (dayOfMonth > today && new Date().getMonth() == 0) {
    // previous year
    year--;
}
startDate = new Date(year + '/' + month + '/' + dayOfMonth);
dateRange = [
    startDate.getTime(),
    startDate.getTime() + (daysInPeriod-1) * 86400000
];

result = accounts.length == 0 ? 
    '' : 
    JSON.stringify({
       dateRange: dateRange,
       accounts: accounts,
       total: cumm_total,
       required: required
    });


result;
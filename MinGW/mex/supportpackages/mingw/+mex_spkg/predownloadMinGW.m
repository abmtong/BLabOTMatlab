%% Pre-Download script for MinGW compiler to show a pop-up dialog

function predownloadMinGW()

msg = 'Please uncheck the checkbox on the next screen';
h = msgbox(msg,'modal');
set(findobj(h,'style','pushbutton'),'String','Next');
uiwait(h);

end
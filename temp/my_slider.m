function my_slider()
hfig = figure();
guidata(hfig,struct('val',0,'diffMax',1));
slider = uicontrol('Parent', hfig,'Style','slider',...
         'Units','normalized',...
         'Position',[0.3 0.5 0.4 0.1],...
         'Tag','slider1',...
         'Callback',@slider_callback);
     
button = uicontrol('Parent', hfig,'Style','pushbutton',...
         'Units','normalized',...
         'Position',[0.4 0.3 0.2 0.1],...
         'String','Display Values',...
         'Callback',@button_callback);
end

function slider_callback(hObject,eventdata)
	data = guidata(hObject);
	data.val = hObject.Value;
	data.diffMax = hObject.Max - data.val;
	% For R2014a and earlier:
	% data.val = get(hObject,'Value');
	% maxval = get(hObject,'Max');
	% data.diffMax = maxval - data.val;

	guidata(hObject,data);
end

function button_callback(hObject,eventdata)
	data = guidata(hObject);
	display([data.val data.diffMax]);
end
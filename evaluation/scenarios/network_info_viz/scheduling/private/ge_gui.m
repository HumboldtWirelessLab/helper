function h = ge_gui
% This function was created by saveas(...,'mfig'), or print -dmfile.
% It loads an HG object saved in binary format in the FIG-file of the
% same name.  NOTE: if you want to see the old-style M code
% representation of a saved object, previously created by print -dmfile,
% you can obtain this by using saveas(...,'mmat'). But be advised that the
% M-file/MAT-file format does not preserve some important information due
% to limitations in that format, including ApplicationData stored using
% setappdata.  Also, references to handles stored in UserData or Application-
% Data will no longer be valid if saved in the M-file/MAT-file format.
% ApplicationData and stored handles (excluding integer figure handles)
% are both correctly saved in FIG-files.
%
%load the saved object
[path, name] = fileparts(which(mfilename));
figname = fullfile(path, [name '.fig']);
if (exist(figname,'file')), open(figname), else open([name '.fig']), end
if nargout > 0, h = gcf; end


% --- Executes during object creation, after setting all properties.
function gname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function gname_Callback(hObject, eventdata, handles)
% hObject    handle to gname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gname as text
%        str2double(get(hObject,'String')) returns contents of gname as a double


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on button press in ToggleButton2.
function ToggleButton2_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleButton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleButton2


% --- Executes on button press in ToggleButton3.
function ToggleButton3_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleButton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleButton3


% --- Executes on button press in ToggleButton4.
function ToggleButton4_Callback(hObject, eventdata, handles)
% hObject    handle to ToggleButton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ToggleButton4



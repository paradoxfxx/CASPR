%--------------------------------------------------------------------------
%% Constructor
%--------------------------------------------------------------------------
function varargout = dynamicsGUI(varargin)
    % DYNAMICSGUI MATLAB code for dynamicsGUI.fig
    %      DYNAMICSGUI, by itself, creates a new DYNAMICSGUI or raises the existing
    %      singleton*.
    %
    %      H = DYNAMICSGUI returns the handle to a new DYNAMICSGUI or the handle to
    %      the existing singleton*.
    %
    %      DYNAMICSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in DYNAMICSGUI.M with the given input arguments.
    %
    %      DYNAMICSGUI('Property','Value',...) creates a new DYNAMICSGUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before dynamicsGUI_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to dynamicsGUI_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help dynamicsGUI

    % Last Modified by GUIDE v2.5 16-Feb-2016 11:42:11

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @dynamicsGUI_OpeningFcn, ...
                       'gui_OutputFcn',  @dynamicsGUI_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT
end

%--------------------------------------------------------------------------
%% GUI Setup Functions
%--------------------------------------------------------------------------
% --- Executes just before dynamicsGUI is made visible.
function dynamicsGUI_OpeningFcn(hObject, ~, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to dynamicsGUI (see VARARGIN)

    % Choose default command line output for dynamicsGUI
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);
    
    % Load the state
    loadState(handles);
    create_tab_group(handles);
    % UIWAIT makes dynamicsGUI wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = dynamicsGUI_OutputFcn(~, ~, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, ~, handles) %#ok<DEFNU>
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: delete(hObject) closes the figure
    saveState(handles);
    delete(hObject);
end


%--------------------------------------------------------------------------
%% Menu Functions
%--------------------------------------------------------------------------
% --------------------------------------------------------------------
function FileMenu_Callback(~, ~, ~) %#ok<DEFNU>
    % hObject    handle to FileMenu (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
end

% --------------------------------------------------------------------
function OpenMenuItem_Callback(~, ~, ~) %#ok<DEFNU>
    % hObject    handle to OpenMenuItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    file = uigetfile('*.fig');
    if ~isequal(file, 0)
        open(file);
    end
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to PrintMenuItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    printdlg(handles.figure1)
end

% --------------------------------------------------------------------
function CloseMenuItem_Callback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to CloseMenuItem (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                         ['Close ' get(handles.figure1,'Name') '...'],...
                         'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end

    delete(handles.figure1)
end

%--------------------------------------------------------------------------
%% Popups
%--------------------------------------------------------------------------
% --- Executes on selection change in popupmenu1.
% --- Executes on selection change in trajectory_popup.
function trajectory_popup_Callback(~, ~, ~) %#ok<DEFNU>
    % hObject    handle to trajectory_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns trajectory_popup contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from trajectory_popup
    
end

function trajectory_popup_Update(~, ~, handles)
    contents = cellstr(get(handles.model_text,'String'));
    model_type = contents{1};
    model_config = ModelConfig(ModelConfigType.(['M_',model_type]));
    setappdata(handles.trajectory_popup,'model_config',model_config);
    % Determine the cable sets
    trajectories_str = xmlObj2stringCellArray(model_config.trajectoriesXmlObj.getElementsByTagName('trajectories').item(0).getElementsByTagName('trajectory'),'id');
    set(handles.trajectory_popup, 'Value', 1);
    set(handles.trajectory_popup, 'String', trajectories_str);
end

% --- Executes during object creation, after setting all properties.
function trajectory_popup_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
    % hObject    handle to trajectory_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
end

% --- Executes on selection change in dynamics_popup.
function dynamics_popup_Callback(hObject, ~, handles) 
    % hObject    handle to dynamics_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns dynamics_popup contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from dynamics_popup
    contents = cellstr(get(hObject,'String'));
    toggle_visibility(contents{get(hObject,'Value')},handles);
end


% --- Executes during object creation, after setting all properties.
function dynamics_popup_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
    % hObject    handle to dynamics_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    dynamics_str = {'Forward Dynamics','Inverse Dynamics'};
    set(hObject, 'String', dynamics_str);
end

% --- Executes on selection change in solver_class_popup.
function solver_class_popup_Callback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to solver_class_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns solver_class_popup contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from solver_class_popup
    % First update then apply callback
    % Updates
    solver_type_popup_update(handles.solver_type_popup,handles);
    objective_popup_Update(handles.objective_popup,handles);
    constraint_popup_Update(handles.constraint_popup,handles);
    tuning_parameter_popup_Update(handles.tuning_parameter_popup,handles);
    % Callbacks
    objective_popup_Callback(handles.objective_popup,[],handles);
    constraint_popup_Callback(handles.constraint_popup,[],handles);
    tuning_parameter_popup_Callback(handles.tuning_parameter_popup,[],handles);
end

% --- Executes during object creation, after setting all properties.
function solver_class_popup_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
    % hObject    handle to solver_class_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    path_string = fileparts(mfilename('fullpath'));
    path_string = path_string(1:strfind(path_string, 'GUI')-2);
    settingsXMLObj =  XmlOperations.XmlReadRemoveIndents([path_string,'/GUI/XML/dynamicsXML.xml']);
    setappdata(hObject,'settings',settingsXMLObj);
    solver_str = xmlObj2stringCellArray(settingsXMLObj.getElementsByTagName('simulator').item(0).getElementsByTagName('solver_class'),'id');
    set(hObject, 'String', solver_str);
end


% --- Executes on selection change in objective_popup.
function objective_popup_Callback(hObject, ~, handles) 
    % hObject    handle to objective_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns objective_popup contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from objective_popup
    contents = cellstr(get(handles.solver_class_popup,'String'));
    solver_class_id = contents{get(handles.solver_class_popup,'Value')};
    settings = getappdata(handles.solver_class_popup,'settings');
    solverObj = settings.getElementById(solver_class_id);
    objectivesUnfiltered = solverObj.getElementsByTagName('objectives').item(0);
    if(isempty(objectivesUnfiltered))
        
    else
        objectivesObj = objectivesUnfiltered.getElementsByTagName('objective');
        objectiveNumber = get(hObject,'Value');
        objective = objectivesObj.item(objectiveNumber-1);
        weight_links = str2double(objective.getElementsByTagName('weight_links_multiplier').item(0).getFirstChild.getData);
        weight_cables = str2double(objective.getElementsByTagName('weight_cables_multiplier').item(0).getFirstChild.getData);
        weight_constants = str2double(objective.getElementsByTagName('weight_constants').item(0).getFirstChild.getData);
        dynObj = getappdata(handles.cable_text,'dynObj');
        weight_number = weight_links*dynObj.numLinks + weight_cables*dynObj.numCables + weight_constants;
        objective_table_Update(weight_number,handles.objective_table);
    end
end

function objective_popup_Update(hObject,handles)
    contents = cellstr(get(handles.solver_class_popup,'String'));
    solver_class_id = contents{get(handles.solver_class_popup,'Value')};
    settings = getappdata(handles.solver_class_popup,'settings');
    solverObj = settings.getElementById(solver_class_id);
    objectivesUnfiltered = solverObj.getElementsByTagName('objectives').item(0);
    if(isempty(objectivesUnfiltered))
        set(hObject,'Value',1);
        set(hObject,'String',{' '});
        set(hObject,'Visible','off');
        set(handles.objective_text,'Visible','off');
        set(handles.objective_radio,'Visible','off');
        set(handles.objective_table,'Visible','off');
    else
        set(hObject,'Visible','on');
        set(handles.objective_text,'Visible','on');
        set(handles.objective_radio,'Visible','on');
        set(handles.objective_table,'Visible','on');
        objective_str = xmlObj2stringCellArray(objectivesUnfiltered.getElementsByTagName('objective'),'type');
        set(hObject,'Value',1);
        set(hObject, 'String', objective_str);
    end
end

% --- Executes during object creation, after setting all properties.
function objective_popup_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
    % hObject    handle to objective_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in solver_type_popup.
function solver_type_popup_Callback(~, ~, ~) %#ok<DEFNU>
    % hObject    handle to solver_type_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns solver_type_popup contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from solver_type_popup
end

function solver_type_popup_update(hObject,handles)
    contents = cellstr(get(handles.solver_class_popup,'String'));
    solver_class_id = contents{get(handles.solver_class_popup,'Value')};
    settings = getappdata(handles.solver_class_popup,'settings');
    solverObj = settings.getElementById(solver_class_id);
    enum_file = solverObj.getElementsByTagName('solver_type_enum').item(0).getFirstChild.getData;
    e_list = enumeration(char(enum_file));
    e_n         =   length(e_list);
    e_list_str  =   cell(1,e_n);
    for i=1:e_n
        temp_str = char(e_list(i));
        e_list_str{i} = temp_str(1:length(temp_str));
    end
    set(hObject,'Value',1);
    set(hObject, 'String', e_list_str);
end

% --- Executes during object creation, after setting all properties.
function solver_type_popup_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
    % hObject    handle to solver_type_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

% --- Executes on selection change in plot_type_popup.
function plot_type_popup_Callback(hObject, ~, ~) 
    % hObject    handle to plot_type_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns plot_type_popup contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from plot_type_popup
    path_string = fileparts(mfilename('fullpath'));
    path_string = path_string(1:strfind(path_string, 'GUI')-2);
    settingsXMLObj =  XmlOperations.XmlReadRemoveIndents([path_string,'/GUI/XML/dynamicsXML.xml']);
    plotsObj = settingsXMLObj.getElementsByTagName('simulator').item(0).getElementsByTagName('plot_functions').item(0).getElementsByTagName('plot_function');
    contents = get(hObject,'Value');
    plotObj = plotsObj.item(contents-1);
    setappdata(hObject,'num_plots',plotObj.getElementsByTagName('figure_quantity').item(0).getFirstChild.getData);
end


% --- Executes during object creation, after setting all properties.
function plot_type_popup_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
    % hObject    handle to plot_type_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    path_string = fileparts(mfilename('fullpath'));
    path_string = path_string(1:strfind(path_string, 'GUI')-2);
    settingsXMLObj =  XmlOperations.XmlReadRemoveIndents([path_string,'/GUI/XML/dynamicsXML.xml']);
    plotsObj = settingsXMLObj.getElementsByTagName('simulator').item(0).getElementsByTagName('plot_functions').item(0).getElementsByTagName('plot_function');
    plot_str = cell(1,plotsObj.getLength);
    % Extract the identifies from the cable sets
    for i =1:plotsObj.getLength
        plotObj = plotsObj.item(i-1);
        plot_str{i} = char(plotObj.getAttribute('type'));
    end
    set(hObject,'Value',1);
    set(hObject, 'String', plot_str);
    setappdata(hObject,'num_plots',1);
end

% --- Executes on selection change in constraint_popup.
function constraint_popup_Callback(hObject, ~, handles) 
    % hObject    handle to constraint_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns constraint_popup contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from constraint_popup
    if(get(hObject,'Value') ~= 1)
        contents = cellstr(get(handles.solver_class_popup,'String'));
        solver_class_id = contents{get(handles.solver_class_popup,'Value')};
        settings = getappdata(handles.solver_class_popup,'settings');
        solverObj = settings.getElementById(solver_class_id);
        constraintsUnfiltered = solverObj.getElementsByTagName('constraints').item(0);
        if(isempty(constraintsUnfiltered))

        else
            constraintsObj = constraintsUnfiltered.getElementsByTagName('constraint');
            constraintNumber = get(hObject,'Value');
            constraint = constraintsObj.item(constraintNumber-2);
            weight_links = str2double(constraint.getElementsByTagName('weight_links_multiplier').item(0).getFirstChild.getData);
            weight_cables = str2double(constraint.getElementsByTagName('weight_cables_multiplier').item(0).getFirstChild.getData);
            weight_constants = str2num(constraint.getElementsByTagName('weight_constants').item(0).getFirstChild.getData); %#ok<ST2NM>
            dynObj = getappdata(handles.cable_text,'dynObj');
            weight_number = weight_links*dynObj.numLinks + weight_cables*dynObj.numCables + sum(weight_constants);
            num_constraints = str2double(get(handles.constraint_number_edit,'String'));
            if(isnan(num_constraints))
                num_constraints = 1;
            end
            constraint_table_Update([num_constraints,weight_number],handles.constraint_table);
        end
    end
end

function constraint_popup_Update(hObject,handles)
    contents = cellstr(get(handles.solver_class_popup,'String'));
    solver_class_id = contents{get(handles.solver_class_popup,'Value')};
    settings = getappdata(handles.solver_class_popup,'settings');
    solverObj = settings.getElementById(solver_class_id);
    constraintsUnfiltered = solverObj.getElementsByTagName('constraints').item(0);
    if(isempty(constraintsUnfiltered))
        set(hObject,'Value',1);
        set(hObject,'String',{' '});
        set(hObject,'Visible','off');
        set(handles.constraint_text,'Visible','off');
        set(handles.constraint_table,'Visible','off');
        set(handles.constraint_number_edit,'Visible','off');
    else
        set(hObject,'Visible','on');
        set(handles.constraint_text,'Visible','on');
        set(handles.constraint_table,'Visible','on');
        set(handles.constraint_number_edit,'Visible','on');
        constraint_str = xmlObj2stringCellArray(constraintsUnfiltered.getElementsByTagName('constraint'),'type');
        constraint_str = [{' '},constraint_str];
        set(hObject,'Value',1);
        set(hObject, 'String', constraint_str);
    end
end


% --- Executes during object creation, after setting all properties.
function constraint_popup_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
    % hObject    handle to constraint_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end 

% --- Executes on selection change in tuning_parameter_popup.
function tuning_parameter_popup_Callback(hObject, ~, handles) 
    % hObject    handle to objective_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns objective_popup contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from objective_popup
    contents = cellstr(get(handles.solver_class_popup,'String'));
    solver_class_id = contents{get(handles.solver_class_popup,'Value')};
    settings = getappdata(handles.solver_class_popup,'settings');
    solverObj = settings.getElementById(solver_class_id);
    tuningUnfiltered = solverObj.getElementsByTagName('tuning_parameters').item(0);
    if(isempty(tuningUnfiltered))
        
    else
        tuningObj = tuningUnfiltered.getElementsByTagName('tuning_parameter');
        tuningNumber = get(hObject,'Value');
        tuning = tuningObj.item(tuningNumber-1);
        weight_links = str2double(tuning.getElementsByTagName('weight_links_multiplier').item(0).getFirstChild.getData);
        weight_cables = str2double(tuning.getElementsByTagName('weight_cables_multiplier').item(0).getFirstChild.getData);
        weight_constants = str2double(tuning.getElementsByTagName('weight_constants').item(0).getFirstChild.getData);
        dynObj = getappdata(handles.cable_text,'dynObj');
        weight_number = weight_links*dynObj.numLinks + weight_cables*dynObj.numCables + weight_constants;
        tuning_parameter_table_Update(weight_number,handles.tuning_parameter_table);
    end
end

function tuning_parameter_popup_Update(hObject,handles)
    contents = cellstr(get(handles.solver_class_popup,'String'));
    solver_class_id = contents{get(handles.solver_class_popup,'Value')};
    settings = getappdata(handles.solver_class_popup,'settings');
    solverObj = settings.getElementById(solver_class_id);
    tuningUnfiltered = solverObj.getElementsByTagName('tuning_parameters').item(0);
    if(isempty(tuningUnfiltered))
        set(hObject,'Value',1);
        set(hObject,'String',{' '});
        set(hObject,'Visible','off');
        set(handles.tuning_parameter_text,'Visible','off');
        set(handles.tuning_parameter_radio,'Visible','off');
        set(handles.tuning_parameter_table,'Visible','off');
    else
        set(hObject,'Visible','on');
        set(handles.tuning_parameter_text,'Visible','on');
        set(handles.tuning_parameter_radio,'Visible','on');
        set(handles.tuning_parameter_table,'Visible','on');
        objective_str = xmlObj2stringCellArray(tuningUnfiltered.getElementsByTagName('tuning_parameter'),'type');
        set(hObject,'Value',1);
        set(hObject, 'String', objective_str);
    end
end

% --- Executes during object creation, after setting all properties.
function tuning_parameter_popup_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
    % hObject    handle to tuning_parameter_popup (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end



%--------------------------------------------------------------------------
%% Push Buttons
%--------------------------------------------------------------------------
% --- Executes on button press in run_button.
function run_button_Callback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to run_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % First read the trajecory information
    clc; 
    contents = cellstr(get(handles.trajectory_popup,'String'));
    trajectory_id = contents{get(handles.trajectory_popup,'Value')};
    model_config = getappdata(handles.trajectory_popup,'model_config');
    trajectory_xmlobj = model_config.getTrajectoryXmlObj(trajectory_id);
    % Then read the form of dynamics
    contents = cellstr(get(handles.dynamics_popup,'String'));
    dynamics_id = contents{get(handles.dynamics_popup,'Value')};
    dynObj = getappdata(handles.cable_text,'dynObj');
    if(strcmp(dynamics_id,'Inverse Dynamics'))
        run_inverse_dynamics(handles,dynObj,trajectory_xmlobj);
    else
        run_forward_dynamics(handles,dynObj,trajectory_xmlobj);
    end
end

% --- Executes on button press in save_button.
function save_button_Callback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to save_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    path_string = fileparts(mfilename('fullpath'));
    path_string = path_string(1:strfind(path_string, 'GUI')-2);
    file_name = [path_string,'\logs\*.mat'];
    [file,path] = uiputfile(file_name,'Save file name');
    saveState(handles,[path,file]);
end

% --- Executes on button press in load_button.
function load_button_Callback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to load_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    path_string = fileparts(mfilename('fullpath'));
    path_string = path_string(1:strfind(path_string, 'GUI')-2);
    file_name = [path_string,'\logs\*.mat'];
    settings = uigetfile(file_name);
    load(settings);
    mp_text = get(handles.model_text,'String');
    cs_text = get(handles.cable_text,'String');
    if(strcmp(mp_text,state.model_text)&&strcmp(cs_text,state.cable_text))
        set(handles.trajectory_popup,'value',state.trajectory_popup);
        set(handles.dynamics_popup,'value',state.dynamics_popup);
        set(handles.solver_class_popup,'value',state.solver_class_popup);
        solver_type_popup_update(handles.solver_type_popup,handles);
        dynamics_popup_Callback(handles.dynamics_popup, [], handles);
        set(handles.solver_type_popup,'value',state.solver_type_popup);
        set(handles.objective_popup,'value',state.objective_popup);
        set(handles.constraint_popup,'value',state.constraint_popup);
        set(handles.tuning_parameter_popup,'value',state.tuning_parameter_popup);
        set(handles.plot_type_popup,'value',state.plot_type_popup);
        set(handles.objective_table,'Data',state.objective_table);
        set(handles.constraint_table,'Data',state.constraint_table);
        set(handles.tuning_parameter_table,'Data',state.tuning_parameter_table);
        % Callback
        plot_type_popup_Callback(handles.plot_type_popup,[],handles);
        objective_popup_Callback(handles.objective_popup,[],handles);
        constraint_popup_Callback(handles.constraint_popup,[],handles);
        tuning_parameter_popup_Callback(handles.tuning_parameter_popup, [], handles);
    else
        warning('Incorrect Model Type');
    end
end


% --- Executes on button press in plot_button.
function plot_button_Callback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to plot_button (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)  
    sim = getappdata(handles.figure1,'sim');
    if(isempty(sim))
        warning('No simulator has been generated. Please press run first');
    else
        contents = cellstr(get(handles.plot_type_popup,'String'));
        plot_type = contents{get(handles.plot_type_popup,'Value')};
        plot_for_GUI(plot_type,sim,handles,str2double(getappdata(handles.plot_type_popup,'num_plots')))
    end
end

%--------------------------------------------------------------------------
%% Toolbar buttons
%--------------------------------------------------------------------------
% --------------------------------------------------------------------
function save_file_tool_ClickedCallback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to save_file_tool (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    tabgp = getappdata(handles.figure1,'tabgp');
    s_tab = get(tabgp,'SelectedTab');
    ax = get(s_tab,'Children');
    f1 = figure; % Open a new figure with handle f1
    copyobj(ax,f1); % Copy axes object h into figure f1
    set(gca,'ActivePositionProperty','outerposition')
    set(gca,'Units','normalized')
    set(gca,'OuterPosition',[0 0 1 1])
    set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
    [file,path] = uiputfile({'*.fig';'*.bmp';'*.eps';'*.emf';'*.jpg';'*.pcx';...
        '*.pbm';'*.pdf';'*.pgm';'*.png';'*.ppm';'*.svg';'*.tif'},'Save file name');
    if(path ~= 0)
        saveas(gcf,[path,file]);
    end
    close(f1);
end

% --------------------------------------------------------------------
function undock_figure_tool_ClickedCallback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to undock_figure_tool (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    tabgp = getappdata(handles.figure1,'tabgp');
    s_tab = get(tabgp,'SelectedTab');
    ax = get(s_tab,'Children');
    f1 = figure; % Open a new figure with handle f1
    copyobj(ax,f1); % Copy axes object h into figure f1
    set(gca,'ActivePositionProperty','outerposition')
    set(gca,'Units','normalized')
    set(gca,'OuterPosition',[0 0 1 1])
    set(gca,'position',[0.1300 0.1100 0.7750 0.8150])
end

% --------------------------------------------------------------------
function delete_figure_tool_ClickedCallback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to delete_figure_tool (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    tabgp = getappdata(handles.figure1,'tabgp');
    s_tab = get(tabgp,'SelectedTab');
    delete(s_tab);
end


%--------------------------------------------------------------------------
%% Radio Buttons
%--------------------------------------------------------------------------
% --- Executes on button press in objective_radio.
function objective_radio_Callback(hObject, ~, handles) %#ok<DEFNU>
    % hObject    handle to objective_radio (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of objective_radio
    r_value = get(hObject,'Value');
    Q_editable = get(handles.objective_table,'ColumnEditable');
    Q_n = size(Q_editable,2);
    if(r_value)
        set(handles.objective_table,'Data',ones(1,Q_n));
        set(handles.objective_table,'ColumnEditable',false(1,Q_n));
    else
        
        set(handles.objective_table,'ColumnEditable',true(1,Q_n));
    end
end

% --- Executes on button press in tuning_parameter_radio.
function tuning_parameter_radio_Callback(hObject,~, handles) %#ok<DEFNU>
    % hObject    handle to tuning_parameter_radio (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of tuning_parameter_radio
    r_value = get(hObject,'Value');
    Q_editable = get(handles.tuning_parameter_table,'ColumnEditable');
    Q_n = size(Q_editable,2);
    if(r_value)
        set(handles.tuning_parameter_table,'Data',ones(1,Q_n));
        set(handles.tuning_parameter_table,'ColumnEditable',false(1,Q_n));
    else
        set(handles.tuning_parameter_table,'ColumnEditable',true(1,Q_n));
    end
end


%--------------------------------------------------------------------------
%% Toggle Buttons
%--------------------------------------------------------------------------
% --- Executes on button press in undock_box.
function undock_box_Callback(~, ~, ~) %#ok<DEFNU>
    % hObject    handle to undock_box (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of undock_box
end

%--------------------------------------------------------------------------
%% Textboxes
%--------------------------------------------------------------------------
function constraint_number_edit_Callback(~, ~, handles) %#ok<DEFNU>
    % hObject    handle to constraint_number_edit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of constraint_number_edit as text
    %        str2double(get(hObject,'String')) returns contents of constraint_number_edit as a double
    constraint_popup_Callback(handles.constraint_popup,[],handles);
end


% --- Executes during object creation, after setting all properties.
function constraint_number_edit_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
    % hObject    handle to constraint_number_edit (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end

%--------------------------------------------------------------------------
%% Tables
%--------------------------------------------------------------------------
function objective_table_Update(dimension,hObject)
    set(hObject,'Data',ones(1,dimension));
    set(hObject,'ColumnWidth',{30});
    set(hObject,'ColumnEditable',true(1,dimension));
    q_position = get(hObject,'Position');
    if(dimension>4)
        q_position(2) = 133;
        q_position(4) = 57;
        set(hObject,'Position',q_position);
    else
        q_position(2) = 150;
        q_position(4) = 40;
        set(hObject,'Position',q_position);
    end
end

function constraint_table_Update(dimension,hObject)
    set(hObject,'Data',ones(dimension));
    set(hObject,'ColumnWidth',{30});
    set(hObject,'ColumnEditable',true(1,dimension(2)));
    q_position = get(hObject,'Position');
    if(dimension(2)>4)
        q_position(2) = 23;
        q_position(4) = 57;
        set(hObject,'Position',q_position);
    else
        q_position(2) = 40;
        q_position(4) = 40;
        set(hObject,'Position',q_position);
    end
end

function tuning_parameter_table_Update(dimension,hObject)
    set(hObject,'Data',ones(1,dimension));
    set(hObject,'ColumnWidth',{30});
    set(hObject,'ColumnEditable',true(1,dimension));
    q_position = get(hObject,'Position');
    if(dimension>4)
        q_position(2) = 133;
        q_position(4) = 57;
        set(hObject,'Position',q_position);
    else
        q_position(2) = 150;
        q_position(4) = 40;
        set(hObject,'Position',q_position);
    end
end

%--------------------------------------------------------------------------
% Additional Functions
%--------------------------------------------------------------------------
function run_inverse_dynamics(handles,dynObj,trajectory_xmlobj)
    % First read the solver form from the GUI
    solver_class_contents = cellstr(get(handles.solver_class_popup,'String'));
    solver_class = solver_class_contents{get(handles.solver_class_popup,'Value')};
    solver_type_contents = cellstr(get(handles.solver_type_popup,'String'));
    solver_type = solver_type_contents{get(handles.solver_type_popup,'Value')};
    objective_contents = cellstr(get(handles.objective_popup,'String'));
    objective = objective_contents{get(handles.objective_popup,'Value')};
    empty_objective = strcmp(objective,' ');
    constraint_contents = cellstr(get(handles.constraint_popup,'String'));
    constraint = constraint_contents{get(handles.constraint_popup,'Value')};
    empty_constraint = strcmp(constraint,' ');
    tuning_parameter_contents = cellstr(get(handles.tuning_parameter_popup,'String'));
    tuning_parameter = tuning_parameter_contents{get(handles.tuning_parameter_popup,'Value')};
    empty_tuning_parameter = strcmp(tuning_parameter,' ');
    settings = getappdata(handles.solver_class_popup,'settings');
    if(empty_objective&&empty_constraint&&empty_tuning_parameter)
        % No inputs
        solver_function = str2func(solver_class);
        solverObj = settings.getElementById(solver_class);
        enum_file = solverObj.getElementsByTagName('solver_type_enum').item(0).getFirstChild.getData;
        id_solver = solver_function(dynObj,eval([char(enum_file),'.',char(solver_type)]));
    elseif(empty_constraint&&empty_objective)
        % Only have tuning parameters
        solver_function = str2func(solver_class);
        solverObj = settings.getElementById(solver_class);
        enum_file = solverObj.getElementsByTagName('solver_type_enum').item(0).getFirstChild.getData;
        q_data = get(handles.tuning_parameter_table,'Data');
        id_solver = solver_function(dynObj,q_data,eval([char(enum_file),'.',char(solver_type)]));
    elseif(empty_constraint)
        % Optimisation without constraints
        objective_function = str2func(objective);
        q_data = get(handles.objective_table,'Data');
        id_objective = objective_function(q_data');
        solver_function = str2func(solver_class);
        solverObj = settings.getElementById(solver_class);
        enum_file = solverObj.getElementsByTagName('solver_type_enum').item(0).getFirstChild.getData;
        id_solver = solver_function(dynObj,id_objective,eval([char(enum_file),'.',char(solver_type)]));
    else
        % There are both constraints and objectives
        objective_function = str2func(objective);
        q_data = get(handles.objective_table,'Data');
        id_objective = objective_function(q_data');
        solver_function = str2func(solver_class);
        solverObj = settings.getElementById(solver_class);
        enum_file = solverObj.getElementsByTagName('solver_type_enum').item(0).getFirstChild.getData;
        id_solver = solver_function(dynObj,id_objective,eval([char(enum_file),'.',char(solver_type)]));
        % Obtain the constaints
        constraint_function = str2func(constraint);
        q_data = get(handles.constraint_table,'Data');
        contents = cellstr(get(handles.solver_class_popup,'String'));
        solver_class_id = contents{get(handles.solver_class_popup,'Value')};
        settings = getappdata(handles.solver_class_popup,'settings');
        solverObj = settings.getElementById(solver_class_id);
        constraintUnfiltered = solverObj.getElementsByTagName('constraints').item(0);
        constraintObj = constraintUnfiltered.getElementsByTagName('constraint');
        constraintNumber = get(handles.constraint_popup,'Value');
        constraint = constraintObj.item(constraintNumber-2);
        weight_constants = str2num(constraint.getElementsByTagName('weight_constants').item(0).getFirstChild.getData); %#ok<ST2NM>
        for i = 1:size(q_data,1)
            id_solver.addConstraint(constraint_function(i, q_data(i,1:weight_constants(1))',...
                q_data(i,weight_constants(1)+1:weight_constants(1)+weight_constants(2)), ...
                q_data(i,weight_constants(1)+weight_constants(2)+1:weight_constants(1)+weight_constants(2)+weight_constants(3))));
        end
    end
    contents = cellstr(get(handles.plot_type_popup,'String'));
    plot_type = contents{get(handles.plot_type_popup,'Value')};
    
    
    % Setup the inverse dynamics simulator with the SystemKinematicsDynamics
    % object and the inverse dynamics solver
    disp('Start Setup Simulation');
    start_tic = tic;
    idsim = InverseDynamicsSimulator(dynObj, id_solver);
    trajectory = JointTrajectory.LoadXmlObj(trajectory_xmlobj, dynObj);
    time_elapsed = toc(start_tic);
    fprintf('End Setup Simulation : %f seconds\n', time_elapsed);

    % Run the solver on the desired trajectory
    disp('Start Running Simulation');
    start_tic = tic;
    idsim.run(trajectory);
    time_elapsed = toc(start_tic);
    fprintf('End Running Simulation : %f seconds\n', time_elapsed);

    % Display information from the inverse dynamics simulator
    fprintf('Optimisation computational time, mean : %f seconds, std dev : %f seconds, total: %f seconds\n', mean(idsim.compTime), std(idsim.compTime), sum(idsim.compTime));

    % Plot the data
    disp('Start Plotting Simulation');
    start_tic = tic;
    
    plot_for_GUI(plot_type,idsim,handles,str2double(getappdata(handles.plot_type_popup,'num_plots')));
    
    
    % Store the simulator information
    setappdata(handles.figure1,'sim',idsim);
    time_elapsed = toc(start_tic);
    fprintf('End Plotting Simulation : %f seconds\n', time_elapsed);
end

function plot_for_GUI(plot_type,sim,handles,figure_quantity)
    plot_function = str2func(plot_type);
    tab_toggle = get(handles.undock_box,'Value');
    if(tab_toggle)
        plot_function(sim,[],[]);    
    else
        tabgp = getappdata(handles.figure1,'tabgp');
        for i = 1:figure_quantity
            tab(i) = uitab(tabgp,'Title',plot_type); %#ok<AGROW>
            ax(i) = axes; %#ok<AGROW>
            set(ax(i),'Parent',tab(i),'OuterPosition',[0,0,1,1])
        end
        plot_function(sim,[],ax);    
    end
end

function loadState(handles)
    % load all of the settings and initialise the values to match
    path_string = fileparts(mfilename('fullpath'));
    path_string = path_string(1:strfind(path_string, 'GUI')-2);
    file_name = [path_string,'\logs\upcra_gui_state.mat'];
    if(exist(file_name,'file'))
        load(file_name)
        set(handles.model_text,'String',state.model_text);
        set(handles.cable_text,'String',state.cable_text);
        setappdata(handles.cable_text,'dynObj',state.dynObj);
        trajectory_popup_Update([], [], handles);
        file_name = [path_string,'\logs\dynamics_gui_state.mat'];
        if(exist(file_name,'file'))
            load(file_name);
            mp_text = get(handles.model_text,'String');
            cs_text = get(handles.cable_text,'String');
            if(strcmp(mp_text,state.model_text)&&strcmp(cs_text,state.cable_text))
                set(handles.trajectory_popup,'value',state.trajectory_popup);
                set(handles.dynamics_popup,'value',state.dynamics_popup);
                set(handles.solver_class_popup,'value',state.solver_class_popup);
                solver_type_popup_update(handles.solver_type_popup,handles);
                dynamics_popup_Callback(handles.dynamics_popup, [], handles);
                set(handles.solver_type_popup,'value',state.solver_type_popup);
                set(handles.objective_popup,'value',state.objective_popup);
                set(handles.constraint_popup,'value',state.constraint_popup);
                set(handles.tuning_parameter_popup,'value',state.tuning_parameter_popup);
                set(handles.plot_type_popup,'value',state.plot_type_popup);
                set(handles.objective_table,'Data',state.objective_table);
                set(handles.constraint_table,'Data',state.constraint_table);
                set(handles.tuning_parameter_table,'Data',state.tuning_parameter_table);
                % Callback
                plot_type_popup_Callback(handles.plot_type_popup,[],handles);
                objective_popup_Callback(handles.objective_popup,[],handles);
                constraint_popup_Callback(handles.constraint_popup,[],handles);
                tuning_parameter_popup_Callback(handles.tuning_parameter_popup, [], handles);
            else
                initialise_popups(handles);
            end
        else
            initialise_popups(handles);
        end
    end
end

function saveState(handles,file_path)
    % Save all of the settings
    % Texts
    state.model_text                        =   get(handles.model_text,'String');
    state.cable_text                        =   get(handles.cable_text,'String');
    % Popups
    state.trajectory_popup                  =   get(handles.trajectory_popup,'value');
    state.dynamics_popup                    =   get(handles.dynamics_popup,'value');
    state.solver_class_popup                =   get(handles.solver_class_popup,'value');
    state.solver_type_popup                 =   get(handles.solver_type_popup,'value');
    state.objective_popup                   =   get(handles.objective_popup,'value');
    state.constraint_popup                  =   get(handles.constraint_popup,'value');
    state.plot_type_popup                   =   get(handles.plot_type_popup,'value');
    state.tuning_parameter_popup            =   get(handles.tuning_parameter_popup,'value');
    % Tables
    state.objective_table                   =   get(handles.objective_table,'Data');
    state.constraint_table                  =   get(handles.constraint_table,'Data');
    state.tuning_parameter_table            =   get(handles.tuning_parameter_table,'Data');
    if(nargin>1)
        save(file_path,'state');
    else
        path_string                             =   fileparts(mfilename('fullpath'));
        path_string                             = path_string(1:strfind(path_string, 'GUI')-2);
        save([path_string,'\logs\dynamics_gui_state.mat'],'state')
    end
end

function run_forward_dynamics(handles,dynObj,trajectory_xmlobj)
    % This will be added once script_FD has been fixed
    % First read the solver form from the GUI
    id_objective = IDObjectiveMinQuadCableForce(ones(dynObj.numCables,1));
    id_solver = IDSolverQuadProg(dynObj,id_objective, ID_QP_SolverType.MATLAB);
    
    
    % Setup the inverse dynamics simulator with the SystemKinematicsDynamics
    % object and the inverse dynamics solver
    disp('Start Setup Simulation');
    start_tic = tic;
    idsim = InverseDynamicsSimulator(dynObj, id_solver);
    fdsim = ForwardDynamicsSimulator(dynObj);
    trajectory = JointTrajectory.LoadXmlObj(trajectory_xmlobj, dynObj);
    time_elapsed = toc(start_tic);
    fprintf('End Setup Simulation : %f seconds\n', time_elapsed);
    
    % First run the inverse dynamics
    disp('Start Running Inverse Dynamics Simulation');
    start_tic = tic;
    idsim.run(trajectory);
    time_elapsed = toc(start_tic);
    fprintf('End Running Inverse Dynamics Simulation : %f seconds\n', time_elapsed);
    
    % Then run the forward dynamics
    disp('Start Running Forward Dynamics Simulation');
    start_tic = tic;
    fdsim.run(idsim.cableForces, trajectory.timeVector, trajectory.q{1}, trajectory.q_dot{1});
    time_elapsed = toc(start_tic);
    fprintf('End Running Forward Dynamics Simulation : %f seconds\n', time_elapsed);
    
    % Finally compare the results
    plot_for_GUI('plotJointSpace',idsim,handles,2);
    plot_for_GUI('plotJointSpace',fdsim,handles,2);
end

function toggle_visibility(dynamics_method,handles)
    if(strcmp(dynamics_method,'Forward Dynamics'))
        % Forward dynamics so hide all of the options
        set(handles.solver_class_text,'Visible','off');
        set(handles.solver_class_popup,'Visible','off');
        set(handles.solver_type_text,'Visible','off');
        set(handles.solver_type_popup,'Visible','off');
        set(handles.objective_text,'Visible','off');
        set(handles.objective_popup,'Visible','off');
        set(handles.constraint_text,'Visible','off');
        set(handles.constraint_popup,'Visible','off');
        set(handles.plot_type_text,'Visible','off');
        set(handles.plot_type_popup,'Visible','off');
        set(handles.objective_radio,'Visible','off');
        set(handles.objective_table,'Visible','off');
        set(handles.constraint_table,'Visible','off');
        set(handles.constraint_number_edit,'Visible','off');
        set(handles.tuning_parameter_radio,'Visible','off');
        set(handles.tuning_parameter_table,'Visible','off');
    else
        % Inverse dynamics so let all of the options be viewed
        set(handles.solver_class_text,'Visible','on');
        set(handles.solver_class_popup,'Visible','on');
        set(handles.solver_type_text,'Visible','on');
        set(handles.solver_type_popup,'Visible','on');
        set(handles.objective_text,'Visible','on');
        set(handles.objective_popup,'Visible','on');
        set(handles.constraint_text,'Visible','on');
        set(handles.constraint_popup,'Visible','on');
        set(handles.plot_type_text,'Visible','on');
        set(handles.plot_type_popup,'Visible','on');
        objective_popup_Update(handles.objective_popup,handles);
        constraint_popup_Update(handles.constraint_popup,handles);
        tuning_parameter_popup_Update(handles.tuning_parameter_popup,handles);
    end
end

function create_tab_group(handles)
    tabgp = uitabgroup(handles.uipanel3,'Position',[0 0 1 1]);
    % A temporary hack to make the figures plot correctly
    tab1 = uitab(tabgp);
    ax = axes;
    set(ax,'Parent',tab1,'OuterPosition',[0,0,1,1])
    delete(tab1);
    setappdata(handles.figure1,'tabgp',tabgp);
end

function str_cell_array = xmlObj2stringCellArray(xmlObj,str)
    str_cell_array = cell(1,xmlObj.getLength);
    % Extract the identifies from the cable sets
    for i =1:xmlObj.getLength
        tempXMLObj = xmlObj.item(i-1);
        str_cell_array{i} = char(tempXMLObj.getAttribute(str));
    end
end

function initialise_popups(handles)
    % Updates
    solver_type_popup_update(handles.solver_type_popup,handles);
    dynamics_popup_Callback(handles.dynamics_popup, [], handles);
    objective_popup_Update(handles.objective_popup,handles);
    constraint_popup_Update(handles.constraint_popup,handles);
    tuning_parameter_popup_Update(handles.tuning_parameter_popup,handles);
    % Needed callbacks
    plot_type_popup_Callback(handles.plot_type_popup,[],handles);
    objective_popup_Callback(handles.objective_popup,[],handles);
    constraint_popup_Callback(handles.constraint_popup,[],handles);
    tuning_parameter_popup_Callback(handles.tuning_parameter_popup, [], handles);
end

%% TO BE DONE
% Modify the constraints and objectives
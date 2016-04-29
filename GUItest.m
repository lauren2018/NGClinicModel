function GUItest
close all
clear all
global fc tm bw bw_INT tm_INT
global txPower txLossFactor rxNF rxLossFactor rad_pat
global radar_init_pos car_init_pos itfer_init_pos
global radar_speed car_speed itfer_speed
global Nsweep scenType

% f = figure('OuterPosition',[200 200 700 650]);
f = figure('OuterPosition',[215 200 700 650]);

% Reference edges
leftTit = 30;
botTit = 400;
leftTB = 250;

leftTit1 = 400;
botTit1 = 200;

botTit2 = botTit+100;
botTit3 = botTit-50;
botTit4 = botTit3-150;
botTit5 = botTit-20;
% leftTB1 = 

%% Simulation Settings
% Titles and labels
tbTitle1 = uicontrol(f,'Style','text',...
                'String','Simulation Settings',...
                'HorizontalAlignment','left',...
                'FontSize',16,...
                'Position',[leftTit botTit2 200 30]);

lbNumSw = uicontrol(f,'Style','text',...
                'String','Number of Sweeps (even number 8-32)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit2-25 130 30]);
            
lbScen = uicontrol(f,'Style','text',...
                'String','Desired Case',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit2-65 200 30]); 

% lbPlot = uicontrol(f,'Style','text',...
%                 'String','Output Plots',...
%                 'HorizontalAlignment','left',...
%                 'FontSize',12,...
%                 'Position',[420 110 200 30]);            

% Editable Items
tbNumSw = uicontrol(f,'Style','edit','FontSize',12,...
                'String','8',...
                'Position',[leftTit+150 botTit2-20 40 20]); 
            
popScen = uicontrol(f,'Style','pop',...
                'FontSize',12,...
                'String',{'1','2','3','4','Custom'},...
                'Position',[leftTit+145 botTit2-53 95 20],...
                'Callback',@scen_Callback);   
            
%% General Parameters
% Labels and Titles
tbTitle2 = uicontrol(f,'Style','text',...
                'String','General Radar Parameters',...
                'HorizontalAlignment','left',...
                'FontSize',16,...
                'Position',[leftTit botTit5 200 30]);
            
lbfc = uicontrol(f,'Style','text',...
                'String','Center Frequency (2-3 GHz)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit5-25 200 30]);
            
lbtm = uicontrol(f,'Style','text',...
                'String','Chirp Period (ms)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit5-50 200 30]);

lbbw = uicontrol(f,'Style','text',...
                'String','Bandwidth (1-1000 MHz)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit5-75 200 30]);
            
lbIbw = uicontrol(f,'Style','text',...
                'String','Interferer Bandwidth (1-1000 MHz)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit5-100 200 30]);
            
lbItm = uicontrol(f,'Style','text',...
                'String','Interferer Chirp Period (ms)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit5-125 200 30]);

% Editable items
tbfc = uicontrol(f,'Style','edit','FontSize',12,...
                'String','2.445','Enable','off',...
                'Position',[leftTB botTit5-13 40 20]);
            
poptm = uicontrol(f,'Style','pop',...
                'FontSize',12,'Enable','off',...
                'String',{'20','40'},'Value',2,...
                'Position',[leftTB-5 botTit5-38 65 20]);   
poptmList = get(poptm,'string');
            
tbbw = uicontrol(f,'Style','edit','FontSize',12,...
                'String','70','Enable','off',...
                'Position',[leftTB botTit5-63 40 20]);  
            
            
tbIbw = uicontrol(f,'Style','edit','FontSize',12,...
                'String','70','Enable','off',...
                'Position',[leftTB botTit5-88 40 20]);            

popItm = uicontrol(f,'Style','pop',...
                'FontSize',12,'Enable','off',...
                'String',{'20','40'},'Value',2,...
                'Position',[leftTB-5 botTit5-113 65 20]);    
popItmList = get(popItm,'string');         
                        
%% Antenna Parameters
% Labels and Titles
tbTitle3 = uicontrol(f,'Style','text',...
                'String','Antenna Parameters',...
                'HorizontalAlignment','left',...
                'FontSize',16,...
                'Position',[leftTit+5 botTit1 200 30]);
      
align([tbTitle2,tbTitle3],'left','none') 

lbtxP = uicontrol(f,'Style','text',...
                'String','TX Power (W)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit1-25 200 30]);
            
lbtxL = uicontrol(f,'Style','text',...
                'String','TX Loss Factor',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit1-50 200 30]);

lbrxN = uicontrol(f,'Style','text',...
                'String','RX Noise Figure (W)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit1-75 200 30]);

lbrxL = uicontrol(f,'Style','text',...
                'String','RX Loss Factor',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit1-100 200 30]);
            
lbrpat = uicontrol(f,'Style','text',...
                'String','Radiation Pattern',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[leftTit+20 botTit1-125 200 30]);            

% Editable items    
tbtxP = uicontrol(f,'Style','edit',...
                'String','0.65','FontSize',12,'Enable','off',...
                'Position',[leftTB 187 40 20]);            
            
tbtxL = uicontrol(f,'Style','edit',...
                'String','0','FontSize',12,'Enable','off',...
                'Position',[leftTB 162 40 20]);            
            
tbrxN = uicontrol(f,'Style','edit',...
                'String','4.5','FontSize',12,'Enable','off',...
                'Position',[leftTB 137 40 20]);
            
tbrxL = uicontrol(f,'Style','edit',...
                'String','0','FontSize',12,'Enable','off',...
                'Position',[leftTB 112 40 20]);            

poprpat = uicontrol(f,'Style','pop',...
                'FontSize',12,'Enable','off',...
                'String',{'TP Link','Patch','Directional'},...
                'Position',[leftTB-5 87 110 20]);
poprpatList = get(poprpat,'string');   

%% Main System Parameters
tbTitle4 = uicontrol(f,'Style','text',...
                'String','Main System Parameters',...
                'HorizontalAlignment','left',...
                'FontSize',16,...
                'Position',[leftTit1 botTit2 200 30]);

lbinitPos_ms = uicontrol(f,'Style','text',...
                'String','Initial Position',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[420 botTit2-25 130 30]);
            
lbxLoc_ms = uicontrol(f,'Style','text',...
                'String','x-Location',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[435 botTit2-50 130 30]);    
            
lbyLoc_ms = uicontrol(f,'Style','text',...
                'String','y-Location',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[435 botTit2-75 130 30]);               

lbms_speed = uicontrol(f,'Style','text',...
                'String','Speed (0-100 m/s)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[420 botTit2-100 130 30]);

% Editable Items
tbxLoc_ms = uicontrol(f,'Style','edit','FontSize',12,...
                'String','0','Enable','off',...
                'Position',[550 botTit2-38 40 20]);
            
tbyLoc_ms = uicontrol(f,'Style','edit','FontSize',12,...
                'String','0','Enable','off',...
                'Position',[550 botTit2-63 40 20]);            
            
tbms_speed = uicontrol(f,'Style','edit','FontSize',12,...
                'String','0','Enable','off',...
                'Position',[550 botTit2-88 40 20]);       

%% Target Parameters
% Title and labels
tbTitle5 = uicontrol(f,'Style','text',...
                'String','Target Parameters',...
                'HorizontalAlignment','left',...
                'FontSize',16,...
                'Position',[leftTit1 botTit3 200 30]);

lbinitPos = uicontrol(f,'Style','text',...
                'String','Initial Position',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[420 botTit3-25 130 30]);
            
lbxLoc = uicontrol(f,'Style','text',...
                'String','x-Location',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[435 botTit3-50 130 30]);    
            
lbyLoc = uicontrol(f,'Style','text',...
                'String','y-Location',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[435 botTit3-75 130 30]);               

lbcar_speed = uicontrol(f,'Style','text',...
                'String','Speed (0-100 m/s)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[420 botTit3-100 130 30]);

% Editable Items
tbxLoc = uicontrol(f,'Style','edit','FontSize',12,...
                'String','10','Enable','off',...
                'Position',[550 botTit3-38 40 20]);
            
tbyLoc = uicontrol(f,'Style','edit','FontSize',12,...
                'String','0','Enable','off',...
                'Position',[550 botTit3-63 40 20]);            
            
tbcar_speed = uicontrol(f,'Style','edit','FontSize',12,...
                'String','428.5714','Enable','off',...
                'Position',[550 botTit3-88 40 20]);           

%% Inteferer Parameters
% Title and labels
tbTitle6 = uicontrol(f,'Style','text',...
                'String','Intereferer Parameters',...
                'HorizontalAlignment','left',...
                'FontSize',16,...
                'Position',[leftTit1 botTit4 200 30]);

lbMultInt = uicontrol(f,'Style','text',...
                'String','Multiple Interferers',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[420 botTit4-25 130 30]);          

lbinitPos_I = uicontrol(f,'Style','text',...
                'String','Initial Position',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[420 botTit4-50 130 30]);
            
lbxLoc_I = uicontrol(f,'Style','text',...
                'String','x-Location',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[435 botTit4-75 130 30]);    
            
lbyLoc_I = uicontrol(f,'Style','text',...
                'String','y-Location',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[435 botTit4-100 130 30]);               

lbInt_speed = uicontrol(f,'Style','text',...
                'String','Speed (0-100 m/s)',...
                'HorizontalAlignment','left',...
                'FontSize',12,...
                'Position',[420 botTit4-125 130 30]);

% Editable Items
cbMultInt = uicontrol(f,'Style','checkbox',...
                'Value',0,'Position',[530 botTit4-18 130 30],...
                'Enable','off',...
                'Callback',@multInt_Callback);
            
tbxLoc_I = uicontrol(f,'Style','edit','FontSize',12,...
                'String','10','Enable','off',...
                'Position',[550 botTit4-63 40 20]);
            
tbyLoc_I = uicontrol(f,'Style','edit','FontSize',12,...
                'String','3.048','Enable','off',...
                'Position',[550 botTit4-88 40 20]);            
            
tbInt_speed = uicontrol(f,'Style','edit','FontSize',12,...
                'String','0','Enable','off',...
                'Position',[550 botTit4-113 40 20]); 

%% Buttons  
pbSim = uicontrol(f,'Style','pushbutton','String','Simulate',...
                    'FontSize',12,'Position',[585 20 75 30],...
                    'Callback',@pbNext_Callback);
                
pbNext = uicontrol(f,'Style','pushbutton','String','Next',...
                    'FontSize',12,'Position',[500 20 75 30],...
                    'Enable','off',...
                    'Callback',@pbNext_Callback);
                
pbPreview = uicontrol(f,'Style','pushbutton','String','Preview',...
                    'FontSize',12,'Position',[415 20 75 30],...
                    'Callback',@pbPreview_Callback);                
                
pbCancel = uicontrol(f,'Style','pushbutton','String','Cancel',...
                    'FontSize',12,'Position',[330 20 75 30],...
                    'Callback',@pbCancel_Callback);
              
%% Callback Functions

    function multInt_Callback(source,callbackdata)
        if (get(cbMultInt,'Value') == get(cbMultInt,'Max'))
            set(pbSim,'Enable','off')
            set(pbNext,'Enable','on')
            set(tbxLoc_I,'Enable','off')
            set(tbyLoc_I,'Enable','off')
            set(tbInt_speed,'Enable','off')
            set(pbPreview,'Enable','off')
        else
            set(pbSim,'Enable','on')
            set(pbNext,'Enable','off')
            set(tbxLoc_I,'Enable','on')
            set(tbyLoc_I,'Enable','on')
            set(tbInt_speed,'Enable','on')
            set(pbPreview,'Enable','on')
        end
    end

    function scen_Callback(source,callbackdata)
        scen = get(popScen,'Value');
        if scen == 1 || scen == 2 || scen == 3 || scen == 4
            set(tbfc,'String','2.445','Enable','off')
            set(tbbw,'String','70','Enable','off')
            set(tbIbw,'String','70','Enable','off')
            set(tbtxP,'String','0.65','Enable','off')
            set(tbtxL,'String','0','Enable','off')
            set(tbrxN,'String','4.5','Enable','off')
            set(tbrxL,'String','0','Enable','off')
            set(tbxLoc_ms,'String','0','Enable','off')
            set(tbyLoc_ms,'String','0','Enable','off')
            set(tbms_speed,'String','0','Enable','off')
            set(tbxLoc,'String','10','Enable','off')
            set(tbyLoc,'String','0','Enable','off')
            set(tbcar_speed,'String','30','Enable','off')
            set(poprpat,'Value',1,'Enable','off')
            set(poptm,'Value',2,'Enable','off')
            set(popItm,'Value',2,'Enable','off')
            set(cbMultInt,'Value',0,'Enable','off')
            set(pbSim,'Enable','on')
            set(pbNext,'Enable','off')
            if scen == 1 || scen == 4
                set(tbxLoc_I,'Enable','off')
                set(tbyLoc_I,'Enable','off')
                set(tbInt_speed,'Enable','off')
            else
                set(tbxLoc_I,'Enable','on')
                set(tbyLoc_I,'Enable','on')
                set(tbInt_speed,'Enable','on')
            end
        else
            set(tbfc,'Enable','on')
            set(tbbw,'Enable','on')
            set(tbIbw,'Enable','on')
            set(tbtxP,'Enable','on')
            set(tbtxL,'Enable','on')
            set(tbrxN,'Enable','on')
            set(tbrxL,'Enable','on')
            set(tbxLoc_ms,'Enable','on')
            set(tbyLoc_ms,'Enable','on')
            set(tbms_speed,'Enable','on')
            set(tbxLoc,'Enable','on')
            set(tbyLoc,'Enable','on')
            set(tbcar_speed,'Enable','on')
            set(poprpat,'Enable','on')
            set(poptm,'Enable','on')
            set(popItm,'Enable','on')
            set(cbMultInt,'Value',0,'Enable','on')
            set(tbxLoc_I,'Enable','on')
            set(tbyLoc_I,'Enable','on')
            set(tbInt_speed,'Enable','on')
        end
     
    end
    
    function pbNext_Callback(source,callbackdata)
       display('Next Pressed')
       
       % RECORD INPUTS
       % Simulation Settings
       Nsweep = str2double(get(tbNumSw,'string'));
       scenType = get(popScen,'value');
       rangeMax = 80;
       MUTUAL_INTERFERENCE = 1;
       TARGET = 1;
       LPmixer = 28e3;
       PHASE_SHIFT = 0;
       target = 'car';
       SAVE = 0;
       fileName = 'filename.mat';
       PLOT.VEHICLES = 0;
       PLOT.POWER = 0;
       PLOT.ACCURACY = 1;
       PLOT.PREVIEW = 0;
       PLOT.BEATSIGNAL = 1;
       PLOT.CHIRP = 0;
       target = 'car';
       
       % General Radar Parameters
       fc = str2double(get(tbfc,'string'))*1e9;
       tmVal = get(poptm,'value');
       tm = str2double(poptmList{tmVal})*1e-3;
       bw = str2double(get(tbbw,'string'))*1e6;
       bw_INT = str2double(get(tbIbw,'string'))*1e6;
       tm_INTVal = get(popItm,'value');
       tm_INT = str2double(popItmList{tm_INTVal})*1e-3;
       tm = 10e-3;
       tm_INT = 10e-3;
       
       % Antenna Parameters
       txPower = str2double(get(tbtxP,'string'));
       txLossFactor = str2double(get(tbtxL,'string'));
       rxNF = str2double(get(tbrxN,'string'));
       rxLossFactor = str2double(get(tbrxL,'string'));
       options = load('SampleRadiationPatterns.mat');
       rad_patVal = get(poprpat,'value');
       if rad_patVal == 1
           rad_pat = options.TPLink;
       elseif rad_patVal == 2
           rad_pat = options.samplePatch;
       else
           rad_pat = options.sampleDirectional;
       end
       
       % Main System Parameters
       xLoc_ms = str2double(get(tbxLoc_ms,'string'));
       yLoc_ms = str2double(get(tbyLoc_ms,'string'));
       radar_init_pos = [xLoc_ms;yLoc_ms;0.5];
       radar_speed = str2double(get(tbms_speed,'string'));
       
       % Target Parameters
       xLoc = str2double(get(tbxLoc,'string'));
       yLoc = str2double(get(tbyLoc,'string'));
       car_init_pos = [xLoc;yLoc;0.5];
       car_speed = str2double(get(tbcar_speed,'string'));
       
       % Interferer Parameters
       multInt = get(cbMultInt,'Value');
       xLoc_I = str2double(get(tbxLoc_I,'string'));
       yLoc_I = str2double(get(tbyLoc_I,'string'));
       itfer_init_pos = [xLoc_I;yLoc_I;0.5];
       itfer_speed = str2double(get(tbInt_speed,'string'));
       itferData = [xLoc_I,yLoc_I,itfer_speed];
             
       % VERIFY ALL INPUTS ARE VALID
        error = 0;
       % General Radar Parameters
       if isnan(fc)||fc<2e9||fc>3e9
           error = 1;
       end
       
       if isnan(bw)||bw<1e6||bw>1000e6
           error = 1;
       end
       
       if isnan(radar_speed)||radar_speed<0||radar_speed>100
           error = 1;
       end
       
       if isnan(bw_INT)||bw_INT<1e6||bw_INT>1000e6
           error = 1;
       end
       
       % Antenna Parameters
       if isnan(txPower)
           error = 1;
       end
       
       if isnan(txLossFactor)
           error = 1;
       end
       
       if isnan(rxNF)
           error = 1;
       end
       
       if isnan(rxLossFactor)
           error = 1;
       end
       
       % Target Parameters
       if isnan(xLoc)
           error = 1;
       end
       
       if isnan(yLoc)
           error = 1;
       end
       
%        if isnan(car_speed)||car_speed<0||car_speed>100
%            error = 1;
%        end
       
%        if isnan(targRange)||targRange<1||targRange>100
%            error = 1;
%        end
       
       % Simulation Settings
       if isnan(Nsweep)||Nsweep<8||Nsweep>32
           error = 1;
       end
       
       
       if error == 1 
          errordlg('Check that input values are within ranges.','Invalid Input','modal')
          return
       end
       
       display(scenType)
       
       if scenType == 1
           MUTUAL_INTERFERENCE = 0;
       elseif scenType == 2 || scenType == 4
           TARGET = 0;
       end
        
       if multInt == 0
          [radarPos, tgtPos, itferPos,...
            radarVel, tgtVel, itferVel] = prevEnv( Nsweep, tm,...
            radar_init_pos, car_init_pos, itferData,...
            radar_speed, car_speed, 0,...
            MUTUAL_INTERFERENCE, 0);

          [~, beatsignal, fs_bs] = radarSim(fc, tm, tm_INT, rangeMax, bw,...
            bw_INT, Nsweep, LPmixer, rad_pat, radarPos,...
            itferPos, tgtPos, radarVel, itferVel,...
            tgtVel, txPower, txLossFactor,rxNF, rxLossFactor,...
            PLOT, MUTUAL_INTERFERENCE,TARGET, ...
            PHASE_SHIFT, SAVE, fileName, target);
        
          [output] = calcSimSIR(beatsignal, fs_bs)
       else
          close(gcf)
          numIntdlg
       end
%        if scenType == 1
%             display('1 Selected');
%        elseif scenType == 2
%             display('2 Selected');
%        elseif scenType == 3
%             display('3 Selected');
%        elseif scenType == 4
%             display('4 Selected');
%        else
%             close(gcf)
%             display('Custom Selected');
%             numIntdlg
%        end
       display('------------------');
                       
    end

    function pbPreview_Callback(source,callbackdata)
       % Simulation Settings
       scenType = get(popScen,'value');
       Nsweep = str2double(get(tbNumSw,'string'));
       
       % General Radar Parameters
       tmVal = get(poptm,'value');
       tm = str2double(poptmList{tmVal})*1e-3;
       
       % Main System Parameters
       xLoc_ms = str2double(get(tbxLoc_ms,'string'));
       yLoc_ms = str2double(get(tbyLoc_ms,'string'));
       radar_init_pos = [xLoc_ms;yLoc_ms;0.5];
       radar_speed = str2double(get(tbms_speed,'string'));
       
       % Target Parameters
       xLoc = str2double(get(tbxLoc,'string'));
       yLoc = str2double(get(tbyLoc,'string'));
       car_init_pos = [xLoc;yLoc;0.5];
       car_speed = str2double(get(tbcar_speed,'string'));
       
       % Interferer Parameters
       xLoc_I = str2double(get(tbxLoc_I,'string'));
       yLoc_I = str2double(get(tbyLoc_I,'string'));
       itfer_init_pos = [xLoc_I;yLoc_I;0.5];
       itfer_speed = str2double(get(tbInt_speed,'string'));
       itferData = [xLoc_I,yLoc_I,itfer_speed];
       
       % Scene Specific Settings
       MUTUAL_INTERFERENCE = 1;
       if scenType == 1
           TARGET = 1;
           MUTUAL_INTERFERENCE = 0;
       elseif scenType == 2
           TARGET = 0;
       elseif scenType == 3
           TARGET = 1;
       else
           TARGET = 0;
           itfer_speed = car_speed;
           itfer_init_pos = car_init_pos;
           itferData = [xLoc yLoc car_speed];
       end
       
       PLOT = 1;
       prevEnv( Nsweep, tm,...
            radar_init_pos, car_init_pos, itferData,...
            radar_speed, car_speed, PLOT, MUTUAL_INTERFERENCE, TARGET);       
        
       display('Plot Preview Environment')
       display('------------------');
    end

    function pbCancel_Callback(source,callbackdata)
       display('Program Cancelled')
       display('------------------');
       close(gcf)
       clear all
    end

    
end
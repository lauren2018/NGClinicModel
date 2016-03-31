%% FMCW Example
% Based on Automotive Radar Example from Matlab
%   Copyright 2012-2015 The MathWorks, Inc.
clc
clear


% % Include these files to run this file
% FMCWsimsetup
% plotPower
% plotVehiclePositions
% plotAccuracy

%% Turn on and off sectio0s of code
PLOT.VEHICLES = 0;
PLOT.POWER = 0;
PLOT.ACCURACY = 0;
PLOT.CHIRP = 0;
PLOT.MUTUAL_INTERFERENCE_SPECTROGRAM = 0;
SCENARIO = 1;
MUTUAL_INTERFERENCE= 0;
ONE_WAY_CHANNEL = 1;

% Scenario 1 == No interferer
% Scenario 2 == Interferer in opposing lane, no target objects
% Scenario 3 == Interferer in opposing lane, target;
% Scenario 4 == Direct interference

%% Set up

%% Constants
fc = 2.43e9;  
c = 3e8;   
lambda = c/fc;  
range_max = 200;   
tm = 20e-3; 
range_res = 100;  
bw = range2bw(range_res,c);
sweep_slope = bw/tm;        
fr_max = range2beat(range_max,sweep_slope,c); 
v_max = 230*1000/3600; 
fd_max = speed2dop(2*v_max,lambda);
fb_max = fr_max+fd_max;
fs = max(2*fb_max,bw);

%% FMCW Generation
hwav = phased.FMCWWaveform('SweepTime',tm/2,'SweepBandwidth',bw,...
    'SampleRate',fs, 'SweepDirection', 'Triangle', 'NumSweeps', 2); %full triangle


%% Radar Parameters
radar_speed = 1; %40;    %m/s, 60mph
radar_init_pos = [0;0;0.5];
hradarplatform = phased.Platform('InitialPosition',radar_init_pos,...
    'Velocity',[radar_speed;0;0]);
hspec = dsp.SpectrumAnalyzer('SampleRate',fs,...
    'PlotAsTwoSidedSpectrum',true,...
    'Title','Spectrum for received and dechirped signal',...
    'ShowLegend',true);

%% Target Model Parameters
car_speed = 31.29; % m/s, 70 mph
car_dist = 10; %radar_speed*3;     %cars should be 3 seconds away!
car_rcs = db2pow(min(10*log10(car_dist)+5,20));
hcar = phased.RadarTarget('MeanRCS',car_rcs,'PropagationSpeed',c,...
    'OperatingFrequency',fc);
hcarplatform = phased.Platform('InitialPosition',...
    [hradarplatform.InitialPosition(1)+car_dist;0;0.5],...
    'Velocity',[car_speed;0;0]);

%% Interference Model

% Car lanes are about 10 ft --> 3.6576 m
itfer_init_pos = [hcarplatform.InitialPosition(1)+10, 3.6576, 0.5]';
itfer_speed = 0;
[int_rng, int_ang] = rangeangle(itfer_init_pos, hradarplatform.InitialPosition);
itfer_rcs = db2pow(min(10*log10(int_rng)+5,20));

hitfer = phased.RadarTarget('MeanRCS',itfer_rcs,'PropagationSpeed',c,...
    'OperatingFrequency',fc);
hitferplatform = phased.Platform('InitialPosition',...
    itfer_init_pos,...
    'Velocity',[itfer_speed;0;0]);

%% Free Space Channel Set Up
hchannel_twoway = phased.FreeSpace('PropagationSpeed',c,...
    'OperatingFrequency',fc,'SampleRate',fs,'TwoWayPropagation',true);
hchannel_oneway = phased.FreeSpace('PropagationSpeed',c,...
    'OperatingFrequency',fc,'SampleRate',fs,'TwoWayPropagation',false);

%% Antenna Model Set Up
% % MIT Values
ant_dia = 0.1524;   % coffee can is 6 inch. 0.1524 m.
ant_aperture = 6.06e-4; %pi*ant_dia^2;    %6.06e-4;       % in square meter
ant_gain = 8.4;  % value from MIT Slide deck || 10*log10((pi*ant_dia/lambda)^2);

tx_ppower = 0.65; %db2pow(5)*1e-3;                     % in watts
tx_gain = 24;   %9+ant_gain;                           % in dB
tx_loss_factor = 0;                             % in dB **TODO**

rx_power = 1;   %Watt
% IF Power = -28 dBm
rx_gain = 15+ant_gain;                          % in dB
rx_nf = 4.5;                                    % in dB
rx_loss_factor = 0;                             % in dB **TODO


% Original Example Values
% ant_aperture = 6.06e-4;                         % in square meter
% ant_gain = aperture2gain(ant_aperture,lambda);  % in dB                                                 %radiator
% 
% tx_ppower = db2pow(5)*1e-3;                     % in watts
% tx_gain = 9+ant_gain;                           % in dB
% tx_loss_factor = 0;      
% 
% rx_gain = 15+ant_gain;                          % in dB
% rx_nf = 4.5;                                    % in dB
% rx_loss_factor = 0;                             % in dB **TODO


htx = phased.Transmitter('PeakPower',tx_ppower,...
    'Gain',tx_gain,...
    'LossFactor',tx_loss_factor);
hrx = phased.ReceiverPreamp('Gain',rx_gain,...
    'NoiseFigure',rx_nf,...
    'LossFactor', rx_loss_factor,...
    'SampleRate',fs);
%% Simulation Loop 
Nsweep = 64;

%% Initializing zero-vectors
radar_pos = zeros(Nsweep,3);
radar_vel = zeros(Nsweep,3);
tgt_pos = zeros(Nsweep,3);
tgt_vel = zeros(Nsweep, 3);
itfer_pos = zeros(Nsweep, 3);
itfer_vel = zeros(Nsweep,3);
xr = zeros(length(step(hwav)), Nsweep);
maxdist = 10;

% Simulation for multiple Sweeps
for m = 1:Nsweep
    
    % Move objects
    [radar_pos(m,:),radar_vel(m,:)] = step(...
        hradarplatform,hwav.SweepTime*hwav.NumSweeps);   % radar moves during sweep
    [tgt_pos(m,:),tgt_vel(m,:)] = step(hcarplatform,... 
        hwav.SweepTime*hwav.NumSweeps);                  % car moves during sweep
    [itfer_pos(m,:), itfer_vel(m,:)] = step(hitferplatform,...
        hwav.SweepTime*hwav.NumSweeps);                  % interferer moves during sweep
  
    % Generate Our Signal
    signal.x = step(hwav);                      % generate the FMCW signal
    signal.xt = step(htx,signal.x);             % transmit the signal
       
    if ONE_WAY_CHANNEL
        signal.xp = step(hchannel_oneway,signal.xt,radar_pos(m,:)',...
             tgt_pos(m,:)',...
             radar_vel(m,:)',...
             tgt_vel(m,:)');                   % propagate through channel
        signal.xrefl = step(hcar,signal.xp);                 % reflect the signal 
        signal.xdone = step(hchannel_oneway,...
            signal.xrefl,tgt_pos(m,:)',radar_pos(m,:)',...
            tgt_vel(m,:)',radar_vel(m,:)');    % propagate through channel

    else
        signal.xp = step(hchannel_twoway,...
            signal.xt,...
            radar_pos(m,:)',....
            tgt_pos(m,:)',...
            radar_vel(m,:)',...
            tgt_vel(m,:)');                     % Propagate signal
        signal.xdone = step(hcar,signal.xp);        % Reflect the signal
    end
    
   
    % Interfering Signal
    if MUTUAL_INTERFERENCE
        xitfer_gen = step(hwav);                % Generate interfer signal
        xitfer_t = step(htx, xitfer_gen);       % Transmit interfer signal
        signal.xitfer = step(hchannel_oneway, xitfer_t, ...
            itfer_pos(m,:)', radar_pos(m,:)',...
            itfer_vel(m,:)', radar_vel(m,:)');  % Propagate through channel       
        signal.xrx = step(hrx,(signal.xdone + signal.xitfer));                        % receive the signal
    else
        signal.xrx = step(hrx,signal.xdone);
    end
     
    xd = dechirp(signal.xrx,signal.x);           % dechirp the signal
    xr(:,m) = xd;                             % buffer the dechirped signal
end




%% Beat Signal
    mult = 2^4;
    figure
    spectrogram(xd, 32*mult, 16*mult, 32*mult, fs, 'yaxis')
    title('Spectrogram of Beat Signal without Interferer')
   
    
    
%% Plot the difference in the received signal
 if PLOT.MUTUAL_INTERFERENCE_SPECTROGRAM
    mult = 2^4;
    figure
    subplot(311)
    [sdone,wdone,tdone] = spectrogram(signal.xdone, 32*mult, 16*mult, 32*mult, fs, 'yaxis');
    imagesc(tdone, wdone,mag2db(abs(sdone)));
    ca = caxis;
    colorbar
    title('No Mutual Interference')
    
    subplot(312)
    [srx,wrx,trx] = spectrogram(signal.xdone + signal.xitfer, 32*mult, 16*mult, 32*mult, fs,'yaxis');
    imagesc(trx, wrx, mag2db(abs(srx)));
    caxis(ca)
    hb = colorbar;
    title(hb, 'Power/frequency (dB/Hz)')
    title('With Mutual Interference')
    
    subplot(313)
    imagesc(tdone, wdone,abs(sdone) - abs(srx));

    colorbar
    title('Difference')
    suptitle('Spectrogram Interference Effects')
    xlabel('time(s)')
    ylabel('Frequency (MHz)')
    
    mult = 2^4;
    figure
    subplot(211)
    spectrogram(signal.xdone, 32*mult, 16*mult, 32*mult, fs, 'yaxis')
    title('No Mutual Interference')
    ca = caxis;
    
    subplot(212)
    spectrogram(signal.xdone + signal.xitfer, 32*mult, 16*mult, 32*mult, fs,'yaxis')
    title('With Mutual Interference')
    caxis(ca);
    suptitle('Spectrogram Interference Effects')
    
end 


%% Plotting Spectral Density

if (PLOT.POWER)
    field = fieldnames(signal);
    for n=1:length(field)
        figure
        x = signal.(field{n});
        [px,f] = periodogram(x, 2*hamming(length(x)), 2^nextpow2(length(x)), fs);
        px = 10*log10(px);
        plot(f,px,'-','DisplayName', ['(' num2str(n) ') '  field{n}]);
        title('Periodogram Power Spectral Density Estimate')
        legend('Location', 'eastoutside')
        text(f(6), px(6), num2str(n))   
        xlabel('Frequency (Hz)')
        ylabel('Power (dB)')
    end
    hold off
    title('Periodogram Power Spectral Density Estimate')
    legend('Location', 'eastoutside')
    
end

%%Plotting Vehicle Positions
%% Plotting Vehicle Positions
if (PLOT.VEHICLES)
    figure
    radar_pos_x = radar_pos(:,1);
    radar_pos_y = radar_pos(:,2);
    radar_pos_z = radar_pos(:,3);
    tgt_pos_x = tgt_pos(:,1);
    tgt_pos_y = tgt_pos(:,2);
    tgt_pos_z = tgt_pos(:,3);
    int_pos_x = itfer_pos(:,1);
    int_pos_y = itfer_pos(:,2);
    int_pos_z = itfer_pos(:,3);
    hold on
    plot(radar_pos_x,radar_pos_y, 'g-', 'DisplayName','Our Radar');
    plot(radar_pos_x(1),radar_pos_y(1), 'go', 'DisplayName', 'Start');
    plot(radar_pos_x(Nsweep),radar_pos_y(Nsweep), 'gx', 'DisplayName', 'End');

    plot(tgt_pos_x, tgt_pos_y, 'k-', 'DisplayName', 'Target System');
    plot(tgt_pos_x(1), tgt_pos_y(1), 'ko', 'DisplayName', 'Start');
    plot(tgt_pos_x(Nsweep), tgt_pos_y(Nsweep), 'kx', 'DisplayName', 'End');
    if (MUTUAL_INTERFERENCE)
        plot(int_pos_x, int_pos_y, 'r-', 'DisplayName', 'Interferer System');
        plot(int_pos_x(1), int_pos_y(1), 'ro', 'DisplayName', 'Start');
        plot(int_pos_x(Nsweep), int_pos_y(Nsweep), 'rx', 'DisplayName', 'End');
    end
    xlabel('X (m)')
    ylabel('Y (m)')
    legend('Location', 'eastoutside')
    title('Position of Vehicles')
    grid
    hold off
end

%% Calculate Range and Doppler
% TODO Fix

xr_upsweep = xr(1:hwav.SweepTime*fs,:);
xr_downsweep = xr((hwav.SweepTime*fs):end, :);
if (1)
    figure
    hrdresp = phased.RangeDopplerResponse('PropagationSpeed',c,...
        'DopplerOutput','Speed',...
        'OperatingFrequency',fc,...
        'SampleRate',fs,...
        'RangeMethod','FFT',...
        'DechirpInput', false,...
        'SweepSlope',sweep_slope,...
        'RangeFFTLengthSource','Property','RangeFFTLength',2048,...
        'DopplerFFTLengthSource','Property','DopplerFFTLength',256);

    clf;
    plotResponse(hrdresp,xr_upsweep)                    % Plot range Doppler map
    axis([0 3 0 50])
    caxis([0 100])
    title('Without Stationary Interference')
end

%% Calculation Range Distance
Ncalc = floor(Nsweep/4);


fbu_rng = rootmusic(pulsint(xr_upsweep,'coherent'),1,fs);
fbd_rng = rootmusic(pulsint(xr_downsweep,'coherent'),1,fs);
output.rng_est = beat2range([fbu_rng fbd_rng],sweep_slope,c)/2;
fd = -(fbu_rng+fbd_rng)/2;
output.v_est = dop2speed(fd,lambda)/2;

rng_est = zeros(Nsweep,1);
rng_true = zeros(Nsweep,1);
v_est = zeros(Nsweep, 1);
for i = 1:Nsweep
    fbu_rng = rootmusic(pulsint(xr_upsweep(:,i),'coherent'),1,fs);
    fbd_rng = rootmusic(pulsint(xr_downsweep(:,i),'coherent'),1,fs);
    rng_est(i) = beat2range([fbu_rng fbd_rng],sweep_slope,c)/2;
    fd = -(fbu_rng+fbd_rng)/2;
    v_est(i) = dop2speed(fd,lambda)/2;
    rng_true(i) = sqrt(sum((radar_pos(i,:)-tgt_pos(i,:)).^2));
end

%% Plot accuracy of calculations
if (PLOT.ACCURACY)
    figure
    subplot(211);
    suptitle(['Accuracy with ' num2str(Nsweep) ' Sweeps'])
    plot((1:Nsweep)*hwav.SweepTime*hwav.NumSweeps, rng_true, ...
        '.-', 'DisplayName', 'Target Range (m)')
    hold on
    plot((1:Nsweep)*hwav.SweepTime*hwav.NumSweeps, rng_est, ...
        '.-', 'DisplayName', 'Calculated Range (m)');
    legend('Location', 'eastoutside'); title('Range'); ylabel('m'); xlabel('s');
%     axis([0 0.08 8 11.1])
    
    subplot(212);
    plot((1:Nsweep)*hwav.SweepTime*hwav.NumSweeps, ...
       (radar_speed-car_speed)*ones(Nsweep,1), ...
        '.-', 'DisplayName', 'Target Speed (m/s)')
    hold on
    plot((1:Nsweep)*hwav.SweepTime*hwav.NumSweeps, v_est,...
        '.-', 'DisplayName', 'Calculated Speed (m/s)');
    hold off
    legend('Location', 'eastoutside')
    title('Velocity'); ylabel('m/s');  xlabel('s');
end
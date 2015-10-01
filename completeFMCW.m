% Top Level File for the FMCW Radar

close all
clear
clc
c = 3*10^8;         % Speed of light (m/s)
df = 380*10^6;      % Bandwidth (Hz)
fc = 1.2*10^9;      % Center frequency (Hz)
fmin = fc-df/2;     % Hz
fmax = fc+df/2;     % 
fs = fmax*2.1;      % Sampling rate (Hz)
Tm = 1.25*10^-3;    %(1/fc)*10^4;   % Modulation index (s)
dt = 1/fs;          % Time Step (s)
t = 0:dt:2*Tm;      % Duration of chirp (s)
theta = pi/2;       % Angle of Arrival for object (radians)
distance = 20;      % Distance of object (m)
velocity = 0;       % Velocity of object (m/s)
gamma = df/Tm;      % Chirp Rate

tic

%% Preallocate memory
% tx_signal = zeros(7297501, 1);
% reflected_signal = zeros(7297501, 1);
% tx_hilbert = zeros(7297501,1);
% freq_hilbert = zeros(7297501,1);

%% Object Processing

% Generate signal
ramp_gen = sawtooth(2*pi*t/(2*Tm),0.5);
tx_signal = vco(ramp_gen,[fmin fmax],fs);
len = length(tx_signal);
fftsize = 2^nextpow2(len);
tx_signal = fft(tx_signal, fftsize);
tx_signal = ifft(tx_signal(1:fftsize/2), fftsize);
tx_signal = tx_signal(1:len);

clear ramp_gen fftsize len t df fmin fmax Tm
 
% % Plot Transmitted Signal
% figure(1)
% plot(1:length(tx_signal), real(tx_signal), 1:length(tx_signal), imag(tx_signal))
% title('Plot TX Signal')

% % Plot Generated Chirp
% figure(2)
% spectrogram(tx_signal,256*4,220*4,512*16,fs, 'yaxis')
% title('Spectrogram of Generated Chirp')


%% Doppler Shift Calculations

% Doppler Shift
vr = velocity*sin(theta);   % radial velocity (m/s)
lambda = c/fc;              % wavelength of carrier signal (m)
fdoppler = (2*vr)/lambda;   % Doppler shift (Hz)

% Determine the necessary resolution for the fft shift
if (fdoppler ~= 0)
    fftsize = 2^nextpow2(max(length(tx_signal),fs/fdoppler));
else 
    fftsize = 2^nextpow2(length(tx_signal));
end


% Freq Shift Data
fftres = fs/fftsize;
fftshift = round(fdoppler/fftres);
fdoppler = fftshift*fftres;
fft_tx = fft(tx_signal,fftsize);

% Shift the FFT data
fft_tx_shift = circshift(fft_tx(1:fftsize/2), [0, fftshift]);
tx_freqshifted = ifft(fft_tx_shift, fftsize);
tx_freqshifted = tx_freqshifted(1:length(tx_signal));

% %% Plot Doppler Shifted Data
% figure(3)
% spectrogram(tx_freqshifted,256*2,220*2,512*8,fs,'yaxis')
% title('Spectrogram of Doppler Shifted Chirp')
clear lambda fftsize fftshift fft_tx_shift fft_tx theta vr lambda fdoppler fftres

%% Time Shift Calculations
% Determine Time Shift
tdelay = 2*distance/c;      % time delay (s)
tshift = tdelay/dt;

len = length(tx_freqshifted);
reflected_signal = circshift(tx_freqshifted, [0, round(tshift)]);

% % Plot Time Shifted Chirp
% figure (4)
% spectrogram(reflected_signal,256*2,220*2,512*8,fs,'yaxis')
% title('Spectrogram of Reflected Chirp')

clear tdelay tshift tx_freqshifted c len
toc 

tic
%% Hilbert Transform
tx_hilbert = hilbert(real(tx_signal));
refl_hilbert = hilbert(real(reflected_signal));

clear tx_signal reflected_signal

txFreqs = fs/(2*pi)*diff(unwrap(angle(tx_hilbert)));
rxFreqs = fs/(2*pi)*diff(unwrap(angle(refl_hilbert)));

clear tx_hilbert refl_hilbert

% Plot Instantaneous Frequency
figure (5)
plot((1000:length(txFreqs)-1000)*dt,txFreqs(1000:length(txFreqs)-1000),...
    (1000:length(rxFreqs)-1000)*dt, rxFreqs(1000:length(txFreqs)-1000))
xlabel('Time')
ylabel('Hz')
grid on
title('Instantaneous Frequency')
legend('Transmitted Signal', 'Reflected Signal')


%% Plot Beat Frequency
beat = abs(rxFreqs - txFreqs);

% Add moving average filter
sizefilter = 100;
filter = repmat(1/sizefilter, 1, sizefilter);
beat = conv(beat, filter, 'same');

clear filter sizefilter

figure(6)
plot((1000:length(beat)-1000)*dt + 1000*dt, beat(1000:length(beat)-1000));
xlabel('Time(s)')
ylabel('Frequency (Hz)')
title('Frequency Difference')

%% Detect plateaus
[txMax,txMaxInd] = max(txFreqs);
txMin = min(txFreqs);
[rxMax,rxMaxInd] = max(rxFreqs);
[rxMin,rxMinInd] = min(rxFreqs);

f1 = abs(median(beat(rxMinInd:txMaxInd)));
f2 = abs(median(beat(rxMaxInd:end)));


%% Calculate velocity and distance
calc_fD = 0.5*(f2-f1);
calc_fB = 0.5*(f2+f1);

calc_vel = abs(calc_fD*(3*10^8)/(2*fc));
vel_error= (calc_vel - velocity)/velocity;

calc_dist = calc_fB*(3*10^8)/(2*gamma);
dist_error = (calc_dist - distance)/distance;
toc

clear f1 f2 txFreqs txMax txMaxInd txMin fftres fmax fmin ...
    rxFreqs rxMax rxMaxInd rxMin rxMinInd beat gamma calc_fB ...
    dt fc fs  gamma 
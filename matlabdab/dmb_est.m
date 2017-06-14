clear all;
f=fopen('C:\temp\DAB.samples.syd1', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);

cv_usrp=transpose(cv_usrp);
fs_usrp=2e6;
resamp_p = 128;
resamp_q = 125; % change depending on fs_u
fs_resamp=fs_usrp * resamp_p / resamp_q;
tnull=2656; %symbols, trans mode I
tsym = 2552;
tu = 2048;
tcp = tsym-tu;
tframe=196608; %symbols, trans mode I
% p / q * 2Msps = 2.048Msps

cv_resamp = resample(cv_usrp, resamp_p, resamp_q);
f_resamp=-fs_resamp/2:fs_resamp/length(cv_resamp):fs_resamp/2-1/fs_resamp;

b=fir1(100, 850e3/(fs_resamp/2));

cv_resamp_lpf=filter(b,1, cv_resamp);
%cv_resamp_lpf = cv_resamp_lpf .* exp(j*160*2*pi*t_resamp);

figure(1)
title('USRP resamp FFT (LPFd)');
plot(f_resamp/1000,((abs(fftshift(fft(cv_resamp_lpf))).^2)));
xlabel('kHz'); ylabel('power'); 

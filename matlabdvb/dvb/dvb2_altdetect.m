clear all;
fprintf(1,'Loading samples...\n');
f=fopen('C:\temp\usrp.dat', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);
clear v;
%f=fopen('C:\temp\dab_mode1_basicrx_2msps.trunc.cf', 'rb'); v=fread(f, inf, 'int'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);

cv_usrp=transpose(cv_usrp);
fs_usrp=2e6;
resamp_p = 128;
resamp_q = 125; % change depending on fs_u
fs_resamp=fs_usrp * resamp_p / resamp_q;
tnull=2656; %symbols, trans mode I
tsym = 2552;
tu = 2048;
tcp = tsym-tu;
symsframe=76; %incl sync, excl null
tframe=196608; %symbols, trans mode I
ncarriers=1536;
% p / q * 2Msps = 2.048Msps
crcpoly=[1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
firepoly = [1 0 1 1 1 1 0 0 0 0 0 1 0 1 1 1 1];
%puncpat

puncpat(1,:)=[1 1 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 0 0 0];
puncpat(2,:)=[1 1 0 0  1 0 0 0  1 0 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 0 0 0  1 0 0 0];
puncpat(3,:)=[1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 0 0 0  1 0 0 0];
puncpat(4,:)=[1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0];
puncpat(5,:)=[1 1 0 0  1 1 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 0 0 0];
puncpat(6,:)=[1 1 0 0  1 1 0 0  1 1 0 0  1 0 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 0 0 0];
puncpat(7,:)=[1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 0 0 0];
puncpat(8,:)=[1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0];
puncpat(9,:)=[1 1 1 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 0 0];
puncpat(10,:)=[1 1 1 0  1 1 0 0  1 1 0 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 0 0  1 1 0 0];
puncpat(11,:)=[1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 0 0  1 1 0 0];
puncpat(12,:)=[1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0];
puncpat(13,:)=[1 1 1 0  1 1 1 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 0 0];
puncpat(14,:)=[1 1 1 0  1 1 1 0  1 1 1 0  1 1 0 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 0 0];
puncpat(15,:)=[1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 0 0];
puncpat(16,:)=[1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0];
puncpat(17,:)=[1 1 1 1  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 0];
puncpat(18,:)=[1 1 1 1  1 1 1 0  1 1 1 0  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 0  1 1 1 0];
puncpat(19,:)=[1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 0  1 1 1 0];
puncpat(20,:)=[1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0];
puncpat(21,:)=[1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 0];
puncpat(22,:)=[1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 0  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 0];
puncpat(23,:)=[1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 0];
puncpat(24,:)=[1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1  1 1 1 1];


    


%figure(1)
%title('USRP FFT');
%plot(f_usrp/1000,((abs(fftshift(fft(cv_usrp))).^2)));
%xlabel('kHz'); ylabel('power');

%resample
fprintf(1,'Resampling from %fMHz to %fMHz\n', fs_usrp/1e6,fs_resamp/1e6);
cv_resamp = resample(cv_usrp, resamp_p, resamp_q);
clear cv_usrp;

%fir filter to 90kHz
fprintf(1,'Filtering unwanted high frequencies...\n');
b=fir1(100, 850e3/(fs_resamp/2));
[tmp_h, tmp_f] = freqz(b,[1], 500, fs_resamp);

cv_resamp_lpf=filter(b,1, cv_resamp);
clear cv_resamp;



clear all;
fprintf(1,'Loading samples...\n');
f=fopen('C:\\temp\\optus_de_9440_4000ksps.usrp', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(2:2:end)+v(1:2:end)*j; fclose(f);
clear v;
%f=fopen('C:\temp\dab_mode1_basicrx_2msps.trunc.cf', 'rb'); v=fread(f, inf, 'int'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);


fs = 4e6;

centre_freq = 944.4e6;

cv_usrp = cv_usrp';




% cv_usrp = cv_usrp(1:6e5); %600 ksamp = 60ksyms = 384 bursts = 48 frames - should be enough for 4-5 FCCH/SCH
% 
% 
% %freq correct early
% 
% te = 0:1/fs:length(cv_usrp)/fs-1/fs;
% 
% cv_usrp = cv_usrp .* exp(-j*2*pi*-4.203e3.*te);
% 
% 
% %fir filter to +-100kHz
% fprintf(1,'Filtering unwanted high frequencies...\n');
% b=fir1(100, 120e3/(fs/2));
% [tmp_h, tmp_f] = freqz(b,[1], 500, fs);
% 
% cv_usrp=filter(b,1, cv_usrp);



upsamp =65;
downsamp = 96*4;
cv_usrp_resamp = resample(cv_usrp, upsamp, downsamp);

fs_resamp = fs * upsamp/downsamp;

nsamples = length(cv_usrp_resamp);

fftout = fftshift(fft(cv_usrp));



f = -fs/2:fs/length(cv_usrp):fs/2-fs/length(cv_usrp);

figure(1);

plot (f,(abs(fftout).^2));


figure(2);


gsmrate = 52e6/192;

sampspersym = fs_resamp/gsmrate;

[pks locs] = findpeaks(-1*abs(cv_usrp_resamp), 'minpeakheight', -200, 'minpeakdistance', 100);

%cv_usrp_resamp =cv_usrp_resamp(15942:15942+30*8*156.25*sampspersym);



t = 0:nsamples-1;
plot (t(1:length(cv_usrp_resamp))/(1), real(cv_usrp_resamp))%,t,imag(cv_usrp_resamp));
title('Optus GSM burst, Doncaster East CellID 31010')
xlabel('bursts, GSM sample clock = 270.8ksym/sec')
ylabel('Amplitude')

fcch = cv_usrp_resamp(1:157);

%figure(3)

%plot([1:64], abs(fftshift(fft(fcch))).^2)

fcch_avg_angle = mean(mod(angle(fcch(5:end-5)) - angle(fcch(5-1:end-5-1)) + 2* pi, 2*pi));
fcch_est_freq =  fcch_avg_angle / (2*pi) * fs_resamp;

fcch_est_freq_adj = fcch_est_freq - (52e6/192 * 1/4); 

%fcch_est_freq_adj = (fcch_avg_angle - pi/2) * fs_resamp;

%fcch_est_freq_adj =    5.696496847110070e+003;

fcch_est_freq_adj= 8.3622e+003;
t = 0:1/fs_resamp:length(cv_usrp_resamp)/fs_resamp-1/fs_resamp;

cv_usrp_resamp = cv_usrp_resamp .* exp(-1i*2*pi*fcch_est_freq_adj*t);

synch_train_seq =  [ ...
1 0 1 1 1 0 0 1 ...
0 1 1 0 0 0 1 0 ...
0 0 0 0 0 1 0 0 ... 
0 0 0 0 1 1 1 1 ...
0 0 1 0 1 1 0 1 ...
0 1 0 0 0 1 0 1 ...
0 1 1 1 0 1 1 0 ...
0 0 0 1 1 0 1 1 ];

tsc_0 = [0 0 1 0 0 1 0 1 1 1 0 0 0 0 1 0 0 0 1 0 0 1 0 1 1 1];
tsc_1 = [0 0 1 0 1 1 0 1 1 1 0 1 1 1 1 0 0 0 1 0 1 1 0 1 1 1];
tsc_2 = [0 1 0 0 0 0 1 1 1 0 1 1 1 0 1 0 0 1 0 0 0 0 1 1 1 0];
tsc_3 = [0 1 0 0 0 1 1 1 1 0 1 1 0 1 0 0 0 1 0 0 0 1 1 1 1 0];
tsc_4 = [0 0 0 1 1 0 1 0 1 1 1 0 0 1 0 0 0 0 0 1 1 0 1 0 1 1];
tsc_5 = [0 1 0 0 1 1 1 0 1 0 1 1 0 0 0 0 0 1 0 0 1 1 1 0 1 0];
tsc_6 = [1 0 1 0 0 1 1 1 1 1 0 1 1 0 0 0 1 0 1 0 0 1 1 1 1 1];
tsc_7 = [1 1 1 0 1 1 1 1 0 0 0 1 0 0 1 0 1 1 1 0 1 1 1 1 0 0];

dummy_burst_mid = [1 1 1 1 1 0 1 1 0 1 1 1 0 1 1 0 0 0 0 0 1 0 1 ...
	0 0 1 0 0 1 1 1 0 0 0 0 0 1 0 0 1 0 0 0 1 0 ...
	0 0 0 0 0 0 1 1 1 1 1 0 0 0 1 1 1 0 0 0 1 0 1 1 1 0 ...
	0 0 1 0 1 1 1 0 0 0 1 0 1 ...
	0 1 1 1 0 1 0 0 1 0 1 0 0 0 1 1 0 0 1 1 0 0 1 1 1 0 0 ...
	1 1 1 1 0 1 0 0 1 1 1 1 1 0 0 0 1 0 0 1 0 1 1 1 1 1 0 ...
	1 0 1 0 ];

dummy_burst = [ 0 0 0 dummy_burst_mid 0 0 0 ];


%synch_train_seq = ;

%synch_train_seq = zeros(1,64);

samps_per_sym = floor(fs_resamp / (52e6/192))
synch_train_seq_diff = mod(synch_train_seq(1:end-1) + synch_train_seq(2:end), 2);
synch_train_seq_nrz = zeros(1,length(synch_train_seq_diff)* samps_per_sym);

for i=1:samps_per_sym,
    synch_train_seq_nrz(i:samps_per_sym:end) = (1-2*synch_train_seq_diff);
end

synch_train_seq_integrated = pi/2*cumsum(synch_train_seq_nrz)/samps_per_sym;


tt = [-1:1/samps_per_sym:1];
T=1;
BT=0.3;
d=sqrt(log(2))/(2*pi*BT);
gsmpulse = exp(-tt.^2/(2*d^2*T^2))/(sqrt(2*pi)*d*T)/samps_per_sym;
gsmpulse = gsmpulse/sum(abs(gsmpulse)); %counter the fact that we are not using the full integral

mskpulse = zeros(1,2*samps_per_sym + 1)
mskpulse(samps_per_sym+1) = 1.0;

% synch_train_seq_nrz_filtered = conv(synch_train_seq_nrz,gsmpulse);
% synch_train_seq_nrz_filtered_nodelay = synch_train_seq_nrz_filtered(2:end-1);
% synch_train_seq_integrated = cumsum(synch_train_seq_nrz_filtered_nodelay) / samps_per_sym;
% synch_train_seq_abs_phase = pi/2 * synch_train_seq_integrated;
% synch_train_seq_modulated = exp(j*synch_train_seq_abs_phase);

synch_train_seq_filtered = conv(synch_train_seq_integrated,gsmpulse);
synch_train_seq_modulated = exp(j*synch_train_seq_filtered);
synch_train_seq_modulated = synch_train_seq_modulated(samps_per_sym+1:end-samps_per_sym)

%sch = cv_usrp_resamp(3762:3919); 





%happrox = 0.96*exp(-1.1380*tt.^2 -0.527*tt.^4);


%crude crosscorr

corroutput = zeros(1,length(cv_usrp_resamp) - length(synch_train_seq_modulated));
for (i=1:length(cv_usrp_resamp) - length(synch_train_seq_modulated))
    corroutput(i) = sum(cv_usrp_resamp(i:i+length(synch_train_seq_modulated)-1) .* (-conj(synch_train_seq_modulated)));
end
figure(5)

%corroutput=xcorr(synch_train_seq_modulate);

plot ([1:length(corroutput)], abs(corroutput));

%SCH locations

[sch_pks sch_locs] = findpeaks(abs(corroutput), 'minpeakheight', 4*mean(abs(corroutput)), 'minpeakdistance',156.25*samps_per_sym*8*(10-1));



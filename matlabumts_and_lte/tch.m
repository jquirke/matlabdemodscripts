clear all;
fprintf(1,'Loading samples...\n');
f=fopen('C:\\temp\\optus_arfcn_65_d8.usrp', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(2:2:end)+v(1:2:end)*j; fclose(f);
clear v;
%f=fopen('C:\temp\dab_mode1_basicrx_2msps.trunc.cf', 'rb'); v=fread(f, inf, 'int'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);


fs = 8e6;
%fs=4.0e6

%centre_freq = 938.2e6; 
centre_freq = 948.0e6;

cv_usrp = cv_usrp';

%cv_usrp = cv_usrp(1:fs);

t = 0:1/fs:length(cv_usrp)/fs-1/fs;

t_burst = t/.000577;

f = -fs/2:fs/length(cv_usrp):fs/2-fs/length(cv_usrp);


b = fir1(100, 120e3/(fs/2));

fprintf(1,'Filters...\n');

%x_bcch = filter(b,[1], cv_usrp .* exp(j*2*pi*t*-8*200000)); % ARFCN=22+8 = 30

%capture is ARFCN=16, BCCH ARFCN=26, and MA = 2,4,7
%x_bcch = filter(b,[1], cv_usrp .* exp(j*2*pi*t*-10*200000)); %ARFCN = 16--10 = 26 
x_bcch = filter(b,[1], cv_usrp .* exp(j*2*pi*t*14*200000)); %ARFCN = 685--11 = 696

x_bcch2 = filter(b,[1], cv_usrp .* exp(j*2*pi*t*11*200000)); %ARFCN = 685--11 = 696

x_bcch3 = filter(b,[1], cv_usrp .* exp(j*2*pi*t*-17*200000));

clear cv_usrp

%x_ch1 = filter(b,[1], cv_usrp .* exp(j*2*pi*t*10*200000)); %@ARFCN =685-10 = 675
%x_ch2 = filter(b,[1], cv_usrp .* exp(j*2*pi*t*9*200000)); %@ARFCN =685-9 = 676
%x_ch3 = filter(b,[1], cv_usrp .* exp(j*2*pi*t*8*200000)); %@ARFCN =685-8 = 677
%x_ch4 = filter(b,[1], cv_usrp .* exp(j*2*pi*t*7*200000)); %@ARFCN =685-7 = 678

%x_ch2 = filter(b,[1], cv_usrp .* exp(j*2*pi*t*-17*200000)); %@ARFCN =65--17 = 82
 
%x_ch2 = filter(b,[1], cv_usrp .* exp(j*2*pi*t*12*200000)); %ARFCN = 16-12 = 4
% 
%x_ch3 = filter(b,[1], cv_usrp .* exp(j*2*pi*t*9*200000)); %ARFCN = 16-9=7

% plot(t_burst,abs(x_bcch).^2,'r', t_burst,abs(x_ch1).^2, 'g', t_burst,abs(x_ch2).^2, 'b',t_burst, abs(x_ch3).^2, 'y');
%plot (t_burst,abs(x_ch1).^2, 'g', t_burst,abs(x_ch2).^2, 'b',t_burst, abs(x_ch3).^2, 'y');

%plot(t_burst-143,abs(x_bcch), 'r', t_burst-143, abs(x_ch1), 'g', t_burst-143, abs(x_ch2), 'b',t_burst-143, abs(x_ch3), 'y',t_burst-143, abs(x_ch4), 'm')

%resamp BCCH
fprintf(1,'resamp BCCH\n');
%[x_bcch_resamp b_ml] = resample(x_bcch, 5,56);
[x_bcch_resamp b_ml] = resample(x_bcch, 1,14);
[x_bcch_resamp2 b_ml] = resample(x_bcch2, 1,14);
[x_bcch_resamp3 b_ml] = resample(x_bcch3, 1,14);

clear x_bcch
clear x_bcch2
clear x_bcch3

[h_jq f_jq] = freqz(b,[1], 4096, 'whole');

[h_ml f_ml] = freqz(b_ml, [1], 4096, 'whole');

%figure(4)
%plot(f_jq, (abs(h_jq*5).^2), f_ml, (abs(h_ml).^2));

file_out_cplx = zeros(1,2*length(x_bcch_resamp));
file_out_cplx(1:2:end) = real(x_bcch_resamp);
file_out_cplx(2:2:end) = imag(x_bcch_resamp);

f=fopen('C:\\temp\\hop0.out', 'wb');
fwrite(f, file_out_cplx, 'float');
fclose(f);


file_out_cplx = zeros(1,2*length(x_bcch_resamp2));
file_out_cplx(1:2:end) = real(x_bcch_resamp2);
file_out_cplx(2:2:end) = imag(x_bcch_resamp2);

f=fopen('C:\\temp\\hop1.out', 'wb');
fwrite(f, file_out_cplx, 'float');
fclose(f);

file_out_cplx = zeros(1,2*length(x_bcch_resamp3));
file_out_cplx(1:2:end) = real(x_bcch_resamp3);
file_out_cplx(2:2:end) = imag(x_bcch_resamp3);

f=fopen('C:\\temp\\hop2.out', 'wb');
fwrite(f, file_out_cplx, 'float');
fclose(f);



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



% upsamp =65;
% downsamp = 96*4;
% cv_usrp_resamp = resample(cv_usrp, upsamp, downsamp);
% 
% fs_resamp = fs * upsamp/downsamp;
% 
% nsamples = length(cv_usrp_resamp);
% 
% fftout = fftshift(fft(cv_usrp));
% 
% 
% 
% f = -fs/2:fs/length(cv_usrp):fs/2-fs/length(cv_usrp);
% 
% figure(1);
% 
% plot (f,(abs(fftout).^2));
% 
% 
% figure(2);
% 
% 
% gsmrate = 52e6/192;
% 
% sampspersym = fs_resamp/gsmrate;
% 
% [pks locs] = findpeaks(-1*abs(cv_usrp_resamp), 'minpeakheight', -200, 'minpeakdistance', 100);
% 
% %cv_usrp_resamp =cv_usrp_resamp(15942:15942+30*8*156.25*sampspersym);
% 
% 
% 
% t = 0:nsamples-1;
% plot (t(1:length(cv_usrp_resamp))/(1), real(cv_usrp_resamp))%,t,imag(cv_usrp_resamp));
% title('Optus GSM burst, Doncaster East CellID 31010')
% xlabel('bursts, GSM sample clock = 270.8ksym/sec')
% ylabel('Amplitude')
% 
% fcch = cv_usrp_resamp(1:157);
% 
% %figure(3)
% 
% %plot([1:64], abs(fftshift(fft(fcch))).^2)
% 
% fcch_avg_angle = mean(mod(angle(fcch(5:end-5)) - angle(fcch(5-1:end-5-1)) + 2* pi, 2*pi));
% fcch_est_freq =  fcch_avg_angle / (2*pi) * fs_resamp;
% 
% fcch_est_freq_adj = fcch_est_freq - (52e6/192 * 1/4); 
% 
% %fcch_est_freq_adj = (fcch_avg_angle - pi/2) * fs_resamp;
% 
% %fcch_est_freq_adj =    5.696496847110070e+003;
% 
% fcch_est_freq_adj= 8.3622e+003;
% t = 0:1/fs_resamp:length(cv_usrp_resamp)/fs_resamp-1/fs_resamp;
% 
% cv_usrp_resamp = cv_usrp_resamp .* exp(-1i*2*pi*fcch_est_freq_adj*t);
% 
% synch_train_seq =  [ ...
% 1 0 1 1 1 0 0 1 ...
% 0 1 1 0 0 0 1 0 ...
% 0 0 0 0 0 1 0 0 ... 
% 0 0 0 0 1 1 1 1 ...
% 0 0 1 0 1 1 0 1 ...
% 0 1 0 0 0 1 0 1 ...
% 0 1 1 1 0 1 1 0 ...
% 0 0 0 1 1 0 1 1 ];
% 
% tsc_0 = [0 0 1 0 0 1 0 1 1 1 0 0 0 0 1 0 0 0 1 0 0 1 0 1 1 1];
% tsc_1 = [0 0 1 0 1 1 0 1 1 1 0 1 1 1 1 0 0 0 1 0 1 1 0 1 1 1];
% tsc_2 = [0 1 0 0 0 0 1 1 1 0 1 1 1 0 1 0 0 1 0 0 0 0 1 1 1 0];
% tsc_3 = [0 1 0 0 0 1 1 1 1 0 1 1 0 1 0 0 0 1 0 0 0 1 1 1 1 0];
% tsc_4 = [0 0 0 1 1 0 1 0 1 1 1 0 0 1 0 0 0 0 0 1 1 0 1 0 1 1];
% tsc_5 = [0 1 0 0 1 1 1 0 1 0 1 1 0 0 0 0 0 1 0 0 1 1 1 0 1 0];
% tsc_6 = [1 0 1 0 0 1 1 1 1 1 0 1 1 0 0 0 1 0 1 0 0 1 1 1 1 1];
% tsc_7 = [1 1 1 0 1 1 1 1 0 0 0 1 0 0 1 0 1 1 1 0 1 1 1 1 0 0];
% 
% dummy_burst_mid = [1 1 1 1 1 0 1 1 0 1 1 1 0 1 1 0 0 0 0 0 1 0 1 ...
% 	0 0 1 0 0 1 1 1 0 0 0 0 0 1 0 0 1 0 0 0 1 0 ...
% 	0 0 0 0 0 0 1 1 1 1 1 0 0 0 1 1 1 0 0 0 1 0 1 1 1 0 ...
% 	0 0 1 0 1 1 1 0 0 0 1 0 1 ...
% 	0 1 1 1 0 1 0 0 1 0 1 0 0 0 1 1 0 0 1 1 0 0 1 1 1 0 0 ...
% 	1 1 1 1 0 1 0 0 1 1 1 1 1 0 0 0 1 0 0 1 0 1 1 1 1 1 0 ...
% 	1 0 1 0 ];
% 
% dummy_burst = [ 0 0 0 dummy_burst_mid 0 0 0 ];
% 
% 
% %synch_train_seq = ;
% 
% %synch_train_seq = zeros(1,64);
% 
% samps_per_sym = floor(fs_resamp / (52e6/192))
% synch_train_seq_diff = mod(synch_train_seq(1:end-1) + synch_train_seq(2:end), 2);
% synch_train_seq_nrz = zeros(1,length(synch_train_seq_diff)* samps_per_sym);
% 
% for i=1:samps_per_sym,
%     synch_train_seq_nrz(i:samps_per_sym:end) = (1-2*synch_train_seq_diff);
% end
% 
% synch_train_seq_integrated = pi/2*cumsum(synch_train_seq_nrz)/samps_per_sym;
% 
% 
% tt = [-1:1/samps_per_sym:1];
% T=1;
% BT=0.3;
% d=sqrt(log(2))/(2*pi*BT);
% gsmpulse = exp(-tt.^2/(2*d^2*T^2))/(sqrt(2*pi)*d*T)/samps_per_sym;
% gsmpulse = gsmpulse/sum(abs(gsmpulse)); %counter the fact that we are not using the full integral
% 
% mskpulse = zeros(1,2*samps_per_sym + 1)
% mskpulse(samps_per_sym+1) = 1.0;
% 
% % synch_train_seq_nrz_filtered = conv(synch_train_seq_nrz,gsmpulse);
% % synch_train_seq_nrz_filtered_nodelay = synch_train_seq_nrz_filtered(2:end-1);
% % synch_train_seq_integrated = cumsum(synch_train_seq_nrz_filtered_nodelay) / samps_per_sym;
% % synch_train_seq_abs_phase = pi/2 * synch_train_seq_integrated;
% % synch_train_seq_modulated = exp(j*synch_train_seq_abs_phase);
% 
% synch_train_seq_filtered = conv(synch_train_seq_integrated,gsmpulse);
% synch_train_seq_modulated = exp(j*synch_train_seq_filtered);
% synch_train_seq_modulated = synch_train_seq_modulated(samps_per_sym+1:end-samps_per_sym)
% 
% %sch = cv_usrp_resamp(3762:3919); 
% 
% 
% 
% 
% 
% %happrox = 0.96*exp(-1.1380*tt.^2 -0.527*tt.^4);
% 
% 
% %crude crosscorr
% 
% corroutput = zeros(1,length(cv_usrp_resamp) - length(synch_train_seq_modulated));
% for (i=1:length(cv_usrp_resamp) - length(synch_train_seq_modulated))
%     corroutput(i) = sum(cv_usrp_resamp(i:i+length(synch_train_seq_modulated)-1) .* (-conj(synch_train_seq_modulated)));
% end
% figure(5)
% 
% %corroutput=xcorr(synch_train_seq_modulate);
% 
% plot ([1:length(corroutput)], abs(corroutput));
% 
% %SCH locations
% 
% [sch_pks sch_locs] = findpeaks(abs(corroutput), 'minpeakheight', 4*mean(abs(corroutput)), 'minpeakdistance',156.25*samps_per_sym*8*(10-1));
% 
% 

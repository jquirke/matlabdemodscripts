clear all;
fprintf(1,'Loading samples...\n');
f=fopen('C:\\temp\\telstralte.d4_8bit.usrp', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(2:2:end)+v(1:2:end)*j; fclose(f);
clear v;
%f=fopen('C:\temp\dab_mode1_basicrx_2msps.trunc.cf', 'rb'); v=fread(f, inf, 'int'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);


fs = 16e6;
cv_usrp = cv_usrp';
plot ([1:length(cv_usrp)]/fs, abs(cv_usrp))


break;

cv_usrp=cv_usrp(1:fs/1000 * 50);


cv_usrp = resample(cv_usrp, 24,25);
cv_usrp = cv_usrp(405:end);
centre_freq = 1810.0e6

fs = 16e6*24/25;

t = 0:1/fs:length(cv_usrp)/fs-1/fs;

f = -fs/2:fs/length(cv_usrp):fs/2-1/length(cv_usrp);
 
plot(f,fftshift(abs(fft(cv_usrp)).^2));
plot ([1:length(cv_usrp)], abs(cv_usrp))

% prepare a mask to capture only the symbol=0,4

mask = zeros(1,30.72e6/1000/2 / 16);
mask(1:(2048+160)/16) = 1;
mask(1+(160+2048+144+2048+144+2048)/16:(160+2048+144+2048+144+2048)/16+(2048+144)/16) = 1;

mask_ext = zeros(1,length(cv_usrp));
for i=0:floor(length(mask_ext)/length(mask))-1,
    mask_ext(1+i*length(mask):length(mask)+i*length(mask)) = mask;
end

%cv_usrp = cv_usrp .* mask_ext;
figure(1)
plot ([1:length(cv_usrp)]/(15360/7/16), abs(cv_usrp))
ylabel('amplitude')
xlabel('time, OFDM symbols average @ normal cyclic prefix');

figure(2)
plot(f,fftshift(abs(fft(cv_usrp)).^2));
ylabel('power')
xlabel('frequency, Hz')


%LTE slot length = 30.72e6/15000 samples * 7 + prefix (for normal) =
%1x160+6x144 = 2048x7 + 160 + 6x144=15360 symbols



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

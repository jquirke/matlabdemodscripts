%f=fopen('C:\temp\FM.samples', 'rb'); v=fread(f, inf, 'short'); cv=v(1:2:end)+v(2:2:end)*j; fclose(f);
f=fopen('C:\temp\FM.samples', 'rb'); v=fread(f, inf, 'short'); cv=v(1:2:end)+0*v(2:2:end)*j; fclose(f);
%awgn(cv,10);
fs_u=320e3;
fu=-fs_u/2:fs_u/length(cv):fs_u/2-1/fs_u;
tu=0:1/fs_u:length(cv)/fs_u-1/fs_u;

cv= mod(tu, 0.1) > 0.05;
figure(1)
title('USRP FFT');
plot(fu/1000,10*log10((abs(fftshift(fft(cv))).^2)));
xlabel('kHz'); ylabel('power, dB');

%fir filter to 90kHz

b=fir1(40, 80e3/(fs_u/2));
[tmp_h, tmp_f] = freqz(b,[1], 500, fs_u);
figure(2)
title('filter response');
xlabel('kHz'); ylabel('power, dB');
plot(tmp_f/1000, 10*log10(abs(tmp_h).^2))

cv2=filter(b,1, cv);


figure(3)
title('USRP FFT (LPFd)');
plot(fu/1000,10*log10((abs(fftshift(fft(cv2))).^2)));
xlabel('kHz'); ylabel('power, dB');
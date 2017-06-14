
f=fopen('C:\temp\usrp.dvb', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(1:2:end)+v(2:2:end)*j; clear v; fclose(f);

fs=8e6;

Ts=1/fs;
Fd=fs/length(cv_usrp);
t=0:Ts:length(cv_usrp)*Ts-Ts;
f=-fs/2:Fd:fs/2-Fd;

figure(1)
title('Spectrum of USRP signal')
plot(f/1e3,abs(fftshift(fft(cv_usrp))).^2);
xlabel('f, KHz')


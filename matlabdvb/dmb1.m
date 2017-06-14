clear all;
fprintf(1,'Loading samples...\n');
f=fopen('C:\temp\DAB.samples.syd1', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);
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


    

f_usrp=-fs_usrp/2:fs_usrp/length(cv_usrp):fs_usrp/2-1/fs_usrp;
t_usrp=0:1/fs_usrp:length(cv_usrp)/fs_usrp-1/fs_usrp;

%figure(1)
%title('USRP FFT');
%plot(f_usrp/1000,((abs(fftshift(fft(cv_usrp))).^2)));
%xlabel('kHz'); ylabel('power');

%resample
fprintf(1,'Resampling from %fMHz to %fMHz\n', fs_usrp/1e6,fs_resamp/1e6);
cv_resamp = resample(cv_usrp, resamp_p, resamp_q);
clear cv_usrp;
t_resamp = 0:1/fs_resamp:length(cv_resamp)/fs_resamp-1/fs_resamp;
f_resamp=-fs_resamp/2:fs_resamp/length(cv_resamp):fs_resamp/2-1/fs_resamp;

%fir filter to 90kHz
fprintf(1,'Filtering unwanted high frequencies...\n');
b=fir1(100, 850e3/(fs_resamp/2));
[tmp_h, tmp_f] = freqz(b,[1], 500, fs_resamp);
%figure(2)
%title('filter response');
%xlabel('kHz'); ylabel('power, dB');
%plot(tmp_f/1000, 10*log10(abs(tmp_h).^2))

cv_resamp_lpf=filter(b,1, cv_resamp);
clear cv_resamp;
%cv_resamp_lpf = cv_resamp_lpf .* exp(j*160*2*pi*t_resamp);
%figure(3)
%title('USRP FFT (LPFd)');
%plot(f_resamp/1000,((abs(fftshift(fft(cv_resamp_lpf))).^2)));
%xlabel('kHz'); ylabel('power');

%figure(4)
%plot (t_resamp,abs(cv_resamp_lpf))
%title('post filter time domain');
%xlabel('t,sec'); ylabel('voltage');


%find sync symbol
avg_filter = ones(1,tnull);
fprintf(1,'Attempting synchronization to start of frame\n');
[t_start_sync, estsnr]=dab_find_sync(cv_resamp_lpf, 1, tframe, tnull, 5);

fprintf(1,'Sync symbol=%d, est SNR dB = %f\n', t_start_sync, 10*log10(estsnr));
[est_freq_adj fft_bin_adj] = dab_est_freqadj(cv_resamp_lpf, t_start_sync, tu, tcp,symsframe,ncarriers);
coarse_adj = fft_bin_adj * 1/(tu/fs_resamp);

fprintf(1,'Performing frequency correction estimated at %f+%fHz\n', coarse_adj, est_freq_adj*fs_resamp/(2*pi));

cv_resamp_lpf = cv_resamp_lpf .* exp(j*(est_freq_adj*fs_resamp+2*pi*coarse_adj)*t_resamp);

%t_sync = t_resamp(t_start_sync+tcp:t_start_sync+tcp+tu-1);
%cv_sync = cv_resamp_lpf(t_start_sync+tcp:t_start_sync+tcp+tu-1);

%z_sync = fft(cv_sync);
%z_sync(769:1280)=zeros(1,512);

%phase_sync = angle(z_sync);
%phase_diff_sync = diff(phase_sync);
%phase_diff_sync_Nmod = mod(floor(mod((phase_diff_sync+2*pi),2*pi)/(pi/2)+0.5),4);


%extract the absolute phase of all symbols

z_frame = dab_ofdm_sample_fft(cv_resamp_lpf, t_start_sync, tu, tcp, symsframe);

%compute the relative phase
y_frame = dab_calc_relphase(z_frame);

%q_frame = dab_freq_deint(y_frame);

%extract the first 3 normal symbols (i.e. the FIC-carrying symbols )
% t_sym1 = t_resamp(t_start_sync+1*tsym+tcp:t_start_sync+1*tsym+tcp+tu-1);
% cv_sym1 = cv_resamp_lpf(t_start_sync+1*tsym+tcp:t_start_sync+1*tsym+tcp+tu-1);
% z_sym1=z_frame(2,:);%fft(cv_sym1);
% z_sym1(769:1280)=zeros(1,512);
% 
% t_sym2 = t_resamp(t_start_sync+2*tsym+tcp:t_start_sync+2*tsym+tcp+tu-1);
% cv_sym2 = cv_resamp_lpf(t_start_sync+2*tsym+tcp:t_start_sync+2*tsym+tcp+tu-1);
% z_sym2=z_frame(3,:);
% z_sym2(769:1280)=zeros(1,512);
% 
% t_sym3 = t_resamp(t_start_sync+3*tsym+tcp:t_start_sync+3*tsym+tcp+tu-1);
% cv_sym3 = cv_resamp_lpf(t_start_sync+3*tsym+tcp:t_start_sync+3*tsym+tcp+tu-1);
% z_sym3=z_frame(4,:);
% z_sym3(769:1280)=zeros(1,512);

%calc relative phase 
%y_sym1 = y_frame(1,:); %z_sym1 .* conj(z_sync);
%y_sym2 = y_frame(2,:); %z_sym2 .* conj(z_sym1);
%y_sym3 = y_frame(3,:); %z_sym3 .* conj(z_sym2);
%frequency deinterleave

q_frame = dab_freq_deint(y_frame);

%q_sym1 = q_frame(1,:);
%q_sym2 = q_frame(2,:);
%q_sym3 = q_frame(3,:);

%split I/Q into soft-vector

p_frame_soft = dab_qpsk_demap(q_frame);

p_sym1 = p_frame_soft(1,:);%dab_qpsk_demap(q_sym1);
p_sym2 = p_frame_soft(2,:);
p_sym3 = p_frame_soft(3,:);

%convolutional decode

trellis=poly2trellis([7], [133, 171,145,133]);
%generate puncturing vector
%first 21 blocks use PI=16 for each 128bit block
for i=1:21,
    puncblk = [puncpat(16,:) puncpat(16,:) puncpat(16,:) puncpat(16,:)];
    ficpuncvec(1+(i-1)*128:i*128) = puncblk;
end
for i=22:24, % last 3 blks use PI=15
    puncblk = [puncpat(15,:) puncpat(15,:) puncpat(15,:) puncpat(15,:)];
    ficpuncvec(1+(i-1)*128:i*128) = puncblk;
end
%last 24bits use the first 2 polys
ficpuncvec(24*128+1:24*128+24) = [1 1 0 0   1 1 0 0   1 1 0 0   1 1 0 0   1 1 0 0   1 1 0 0];

%extract the 4 FIB groups for mode I

FICs = dab_extract_fics(p_frame_soft(1:3,:),2304);
%CIFS = dab_extract_cifs(p_frame_soft(4:75,:),55296);

%FIC1_group_coded = FICs(1,:);%[p_sym1(1:2304)];
%FIC2_group_coded = FICs(2,:);%[p_sym1(2305:3072) p_sym2(1:1536)];
%FIC3_group_coded = FICs(3,:);%[p_sym2(1537:3072) p_sym3(1:768)];
%FIC4_group_coded = FICs(4,:);%[p_sym3(769:3072)];

for ific=1:4,
    FICdec=vitdec(FICs(ific,:),trellis,10*7, 'term', 'unquant', ficpuncvec);
    FIC_dewhiten(ific,:)=dab_dewhiten_fibs(FICdec(1:768));
end

%FIC2_group_decoded=vitdec(FIC2_group_coded,trellis,10*7, 'term', 'unquant', ficpuncvec);
%FIC3_group_decoded=vitdec(FIC3_group_coded,trellis,10*7, 'term', 'unquant', ficpuncvec);
%FIC4_group_decoded=vitdec(FIC4_group_coded,trellis,10*7, 'term', 'unquant', ficpuncvec);

%remove whiten noise after stripping tail bits
%FIC1_group_binary = dab_dewhiten_fibs(FIC1_group_decoded(1:768));
%FIC2_group_binary = dab_dewhiten_fibs(FIC2_group_decoded(1:768));
%FIC3_group_binary = dab_dewhiten_fibs(FIC3_group_decoded(1:768));
%FIC4_group_binary = dab_dewhiten_fibs(FIC4_group_decoded(1:768));

%extract individual FIBs
FIBs(1,:)=FIC_dewhiten(1,1:256);
FIBs(2,:)=FIC_dewhiten(1,257:512);
FIBs(3,:)=FIC_dewhiten(1,513:768);
FIBs(4,:)=FIC_dewhiten(2,1:256);
FIBs(5,:)=FIC_dewhiten(2,257:512);
FIBs(6,:)=FIC_dewhiten(2,513:768);
FIBs(7,:)=FIC_dewhiten(3,1:256);
FIBs(8,:)=FIC_dewhiten(3,257:512);
FIBs(9,:)=FIC_dewhiten(3,513:768);
FIBs(10,:)=FIC_dewhiten(4,1:256);
FIBs(11,:)=FIC_dewhiten(4,257:512);
FIBs(12,:)=FIC_dewhiten(4,513:768);

%verify CRCs

for i=1:12,
    FIB_crc_err(i) = sum(abs(dab_crc(FIBs(i,1:240), crcpoly) - FIBs(i,241:256)));
end

nFICserr=sum(FIB_crc_err>0);
if (nFICserr == 12)
    fprintf(1, 'Error in demodulating any FIB\n');
else
    fprintf(1, '%d/%d FIBs in frame demodulated error free\n', 12-nFICserr,12);
end
%figure(5);
%hist(phase_diff_sync/(pi/2), 200);
%title('phase diff histogram between adjacent carriers in steps of pi/2');
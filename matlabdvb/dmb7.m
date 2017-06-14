clear all;
%fprintf(1,'Loading samples...\n');
%f=fopen('C:\temp\DAB.samples.syd1', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);
%f=fopen('C:\temp\ofdm_sync_afterdelay.dat', 'rb'); v=fread(f, inf, 'float'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);
%clear v;
%f=fopen('C:\temp\dab_mode1_basicrx_2msps.trunc.cf', 'rb'); v=fread(f, inf, 'int'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);

%cv_usrp=transpose(cv_usrp);
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


    


% figure(1)
% f_usrp=-fs_usrp/2:fs_usrp/length(cv_usrp):fs_usrp/2-1/fs_usrp;
% title('USRP FFT');
% plot(f_usrp/1000,((abs(fftshift(fft(cv_usrp))).^2)));
% xlabel('kHz'); ylabel('power');

%resample
%fprintf(1,'Resampling from %fMHz to %fMHz\n', fs_usrp/1e6,fs_resamp/1e6);
%cv_resamp = resample(cv_usrp, resamp_p, resamp_q);
%clear cv_usrp;

%fir filter to 90kHz
%fprintf(1,'Filtering unwanted high frequencies...\n');
%b=fir1(100, 850e3/(fs_resamp/2));

%[tmp_h, tmp_f] = freqz(b,[1], 500, fs_resamp);

%cv_resamp_lpf=filter(b,1, cv_resamp);
% f=fopen('C:\temp\ofdm_sync_output.dat', 'rb'); v=fread(f, inf, 'float'); cv_resamp_lpf=transpose(v(1:2:end)+v(2:2:end)*j); fclose(f);
% f=fopen('C:\temp\ofdm_sync_output_ctrl.dat', 'rb'); v=fread(f, inf, 'char'); v=transpose(v);fclose(f);
% syncs = find (v == 1);
% clear v;
% clear cv_resamp;
% %%%TEMP%%%%cv_resamp_lpf=resample(cv_resamp_lpf, resamp_p, resamp_q);
% figure(2)
% f_resamp=-fs_resamp/2:fs_resamp/length(cv_resamp_lpf):fs_resamp/2-1/fs_resamp;
% title('SOFDM SYNC');
% plot(f_resamp/1000,((abs(fftshift(fft(cv_resamp_lpf))).^2)));
% xlabel('kHz'); ylabel('power');


%find sync symbol
% fprintf(1,'Attempting synchronization to start of frame\n');
% [t_start_sync, estsnr]=dab_find_sync(cv_resamp_lpf, 1, tframe, tnull, 5);
% %syncs = [209204,405803 , 602435,799007, 995601, 1192201, 1388819, 1585401, 1782002, 1978744];
% syncptr=1;
% t_start_sync = syncs(syncptr);
% estsnr=0;
% fprintf(1,'Sync symbol=%d, est SNR dB = %f\n', t_start_sync, 10*log10(estsnr));
% [est_freq_adj fft_bin_adj] = dab_est_freqadj(cv_resamp_lpf, t_start_sync, tu, tcp,symsframe,ncarriers);
% coarse_adj = fft_bin_adj * 1/(tu/fs_resamp);
% 
% fprintf(1,'NOT Performing frequency correction estimated at %f+%fHz\n', coarse_adj, est_freq_adj*fs_resamp/(2*pi));

%t_resamp = 0:1/fs_resamp:length(cv_resamp_lpf)/fs_resamp-1/fs_resamp;
%cv_resamp_lpf = cv_resamp_lpf .* exp(j*(est_freq_adj*fs_resamp+2*pi*coarse_adj)*t_resamp);
%clear t_resamp;

CIFs = [];
%syncs

%load sampled data
%f=fopen('C:\temp\ofdm_deinterleave_output.dat', 'rb'); v=fread(f, inf, 'float'); ofdm_samples=transpose(v(1:2:end)+v(2:2:end)*j); fclose(f);
f=fopen('C:\temp\fic_convdec_output.dat', 'rb'); v=fread(f, inf, 'char'); ofdm_samples=transpose(v); fclose(f);
%f=fopen('C:\temp\ofdm_removepilot_output_ctrl.dat', 'rb'); v=fread(f, inf, 'char'); ofdm_samples_sync=transpose(v);fclose(f);
clear v;
nsamples=length(ofdm_samples)/774;
ofdm_samples = transpose(reshape(ofdm_samples, 774, nsamples));
frameno = 0;

nframes=floor(nsamples/4);
%diff(find(ofdm_samples_sync == 1))
while (frameno < nframes),
    %extract the absolute phase of all symbols

    %z_frame = dab_ofdm_sample_fft(cv_resamp_lpf, t_start_sync, tu, tcp, symsframe);
    %extract the samples for this frame
    FICs = ofdm_samples(frameno*4+1:frameno*4+4,:);
    %z_frame=zeros(76,2048);



    %compute the relative phase
    %y_frame = dab_calc_relphase(z_frame);

    %frequency deinterleave
    %q_frame = dab_freq_deint(y_frame);

    %split I/Q into soft-vector

    %p_frame_soft = dab_qpsk_demap(q_frame);

    %convolutional decode

    trellis=poly2trellis([7], [133, 171,145,133]);
    %generate puncturing vector
    %first 21 blocks use PI=16 for each 128bit block
%     for i=1:21,
%         puncblk = [puncpat(16,:) puncpat(16,:) puncpat(16,:) puncpat(16,:)];
%         ficpuncvec(1+(i-1)*128:i*128) = puncblk;
%     end
%     for i=22:24, % last 3 blks use PI=15
%         puncblk = [puncpat(15,:) puncpat(15,:) puncpat(15,:) puncpat(15,:)];
%         ficpuncvec(1+(i-1)*128:i*128) = puncblk;
%     end
%     %last 24bits use the first 2 polys
%     ficpuncvec(24*128+1:24*128+24) = [1 1 0 0   1 1 0 0   1 1 0 0   1 1 0 0   1 1 0 0   1 1 0 0];

    %extract the 4 FIB groups for mode I

    %FICs = dab_extract_fics(p_frame_soft(1:3,:),2304);
    %CIFs_frame = dab_extract_cifs(p_frame_soft(4:75,:),55296);
    %CIFs = [CIFs;CIFs_frame];
    for ific=1:4,
        FICdec=vitdec(FICs(ific,:),trellis,10*7, 'term', 'unquant');
        FIC_dewhiten(ific,:)=dab_dewhiten_fibs(FICdec(1:768));
    end

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
        fprintf(1, '%d/%d FIBs in frame %d demodulated error free\n', 12-nFICserr,12,frameno);
    end
    for i=1:12,
        if (FIB_crc_err(i) == 0)
            %dab_parse_fib(FIBs(i,:));
        end
    end
           
    %[t_start_sync, estsnr]=dab_find_sync(cv_resamp_lpf, t_start_sync, tframe, tnull, 5);
%     syncptr = syncptr+1;
%     t_start_sync=syncs(syncptr);
%     if (length(cv_resamp_lpf) - t_start_sync < tframe)
%         t_start_sync = -1;
%         fprintf(1,'End of Data\n');
%     else
%         fprintf(1,'Next frame: Sync symbol=%d, est SNR dB = %f\n', t_start_sync, 10*log10(estsnr));
%     end
    frameno = frameno+1;
end
%deinterleave
% CIFs_deint=dab_time_deint(CIFs);
%
% subch_coded=dab_select_subch(CIFs_deint,576,48);
% [subch_decoded subchbiterr] = dab_viterbi_eep(subch_coded,0,2);
% subch_bits = dab_dewhiten(subch_decoded);
% 
% audiosuperframe=dabplus_rs_correct(subch_bits(4:8,:));
% dabplus_aac_info(audiosuperframe);
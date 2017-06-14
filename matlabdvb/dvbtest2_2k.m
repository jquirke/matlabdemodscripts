clear all;
fprintf(1,'Loading samples...\n');
f=fopen('C:\temp\ofdm_40.short.dump', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);
clear v;
%f=fopen('C:\temp\dab_mode1_basicrx_2msps.trunc.cf', 'rb'); v=fread(f, inf, 'int'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);

cv_usrp=transpose(cv_usrp);




dvb = 1;

if (dvb == 1)
    fs_usrp = 8e6;
else
    fs_usrp=2e6;
end

resamp_p = 128;
resamp_q = 125; % change depending on fs_u

if (dvb == 1)
    fs_resamp = fs_usrp;
else
    fs_resamp=fs_usrp * resamp_p / resamp_q;
end
tnull=2656; %symbols, trans mode I


t = 0:1/fs_resamp:length(cv_usrp)/fs_resamp-1/fs_resamp;
%cv_resamp_lpf = cv_resamp_lpf .*
%cv_usrp = cv_usrp .* exp(j*(2*pi*2200)*t);


if (dvb == 1)
    tu = 2048, tcp = tu/4;
else
    tu =  2048;
    tcp = 504;
end

tsym = tu+tcp;

%figure(1)
%title('USRP FFT');
%plot(f_usrp/1000,((abs(fftshift(fft(cv_usrp))).^2)));
%xlabel('kHz'); ylabel('power');

%resample

if (dvb == 0)
    fprintf(1,'Resampling from %fMHz to %fMHz\n', fs_usrp/1e6,fs_resamp/1e6);
    cv_resamp = resample(cv_usrp, resamp_p, resamp_q);
    %clear cv_usrp;
else

    cv_resamp = cv_usrp;
    
end

if (dvb == 0)

    %fir filter to 90kHz
    fprintf(1,'Filtering unwanted high frequencies...\n');
    b=fir1(100, 850e3/(fs_resamp/2));
    [tmp_h, tmp_f] = freqz(b,[1], 500, fs_resamp);

    cv_resamp_lpf=filter(b,1, cv_resamp);
    
else
    
    cv_resamp_lpf = cv_resamp;
    clear cv_resamp;
end



%cv_resamp_lpf = cv_usrp;

%find sync symbol
%fprintf(1,'Attempting synchronization to start of frame\n');
%[t_start_sync, estsnr]=dab_find_sync(cv_resamp_lpf, 1, tframe, tnull, 5);

%fprintf(1,'Sync symbol=%d, est SNR dB = %f\n', t_start_sync, 10*log10(estsnr));
%[est_freq_adj fft_bin_adj] = dab_est_freqadj(cv_resamp_lpf, t_start_sync, tu, tcp,symsframe,ncarriers);
%coarse_adj = fft_bin_adj * 1/(tu/fs_resamp);

%fprintf(1,'Performing frequency correction estimated at %f+%fHz\n', coarse_adj, est_freq_adj*fs_resamp/(2*pi));

%t_resamp = 0:1/fs_resamp:length(cv_resamp_lpf)/fs_resamp-1/fs_resamp;
%cv_resamp_lpf = cv_resamp_lpf .* exp(j*(est_freq_adj*fs_resamp+2*pi*coarse_adj)*t_resamp);
%clear t_resamp;

% % fprintf(1,'Performing time correlation\n');
% % corroutput  = dvbtest_timecorrelate(cv_resamp_lpf, tu, tcp);
% % figure (1)
% % plot ([1:length(corroutput)], corroutput)


% find first sync

% % syncblk = corroutput(1:tu+tcp+tcp);
% % pkcorr = find (syncblk == max(syncblk));
% % corroutput2 = corroutput(pkcorr:end);


pkcorr = 1;


samples = cv_resamp_lpf(pkcorr:end);

clear cv_resamp_lpf;
%clear corroutput;


%%figure (2)
%%plot ([1:length(corroutput2)], corroutput2)

%clear corroutput2;

% estimate fine freq

for i=1:floor(length(samples)/tsym),
    freq_est(i) = dvbtest_finefreqest(samples(1+(i-1)*tsym:tsym+(i-1)*tsym), tu, tcp) / (2*pi) / tu * fs_resamp;
end

mean(freq_est)
sqrt(var(freq_est))


% adjust for fine freq
%est_freq_adj = 79.1193;

est_freq_adj = mean(freq_est);

%est_freq_adj = est_freq_adj + 335;

t = 0:1/fs_resamp:length(samples)/fs_resamp-1/fs_resamp;
%cv_resamp_lpf = cv_resamp_lpf .*
%samples = samples .* exp(j*(2*pi*est_freq_adj)*t);


 for i=1:floor(length(samples)/tsym),
    freq_est2(i) = dvbtest_finefreqest(samples(1+(i-1)*tsym:tsym+(i-1)*tsym), tu, tcp) / (2*pi) / tu * fs_resamp;
end

mean(freq_est2)
sqrt(var(freq_est2))

dvb_centre_carrier_2k = 852;
dvb_num_data_carriers_2k = 1512;
dvb_centre_carrier_8k = 3408
dvb_num_data_carriers_8k = 6048;

dvb_cp_8k = [0 48 54 87 141 156 192 ...
201 255 279 282 333 432 450 ...
483 525 531 618 636 714 759 ...
765 780 804 873 888 918 939 ...
942 969 984 1050 1101 1107 1110 ...
1137 1140 1146 1206 1269 1323 1377 ...
1491 1683 1704 1752 1758 1791 1845 ...
1860 1896 1905 1959 1983 1986 2037 ...
2136 2154 2187 2229 2235 2322 2340 ...
2418 2463 2469 2484 2508 2577 2592 ...
2622 2643 2646 2673 2688 2754 2805 ...
2811 2814 2841 2844 2850 2910 2973 ...
3027 3081 3195 3387 3408 3456 3462 ...
3495 3549 3564 3600 3609 3663 3687 ...
3690 3741 3840 3858 3891 3933 3939 ... 
4026 4044 4122 4167 4173 4188 4212 ...
4281 4296 4326 4347 4350 4377 4392 ...
4458 4509 4515 4518 4545 4548 4554 ...
4614 4677 4731 4785 4899 5091 5112 ...
5160 5166 5199 5253 5268 5304 5313 ...
5367 5391 5394 5445 5544 5562 5595 ...
5637 5643 5730 5748 5826 5871 5877 ...
5892 5916 5985 6000 6030 6051 6054 ...
6081 6096 6162 6213 6219 6222 6249 ...
6252 6258 6318 6381 6435 6489 6603 ...
6795 6816 ];


dvb_cp_2k = [ 0 48 54 87 141 156 192 ...    
201 255 279 282 333 432 450 ...
483 525 531 618 636 714 759 ...
765 780 804 873 888 918 939 ...
942 969 984 1050 1101 1107 1110 ...
1137 1140 1146 1206 1269 1323 1377 ...
1491 1683 1704 ];

dvb_tps_8k = [34 50 209 346 413 569 595 688 ...
0790 0901 1073 1219 1262 1286 1469 1594 ...
1687 1738 1754 1913 2050 2117 2273 2299 ...
2392 2494 2605 2777 2923 2966 2990 3173 ...
3298 3391 3442 3458 3617 3754 3821 3977 ...
4003 4096 4198 4309 4481 4627 4670 4694 ...
4877 5002 5095 5146 5162 5321 5458 5525 ...
5681 5707 5800 5902 6013 6185 6331 6374 ...
6398 6581 6706 6799 ];

dvb_tps_2k = [34 50 209 346 413 ...
    569 595 688 790 901 ...
    1073 1219 1262 1286 1469 ...
    1594 1687 ];

dvb_cp = dvb_cp_2k;
dvb_tps = dvb_tps_2k;
dvb_num_data_carriers = dvb_num_data_carriers_2k;
dvb_centre_carrier = dvb_centre_carrier_2k;
dvb_num_active_carriers = dvb_centre_carrier * 2 + 1;
%map of CPs, using fftshifted space (i.e. DC at k=fftn/2
dvb_8k = 0;

dvb_refseq = dvb_init_refseq(dvb_num_active_carriers);
dvb_data_carriers = dvb_init_data_carriers(dvb_cp, dvb_tps, dvb_num_data_carriers, dvb_num_active_carriers);
cp_map(1:tu) = 0;
cp_map((dvb_cp - dvb_centre_carrier + tu/2+1)) = 1;

dvb_scatterseq = dvb_init_scatterseq(dvb_num_active_carriers) ;%.* dvb_refseq;

dvb_H = dvb_init_h(dvb_8k);
%figure(5)

%plot([-688:688], const_pilot_corr)

for i=1:floor(length(samples)/tsym)-1,
    dc_offset = dvb_corr_const_pilots(samples(1+(i-1)*tsym:tsym+(i-1)*tsym), samples(1+(i)*tsym:tsym+(i)*tsym), tu, tcp, dvb_num_active_carriers, cp_map);
    coarse_freq_adjs(i) = dc_offset;
    
    frame(i,:) = dvb_ofdm_sample_and_shift(samples(1+(i-1)*tsym:tsym+(i-1)*tsym), tu, tcp, dvb_num_active_carriers, dc_offset);
    
    if (i>5)
        scattered_cycle_number(i) = dvb_corr_scattered_pilots(frame(i-4,:), frame(i,:));
    end
    
    if (i>1)
        tps_softbits(i,:) = dvb_tps_softbits(frame(i-1,:), frame(i,:), dvb_tps);
    end
end


start_decode_symbol  = -1;
[rel_symbol_no tps_bits] = dvb_tps_sync_and_decode(tps_softbits, 1);
while (rel_symbol_no ~= -1)
    fprintf('TPS sync at rel_framse_no=%d\n', rel_symbol_no);
    this_frame = dab_binval(tps_bits(24:25));
    if (start_decode_symbol == -1 && this_frame == 0)
        start_decode_symbol = rel_symbol_no;
    end
    dvb_dump_tps(tps_bits);
    [rel_symbol_no tps_bits] = dvb_tps_sync_and_decode(tps_softbits, rel_symbol_no+1);
end

%begin DVB-T decode

if (start_decode_symbol < 0)
    error('Could not find start DVB-T superframe');
end
    
x_stream = [];

for sym=start_decode_symbol:size(frame,1),
   
    %sym is 1-based. DVB-T is 0-bsaed
    dvb_sym_no = sym - start_decode_symbol;

    data_frame(dvb_sym_no+1,:)  = dvb_crude_estimate(frame(sym,:),dvb_data_carriers, dvb_sym_no);
    data_frame_deint(dvb_sym_no+1,:) = dvb_freq_deint(data_frame(dvb_sym_no+1,:),dvb_H, dvb_sym_no);
    %demapped(dvb_sym_no+1,:) = dvb_test_hard_qpsk_demap(data_frame_deint(dvb_sym_no+1,:));
    
    
    demapped = dvb_test_hard_qpsk_demap(data_frame_deint(dvb_sym_no+1,:));

    %extract the individual bits, in a single row each (1512 bits)
    a0 = demapped(:,1)';
    a1 = demapped(:,2)';
    a2 = demapped(:,3)';
    a3 = demapped(:,4)';

    %group into rows of 126 columns
    a0_blk = reshape(a0,126,length(a0)/126)';
    a1_blk = reshape(a1,126,length(a1)/126)';
    a2_blk = reshape(a2,126,length(a2)/126)';
    a3_blk = reshape(a3,126,length(a3)/126)';

    %de-bit interleave (think about this..)

    b0_blk = circshift(a0_blk, [0 +0]);
    b1_blk = circshift(a1_blk, [0 +63]);
    b2_blk = circshift(a2_blk, [0 +105]);
    b3_blk = circshift(a3_blk, [0 +42]);

    %flatten

    b0 = reshape(b0_blk', 1, numel(b0_blk));
    b1 = reshape(b1_blk', 1, numel(b1_blk));
    b2 = reshape(b2_blk', 1, numel(b2_blk));
    b3 = reshape(b3_blk', 1, numel(b3_blk));

    %remux

    x = zeros(1,length(b0) * 4);
    x(1:4:end) = b0;
    x(2:4:end) = b2;
    x(3:4:end) = b1;
    x(4:4:end) = b3;
    
    x_stream = [x_stream x];
end



 
%trellis

trellis=poly2trellis([7], [171,133]);

x_stream_correct = vitdec(x_stream, trellis, 10*7, 'trunc', 'hard', [1 1 0 1]);

x_stream_recode = convenc(x_stream_correct,trellis, [1 1 0 1]);

viterbi_errs = sum(abs(x_stream_recode-x_stream));
fprintf(1,'viterbi errs = %d\n', viterbi_errs);
%parse to bytes

rs_int_data = zeros(1,length(x_stream_correct)/8);
for i=1:(length(x_stream_correct)/8)
    rs_int_data(i) = dab_binval(x_stream_correct(1+8*(i-1):8+8*(i-1)));
end


%forney de-interleave
rs_gf_poly = dab_binval([1 0 0 0 1 1 1 0 1]) ;
rs_dvb_poly = rsgenpoly(255,239,rs_gf_poly, 0); %PROD(i=0..9)(x+-alpha^i)
depth_I = 12;
packet_len = 204;
npackets = floor(length(rs_int_data)/packet_len) - 11;
mpeg_out = zeros(npackets, 188);
packet_deint = zeros(npackets,packet_len);
rs_errors = zeros(1, npackets);
for packet = 1:npackets
    for pkt_I  = 1:12,   
        packet_deint(packet,pkt_I:12:204) = rs_int_data(pkt_I+204*(packet-1)+204*(pkt_I - 1):12:204+204*(packet-1)+204*(pkt_I - 1));
    end
    %reedsolomon
    rs_in = gf(packet_deint(packet,:), 8, rs_gf_poly);
    [rs_corrected_gf rs_errorcount] = rsdec(rs_in, 204,188,rs_dvb_poly);  
    rs_errors(packet) = rs_errorcount;
    mpeg_out(packet,:) = (rs_corrected_gf.x);

    if (mod(packet, 10) == 0) 
        fprintf(1,'packet count = %d\n', packet);
    end
end




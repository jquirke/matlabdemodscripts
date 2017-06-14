clear all;
fprintf(1,'Loading samples...\n');
%telstra-umts5-4436-MG.usrp
%vodafone-4363-CH-0706.usrp PSC=2
f=fopen('C:\\temp\\optusu900_de_9476.usrp', 'rb'); v=fread(f, inf, 'short'); cv_usrp=v(2:2:end)+v(1:2:end)*j; fclose(f);
clear v;
%f=fopen('C:\temp\dab_mode1_basicrx_2msps.trunc.cf', 'rb'); v=fread(f, inf, 'int'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);


fs = 4e6;
cv_usrp = cv_usrp';
%plot ([1:length(cv_usrp)]/fs, abs(cv_usrp))

t = 0:1/fs:length(cv_usrp)/fs-1/fs;

cv_usrp = cv_usrp .* exp(j*2*pi*(-5300)*t);

cv_usrp = resample(cv_usrp, 24,25);


N_corr_samples=length(cv_usrp)-38399;
%N_corr_samples = 38400*20;

%PSC

a = [1, 1, 1, 1, 1, 1, -1, -1, 1, -1, 1, -1, 1, -1, -1, 1 ];
Cpsc = (1+j) * [ a, a, a, -a, -a, a, -a, -a, a, a, a, -a, a, -a, a, a ];

%SSC 

b=[a(1), a(2), a(3), a(4), a(5), a(6), a(7), a(8), -a(9), -a(10), -a(11), -a(12), -a(13), -a(14), -a(15),  -a(16) ];

z =  [b, b, b, -b, b, b, -b, -b, b, -b, b, -b, -b, -b, -b, -b];

H = cell(1,9);

%compute the hadamard matrix
H(1) = {[1]};
for k=2:9
    H(k) = {[cell2mat(H(k-1)) cell2mat(H(k-1)) ; cell2mat(H(k-1)) -cell2mat(H(k-1))]};
end

Hs = cell2mat(H(9));

%Hm = Hs(1+0:16:256,:); %every 16th row starting from 1st row

for i=1:16,
    Cssc(i,:) = (1+j) * Hs(1+(i-1)*16,:) .* z;
end

fprintf(1,'Correlating PSC...\n');
%attempt to correlate PSC
corr = zeros(1,N_corr_samples);
corr_diff = zeros(1,N_corr_samples*2);

% for (i=1:N_corr_samples)
%     corr(i) = sum( conj(Cpsc(1:256)) .* cv_usrp(i:i+255) ) ;
%     %+ abs(sum( conj(Cpsc(129:256)) .* cv_usrp(38400+i+128:38400+i+255) )).^2 ;
%     %corr_diff(i) = ...
%      %     abs(sum( conj(Cpsc(1:64)) .* cv_usrp(38400+i:38400+i+63) )).^2 ;%s...
%        % + abs(sum( conj(Cpsc(65:128)) .* cv_usrp(38400+i+64:38400+i+127) )).^2 ...
%        % + abs(sum( conj(Cpsc(129:192)) .* cv_usrp(38400+i+128:38400+i+191) )).^2 ...
%        % + abs(sum( conj(Cpsc(193:256)) .* cv_usrp(38400+i+192:38400+i+255) )).^2;
% end
% figure(1)
% plot([1:N_corr_samples], abs(corr).^2)




%slot_sample = 14129; %adj%
slot_sample = 65150;

%attempt to correlate SSC

scorr = zeros(1,15);

ssc_seq = [
    [1,1,2,8,9,10,15,8,10,16,2,7,15,7,16]        
[1,1,5,16,7,3,14,16,3,10,5,12,14,12,10]      
[1,2,1,15,5,5,12,16,6,11,2,16,11,15,12]      
[1,2,3,1,8,6,5,2,5,8,4,4,6,3,7]              
[1,2,16,6,6,11,15,5,12,1,15,12,16,11,2]      
[1,3,4,7,4,1,5,5,3,6,2,8,7,6,8]              
[1,4,11,3,4,10,9,2,11,2,10,12,12,9,3]        
[1,5,6,6,14,9,10,2,13,9,2,5,14,1,13]         
[1,6,10,10,4,11,7,13,16,11,13,6,4,1,16]      
[1,6,13,2,14,2,6,5,5,13,10,9,1,14,10]        
[1,7,8,5,7,2,4,3,8,3,2,6,6,4,5]              
[1,7,10,9,16,7,9,15,1,8,16,8,15,2,2]         
[1,8,12,9,9,4,13,16,5,1,13,5,12,4,8]         
[1,8,14,10,14,1,15,15,8,5,11,4,10,5,4]       
[1,9,2,15,15,16,10,7,8,1,10,8,2,16,9]        
[1,9,15,6,16,2,13,14,10,11,7,4,5,12,3]       
[1,10,9,11,15,7,6,4,16,5,2,12,13,3,14]       
[1,11,14,4,13,2,9,10,12,16,8,5,3,15,6]       
[1,12,12,13,14,7,2,8,14,2,1,13,11,8,11]      
[1,12,15,5,4,14,3,16,7,8,6,2,10,11,13]       
[1,15,4,3,7,6,10,13,12,5,14,16,8,2,11]       
[1,16,3,12,11,9,13,5,8,2,14,7,4,10,15]       
[2,2,5,10,16,11,3,10,11,8,5,13,3,13,8]       
[2,2,12,3,15,5,8,3,5,14,12,9,8,9,14]         
[2,3,6,16,12,16,3,13,13,6,7,9,2,12,7]        
[2,3,8,2,9,15,14,3,14,9,5,5,15,8,12]         
[2,4,7,9,5,4,9,11,2,14,5,14,11,16,16]        
[2,4,13,12,12,7,15,10,5,2,15,5,13,7,4]       
[2,5,9,9,3,12,8,14,15,12,14,5,3,2,15]        
[2,5,11,7,2,11,9,4,16,7,16,9,14,14,4]        
[2,6,2,13,3,3,12,9,7,16,6,9,16,13,12]        
[2,6,9,7,7,16,13,3,12,2,13,12,9,16,6]        
[2,7,12,15,2,12,4,10,13,15,13,4,5,5,10]      
[2,7,14,16,5,9,2,9,16,11,11,5,7,4,14]        
[2,8,5,12,5,2,14,14,8,15,3,9,12,15,9]        
[2,9,13,4,2,13,8,11,6,4,6,8,15,15,11]        
[2,10,3,2,13,16,8,10,8,13,11,11,16,3,5]      
[2,11,15,3,11,6,14,10,15,10,6,7,7,14,3]      
[2,16,4,5,16,14,7,11,4,11,14,9,9,7,5]        
[3,3,4,6,11,12,13,6,12,14,4,5,13,5,14]       
[3,3,6,5,16,9,15,5,9,10,6,4,15,4,10]         
[3,4,5,14,4,6,12,13,5,13,6,11,11,12,14]      
[3,4,9,16,10,4,16,15,3,5,10,5,15,6,6]        
[3,4,16,10,5,10,4,9,9,16,15,6,3,5,15]        
[3,5,12,11,14,5,11,13,3,6,14,6,13,4,4]       
[3,6,4,10,6,5,9,15,4,15,5,16,16,9,10]        
[3,7,8,8,16,11,12,4,15,11,4,7,16,3,15]       
[3,7,16,11,4,15,3,15,11,12,12,4,7,8,16]      
[3,8,7,15,4,8,15,12,3,16,4,16,12,11,11]      
[3,8,15,4,16,4,8,7,7,15,12,11,3,16,12]       
[3,10,10,15,16,5,4,6,16,4,3,15,9,6,9]        
[3,13,11,5,4,12,4,11,6,6,5,3,14,13,12]       
[3,14,7,9,14,10,13,8,7,8,10,4,4,13,9]        
[5,5,8,14,16,13,6,14,13,7,8,15,6,15,7]       
[5,6,11,7,10,8,5,8,7,12,12,10,6,9,11]        
[5,6,13,8,13,5,7,7,6,16,14,15,8,16,15       ]
[5,7,9,10,7,11,6,12,9,12,11,8,8,6,10        ]
[5,9,6,8,10,9,8,12,5,11,10,11,12,7,7        ]
[5,10,10,12,8,11,9,7,8,9,5,12,6,7,6         ]
[5,10,12,6,5,12,8,9,7,6,7,8,11,11,9         ]
[5,13,15,15,14,8,6,7,16,8,7,13,14,5,16      ]
[9,10,13,10,11,15,15,9,16,12,14,13,16,14,11 ]
[9,11,12,15,12,9,13,13,11,14,10,16,15,14,16 ]
[9,12,10,15,13,14,9,14,15,11,11,13,12,16,10 ]
];

%for each block

for group = 1:64,
    seq = ssc_seq(group,:);
    for shift = 0:40 %try all 15 shifts
        test_slot = slot_sample + shift*2560;
        %sum over all the SSCs in the block
        scorr(group,shift+1) = 0;
        for slot=0:14
            scorr(group,shift+1) = scorr(group,shift+1)+ abs(sum((Cssc(seq(slot+1),1:256) .* conj(cv_usrp(test_slot+2560*slot:test_slot+255+2560*slot))))).^2;
        end
    end
end
   

%guess the primary scrambling code group

psc_group = find (max(scorr') == max(max(scorr')));
slot_offset = find (scorr(psc_group,:) == max(max(scorr')));


%antenna 0 CPICH pattern is 00.....
%antenna 1 CPICH pattern is 0011 1100 0011.... (even slot) 1100 0011. (odd)

%CPICH channelization code in both cases is C{256,0} which is 111....

%therefore, since ch code, is unity, the CPICH pattern is directly
%chipped by scrambling code

%00 modulates to QPSK (+1+1j, 11 modulates to QPSK (-1-1j)

seq1 = commsrc.pn('genpoly', [18 7 0]);
seq2 = commsrc.pn('genpoly', [18 10 7 5 0], 'InitialStates', ones(1,18));

% reg = zeros(1,18);
% reg(18) = 1;
% for i = 1:100,
%     jqout2(i) = reg(18);
%     bit = mod(reg(18)  + reg(13) + reg(11) + reg(8),2);
%     reg(2:18) = reg(1:17);
%     reg(1) = bit;
%     
% end

seq1.reset
seq2.reset

seq1.NumBitsOut = 2^18 - 1;
seq2.NumBitsOut = 2^18 - 1;

x = seq1.generate';
y = seq2.generate';

%n'th gold seq
n = 16*336;
%no need to do modulo operation as all the codes used will never wrap
xn_lower = x(1+n:38400+n);

zn_real = mod(xn_lower + y(1:38400), 2);

xn_upper = x(1+n+131072:38400+n+131072);

zn_imag = mod(xn_upper + y(1+131072:38400+131072),2);

Sn = (1-2*zn_real) + (1-2*zn_imag)*1i;

%N_corr_samples=length(cv_usrp)-38399;
scramb_corr = zeros(1,N_corr_samples);

fprintf(1,'Correlating CPICH...\n');


 for (i=1:N_corr_samples)
     scramb_corr(i) = sum( conj(Sn(1:512) .* (1+1i)) .* cv_usrp(i:i+511) );
     if (mod(i,10*38400) == 1)
         fprintf(1,'*');
     end
 end
 

 
 figure(2)
 plot([1:N_corr_samples], abs(scramb_corr));

break  

% base=1;
% xalt = zeros(1,2^18-1);
% yalt = zeros(1,2^18-1);
% 
% xalt(base+0) = 1;
% xalt(base+1:base+17) = 0;
% 
% yalt(base+0:base+17) = 1;
% 
% for i=0:2^18-20
%     xalt(base+i+18) = mod(xalt(base+i+7) + xalt(base+i),2);
%     yalt(base+i+18) = mod(yalt(base+i+10) + yalt(base+i+7) + yalt(base+i+5) + yalt(base+i),2);
% end

%strong correlation at sample 55089

%descramle

%slot sync is at 16689       55089       93489      131889      170289

%slot_syncs = [16689       55089       93489      131889      170289
%208689      247089          285489];

slot_syncs_de =   [     15825       54225       92625      131025      169426      207826      246224 ...
      284627      323025      361425      399825      438223      476626      515024 ...
      553424      591822      630225      668623      707023      745423      783823 ... 
      822224      860622      899022      937420      975823     1014223     1052621 ... 
     1091021     1129422     1167820     1206220     1244620     1283020     1321421 ... 
     1359819     1398219     1436619     1475017     1513419     1551818     1590218 ... 
     1628618     1667018     1705419     1743817     1782217     1820617     1859018 ... 
     1897416     1935816     1974216     2012616     2051017     2089415     2127815 ... 
     2166215     2204615     2243016     2281414     2319814     2358214     2396612 ... 
     2435015     2473413     2511813     2550213     2588614     2627014     2665412 ... 
     2703812     2742212     2780613     2819011     2857411     2895811     2934212 ... 
     2972612     3011010     3049410     3087810     3126211     3164611     3203007 ... 
     3241409     3279807     3318210     3356610     3395008     3433408     3471806 ... 
     3510209     3548607     3587007     3625405     3663808     3702208     3740606 ... 
     3779004 ];
 
 %warrandyte west
 slot_syncs =       [ 33473       71873      110273      148673      187072      225472      263872 ...
      302272      340671      379071      417471      455871      494271      532670 ...
      571070      609470      647870      686269      724669      763069      801469 ...
      839869      878268      916668      955068      993468     1031868     1070267 ...
     1108667     1147067     1185467     1223866     1262266     1300666     1339066 ...
     1377466     1415865     1454265     1492665     1531065     1569464     1607864 ...
     1646264     1684664     1723064     1761463     1799863     1838263     1876663 ...
     1915063     1953462     1991862     2030262     2068662     2107061     2145461 ...
     2183861     2222261     2260661     2299060     2337460     2375860     2414260 ...
     2452660     2491059     2529459     2567859     2606259     2644658     2683058 ...
     2721458     2759858     2798258     2836657     2875057     2913457     2951857 ...
     2990257     3028656     3067056     3105456     3143856     3182255     3220655 ...
     3259055     3297455     3335855     3374254     3412654     3451054     3489454 ...
     3527853     3566253     3604653     3643053     3681453     3719852     3758252 ...
     3796652]

 descrambled_data = zeros(1,length(slot_syncs)*38400);

%descramble all data
descrambled_data = zeros(1,length(slot_syncs) * 38400); %prealloc
for frame =1:length(slot_syncs)
 
    frame_scrambled = cv_usrp(slot_syncs(frame)+0:slot_syncs(frame)+0+38399);
    frame_out = frame_scrambled .* conj(Sn);

    descrambled_data(1+(frame-1)*38400:38400+(frame-1)*38400) = frame_out;
    
end

clear cv_usrp

%compute the pilot symbols

pilot_CPICH_channel = zeros(1,150*length(slot_syncs));

for symbol_idx = 1:length(slot_syncs)*150
    pilot_CPICH_channel(symbol_idx) = sum(descrambled_data(1+(symbol_idx-1)*256:256+(symbol_idx-1)*256) .* umts_spread_code(256,0));
end

%compute the P-CCPCH symbols

CCPCH_channel = zeros(1,150*length(slot_syncs));
for symbol_idx = 1:length(slot_syncs)*150
    CCPCH_channel(symbol_idx) = sum(descrambled_data(1+(symbol_idx-1)*256:256+(symbol_idx-1)*256) .* umts_spread_code(256,1)) ...
        ./ pilot_CPICH_channel(symbol_idx) * exp(j*pi/4);
end

%compute the PICH symbols

PICH_channel = zeros(1,150*length(slot_syncs)); 
PICH_offset = -10;

if (PICH_offset < 0)
    PICH_offset = PICH_offset + 150;
end
PICH_offset_chips = PICH_offset  *256;

%the PICH that begins in frame 'n' really is for the PCH that begins offset
%into frame n+2. i.e. the one that begins near the end of frame 1, actually
%is for SCH that starts in frame 3. So correct accordingly
for symbol_idx = 1:(length(slot_syncs)-2)*150
    PICH_channel(symbol_idx+2*150) = sum(descrambled_data(1+(symbol_idx-1)*256+PICH_offset_chips:256+(symbol_idx-1)*256+PICH_offset_chips) .* umts_spread_code(256,3)) ...
        ./ pilot_CPICH_channel(symbol_idx+2*150) * exp(j*pi/4);
end

%compute the SCCPCH(PCH) symbols  note this is SF128 on telstra

PCH_channel = zeros(1,300*length(slot_syncs)); 
PCH_offset = 20;
PCH_offset_chips = PCH_offset  *256;

for symbol_idx = 1:(length(slot_syncs)-1)*300
    PCH_channel(symbol_idx) = sum(descrambled_data(1+(symbol_idx-1)*128+PCH_offset_chips:128+(symbol_idx-1)*128+PCH_offset_chips) .* umts_spread_code(128,4)) ...
        ./ pilot_CPICH_channel(floor((symbol_idx-1)/2)+1) * exp(j*pi/4);
end

%PICH 'demod'

for (i=1:length(PICH_channel)/150)
    PICH_demod(i,:) = umts_qpsk_demap(PICH_channel(1+(i-1)*150:150+(i-1)*150));
    PICH_sum(i) = sum(PICH_demod(i,1:288));
end


%compute the SCCPCH(FACH) symbols  note this is SF64 on telstra

FACH_channel = zeros(1,600*length(slot_syncs)); 
FACH_offset = 0;
FACH_offset_chips = FACH_offset  *256;

for symbol_idx = 1:(length(slot_syncs))*600
    FACH_channel(symbol_idx) = sum(descrambled_data(1+(symbol_idx-1)*64+FACH_offset_chips:64+(symbol_idx-1)*64+FACH_offset_chips) .* umts_spread_code(64,1)) ...
        ./ pilot_CPICH_channel(floor((symbol_idx-1)/4)+1) * exp(j*pi/4);
end


%estimate the frequency offset by partially correlation CPICH
%CPICH in STTD mode varies every symbol (256-chips) due to STTD pattern
%therefore, look at the phase different in every pair of (128,128)chips

% N_freq_est_slots = 120;
% T_freq_est_start_symbol = slot_syncs(1);
% 
% 
% for i=1:N_freq_est_slots
%     first_half(i) = sum(cv_usrp(T_freq_est_start_symbol+(i-1)*2560:T_freq_est_start_symbol+127+(i-1)*2560) .* conj(Cpsc(1:128)));
%     second_half(i) = sum(cv_usrp(T_freq_est_start_symbol+128+(i-1)*2560:T_freq_est_start_symbol+255+(i-1)*2560) .* conj(Cpsc(129:256)));
% end

%P-CCPCH demod histogram
% figure(5)
% hist(diff(angle(symbols_out_CCPCH ./ symbols_out_CPICH))/(pi/2), 100)

%estimate modulation of the PSC

  %  angle(corr(slot_syncs))
  %  angle(scramb_corr(slot_syncs))

%reference (non STTD) CPICH is modulated with (1,1) = 1+j. Therefore, to get absolute phase, rotate phase by +angle(1+j) = pi/4     

%estimate phase

%figure(10)
% plot([1:150], angle(symbols_out_CPICH(1,:)))


offset = 0; % can be 1, for odd BCH

%decode BCH mapped to P-CCPCH
for (i=offset:2:length(CCPCH_channel)/150-2)


    CCPCH_symbols_corrected_stripped_0 = umts_extract_pccpch_frame(CCPCH_channel(1+i*150:150+i*150) );
    CCPCH_symbols_corrected_stripped_1 = umts_extract_pccpch_frame(CCPCH_channel(151+i*150:300+i*150) );



    figure(3)
     plot(real(CCPCH_symbols_corrected_stripped_0), imag(CCPCH_symbols_corrected_stripped_0), '+')


    figure(4)
     plot(real(CCPCH_symbols_corrected_stripped_1), imag(CCPCH_symbols_corrected_stripped_1), '+')

     
     
    CCPCH_bits_frame_0 = umts_qpsk_demap(CCPCH_symbols_corrected_stripped_0);
    CCPCH_bits_frame_1 = umts_qpsk_demap(CCPCH_symbols_corrected_stripped_1);

    CCPCH_bits_frame_2nddeint_0 = umts_2nd_deinterleave(CCPCH_bits_frame_0);
    CCPCH_bits_frame_2nddeint_1 = umts_2nd_deinterleave(CCPCH_bits_frame_1);

    trellis = poly2trellis([9], [561 753]);

    merged = zeros(1,length(CCPCH_bits_frame_2nddeint_0)*2);

    merged(1:2:end) = CCPCH_bits_frame_2nddeint_0;
    merged(2:2:end) = CCPCH_bits_frame_2nddeint_1;

    decoded = vitdec(merged,trellis, 70, 'term', 'hard');
    encoded = umts_conv_encode(decoded); 

    crcpoly=[1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];

    crc = umts_crc(decoded(1:246), crcpoly);
    if (sum(abs(crc - decoded(247:247+15))) == 0)
        fprintf(1, 'CRC matches\n');
        fname = sprintf('C:\\temp\\umts\\bch%03d.bin', floor(i/2));
        umts_write_bitstring_file(fname, decoded(1:246));
    else
        fprintf(1, 'CRC error!\n');    
    end
    fprintf(1, 'bit errors = %d\n', sum(abs(encoded - merged)));
    

end



 %correlate the half-PSCs
 
 % d

 
 break
 
 
 %FACH
 
 for i=1:length(FACH_channel)/600;
     FACH_tti = FACH_channel(1+(i-1)*600:600+(i-1)*600);
     FACH_pwr = mean(abs(FACH_tti));
     if (FACH_pwr <0.2)
         continue;
     end
     FACH_tti_softbits = umts_qpsk_demap_soft(FACH_tti);
     FACH_soft_tfci = umts_fach_extract_tfci(FACH_tti_softbits, 8);
     tfci = umts_soft_decode_tfci(FACH_soft_tfci);
     fprintf(1,'Frame %d, tfci = %d\n', i, tfci);
 end
 
 i=124;
 i=115;
 i=124;
 i=21;
 FACH_tti = FACH_channel(1+(i-1)*600:600+(i-1)*600);
 FACH_tti_softbits = umts_qpsk_demap_soft(FACH_tti);
 FACH_tti_softdatabits = umts_fach_extract_ndata(FACH_tti_softbits,8);
 FACH_tti_deintbits = umts_2nd_deinterleave(FACH_tti_softdatabits);
 %FACH_tti_deintbits = FACH_tti_deintbits(1:552);
 plot([1:length(FACH_tti_deintbits)], abs(FACH_tti_deintbits))
 
 
eplus = 2*384;
 eminus = 2*168;
 eini  =1;
 
 e = eini;
 m = 1;
 Xi = 384;
 
 bits_inserted_index = zeros(1,168);
 
 repeatcnt = 0;
 
 while (m<=Xi)
     e = e - eminus;
     while (e<=0)
         %fprintf(1, 'Repeat bit %d, post stuffed offset = %d\n', m, m+repeatcnt+1);
         bits_inserted_index(repeatcnt+1) = m+repeatcnt+1;
         e = e + eplus;
         repeatcnt = repeatcnt+1;
     end
     m = m + 1;
 end
 
 map_inserted = ones(1,552);
 map_inserted(bits_inserted_index) = 0;
 
 idx = 1;
 for i=1:552,
     if (map_inserted(i) > 0)
        output_keep(idx) = i;
        idx = idx + 1;
     end
 end

  
 
 
 %PCH
 
 eplus = 2*528;
 eminus = 2*72;
 eini  =1;
 
 e = eini;
 m = 1;
 Xi = 528;
 
 bits_inserted_index = zeros(1,72);
 
 repeatcnt = 0;
 
 while (m<=Xi)
     e = e - eminus;
     while (e<=0)
         %fprintf(1, 'Repeat bit %d, post stuffed offset = %d\n', m, m+repeatcnt+1);
         bits_inserted_index(repeatcnt+1) = m+repeatcnt+1;
         e = e + eplus;
         repeatcnt = repeatcnt+1;
     end
     m = m + 1;
 end
 
 map_inserted = ones(1,600);
 map_inserted(bits_inserted_index) = 0;
 
 idx = 1;
 for i=1:600,
     if (map_inserted(i) > 0)
        output_keep(idx) = i;
        idx = idx + 1;
     end
 end
 
 %fprintf(1,'Total repeat = %d\n', repeatcnt);
 
 for i=1:length(PCH_channel)/300-1
     PCH_tti = PCH_channel(1+(i-1)*300:300+(i-1)*300);
     PCH_bits = umts_qpsk_demap(PCH_tti);
     PCH_deint = umts_2nd_deinterleave(PCH_bits);
     PCH_depuncture = PCH_deint(output_keep);
     PCH_decoded = vitdec(PCH_depuncture,trellis, 70, 'term', 'hard');
     PCH_L3frame = PCH_decoded(1:240);
     PCH_CRC = PCH_decoded(241:256);
     PCH_calc_CRC = umts_crc(PCH_L3frame, crcpoly);
     if (sum(abs(PCH_CRC - PCH_calc_CRC)) == 0)
        fprintf(1,'%d PCH CRC matches\n', i);
        fname = sprintf('C:\\temp\\umts\\pch%03d.bin', i);
        umts_write_bitstring_file(fname, PCH_L3frame)
     else
        fprintf(1,'%d PCH CRC error\n', i);
     end
 end
 
 
     
     
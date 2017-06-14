clear all;
fprintf(1,'Loading samples...\n');
%telstra-umts5-4436-MG.usrp
%vodafone-4363-CH-0706.usrp PSC=2
f=fopen('c:\\temp\\genlte.uplink.0_3_0_10.bin', 'rb'); fseek(f, 0.0*(7.68e6 * (2*2)), 'bof');v=fread(f, 10*7.68e6*(2), 'int16'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);
%f=fopen('C:\\temp\\test.lte', 'rb');v=fread(f, inf, 'int16'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);

%fout=fopen('C:\\temp\\genlte.uplink.shortened.bin', 'wb');
%fwrite(fout, v, 'int16');
%fclose(fout)

cv_usrp = cv_usrp.';
clear v;

fs=30.72e6
%plot([0:length(cv_usrp)-1],real(cv_usrp))
break





%chirp2 is actually the initial uplink assignment 
%chirp2 = cv_usrp(454985:485610);
%chirp2_strip = chirp2(end-24575:end);
%plot(abs(fftshift(fft(chirp2_strip))))


%seq51
chirp1 = cv_usrp(928725:935580);
chirp1_strip = chirp1(end-6143:end);%(end-24575:end);

%seq0
chirp2 = cv_usrp(4000650:4007579);

%seq54
chirp3 = cv_usrp(5075856:5082780);

%seq45
chirp4 = cv_usrp(7072664:7079575);


chirp_ref = gen_prach_seq_base(49,12,0,25,10,4);
%chirp_ref762 = gen_prach_seq_base(762,12,0,75,5,1);

plot([0:6143], 1e3*abs(fftshift(fft(chirp_ref))), [0:6143],  abs(fftshift(fft(chirp1_strip))))


%plot([-24576/2:24576/2-1]/144, abs(fftshift(fft(chirp1_strip))),[-24576/2:24576/2-1]/144, 7700*abs(fftshift(fft(chirp_ref))))


%try all
% seqs = zeros(64, 24576/4);
% corrseqs = zeros(64, length(chirp1_strip));
% for seqidx = 1:64,
%     seqs(seqidx, :) = gen_prach_seq_base(0+seqidx+1, 0, 0, 25,10,4);
%     tempcorr = conv(chirp1_strip, fliplr(conj(seqs(seqidx,:)))); 
%     corrseqs(seqidx,:) = tempcorr(1:end-6143);
%     seqidx
% end

%chirp identified as 762

%plot([0:length(cv_usrp)-1], abs(corrseqs(3,:)), [0:length(cv_usrp)-1], real(cv_usrp))

%chirp begin at 117086, 
%first peak at 128655
%second peak at 153231

%difference between peaks =  153231-128655 = 24576!! - not sure how the
%second correlation runs outside... maybe something wrong with my code

%128655 - 117086=11569 (%first peak to begin chirp)

%11569 - 3168 (remove cyclic prefix) = 8401

%known sequences in in use - 0[1],1[1], 3[1], 4[1],5,7,9,15,16,18, 20,21,23,27,28,32,33,34,35,37,38,39,41[2],45[3],46[1], 49,51,52,54,58,59,60,62

chirp_ref = gen_prach_seq_base(51,12,0,25,10,4);
corrzoom = conv(cv_usrp, fliplr(conj(chirp_ref)));
plot([0:length(cv_usrp)-1], abs(cv_usrp), [0:length(cv_usrp)-1], abs(corrzoom(1:length(cv_usrp))))

chirp_ref = gen_prach_seq_base(51,0,0,25,10,4);


for i=0:length(chirp1)-1,
    remain = min(length(chirp_ref), length(chirp1)-i);
    corrold(i+1) = sum((chirp1(1+i:remain+i) .* conj(chirp_ref(1:remain))));
end

plot(abs(corrold))



chirp_ref = gen_prach_seq_base(0,0,0,25,10,4);
for i=0:length(chirp2)-1,
    remain = min(length(chirp_ref), length(chirp2)-i);
    corrold(i+1) = sum((chirp2(1+i:remain+i) .* conj(chirp_ref(1:remain))));
end

plot(abs(corrold))

chirp_ref = gen_prach_seq_base(54,0,0,25,10,4);
for i=0:length(chirp3)-1,
    remain = min(length(chirp_ref), length(chirp3)-i);
    corrold(i+1) = sum((chirp3(1+i:remain+i) .* conj(chirp_ref(1:remain))));
end

plot(abs(corrold))


chirp_ref = gen_prach_seq_base(45,0,0,25,10,4);
for i=0:length(chirp4)-1,
    remain = min(length(chirp_ref), length(chirp4)-i);
    corrold(i+1) = sum((chirp4(1+i:remain+i) .* conj(chirp_ref(1:remain))));
end

plot(abs(corrold))

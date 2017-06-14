clear all;
fprintf(1,'Loading samples...\n');
%telstra-umts5-4436-MG.usrp
%vodafone-4363-CH-0706.usrp PSC=2
f=fopen('C:\\temp\\genlte.uplink.3_3_14_3.bin', 'rb'); fseek(f, 0.0*(7.68e6 * (2*2)), 'bof');v=fread(f, 10*7.68e6*(2), 'int16'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);
%f=fopen('C:\\temp\\test.lte', 'rb');v=fread(f, inf, 'int16'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);

%fout=fopen('C:\\temp\\genlte.uplink.bin', 'wb');
%fwrite(fout, v, 'int16');
%fclose(fout)

cv_usrp = cv_usrp.';
clear v;

fs=30.72e6
plot([0:length(cv_usrp)-1],real(cv_usrp))

break;




%chirp2 is actually the initial uplink assignment 
%chirp2 = cv_usrp(454985:485610);
%chirp2_strip = chirp2(end-24575:end);
%plot(abs(fftshift(fft(chirp2_strip))))

chirp1 = cv_usrp(117086:144799);
chirp1_strip = chirp1(end-24575:end);
plot(abs(fftshift(fft(chirp1_strip))))

chirp_ref = gen_prach_seq_base(760,12,0,75,5,1);
chirp_ref762 = gen_prach_seq_base(762,12,0,75,5,1);
%plot([-24576/2:24576/2-1]/144, abs(fftshift(fft(chirp1_strip))),[-24576/2:24576/2-1]/144, 7700*abs(fftshift(fft(chirp_ref))))


%try all
seqs = zeros(9, 24576);
corrseqs = zeros(9, length(cv_usrp));
for seqidx = 1:9,
    seqs(seqidx, :) = gen_prach_seq_base(760+seqidx-1, 12, 0, 75,5,1);
    tempcorr = conv(cv_usrp, fliplr(conj(seqs(seqidx,:)))); 
    corrseqs(seqidx,:) = tempcorr(1:end-24575);
    seqidx
end

%chirp identified as 762

plot([0:length(cv_usrp)-1], abs(corrseqs(3,:)), [0:length(cv_usrp)-1], real(cv_usrp))

%chirp begin at 117086, 
%first peak at 128655
%second peak at 153231

%difference between peaks =  153231-128655 = 24576!! - not sure how the
%second correlation runs outside... maybe something wrong with my code

%128655 - 117086=11569 (%first peak to begin chirp)

%11569 - 3168 (remove cyclic prefix) = 8401


chirp_ref = gen_prach_seq_base(0,14,0,25,3,4);
corrzoom = conv(cv_usrp, fliplr(conj(chirp_ref)));

chirp_ref = gen_prach_seq_base(1,14,0,25,3,4);
corrzoom2 = conv(cv_usrp, fliplr(conj(chirp_ref)));

chirp_ref = gen_prach_seq_base(2,14,0,25,3,4);
corrzoom3 = conv(cv_usrp, fliplr(conj(chirp_ref)));

plot([0:length(cv_usrp)-1], abs(cv_usrp), [0:length(cv_usrp)-1], abs(corrzoom(1:length(cv_usrp))), [0:length(cv_usrp)-1], abs(corrzoom2(1:length(cv_usrp))))





corrzoom = conv(chirp1, fliplr(conj(chirp_ref762)));

plot(abs(corrzoom));



chirp_ref = gen_prach_seq_base(0,15,1,25,3,4);

for i=0:length(temp)-1,
    remain = min(length(chirp_ref), length(temp)-i);
    corrold(i+1) = sum((temp(1+i:remain+i) .* conj(chirp_ref(1:remain))));
end

plot(abs(corrold))



   
    
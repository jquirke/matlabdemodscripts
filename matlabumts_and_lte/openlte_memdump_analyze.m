clear all;
fprintf(1,'Loading samples...\n');
%telstra-umts5-4436-MG.usrp
%vodafone-4363-CH-0706.usrp PSC=2
f=fopen('C:\\temp\\detect_i.bin', 'rb'); v=fread(f, inf, 'float32'); cv_i=v.'; fclose(f);
f=fopen('C:\\temp\\detect_q.bin', 'rb'); v=fread(f, inf, 'float32'); cv_q=v.'; fclose(f);
%f=fopen('C:\\temp\\test.lte', 'rb');v=fread(f, inf, 'int16'); cv_usrp=v(1:2:end)+v(2:2:end)*j; fclose(f);

cv_usrp = cv_i + j*cv_q;cv_q


%fout=fopen('C:\\temp\\genlte.uplink.shortened.bin', 'wb');
%fwrite(fout, v, 'int16');
%fclose(fout)

clear v;

fs=30.72e6
plot([0:length(cv_usrp)-1]/7.68e6*1000,real(cv_usrp))

break;
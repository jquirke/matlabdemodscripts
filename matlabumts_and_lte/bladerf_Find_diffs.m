clear all;
fprintf(1,'Loading samples...\n');
%telstra-umts5-4436-MG.usrp
%vodafone-4363-CH-0706.usrp PSC=2
f=fopen('C:\\temp\\bladecounter.bin', 'rb'); fseek(f, 0*(15.36e6 * (2*2)), 'bof');v=fread(f, 100*1048576, 'int32');

v2 = v(1:100*1048576).';
 v2_diff = v2(2:end) - v2(1:end-1);
 

  fprintf(1, 'Differences at locations:\n');
  
 v2_difflocs = find (v2_diff>1)
 
 fprintf (1,'Size of differences'); 
 v2_diff(v2_difflocs)
 
 fprintf(1, 'Differences at locations div 32k:\n');
 
 (v2_difflocs)/32768
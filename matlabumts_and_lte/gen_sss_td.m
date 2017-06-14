function seqtd = gen_sss_td(nid, subframe, fftsize)

    freq_seq = gen_sss(nid, subframe);
    
    carriers = zeros(1,fftsize);%for the 3.84Mhz clock case
    
    carriers(2:(2+30)) = freq_seq(32:62); %DC carrier = 0, carrier 1 map to NDLRB*Nsc/2 etc
    
    carriers((end-30):end) = freq_seq(1:31); %  carriers -1 map to NDLRB*Nsc/2 - 1 ...
    
    seqtd = ifft(carriers);
    
end


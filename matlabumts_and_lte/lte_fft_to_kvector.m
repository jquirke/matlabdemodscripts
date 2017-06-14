function kvector = lte_fft_to_kvector( fftsize, fftdata )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


    kvector = zeros(1,110*12); %max RB*12 = max RE
    
    num_k = min((fftsize-2)/2, 1320/2);
    
    kvector(110/2*12+1:110/2*12+1+num_k-1) = fftdata(2:num_k+1);
    kvector(110/2*12-num_k+1:110/2*12) = fftdata(end-num_k+1:end);

    
end


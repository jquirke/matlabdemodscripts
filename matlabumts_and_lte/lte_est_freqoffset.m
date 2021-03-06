function est_freq_offset_hz = lte_est_freqoffset( samples, fftsize, sssposindices)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    corr = 0;
    cyclicprefixsamples = 160 * fftsize/2048;
    for i=1:length(sssposindices)
        idx = sssposindices(i);
        corr = corr + sum ( conj(samples((idx-cyclicprefixsamples):(idx-1))) .* samples((idx+fftsize-cyclicprefixsamples+1):(idx+fftsize)) );
    end
    
    est_freq_offset_hz = angle(corr)/(2*pi) * 30.72e6/2048;
    
    
end


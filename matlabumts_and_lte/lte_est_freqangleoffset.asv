function est_angle = lte_est_freqangleoffset(samples, pssindices, fftsize)

    sums = zeros(1,length(pssindices));
    fftfactor = fftsize/2048;
    
    pssindices
    for i = 1:length(pssindices)
        sums(i) = sum( samples(pssindices(i)-144*fftfactor:pssindices(i)-1) .* conj(samples(pssindices(i)+fftsize-144*fftfactor:pssindices(i)+fftsize-1)) );
    end
    est_angle = sums;
end


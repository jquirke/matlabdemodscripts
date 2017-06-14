function kvectors = lte_slot_to_kvectors( fftsize, samples, ncp)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    if (ncp == 1)
        nsymbols = 7;
        kvectors = zeros(nsymbols, 110*12);
        
        for i=0:nsymbols-1;
            offset = 160 * fftsize/2048 + i* (2048+144)* fftsize/2048;
            kvectors(i+1,:) = lte_fft_to_kvector(fftsize,fft(samples(offset+1:offset+fftsize)));
        end
    else
        nsymbols = 6;
        kvectors = zeros(nsymbols, 110*12);
        for i=0:nsymbols-1;
            offset = 512 * fftsize/2048 + i*(2048+512)* fftsize/2048;
            kvectors(i+1,:) = lte_fft_to_kvector(fftsize,fft(samples(offset+1:offset+fftsize)));
        end
    end 
end


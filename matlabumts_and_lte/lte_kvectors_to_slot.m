function samples = lte_kvectors_to_slot( fftsize, kvector, ncp)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    SLOTS_PER_FRAME = 100 * 10 * 2;
    FRAME_SIZE_SAMPLES = 30.72e6;
    FFTSIZEMAX = 2048;
    NMAXRB = 110;
    RES_PER_RB = 12;
    NSUBCARRIERS = NMAXRB*RES_PER_RB;
    NORMAL_CYCLIC_PREFIX_FIRST = 160;
    NORMAL_CYCLIC_PREFIX = 144;
    EXTENDED_CYCLIC_PREFIX = 512;
    samples = zeros(1,FRAME_SIZE_SAMPLES/SLOTS_PER_FRAME * fftsize/FFTSIZEMAX);

    
    num_k = fftsize/2 - 2;
    if (ncp ~= 0)
        nsymbols = 7;
        for symbol = 0:(nsymbols-1),
            offset = NORMAL_CYCLIC_PREFIX_FIRST * fftsize/FFTSIZEMAX + symbol*(FFTSIZEMAX+NORMAL_CYCLIC_PREFIX) * fftsize/FFTSIZEMAX;
            if (symbol == 0) 
                cplen = NORMAL_CYCLIC_PREFIX_FIRST * fftsize/FFTSIZEMAX;
            else
                cplen = NORMAL_CYCLIC_PREFIX * fftsize/FFTSIZEMAX;
            end
            ifftdata = zeros(1,fftsize);
            ifftdata(2:num_k+1) = kvector(symbol+1,NSUBCARRIERS/2+1:NSUBCARRIERS/2+num_k);
            ifftdata(end-num_k+1:end) = kvector(symbol+1,NSUBCARRIERS/2-num_k+1:NSUBCARRIERS/2);
            symsamples = ifft(ifftdata);
            samples(offset+1:offset+fftsize) = symsamples;
            samples(offset-cplen+1:offset) = symsamples(end-cplen+1:end);
        end
    else
        for symbol = 0:(nsymbols-1),
            offset = EXTENDED_CYCLIC_PREFIX * fftsize/FFTSIZEMAX + symbol*(FFTSIZEMAX+EXTENDED_CYCLIC_PREFIX) * fftsize/FFTSIZEMAX;
            cplen = EXTENDED_CYCLIC_PREFIX;
            ifftdata = zeros(1,fftsize);
            ifftdata(2:num_k+1) = kvector(symbol+1,NSUBCARRIERS/2+1:NSUBCARRIERS/2+num_k);
            ifftdata(end-num_k+1:end) = kvector(symbol+1,NSUBCARRIERS/2-num_k+1:NSUBCARRIERS);
            symsamples = ifft(ifftdata);
            samples(offset+1:offset+fftsize) = symsamples;
            samples(offset-cplen+1:offset) = symsamples(end-cplen+1:end);
        end
        
    end

end
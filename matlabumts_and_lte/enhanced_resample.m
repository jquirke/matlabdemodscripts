function [outdata outstate] = enhanced_resample(indata, P, Q, B, instate)

    upsamp = upsample(indata, P);
    [filtered outstate] = filter(B,[1], upsamp, instate);
    outdata = downsample(filtered, Q);
    
end

%attempt coarse time, fine freq sync

function corroutput = dvbtest_timecorrelate(samples, tu, tguard)
    corroutput = zeros(1, length(samples));
    
    for i=1:(length(samples)-(tu+tguard)),
        prefix = samples(i+0:i+tguard-1);
        tail = samples(i+tu:i+tu+tguard-1);
        corr = conj(prefix).*tail;
        
        corroutput(i) = abs(sum(corr));

    end
        
end




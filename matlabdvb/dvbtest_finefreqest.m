%attempt coarse time, fine freq sync

function phase_avg = dvbtest_finefreqest(symbol, tu, tguard)
    
    prefix = symbol(1:tguard);
    tail = symbol(tu+1:tu+tguard);
    phases_est = prefix.*conj(tail);
    phase_avg = angle(sum(phases_est));    
        
end

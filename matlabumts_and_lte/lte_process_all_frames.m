function retrntis = lte_process_all_frames(usrpdata, sss1corr, fftsize, ncellid, ncp, tdd, tddconfig, path, specific_RNTIs)
%the timing, cellid and ncp have been detected by low level sync at this
%point
    avg = mean(abs(sss1corr));
    ExtraRNTIs = [specific_RNTIs];
    [pks locs] = findpeaks(abs(sss1corr),'minpeakheight', 5*avg, 'minpeakdistance', floor(30.72e6/100 * fftsize/2048 *.999));
    
    if (ncp) cplen = 144;, else cplen = 512; end
    
    locs 
    diff(locs)
     for loc = locs,
        
        %FDD - SSS subframe 0 is at second last symbol of slot 0
        %TDD - SSS subframe 0 is at LAST symbol of slot 1
        
        if (tdd == 0),
            start = loc + ... 
                fftsize + ...% advance the length of the second last symbol
                (cplen * fftsize/2048) + ... %then the cyclic prefix of last symbol
                fftsize ... %then the length of the last symbol
                -  (30.72e6/2000 * fftsize/2048); %then backtrack the entire length of one slot to get to the start of slot 0
        else
            start = loc + ...
                fftsize + ... %advance the length of the last symbol
                - 2 * (30.72e6/2000 * fftsize/2048); %then backtrack the entire length of two slots
            
            if (start < 0)
                continue;
                
            end
                
        end
        

        if (start + 30.72e6/100 * fftsize/2048 -1  > length(usrpdata)) break; end;
        radio_frame = usrpdata(start:start+30.72e6/100 * fftsize/2048 - 1);
        NewRNTIs = lte_process_radio_frame(radio_frame, fftsize,ncellid,ncp,tdd,tddconfig, ExtraRNTIs, path);
        ExtraRNTIs = [ExtraRNTIs NewRNTIs];
     end
     retrntis = ExtraRNTIs;
end
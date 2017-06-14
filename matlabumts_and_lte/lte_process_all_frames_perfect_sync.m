function lte_process_all_frames_perfect_sync(usrpdata, fftsize, ncellid, ncp)
%the timing, cellid and ncp have been detected by low level sync at this
%point
    
    %if (ncp) cplen = 144;, else cplen = 512; end
    
     for start=1:30.72e6/100*fftsize/2048:length(usrpdata)%loc = locs,
        
        %start = loc + fftsize + (cplen * fftsize/2048) + fftsize - (30.72e6/2000 * fftsize/2048);

        if (start + 30.72e6/100 * fftsize/2048 -1  > length(usrpdata)) break; end;
        radio_frame = usrpdata(start:start+30.72e6/100 * fftsize/2048 - 1);
        length(radio_frame)
        lte_process_radio_frame(radio_frame, fftsize,ncellid,ncp);
     end
end
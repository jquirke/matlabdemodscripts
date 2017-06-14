function [rel_frame_no tps_bits] = dvb_tps_sync_and_decode(tps_softbits, startfrom)
    %
    sync_odd = 2*(0.5 - [0 0 1 1 0 1 0 1 1 1 1 0 1 1 1 0] );
    sync_even = 2*(0.5 - [1 1 0 0 1 0 1 0 0 0 0 1 0 0 0 1 ] );
    
    dvb_tps_length = 68;
    dvb_sync_seq_start = 1;
    dvb_tps_nonsync = dvb_tps_length - dvb_sync_seq_start - length(sync_odd);
   
    dvb_bch_code_start = 54;
    dvb_bch_code_length = 14;
    
    dvb_bch_code_n = 127;
    dvb_bch_code_k = 113;
    %combine all of the energy from all carriers
    tps_combined_softbits = transpose(sum(tps_softbits, 2));

  

    %tolerate a maximum of 1-bit error in the sync word. As realistically
    %if there are any more errors the BCH code wont pick them.
    % and if we are getting this level of errors in the TPS
    % then the signal is awful
    
    possible_syncs = zeros(1, length(tps_combined_softbits)-dvb_tps_length+dvb_sync_seq_start+1);

    for i = startfrom+1:length(tps_combined_softbits)-dvb_tps_length+dvb_sync_seq_start+1;
        possible_syncs(i) = sum(sign(tps_combined_softbits(i:i+length(sync_even)-1)) .* sign(sync_even));
    end
   
    
    
   % figure(8);
   % plot ([1:length(possible_syncs)], possible_syncs);
    
    [~, possible_sync_idx] = find(abs(possible_syncs) >= 15);

    synced = 0;
    test_idx = 1;
    rel_frame_no = -1;
    while (synced == 0 && test_idx <= length(possible_sync_idx))
         % extract TPS
         tps_test_idx = possible_sync_idx(test_idx) - dvb_sync_seq_start ;

         %tps_bits_raw contains the entire 68-bit frame inc. modulation bit

         tps_bits_raw = cast(tps_combined_softbits(tps_test_idx:tps_test_idx+dvb_tps_length-1) < 0, 'double');
 
         %zero pad to (127,113) BCH code    
       
         tps_frame_bch = [zeros(1,60) tps_bits_raw(dvb_sync_seq_start+1:dvb_bch_code_start) tps_bits_raw(dvb_bch_code_start+1:dvb_tps_length) ];
         
         [tps_frame_bch_out_gf bcherr] = bchdec(gf(tps_frame_bch), dvb_bch_code_n, dvb_bch_code_k);
         %tps_bits
         
         tps_frame_bch_out = cast(tps_frame_bch_out_gf.x, 'double');
         if (bcherr >= 0)
             %fprintf(1,'bcherr = %d\n', bcherr);
             rel_frame_no = tps_test_idx;
             %tps_bits = tps_frame_bch_out(dvb_sync_seq_start+1:dvb_bch_code_start);
             %tps_bits = [zeros(1, dvb_sync_seq_start) tps_frame_bch_out(dvb_sync_seq_start:dvb_bch_code_start-1) tps_frame_bch_out(end-dvb_bch_code_length+1:end)];
             %tps_bits = [0 tps_bits_raw];
             tps_bits = tps_bits_raw;
             synced = 1;
             %dvb_dump_tps(tps_bits);
             break;
         end
         
         test_idx = test_idx + 1;
         
    end
    if (synced == 0)
       rel_frame_no = -1;
       tps_bits = [];
    end
end
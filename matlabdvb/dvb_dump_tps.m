function [ nulloutput ] = dvb_dump_tps( tps_bits )



    length_ind = dab_binval(tps_bits(18:23));
    frame_no = dab_binval(tps_bits(24:25));
    constellation = dab_binval(tps_bits(26:27));
    heirarchy = dab_binval(tps_bits(28:30));
    coderateHP = dab_binval(tps_bits(31:33));
    coderateLP = dab_binval(tps_bits(34:36));
    guardinterval = dab_binval(tps_bits(37:38));
    transmode = dab_binval(tps_bits(39:40));
    cellid = dab_binval(tps_bits(41:48));
    
    constellation_str = char('QPSK', '16-QAM', '64-QAM', 'Reserved');
    heirarchy_str = char('Non heirarchical', 'alpha=1', 'alpha=2', 'alpha=3', 'DVB-H','DVB-H','DVB-H','DVB-H');
    coderate_str = char('1/2', '2/3', '3/4', '5/6','7/8','Reserved','Reserved','Reserved');
    guardinterval_str = char('1/32', '1/16', '1/8', '1/4');
    transmode_str = char('2K', '8K', 'DVB-H', 'Reserved');
    
    fprintf(1, 'DVB-TPS: lengthind=%d, frame_no=%d, Modulation=%s, Heirarchy=%s\n', ...
        length_ind, frame_no, constellation_str(constellation + 1,:), ...
        heirarchy_str(heirarchy+1,:) ...
        );
    fprintf(1, 'DVB-TPS: Coderate(HP)=%s, Coderate(LP)=%s, Guardinterval=%s, Transmode=%s\n', ...
        coderate_str(coderateHP+1,:),...
        coderate_str(coderateLP+1,:),...
        guardinterval_str(guardinterval+1,:),...
        transmode_str(transmode+1, :)...
        );
    fprintf(1,'DVB-TPS: CellID = %d\n', cellid);

end


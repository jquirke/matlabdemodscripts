function data_frame = dvb_crude_estimate(dvb_frame, data_carriers, symbol_no)

    dvb_frame = dvb_frame / 2048; % crude channel estimate substitute for now
    
    symbol_no_mod4 = mod(symbol_no, 4);

    data_frame = dvb_frame(data_carriers( symbol_no_mod4  + 1,:) + 1);

end


function data_carriers = dvb_init_data_carriers(dvb_cp, dvb_tps, ndatacarriers, nactivecarriers)

    data_carriers = zeros(4,ndatacarriers);
    
    for i=0:3,
        carriermap = zeros(1, nactivecarriers);
        carriermap(dvb_cp+1) = 1;
        carriermap(dvb_tps+1) = 1;
        carriermap(1+(i*3):12:end) = 1;    
        data_carriers(i+1,:) = find (carriermap == 0) - 1;
    end

end


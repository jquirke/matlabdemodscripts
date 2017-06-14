function estimate_kvs = lte_linear_est_slot(NDLRB, kvectors, ncellid, ns, ncp,  num_antennas )
%no interpolation of symbols, just copy for now

    if (ncp == 1) 
        num_symbols = 7;
        ant01_2nd_ref_symbol = 4;
    else
        num_symbols = 6;
        ant01_2nd_ref_symbol = 3;
    end

    %for single antenna, the second antenna is just zeros, but the de-Alamouti code handles it fine 
    estimate_kvs = zeros(max(num_antennas,2), num_symbols, 110*12);

    for antenna = 0:num_antennas - 1,
        for symbol=0:num_symbols - 1,
            if (antenna <= 1)
               if (symbol < ant01_2nd_ref_symbol)
                    estimate_kvs(antenna+1, symbol+1, :) = lte_linear_est_symbol_antenna(NDLRB,kvectors(0+1,:), ncellid, 0, ns, ncp, antenna);
                    %estimate_kvs(antenna+1, symbol+1, :) = lte_linear_est_symbol_antenna(kvectors(ant01_2nd_ref_symbol+1,:), ncellid, ant01_2nd_ref_symbol, ns, ncp, antenna);
               else
                   estimate_kvs(antenna+1, symbol+1, :) = lte_linear_est_symbol_antenna(NDLRB,kvectors(ant01_2nd_ref_symbol+1,:), ncellid, ant01_2nd_ref_symbol, ns, ncp, antenna);
               end 
            else
                estimate_kvs(antenna+1, symbol+1, :) = lte_linear_est_symbol_antenna(NDLRB,kvectors(1+1,:), ncellid, 1, ns, ncp, antenna);
            end
        end
    end
    
end


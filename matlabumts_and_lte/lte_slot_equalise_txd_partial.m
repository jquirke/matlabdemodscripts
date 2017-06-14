function eq_kvectors = lte_slot_equalise_txd_partial(eq_kvectors_input, inputkvectors, est_kvectors,NDLRB, ncellid, ns, ncp, symbol_list )
%Very simple equalisation 2x2 only
%   Detailed explanation goes here


    eq_kvectors = eq_kvectors_input;
    
    for symbol = [symbol_list]
        
        antenna0 = reshape(est_kvectors(0+1, symbol+1,:), 1, 110*12);
        antenna1 = reshape(est_kvectors(1+1, symbol+1,:), 1, 110*12);        
        
        eq_kvectors(symbol+1, :) = lte_symbol_eq(inputkvectors(symbol+1, :), ...
            antenna0, antenna1,NDLRB, ncellid, symbol, ns, ncp);
        
    end

end
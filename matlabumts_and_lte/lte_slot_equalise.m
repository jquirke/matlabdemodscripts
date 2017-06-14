function eq_kvectors = lte_slot_equalise( inputkvectors, est_kvectors,NDLRB, ncellid, ns, ncp )
%Very simple equalisation 2x2 only
%   Detailed explanation goes here

    if (ncp == 1)
        nsymbols = 7;
    else
        nsymbols = 6;
    end
    
    eq_kvectors = zeros(nsymbols, 110*12);
    
    for symbol = 0:nsymbols-1,
        
        antenna0 = reshape(est_kvectors(0+1, symbol+1,:), 1, 110*12);
        antenna1 = reshape(est_kvectors(1+1, symbol+1,:), 1, 110*12);        
        
        eq_kvectors(symbol+1, :) = lte_symbol_eq(inputkvectors(symbol+1, :), ...
            antenna0, antenna1,NDLRB, ncellid, symbol, ns, ncp);
        
    end

end
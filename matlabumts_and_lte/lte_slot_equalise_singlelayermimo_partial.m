function eq_kvectors = lte_slot_equalise_singlelayermimo_partial(eq_kvectors_input, inputkvectors, est_kvectors,NDLRB, ncellid, ns, ncp, codebook_idx,symbol_list )
%Very simple equalisation 2x2 only
%   Detailed explanation goes here

   % codebook = {1/sqrt(2) * [1;1] 1/sqrt(2) * [1;-1] 1/sqrt(2) * [1;j] 1/sqrt(2) * [1;-j]};
    
   %this is hard to get your head around... the sqrt(2) factors
    codebook = { [1;1] [1;-1] [1;j] [1;-j]};
    
    eq_kvectors = eq_kvectors_input;
    
    for symbol = [symbol_list]
        
        antenna0 = reshape(est_kvectors(0+1, symbol+1,:), 1, 110*12);
        antenna1 = reshape(est_kvectors(1+1, symbol+1,:), 1, 110*12);        
        
        eq_kvectors(symbol+1, :) = lte_symbol_eq_singlelayermimo(inputkvectors(symbol+1, :), ...
            antenna0, antenna1,NDLRB, ncellid, symbol, ns, ncp, codebook{codebook_idx+1});
        
    end

end
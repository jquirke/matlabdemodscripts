function eq_kv = lte_symbol_eq_singlelayermimo( kvector, kvest0, kvest1, NDLRB, ncellid, l, ns, ncp, codebook )
%Very simple equalisation 2x2 only
%   Detailed explanation goes here


    eq_kv = kvector ./ (codebook(1) * kvest0 + codebook(2) * kvest1);

end





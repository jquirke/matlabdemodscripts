function kvector = lte_pbch_insert_notxd( kvector, pbch_syms, ncellid, ncp )

    data_idxs = [660-35:661+35];

    vshift = mod(ncellid, 3); 
    
    reference_signal_idxs = [660-35+vshift:3:661+35];

    data_idxs_refsymbol = setdiff(data_idxs, reference_signal_idxs);

    offset = 0;
    for symbol = 0:3,      
        
        if (symbol <= 1 || (ncp == 0 && symbol == 3))
            kvector(symbol+1,data_idxs_refsymbol) = pbch_syms(offset+1:offset+length(data_idxs_refsymbol));
            offset = offset + length(data_idxs_refsymbol);
        else
            kvector(symbol+1,data_idxs) = pbch_syms(offset+1:offset+length(data_idxs));
            offset = offset + length(data_idxs);            
        end        
    end
end
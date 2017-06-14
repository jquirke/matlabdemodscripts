function pbch_symbols = lte_pbch_extract( equalized_kvectors, ncellid, ncp )

    data_idxs = [660-35:660+36];

    vshift = mod(ncellid, 3); 
    
    reference_signal_idxs = [660-35+vshift:3:660+36];

    data_idxs_refsymbol = setdiff(data_idxs, reference_signal_idxs);
    
    pbch_symbols = [];
    
    for symbol = 0:3,
        
        %ref containing symbol
        if (symbol <= 1 || (ncp == 0 && symbol == 3))
            pbch_symbols = [pbch_symbols equalized_kvectors(symbol+1, data_idxs_refsymbol)];
        else
            pbch_symbols = [pbch_symbols equalized_kvectors(symbol+1, data_idxs)];            
        end
        
    end

end
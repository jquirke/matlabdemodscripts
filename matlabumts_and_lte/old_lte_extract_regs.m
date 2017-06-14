function reg_symbols = lte_extract_regs(kvector,NDLRB, cell_list_regs, ncellid, ncp, num_tx_antennas  )
%given a k value with respect to NDLRB, extract the REGs specified, cutting
%out reference symbols if they exist

    reg_symbols = [];

    for symbol=0:length(cell_list_regs)-1,
        regs = cell_list_regs{symbol+1};
            symbol_indices = zeros(1,length(regs) * 4); % 4 symbols/reg
        if (lte_symbol_is_reference(symbol, ncp, num_tx_antennas))
            ref_koffset = mod(ncellid, 3); %the offset of the ref signals
            data_indices = [1 2 4 5; 0 2 3 5; 0 1 3 4];
            symbol_indices(1:4:end) = regs+data_indices(ref_koffset+1,1);
            symbol_indices(2:4:end) = regs+data_indices(ref_koffset+1,2);
            symbol_indices(3:4:end) = regs+data_indices(ref_koffset+1,3);
            symbol_indices(4:4:end) = regs+data_indices(ref_koffset+1,4);                        
        else
            % no reference
            symbol_indices(1:4:end) = regs;
            symbol_indices(2:4:end) = regs+1;
            symbol_indices(3:4:end) = regs+2;
            symbol_indices(4:4:end) = regs+3;
        end
        
        %rebase symbol indices to the full kvector
        symbol_indices = symbol_indices + (110-NDLRB)/2 * 12;
        reg_symbols = [reg_symbols kvector(symbol+1, symbol_indices+1)];
        %reg_symbols = symbol_indices;
    end
     
end


function kvector = lte_insert_regs(kvector,reg_symbols,NDLRB, regs, ncellid, ncp, num_tx_antennas  )
%given a k value with respect to NDLRB, extract the REGs specified, cutting
%out reference symbols if they exist

% the convention is reg value is ofdm_symbol*NDLRB*12 + reg, i.e. absolut
    KMAX = NDLRB * 12;
    
    reg_actuals = mod(regs,KMAX);
    reg_symno = floor(regs/KMAX);
    for ireg=0:length(regs)-1,
        if (lte_symbol_is_reference(reg_symno(ireg+1), ncp, num_tx_antennas)) 
            ref_koffset = mod(ncellid, 3); %the offset of the ref signals
            data_indices = [1 2 4 5; 0 2 3 5; 0 1 3 4];
            symbol_indices = reg_actuals(ireg+1)+data_indices(ref_koffset+1,:); 
        else
            symbol_indices = reg_actuals(ireg+1) + [0:3];
        end
        symbol_indices = symbol_indices + (110-NDLRB)/2 * 12;
        kvector(reg_symno(ireg+1)+1, symbol_indices+1) = reg_symbols(1+ireg*4:4+ireg*4);
        
        %reg_symbols = [reg_symbols kvector(reg_symno(ireg+1)+1, symbol_indices+1)];
    end
end


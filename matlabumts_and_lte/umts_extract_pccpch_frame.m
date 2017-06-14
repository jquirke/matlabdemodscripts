function pccpch_symbols_out = umts_extract_pccpch_frame( pccpch_symbols )
%remove the first of the 10-symbols in each slot, which is SCH, not P-CCPCH
%   Each slot = 2560 chips of 10 SF-256 symbols. But the first 256 chips
%   are the PSC (SCH) and do make up the P-CCPCH. remove them

% there are a total of 15 slots/frame = 15*(10-1) symbols = 135 complex symbols

    pccpch_symbols_out = zeros(1,135);
	for i=1:15
        pccpch_symbols_out(1+(i-1)*9:9+(i-1)*9) = pccpch_symbols(2+(i-1)*10:10+(i-1)*10);
    end


end


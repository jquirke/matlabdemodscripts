function lte_cell_id = lte_validate_refslot( slotdata, l, ns, ncp, max_antennas)
%given an OFDM symbol with ref signals, guess the cell ID using a
%differential correlation
%   Detailed explanation goes here

    fftsize = length(slotdata);
    cellid_corr = zeros(1,504);
    slot_kv = lte_fft_to_kvector(fftsize, fft(slotdata));
    
    for cellid=0:503,
        for antenna=0:(max_antennas-1)
            test_kv = lte_refsig_to_kvector(cellid, l, ns, ncp, antenna);
            koffset = lte_ref_koffset(cellid,l,ns,antenna);
            test_kv_diff = test_kv(1+koffset+6:6:end) .* conj(test_kv(1+koffset:6:end-6));
            slot_kv_diff = slot_kv(1+koffset+6:6:end) .* conj(slot_kv(1+koffset:6:end-6));

            cellid_corr(cellid+1) =cellid_corr(cellid+1) + sum(slot_kv_diff .* conj(test_kv_diff));
        end
    end
    
    lte_cell_id = cellid_corr;
    
end


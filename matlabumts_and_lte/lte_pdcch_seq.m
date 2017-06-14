function pcfich_seq = lte_pdcch_seq(ncellid,ns, Nreg)

    cinit = floor(ns/2) * 2^9 + ncellid;
    
    pcfich_seq = lte_pnseq(cinit,8*Nreg);
     
end


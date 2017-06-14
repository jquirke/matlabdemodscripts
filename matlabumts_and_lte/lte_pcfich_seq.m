function pcfich_seq = lte_pcfich_seq(ncellid,ns)

    cinit = (floor(ns/2)+1) * (2*ncellid+1) * 2^9 + ncellid;
    
    pcfich_seq = lte_pnseq(cinit,32);
     
end


function pdsch_seq = lte_pdsch_seq(nrnti, codeword, ncellid,ns, length)

    cinit = nrnti*2^14 + codeword*2^13 + floor(ns/2)*2^9 + ncellid;
    
    pdsch_seq = lte_pnseq(cinit,length);
     
end


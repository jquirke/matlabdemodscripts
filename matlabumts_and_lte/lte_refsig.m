function ref_sig = lte_refsig( ncellid, l, ns, ncp)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    NMAXRB = 110;
    
    %produce the PN seq
    cinit = 2^10 * (7 * (ns + 1) + l + 1) * (2*ncellid + 1) + 2 * ncellid + ncp;
   
    
    pnseq = lte_pnseq(cinit, NMAXRB*2*2);
    
    ref_sig = 1/sqrt(2) * (1-2*pnseq(1:2:end)) + j/sqrt(2) * (1-2*pnseq(2:2:end));
    
    
    
end


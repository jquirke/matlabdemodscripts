function pbch_seq = lte_pbch_seq( ncellid, ncp)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
   
    if (ncp == 1)
        length = 1920;
    else
        length = 1728;
    end 
    pbch_seq= lte_pnseq(ncellid, length);
    
end


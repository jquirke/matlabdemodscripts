function kvector = lte_refsig_to_kvector(ncellid, l, ns, ncp, antenna )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    kvector = zeros(1,110*12);
    
    ref_sig = lte_refsig(ncellid, l, ns,ncp);
    
    if (antenna == 0 && l == 0)
        v = 0;
    elseif (antenna == 0 && l ~= 0)
        v = 3;
    elseif (antenna == 1 && l  == 0)
        v = 3;
    elseif (antenna == 1 && l ~= 0)
        v = 0;
    elseif (antenna == 2)
        v = 3 * mod(ns,2);
    elseif (antenna == 3)
        v = 3 + 3 * mod(ns,2);
    end
    
    vshift = mod(ncellid,6);
    
    koffset = mod(v+vshift,6);
    
    kvector(1+koffset:6:end) = ref_sig;
    
end


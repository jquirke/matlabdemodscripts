function kvector_out = lte_refsig_to_kvector_insert(kvector, refscale, NDLRB, ncellid, l, ns, ncp, antenna )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    %kvector = zeros(1,110*12);
    
    NMAXRB = 110;
    NRES_PER_RB = 12;
    
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
    
    startRE = NRES_PER_RB* ((NMAXRB-NDLRB)/2);
    endRE = NRES_PER_RB* (NMAXRB - ((NMAXRB-NDLRB)/2));
    startRE+1+koffset:6:endRE;

    
    kvector(l+1,startRE+1+koffset:6:endRE) = refscale * ref_sig((NMAXRB-NDLRB)/2*2+1:(NMAXRB-NDLRB)/2*2+NDLRB*2);
    kvector_out = kvector;
end


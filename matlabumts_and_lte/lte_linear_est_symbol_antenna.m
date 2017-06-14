function estimate_kv = lte_linear_est_symbol_antenna( NDLRB, kvector, ncellid, l, ns, ncp,  antenna )
%Very simple linear estimation
%   Detailed explanation goes here


    estimate_kv = zeros(1,110*12);
    koffset = lte_ref_koffset(ncellid, l, ns, antenna);
    
    ref_kv = lte_refsig_to_kvector(ncellid,l,ns,ncp,antenna);

    kvector = kvector .* conj(ref_kv);
    
    for i=0:koffset-1
        estimate_kv(i+1) = kvector(koffset+1);
    end
    
    %only use what we have, otherwise we stuff up the edges
    clip = (110-NDLRB)*12/2;
    
    for i=clip+koffset:6:110*12-6-6+koffset-clip
        lower = kvector(i+1);
        upper = kvector(i+6+1);
        estimate_kv(i+0+1) = lower;
        estimate_kv(i+1+1) = lower + 1/6 * (upper-lower);
        estimate_kv(i+2+1) = lower + 2/6 * (upper-lower);
        estimate_kv(i+3+1) = lower + 3/6 * (upper-lower);
        estimate_kv(i+4+1) = lower + 4/6 * (upper-lower);
        estimate_kv(i+5+1) = lower + 5/6 * (upper-lower);
        estimate_kv(i+6+1) = upper;
    end
    
    for i=110*12-clip-6+koffset:110*12-clip-1
        estimate_kv(i+1) = kvector(110*12-6+koffset-clip+1);
    end
    for i=0+clip:koffset+clip-1
        estimate_kv(i+1) = kvector(koffset+clip+1);
    end
    
    
end


function koffset = lte_ref_koffset( ncellid, l, ns, antenna )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

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


end


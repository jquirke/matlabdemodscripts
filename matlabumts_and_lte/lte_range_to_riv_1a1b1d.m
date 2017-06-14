function RIV = lte_range_to_riv_1a1b1d( NDLRB, RBstart, Lcrbs)
%see 36.213 7.1.6.3

    if (RBstart + Lcrbs > NDLRB) 
        RIV = -1;
    elseif ((Lcrbs - 1) <= floor(NDLRB/2))
        RIV = NDLRB * (Lcrbs - 1) + RBstart;
    else
        RIV = NDLRB * (NDLRB - Lcrbs + 1) + (NDLRB - 1 - RBstart);
    end
    
end


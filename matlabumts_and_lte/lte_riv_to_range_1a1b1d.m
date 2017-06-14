function [RBstart Lcrbs ] = lte_riv_to_range_1a1b1d( NDLRB, RIV)
%see 36.213 7.1.6.3

    divriv = floor(RIV/NDLRB);
    modriv = mod(RIV, NDLRB);
    
    if (RIV == -1)
        RBstart = -1;
        Lcrbs = -1;
    elseif (divriv + 1 + modriv <= NDLRB)
        Lcrbs = divriv + 1;
        RBstart = modriv;
    else
        Lcrbs = -(divriv - NDLRB - 1);
        RBstart = -(modriv - NDLRB + 1);
    end
        
end


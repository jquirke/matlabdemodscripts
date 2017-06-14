function contains_ref = lte_symbol_is_reference( symbol, ncp, num_tx_antennas )
%UNTITLED Is the the specified OFDM symbol containing a reference signal?
%   Detailed explanation goes here

    if (symbol == 0)
        contains_ref = true;
    elseif (symbol == 1 && num_tx_antennas > 2)
        contains_ref = true;
    elseif (ncp == 1 && symbol == 4)
        contains_ref = true;
    elseif (ncp == 0 && symbol == 3)
        contains_ref = true;
    else
        contains_ref = false;
    end

end


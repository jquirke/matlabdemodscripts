function code = umts_spread_code( sf, idx )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    code = [1];
    sfdiv=sf;
    
    for i = 1:log2(sf)
        if (idx >= sfdiv/2)
            code = [code -code];
            idx = idx - sfdiv/2;
        else
            code = [code code];
        end
        
        sfdiv = sfdiv/2;
    end
            


end


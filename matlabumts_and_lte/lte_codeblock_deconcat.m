function codeblocks_cell = lte_codeblock_deconcat(softbits, nlayers_transportblock, Qm, tbsize)

    %follow the nomenclature in TS 36.212 5.1.2
    
        
%compute the number of codewords, C
    Z=6144;
    B = tbsize + 24;

    
    if (B<=Z)
        L=0;
        C=1;
    else
        L=24;
        C=ceil(B/(Z-L));

    end

    codeblocks_cell = cell(1,C);
    

    
    G = length(softbits);
    Gprime = G/(Qm * nlayers_transportblock);
    gamma = mod(Gprime, C);
    
    start = 1;
    for r=0:C-1
        if (r<(C-gamma))
            E = nlayers_transportblock * Qm * floor(Gprime/C);
        else
            E = nlayers_transportblock * Qm * ceil(Gprime/C);
        end
        codeblocks_cell{r+1} = softbits(start:start+E-1);
        start = start + E;
    end

end


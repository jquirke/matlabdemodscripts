function avail_symbols = lte_calc_prbs_avail_symbols(NDLRB, prblist, ncellid, ns, ncp, numtxantennas, control_symbols)

    if (ncp), maxsymbols = 14; slotsymbols=7; else maxsymbols = 12; slotsymbols = 6; end;


    %produce a list of all the REs in the non control region
    REs = [];
    for symbol = control_symbols:maxsymbols-1,
        for prb=0:length(prblist)-1,
            REs = [REs (symbol*NDLRB*12+12*prblist(prb+1) + [0:11])];
        end
    end
    
    exclREs = [];
    %exclusions
    if (ns == 0 || ns == 10) %SSS,PSS
        exclREs = [exclREs (slotsymbols-2) * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
        exclREs = [exclREs (slotsymbols-1) * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
    end
    if (ns == 0) %PBCH
        exclREs = [exclREs (slotsymbols)   * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
        exclREs = [exclREs (slotsymbols+1) * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
        exclREs = [exclREs (slotsymbols+2) * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
        exclREs = [exclREs (slotsymbols+3) * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
    end
    
    vshift = mod(ncellid, 6);
    vshift2 = mod(ncellid, 3);
    for symbol = control_symbols:maxsymbols-1,
 
        if (lte_symbol_is_reference(mod(symbol, slotsymbols), ncp, numtxantennas))           
            if (numtxantennas == 1)
                %offset antennas in the alternate symbols

                v = (mod(symbol, slotsymbols)>0) * 3;
                vmod = mod(v + vshift,6);
                exclREs = [exclREs (symbol*NDLRB*12 + (vmod:6:(NDLRB*12-1)))];
            else %must always be 2 antenna ref signals in a ref sig slot
                exclREs = [exclREs (symbol*NDLRB*12 + (vshift2:3:(NDLRB*12-1)))];
            end
    end     
        
    REs = setdiff_ns(REs, exclREs);
    
    avail_symbols = length(REs);
end


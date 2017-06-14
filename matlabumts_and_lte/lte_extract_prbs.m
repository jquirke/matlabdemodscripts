function prb_symbols = lte_extract_prbs(slot0,slot1, NDLRB, prblist, ncellid, ns, ncp, tdd, numtxantennas, control_symbols, Qm, PB)

    if (ncp), maxsymbols = 14; slotsymbols=7; else maxsymbols = 12; slotsymbols = 6; end;

    %combine into linear subframe
    subframe = [slot0; slot1];
    
    %power equalization
    
    if (Qm > 2) % for greater than QPSK perform power equalization
        PB_PA = [1 4/5 3/5 2/5 ; 5/4 1 3/4 1/2];
        pb_pa = PB_PA((numtxantennas>1)+1, PB+1);
        
        for symbol = control_symbols:maxsymbols-1
            if (lte_symbol_is_reference(mod(symbol, slotsymbols), ncp, numtxantennas))
                %boost the (usually) weaker reference signals (PB) to non
                %reference signal power (PA) to assist the QAM demodulator, as
                %its decisions are based on PA
                subframe(symbol+1,:) = subframe(symbol+1,:) * 1/pb_pa;
            end
        end
    end
    

    subframe = subframe(:,1320/2-NDLRB*12/2+1:1320/2+NDLRB*12/2);
    subframe = reshape(subframe.', 1, maxsymbols*NDLRB*12);
    
    %produce a list of all the REs in the non control region
    REs = [];
    for symbol = control_symbols:maxsymbols-1,
        for prb=0:length(prblist)-1,
            REs = [REs (symbol*NDLRB*12+12*prblist(prb+1) + [0:11])];
        end
    end
    
    exclREs = [];
    %exclusions
    if (tdd ==0 && (ns == 0 || ns == 10)) %SSS,PSS
        exclREs = [exclREs (slotsymbols-2) * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
        exclREs = [exclREs (slotsymbols-1) * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
    end
    if (tdd ==1)
        if (ns == 0 || ns == 10) %SSS - really on slot 1/11
            
            exclREs = [exclREs (slotsymbols + slotsymbols-1) * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
        end
        if (ns == 2 || ns == 12) %PSS
            exclREs = [exclREs (3) * NDLRB*12 + ((NDLRB/2-3) * 12 + [0:71])  ];
        end
        
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
    end     
        
    REs = setdiff_ns(REs, exclREs);
    
    prb_symbols = (subframe(REs+1));
end


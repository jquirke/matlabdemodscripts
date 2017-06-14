
function dci = lte_create_dci1a_ccch( NDLRB, start, numRBs, rnti, mcs, harq, rv, n1aprb, tpc )

    SI_RNTI = 65535;
    P_RNTI = 65534;

    dci = [1]; % DCI1A format
 
    dci = [dci 0]; %localized only support
    
    Nresourcebits = ceil(log2(NDLRB*(NDLRB+1)/2));
    
    if ( (numRBs - 1) <= floor(NDLRB/2))
        RIV = NDLRB * (numRBs - 1) + start;
    else
        RIV = NDLRB * (NDLRB - numRBs + 1) + (NDLRB - 1 - start);
    end
    
    dci = [dci lte_dec_to_binstring(RIV, Nresourcebits)]; %resource
    dci = [dci lte_dec_to_binstring(mcs, 5)];
    dci = [dci lte_dec_to_binstring(harq, 3)];
    dci = [dci 0]; %ngap alloc bit for RA/P/SI-RNTI - not used for localised
    dci = [dci lte_dec_to_binstring(rv, 2)];
    
    if (rnti == SI_RNTI || rnti == P_RNTI) 
        dci = [dci lte_dec_to_binstring(n1aprb, 1) 0]; %1 bit for column, reserved
    else
        dci = [dci lte_dec_to_binstring(tpc, 2)]; %TPC cmd
    end
    
    ambig_size_table = [12, 14, 16 ,20, 24, 26, 32, 40, 44, 56];
    
    if (find (length(dci) == ambig_size_table) > 0)
        dci = [dci 0]; % 0 pad to avoid ambiguity
    end
    
    %attach CRC
    crcpoly16 =  [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
    crc = lte_crc(dci, crcpoly16);
    crc = mod(crc+lte_dec_to_binstring(rnti, 16),2); %mask with CRC
    
    dci = [dci crc];
    
end
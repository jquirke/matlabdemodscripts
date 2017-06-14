function [NewRNTIS] = lte_process_radio_frame(framesamples, fftsize, ncellid, ncp, tdd, tddconfig, Extra_RNTIS, path)
%the timing, cellid and ncp have been detected by low level sync at this
%point

    SLOTLEN = 30.72e6/2000 * fftsize/2048;
    if (ncp) PBCH_RATEMATCHED_LEN = 1920 ; else PBCH_RATEMATCHED_LEN = 1728; end;
    PBCH_CODED_LEN = 40;
    PBCH_TB_SIZE = 24;
    crcpoly16 =  [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
    crcpoly24A = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1];
    antenna_config_PBCH_CRC_mask = [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]; ...
                                    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]; ...
                                    [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]];
    antenna_config_to_num_antennas = [1 2 4];
    
    PBCH_NDLRBS_tab = [6, 15, 25, 50, 75, 100];
    PBCH_PHICH_DURATION_tab = [0 1];
    PBCH_PHICH_RESOURCE_tab = [1/6 1/2 1 2];
    
    LTE_CFI = [[0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1]; ...
               [1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0]; ...
               [1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1,0,1,1]];
    
    SI_RNTI = 65535;
    P_RNTI = 65534;
    RA_RNTI = [1:10]; %FDD only is 1-10, in theory should adjust based on SI data and TDD
    NewRNTIS = []; %gets updated by MAC as we spot RA responses
    
    %detecT BCCH slot
    pbchslotsamples = framesamples(SLOTLEN+1:2*SLOTLEN); %slot1
    pbch_kvs = lte_slot_to_kvectors(fftsize,pbchslotsamples,ncp);
    
    pbch_found = 0;
    for antenna_config = [ 1 2 ], %just 2 for now
        %have to use NDLRB estimate of 100 here
        pbch_est = lte_linear_est_slot(100,pbch_kvs,ncellid,1,ncp,antenna_config_to_num_antennas(antenna_config));
        pbch_eq = lte_slot_equalise(pbch_kvs, pbch_est,6, ncellid,1,ncp);
        pbch_syms = lte_pbch_extract(pbch_eq,ncellid,ncp);
        figure(3)
        plot(pbch_syms, '+')
        %axis([-1 1 -1 1]);
        pbch_softbits_sc = lte_demod_soft_qpsk(pbch_syms); % soft decision 
        % try each scrambling code permutation

        PBCH_SEQ = lte_pbch_seq(ncellid, ncp);

        for ms40frame = 0:3,
           pbch_offset = ms40frame * PBCH_RATEMATCHED_LEN/4; 
           pbch_softbuffer = zeros(1,PBCH_RATEMATCHED_LEN);
           
           pbch_softbuffer(pbch_offset+1:pbch_offset+PBCH_RATEMATCHED_LEN/4) = pbch_softbits_sc;
           pbch_softbuffer = pbch_softbuffer .* (1-2*PBCH_SEQ);
           pbch_aggregated_softbits = lte_conv_deratematch(pbch_softbuffer, PBCH_CODED_LEN) ;
           pbch_aggregated_bits = pbch_aggregated_softbits < 0 ;%hard decision here now
           pbch_MAC = lte_tailbite_dec(lte_conv_deint(pbch_aggregated_bits(0*PBCH_CODED_LEN+1:1*PBCH_CODED_LEN)), ...
                                       lte_conv_deint(pbch_aggregated_bits(1*PBCH_CODED_LEN+1:2*PBCH_CODED_LEN)), ...
                                       lte_conv_deint(pbch_aggregated_bits(2*PBCH_CODED_LEN+1:3*PBCH_CODED_LEN)));
                                   
          pbch_CRC = pbch_MAC(PBCH_TB_SIZE+1:end);
          pbch_computed_CRC = lte_crc(pbch_MAC(1:PBCH_TB_SIZE), crcpoly16);
          pbch_computed_CRC = mod(pbch_computed_CRC +antenna_config_PBCH_CRC_mask(antenna_config,:), 2);
          if (sum(abs(pbch_CRC - pbch_computed_CRC)) == 0)
            pbch_found = 1; 
            fprintf (1, 'Found PBCH at ms40frame = %d\n', ms40frame);   
          end
          if (pbch_found) break; end;
        end

     
    if (pbch_found) break ; end; % use this antenna config
    
    end
    
    if (~pbch_found) return; end; %no PBCH ever found
    
    fprintf(1, 'Using antennas: %d\n', antenna_config);
   
    pbch_bandwidth_idx = pbch_MAC(1:3);
    pbch_phich_config_duration_idx = pbch_MAC(4);
    pbch_phich_config_resource_idx = pbch_MAC(5:6);
    pbch_frameno = pbch_MAC(7:14);
    
    NDLRB = PBCH_NDLRBS_tab(dab_binval(pbch_bandwidth_idx)+1);
    phich_duration = PBCH_PHICH_DURATION_tab(dab_binval(pbch_phich_config_duration_idx)+1);
    phich_resource = PBCH_PHICH_RESOURCE_tab(dab_binval(pbch_phich_config_resource_idx)+1);
    frame_no = dab_binval(pbch_frameno) * 4 + ms40frame;
    fprintf(1, 'NDLRB = %d, phich_duration = %d, phich_resource = %.4f frame_no = %d\n', NDLRB,phich_duration,phich_resource,frame_no);
  
    %return;
    %compute some other parameters based on NDLRB
    PCFICH_KINDICES = lte_pcfich_kindices(NDLRB,ncellid);
    
    DCI_FORMAT_1A_LEN = 1+1+ceil(log2(NDLRB*(NDLRB+1)/2)) + 5 + 3 + 1 +2 + 2;
    if (tdd)
        DCI_FORMAT_1A_LEN = DCI_FORMAT_1A_LEN + 2 ...%DAI
            + 1;  %extra bit for HARQ process
    end
    
    DCI_FORMAT_FORBIDDEN_SIZES = [12, 14, 16 ,20, 24, 26, 32, 40, 44, 56]; 
    
    %forbidden sizes
    while(find (DCI_FORMAT_FORBIDDEN_SIZES == DCI_FORMAT_1A_LEN))
        DCI_FORMAT_1A_LEN = DCI_FORMAT_1A_LEN + 1;
    end
    
    %DCI 1C size
    if (NDLRB<50)
        NstepRB = 2;
    else
        NstepRB = 4;
    end
    
    NGAP_BW = [6, 11, 12, 20, 27, 45, 50, 64, 80];
    NGAP_1_VAL = [NDLRB/2, 4, 8, 12, 18, 27, 27, 32, 48];
    NGAP_2_VAL = [0 0 0 0 0 0 9 16 16];
    
    Ngap1 = NGAP_1_VAL(max(find (NDLRB >= NGAP_BW)));
    
    NDLVRB_gap1 = 2*min(Ngap1, NDLRB - Ngap1);
    
    %DCI 1C size
    if (NDLRB<50)
        NstepRB = 2;
        DCI_FORMAT_1C_LEN = 0 + ceil(log2(floor(NDLVRB_gap1/NstepRB)*(floor(NDLVRB_gap1/NstepRB)+1)/2)) + 5;
    else
        NstepRB = 4;
        DCI_FORMAT_1C_LEN = 1 + ceil(log2(floor(NDLVRB_gap1/NstepRB)*(floor(NDLVRB_gap1/NstepRB)+1)/2)) + 5;
    end
    
    %DCI format 1 size
    
    P_VAL = [1 2 3 4];
    P_RANGE = [0 11 27 64];
    
    P = P_VAL(max(find (NDLRB >= P_RANGE)));
    
    DCI_FORMAT_1_LEN = 0 + ceil(NDLRB/P) + 5 + 3 + 1 + 2 + 2 + 0; %
    
    if (NDLRB>10)
        DCI_FORMAT_1_LEN = DCI_FORMAT_1_LEN + 1; %extra bit for resource alloc header
    end
    
    if (tdd)
        DCI_FORMAT_1_LEN = DCI_FORMAT_1_LEN + 1 + 2; %extra bit for HARQ process number and 2 bits for DAI
    end
    
    if (DCI_FORMAT_1_LEN == DCI_FORMAT_1A_LEN)
        DCI_FORMAT_1_LEN = DCI_FORMAT_1_LEN + 1;
    end
    
    %forbidden sizes
    while(find (DCI_FORMAT_FORBIDDEN_SIZES == DCI_FORMAT_1_LEN))
        DCI_FORMAT_1_LEN = DCI_FORMAT_1_LEN + 1;
    end
    
    %DCI format 2A size
    
    
    for subframe=0:9,
        subframeoffset = subframe*(2*SLOTLEN);
        slot0 = framesamples(subframeoffset+1:subframeoffset+SLOTLEN);
        slot1 = framesamples(subframeoffset+SLOTLEN+1:subframeoffset+2*SLOTLEN);
        
        slot0_kvs = lte_slot_to_kvectors(fftsize,slot0, ncp);
        slot1_kvs = lte_slot_to_kvectors(fftsize,slot1, ncp);
        
        slot0_est = lte_linear_est_slot(NDLRB, slot0_kvs,ncellid,subframe*2+0, ncp, antenna_config_to_num_antennas(antenna_config));
        slot1_est = lte_linear_est_slot(NDLRB, slot1_kvs,ncellid,subframe*2+1, ncp, antenna_config_to_num_antennas(antenna_config));  
        
        if (antenna_config_to_num_antennas(antenna_config) == 1)
            slot0_eq = lte_slot_equalise_notxd(slot0_kvs,slot0_est,NDLRB,ncellid,subframe*2+0,ncp);
            slot1_eq = lte_slot_equalise_notxd(slot1_kvs,slot1_est,NDLRB,ncellid,subframe*2+1,ncp);              
        else
            slot0_eq = lte_slot_equalise(slot0_kvs,slot0_est,NDLRB,ncellid,subframe*2+0,ncp);
            slot1_eq = lte_slot_equalise(slot1_kvs,slot1_est,NDLRB,ncellid,subframe*2+1,ncp);   
                    
        end

        %get the PCFICH
       	pcfich_syms = lte_extract_regs(slot0_eq,NDLRB,PCFICH_KINDICES,ncellid,ncp,antenna_config_to_num_antennas(antenna_config));
        pcfich_bits_sc = lte_demod_soft_qpsk(pcfich_syms)<0; %hard decode
        pcfich_bits = mod(pcfich_bits_sc+lte_pcfich_seq(ncellid, subframe*2), 2); 
        cfi_score = zeros(1,3);
        for cfi = 1:3,
            cfi_score(cfi) = sum(abs(pcfich_bits - LTE_CFI(cfi,:)));
        end
        [cfidelta mincfi] = min(cfi_score);
        
        if (frame_no == 0 && subframe == 5)
            pcfich_syms;
        end
        
        if (cfidelta > 8)
            fprintf(1, '%d.%d No PDCCH symbols or bad subframe decode cfidelta=%d\n', frame_no, subframe,cfidelta);
            continue;
        end
        %ignore MBSFN, TD stuff - actually these rules are generic for
        %TD and MBSFN too
        if (NDLRB <= 10)
            pdcch_nsymbols = mincfi+1;
        else
            pdcch_nsymbols = mincfi;
        end

        
        fprintf(1, '%d:%d PDCCH symbols: %d (cfidelta=%d)\n', frame_no, subframe,pdcch_nsymbols,cfidelta);
        
        phich_kindices = lte_phich_indices(NDLRB, ncellid, PCFICH_KINDICES, ncp, tdd, tddconfig, subframe, antenna_config_to_num_antennas(antenna_config),... 
            phich_resource, phich_duration, pdcch_nsymbols);

        pdcch_kindices = lte_pdcch_kindices(NDLRB, ncellid, PCFICH_KINDICES, phich_kindices,ncp, ...
                antenna_config_to_num_antennas(antenna_config),phich_duration, pdcch_nsymbols);
        N_PDCCH_REGS = length(pdcch_kindices);
        
        pdcch_symbols = lte_extract_regs(slot0_eq, NDLRB, pdcch_kindices,ncellid,ncp, ...
                antenna_config_to_num_antennas(antenna_config));
            
%        figure(8)
%        plot(pdcch_symbols, '+')
        
        pdcch_symbols_deint = lte_pdcch_deint(pdcch_symbols, ncellid);
        pdcch_symbols_deint_softbits_sc = lte_demod_soft_qpsk(pdcch_symbols_deint); % soft decision 
        pdcch_symbols_deint_softbits = pdcch_symbols_deint_softbits_sc .* (1-2*lte_pdcch_seq(ncellid, subframe*2, N_PDCCH_REGS));
  
        N_PDCCH_CCE = floor(N_PDCCH_REGS/9);
        
        Yk = 0; %Common only
        
        PDCCH_COMMON_L = [4 8];
        PDCCH_COMMON_ML = [4 2];
        
        CCE_START = zeros(1,sum(PDCCH_COMMON_ML))-1;
        CCE_L = zeros(1,sum(PDCCH_COMMON_ML))-1;
        i=1;
        PDCCH_AGGR_LEVEL_MAX = min(floor(N_PDCCH_CCE/4),2); %cover the case where not enough RBs for 8CCE
        for PDCCH_AGGR_LEVEL_idx = 1:PDCCH_AGGR_LEVEL_MAX, %for each aggregation level
            L = PDCCH_COMMON_L(PDCCH_AGGR_LEVEL_idx);
            ML = PDCCH_COMMON_ML(PDCCH_AGGR_LEVEL_idx);
            CCELIST=zeros(1, ML) - 1;
            for m = 0:ML-1, %for each candidate 
                % note can end up with some duplicates where N_PDCCH_CCE =
                % multiple of 4,8 etc
                CCE = L * (mod(Yk+m, floor(N_PDCCH_CCE/L)));
                if ((find (CCELIST == CCE)))
                   continue;
                end
                CCELIST(m+1) = CCE;
                CCE_START(i) = CCE;
                CCE_L(i) = L;
                i = i+1;
            end
        end
        CCE_START = CCE_START(find(CCE_START >= 0));
        CCE_L = CCE_L(find(CCE_L >= 0));
        
        PDCCH_SIZES = [DCI_FORMAT_1A_LEN];%[DCI_FORMAT_1A_LEN];

        
        %now process the CCE
        for cce = 1:length(CCE_START),
            cce_start = CCE_START(cce);
            cce_L = CCE_L(cce);
            cce_softbits = pdcch_symbols_deint_softbits(cce_start*9*8+1:(cce_start+cce_L)*9*8);
            %test it against each size
            for pdcch_size_idx=1:length(PDCCH_SIZES),
                pdcch_tb_size = PDCCH_SIZES(pdcch_size_idx); %CRC
                pdcch_coded_size = pdcch_tb_size  + 16;
                pdcch_aggregated_softbits = lte_conv_deratematch(cce_softbits,pdcch_coded_size);
                pdcch_aggregated_bits = pdcch_aggregated_softbits <0;

                pdcch_aggregated_bits = pdcch_aggregated_softbits<0;
                pdcch_MAC = lte_tailbite_dec(lte_conv_deint(pdcch_aggregated_bits(0*pdcch_coded_size+1:1*pdcch_coded_size)), ...
                                           lte_conv_deint(pdcch_aggregated_bits(1*pdcch_coded_size+1:2*pdcch_coded_size)), ...
                                           lte_conv_deint(pdcch_aggregated_bits(2*pdcch_coded_size+1:3*pdcch_coded_size)));
                pdcch_CRC = pdcch_MAC(end-15:end);

                
                for rnti = [Extra_RNTIS RA_RNTI SI_RNTI P_RNTI],
                    
                    pdcch_calculated_CRC = mod(lte_crc(pdcch_MAC(1:pdcch_tb_size), crcpoly16) + lte_dec_to_binstring(rnti, 16), 2);
                    pdcch_CRC - pdcch_calculated_CRC;
                    if (sum(abs(pdcch_CRC-pdcch_calculated_CRC)) == 0)
                        fprintf (1, '%d:%d found PDCCH at CCE %d (L=%d) RNTI=%d\n', frame_no, subframe, cce_start, cce_L, rnti);

                        nextfield = 1;
                        % if DCI-1A - assume for now
                        dci1A_diff = pdcch_MAC(nextfield:nextfield);
                        if (dci1A_diff == 0)
                            dci0_hopping = dab_binval(pdcch_MAC(nextfield:nextfield));
                            nextfield = nextfield + 1;
                            
                            %assumg NULRB = NDLRB for now
                            if (NDLRB < 50)
                                NULhop = 1;
                            else
                                NULhop = 2;
                            end
                            
                            if (dci0_hopping > 0)
                              dci0hopidx = ab_binval(pdcch_MAC(nextfield:nextfield+NULhop-1));
                              nextfield = nextfield + NULhop;
                              dci0_resource = dab_binval(pdcch_MAC(nextfield:nextfield+ceil(log2(NDLRB*(NDLRB+1)/2))-NULhop-1));
                              nextfield = nextfield + ceil(log2(NDLRB*(NDLRB+1)/2)) - NULhop;
                            else
                              dci0hopidx = -1;
                              dci0_resource = dab_binval(pdcch_MAC(nextfield:nextfield+ceil(log2(NDLRB*(NDLRB+1)/2))-1));
                              nextfield = nextfield + ceil(log2(NDLRB*(NDLRB+1)/2));
                            end
                            

                            
                            dci0_MCS = dab_binval(pdcch_MAC(nextfield:nextfield+5-1));
                            nextfield = nextfield + 5;
                                                        
                            dci0_NDI = dab_binval(pdcch_MAC(nextfield:nextfield));
                            nextfield = nextfield + 1; 
                         
                            dci0_TPC = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                            
                            dci0CyclicShift = dab_binval(pdcch_MAC(nextfield:nextfield+3-1));
                            nextfield = nextfield + 3;

                            dci0CQIRequest = dab_binval(pdcch_MAC(nextfield:nextfield+1-1));
                            nextfield = nextfield + 1;
                            
                            fprintf(1, 'Uplink Grant:: hopping=%d hopidx=%d resource=%d, MCS=%d, NDI=%d, TPC=%d, CyclicShift=%d, CQI request=%d\n', ...
                                dci0_hopping,dci0hopidx,dci0_resource,dci0_MCS,dci0_NDI,dci0_TPC,dci0CyclicShift,dci0CQIRequest);
                        
                        else
                            nextfield = nextfield + 1;
                            dci1A_distlocal = pdcch_MAC(nextfield:nextfield);
                            if (dci1A_distlocal)

                                fprinf(1, 'DCI Format 1A (distributed VRB), skipping\n'); 
                                continue;
                            end
                            nextfield = nextfield + 1;
                            dci1A_resource = dab_binval(pdcch_MAC(nextfield:nextfield+ceil(log2(NDLRB*(NDLRB+1)/2))-1));
                            nextfield = nextfield + ceil(log2(NDLRB*(NDLRB+1)/2));
                            dci1A_MCS = dab_binval(pdcch_MAC(nextfield:nextfield+5-1));
                            nextfield = nextfield + 5;
                            nHARQbits = 3 + (tdd>0) * 1;

                            dci1A_HARQ = dab_binval(pdcch_MAC(nextfield:nextfield+nHARQbits-1));
                            nextfield = nextfield + nHARQbits;
                            dci1A_NDI = dab_binval(pdcch_MAC(nextfield:nextfield));
                            nextfield = nextfield + 1;
                            dci1A_RV = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                            dci1A_TPC = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                            if (tdd)
                                dci1A_DAI = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            else 
                                dci1A_DAI = -1;
                            end

                            fprintf(1, 'Resource=%d, MCS=%d, HARQ=%d, NDI=%d, RV=%d, TPC(NPRB_1A)=%d, TAI=%d\n', ...
                                dci1A_resource,dci1A_MCS,dci1A_HARQ,dci1A_NDI,dci1A_RV,dci1A_TPC,dci1A_DAI);

                            %attempt to decode it
                            [RBstart Lcrbs] = lte_riv_to_range_1a1b1d(NDLRB, dci1A_resource);


                            %SI/RA/P RNTI are handled differently
                            if (find ([RA_RNTI SI_RNTI P_RNTI] == rnti))
                                N1APRB = mod(dci1A_TPC, 2) + 2;
                                tbsize = lte_compute_tbsize(NDLRB, N1APRB, dci1A_MCS, 1, 1);
                            else

                                tbsize = lte_compute_tbsize(NDLRB, Lcrbs, dci1A_MCS, 0, 1);
                            end

                            pdsch_symbols = lte_extract_prbs(slot0_eq,slot1_eq,NDLRB, [RBstart:(RBstart+Lcrbs-1)], ncellid, subframe*2, ncp, tdd, ...
                                antenna_config_to_num_antennas(antenna_config), pdcch_nsymbols);

                            figure(6);
                            plot(pdsch_symbols, '+');
                           % figure(5);
                            %plot([0:1319],abs(slot0_eq(2,:)));

                            pdsch_softbits_sc = lte_demod_soft_qpsk(pdsch_symbols);
                            pdsch_softbits = pdsch_softbits_sc .* (1-2*lte_pdsch_seq(rnti, 0, ncellid, subframe*2, length(pdsch_softbits_sc)));
                            fprintf(1, '-->Resource: [%d %d] tbsize: %d coderate=%.3f\n', RBstart, RBstart+Lcrbs-1, tbsize, (tbsize+24)/(length(pdsch_softbits)));
                            pdsch_softbuffer = zeros(1,3*(tbsize+24+4));
                            pdsch_softbuffer = lte_turbo_deratematch(pdsch_softbuffer, 1e6, dci1A_RV, pdsch_softbits);
                            pdsch_hardbits = pdsch_softbuffer < 0;
                            pdsch_crc = pdsch_hardbits(tbsize+1:tbsize+24);
                            pdsch_calc_crc = lte_crc(pdsch_hardbits(1:tbsize), crcpoly24A);

                            %test turbo encoder
                            turbo_errs=abs(lte_turbo_encode(pdsch_hardbits(1:tbsize+24), tbsize+24) - pdsch_hardbits);                        
                            turbo_errs_cnt = sum(turbo_errs);

                            if (sum(abs(pdsch_crc - pdsch_calc_crc)) == 0)

                                fprintf(1,'-->CRC OK, turbo_errs=%d!\n',turbo_errs_cnt);
                                if (turbo_errs_cnt)
                                    find (turbo_errs == 1)
                                end

                                str = sprintf('%s\\frame%d_%d_rnti%d.bin',path, frame_no,subframe,rnti);
                                umts_write_bitstring_file(str, pdsch_hardbits(1:tbsize));
                            else
                                fprintf(1,'-->BAD CRC, turbo_errs=%d!\n',turbo_errs_cnt);
                                continue;
                            end    
                            
                            if (find(RA_RNTI == rnti))
                                RAR_E = 1;
                                RAR_RAPID = -1;
                                RAR_BI = -1;
                                num_RAR_payloads = 0;
                                
                                nextfield = 1;
                                while (RAR_E == 1)
                                    RAR_E = dab_binval(pdsch_hardbits(nextfield:nextfield+1-1));
                                    nextfield = nextfield + 1;
                                    RAR_T = dab_binval(pdsch_hardbits(nextfield:nextfield+1-1));
                                    nextfield = nextfield + 1;
                                    
                                    if (RAR_T == 1) %RAPID
                                        RAR_RAPID = dab_binval(pdsch_hardbits(nextfield:nextfield+6-1));
                                        nextfield = nextfield + 6;
                                        num_RAR_payloads = num_RAR_payloads + 1;
                                        fprintf(1,'RAR: RAPID=%d\n', RAR_RAPID);
                                    else
                                        nextfield = nextfield + 2;
                                        RA_BI = dab_binval(pdsch_hardbits(nextfield:nextfield+4-1));
                                        nextfield = nextfield + 4;
                                        fprintf(1,'RAR: BI=%d\n', RAR_BI);
                                    end
                                end
                                fprintf(1,'RAR: num payloads = %d\n', num_RAR_payloads);
                                
                                if (num_RAR_payloads * 6*8 + (nextfield-1) > tbsize)
                                    fprintf(1,'RAR: header size = %d, num payloads = %d but tbsize only %d, error, skip\n',...
                                        nextfield, num_RAR_payloads, tbsize);
                                    continue;
                                end
                                
                                for i=0:num_RAR_payloads-1,
                                    nextfield = nextfield + 1; %skip reserved
                                    RAR_TA = dab_binval(pdsch_hardbits(nextfield:nextfield+11-1));
                                    nextfield = nextfield + 11;
                                    RAR_ULgrant = dab_binval(pdsch_hardbits(nextfield:nextfield+20-1));
                                    nextfield = nextfield + 20;
                                    RAR_TCRNTI = dab_binval(pdsch_hardbits(nextfield:nextfield+16-1));
                                    nextfield = nextfield + 16;
                                    
                                    fprintf('RAR payload %d: TA = %d, ULGrant=%d, TCRNTI=%d\n', i, RAR_TA, RAR_ULgrant, RAR_TCRNTI);
                                    if (isempty((find(Extra_RNTIS == RAR_TCRNTI)))),
                                        fprintf('new T_CRNTI = %d, adding\n', RAR_TCRNTI);
                                        %temporarily add it to here as well
                                        %for the rest of the frame
                                        Extra_RNTIS = [Extra_RNTIS RAR_TCRNTI];
                                        NewRNTIS = [NewRNTIS RAR_TCRNTI]; %add to the search list

                                    end
                                end
                            elseif (~isempty(find(Extra_RNTIS == rnti))) %normal MAC SDU on CCCH or DCCH
                                
                                nextfield = 1;
                                MAC_E = 1;
                                MAC_LCIDs = [];
                                MAC_lengths_octets = [];
                                MAC_control_LCID_types = [28 29 30];
                                MAC_control_LCID_lengths_octets = [6 1 0]; %contention, Timing advance, DRX command
                                
                                while (MAC_E == 1)
                                    
                                    nextfield = nextfield + 2; %skip reserved
                                    MAC_E = dab_binval(pdsch_hardbits(nextfield:nextfield+1-1));
                                    nextfield = nextfield + 1;
                                    MAC_LCID = dab_binval(pdsch_hardbits(nextfield:nextfield+5-1));
                                    nextfield = nextfield + 5;
                                    
                                    MAC_LCIDs = [MAC_LCIDs MAC_LCID];
                                    
                                    %is there an L field
                                    
   
                                    %the first 2 LCIDs can be padding, in
                                    %which case they have no lengths
                                    if ( (length(MAC_LCIDs) == 0 || (length(MAC_LCIDs) == 1 && MAC_LCIDs(1) == 31)) && MAC_LCID == 31),
                                        MAC_lengths_octets = [MAC_lengths_octets 0];
                                        continue;
                                    end
                                         
                                    if (~isempty(find(MAC_control_LCID_types == MAC_LCID)))  %if control LCID, length is fixed,
                                        idx = find(MAC_control_LCID_types == MAC_LCID); 
                                        MAC_lengths_octets = [MAC_lengths_octets MAC_control_LCID_lengths_octets(idx)];
                                        continue;
                                    end
                                    
                                    if (MAC_E == 0) %last is implicit
                                        MAC_length_bits = (tbsize - (nextfield - 1) - sum(MAC_lengths_octets)*8);
                                        
                                        assert(MAC_length_bits >= 0);
                                        assert(mod(MAC_length_bits, 8) == 0);
                                        
                                        MAC_lengths_octets = [MAC_lengths_octets MAC_length_bits/8]; 
                                        continue;
                                    end

                                    MAC_L = dab_binval(pdsch_hardbits(nextfield:nextfield+1-1));
                                    nextfield = nextfield + 1;
                                    MAC_length_length = 7 + MAC_L*8;
                                    MAC_length = dab_binval(pdsch_hardbits(nextfield:nextfield+MAC_length_length-1));
                                    nextfield = nextfield + MAC_length_length;
                                    
                                    MAC_lengths_octets = [MAC_lengths_octets MAC_length];
                                    
                                end
                                
                                %now go thru the PDUs
                                for i=1:length(MAC_LCIDs),
                                    LCID = MAC_LCIDs(i);
                                    MAC_length_octets = MAC_lengths_octets(i);
                                    MAC_data = pdsch_hardbits(nextfield:nextfield+MAC_length_octets*8-1);
                                    nextfield = nextfield + MAC_length_octets*8;
                                    fprintf('LCID %d, length %d\n', LCID, MAC_length_octets);
                                    
                                    if (LCID == 28) %contention resolution
                                        UEID = dab_binval(MAC_data);
                                        fprintf(1,'-->Contention Resolution UE ID = %08X\n', UEID);
                                    elseif (LCID == 29)
                                        TAcmd = dab_binval(MAC_data(3:8));
                                        fprintf(1, '-->TA command %d\n', TAcmd);                                        
                                    elseif (LCID == 30) % DRX COMMAND
                                        fprintf(1, '-->DRX Command\n');
                                    elseif (LCID == 31)
                                        fprintf(1, '-->Padding\n');
                                    elseif (LCID <= 10) %CCCH or DCCH
     
                                        str = sprintf('%s\\frame%d_%d_rnti%d_MACSDU%d_LCID%d.bin',path, frame_no,subframe,rnti, (i-1), LCID );
                                        fprintf(1, '-->CCCH/DCCH data written to disk file %s\n', str);
                                        umts_write_bitstring_file(str, MAC_data);
                                    else
                                        fprintf(1', '-->Unknown LCID\n');
                                    end
                                    
                                end
i=1;
                            end              
                        end                                              
                    end
                end
            end
        end
    

    end

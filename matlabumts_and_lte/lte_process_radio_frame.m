function [NewRNTIS] = lte_process_radio_frame(framesamples, fftsize, ncellid, ncp, tdd, tddconfig, Extra_RNTIs, path)
%the timing, cellid and ncp have been detected by low level sync at this
%point

    SLOTLEN = 30.72e6/2000 * fftsize/2048;
    if (ncp) 
        PBCH_RATEMATCHED_LEN = 1920 ;
        nsymbols = 7;
    else
        PBCH_RATEMATCHED_LEN = 1728;
        nsymbols = 6;
    end;
    PBCH_CODED_LEN = 40;
    PBCH_TB_SIZE = 24;
    crcpoly16 =  [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
    crcpoly24A = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 0 1 1];
    crcpoly24B = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1];
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
    %RA_RNTI = [1:10]; %FDD only is 1-10, in theory should adjust based on SI data and TDD
    
    %RA_RNTI = [2]; %telstra - subframe 1
    RA_RNTI = [2 7]; % optus subframe 1,6
   % RA_RNTI = [8]; %telstra1800 subframe 7
    NewRNTIS = []; %gets updated by MAC as we spot RA responses 
    
    PB = 1;
    PA_dB = -3;
    
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
    
    if (~pbch_found)
        fprintf(1, 'No PBCH found');
        return; 
    
    end; %no PBCH ever found
    
    fprintf(1, 'Using antennas: %d\n', antenna_config_to_num_antennas(antenna_config));
   
    pbch_bandwidth_idx = pbch_MAC(1:3);
    pbch_phich_config_duration_idx = pbch_MAC(4);
    pbch_phich_config_resource_idx = pbch_MAC(5:6);
    pbch_frameno = pbch_MAC(7:14);
    pbch_schedulingInfoSIB1_BR_r13 = pbch_MAC(15:19);
    
    NDLRB = PBCH_NDLRBS_tab(dab_binval(pbch_bandwidth_idx)+1);
    phich_duration = PBCH_PHICH_DURATION_tab(dab_binval(pbch_phich_config_duration_idx)+1);
    phich_resource = PBCH_PHICH_RESOURCE_tab(dab_binval(pbch_phich_config_resource_idx)+1);
    frame_no = dab_binval(pbch_frameno) * 4 + ms40frame;
    pbch_schedulingInfoSIB1_BR_r13_val = dab_binval(pbch_schedulingInfoSIB1_BR_r13);
    fprintf(1, 'NDLRB = %d, phich_duration = %d, phich_resource = %.4f frame_no = %d pbch_schedulingInfoSIB1_BR_r13 = %d\n', NDLRB,phich_duration,phich_resource,frame_no, pbch_schedulingInfoSIB1_BR_r13_val);
  
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
    
    DCI_FORMAT_2A_LEN = 0 + ceil(NDLRB/P) + 2 + 0 + 3 + 1 + 2*(5+1+2) + 0;
    
    if (NDLRB>10)
        DCI_FORMAT_2A_LEN = DCI_FORMAT_2A_LEN + 1; %extra bit for resource alloc header
    end
    
    if (tdd)
        DCI_FORMAT_2A_LEN = DCI_FORMAT_2A_LEN + 2 + 1; %extra 2 bits for DAI + 1 extra HARQ bit
    end
    
    DCI_FORMAT_2A_PRECODING_BITS = [0 0 2]; %strictly speaking format 2A should not be used on single antenna port??
    DCI_FORMAT_2A_LEN = DCI_FORMAT_2A_LEN + DCI_FORMAT_2A_PRECODING_BITS(antenna_config);
    
    %forbidden sizes
    while(find (DCI_FORMAT_FORBIDDEN_SIZES == DCI_FORMAT_2A_LEN))
        DCI_FORMAT_2A_LEN = DCI_FORMAT_2A_LEN + 1;
    end
    
    %DCI format 2 size
    
    DCI_FORMAT_2_LEN = 0 + ceil(NDLRB/P) + 2 + 0 + 3 + 1 + 2*(5+1+2) + 0;
    
    if (NDLRB>10)
        DCI_FORMAT_2_LEN = DCI_FORMAT_2_LEN + 1; %extra bit for resource alloc header
    end
    
    if (tdd)
        DCI_FORMAT_2_LEN = DCI_FORMAT_2_LEN + 2 + 1; %extra 2 bits for DAI + 1 extra HARQ bit
    end
    
    DCI_FORMAT_2_PRECODING_BITS = [0 3 6]; %strictly speaking format 2 should not be used on single antenna port??
    DCI_FORMAT_2_LEN = DCI_FORMAT_2_LEN + DCI_FORMAT_2_PRECODING_BITS(antenna_config);
    
    %forbidden sizes
    while(find (DCI_FORMAT_FORBIDDEN_SIZES == DCI_FORMAT_2_LEN))
        DCI_FORMAT_2_LEN = DCI_FORMAT_2_LEN + 1;
    end
    
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
            slot0_eq = zeros(nsymbols,110*12);
            slot1_eq = zeros(nsymbols,110*12);
            
            %optimisation. Also now that TM4 single layer is supported,
            %don't necessarily want to TXD equalize
            slot0_eq = lte_slot_equalise_txd_partial(slot0_eq,slot0_kvs,slot0_est,NDLRB,ncellid,subframe*2+0,ncp, 0);
            %slot1_eq = lte_slot_equalise(slot1_kvs,slot1_est,NDLRB,ncellid,subframe*2+1,ncp);   
                    
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

        %perform the remaining equalization of PDCCH symbols greater than 1
        %for non single antenna port
        if (pdcch_nsymbols > 1 && antenna_config_to_num_antennas(antenna_config) > 1)
            slot0_eq = lte_slot_equalise_txd_partial(slot0_eq,slot0_kvs,slot0_est,NDLRB,ncellid,subframe*2+0,ncp, [2:pdcch_nsymbols] -1);
        end
        
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
        
        %we can search them all, the search space is actually not that
        %complicated
        % 'A PDCCH consisting of  n  
         %consecutive CCEs may only start on a CCE fulfilling 0 mod = n i ,
         %where  i  is the CCE number.  '
         
        
%        Yk = 0; %Common only
        
%         PDCCH_COMMON_L = [4 8];
%         PDCCH_COMMON_ML = [4 2];
%         
%         CCE_START = zeros(1,sum(PDCCH_COMMON_ML))-1;
%         CCE_L = zeros(1,sum(PDCCH_COMMON_ML))-1;
%         i=1;
%         PDCCH_AGGR_LEVEL_MAX = min(floor(N_PDCCH_CCE/4),2); %cover the case where not enough RBs for 8CCE
%         for PDCCH_AGGR_LEVEL_idx = 1:PDCCH_AGGR_LEVEL_MAX, %for each aggregation level
%             L = PDCCH_COMMON_L(PDCCH_AGGR_LEVEL_idx);
%             ML = PDCCH_COMMON_ML(PDCCH_AGGR_LEVEL_idx);
%             CCELIST=zeros(1, ML) - 1;
%             for m = 0:ML-1, %for each candidate 
%                 % note can end up with some duplicates where N_PDCCH_CCE =
%                 % multiple of 4,8 etc
%                 CCE = L * (mod(Yk+m, floor(N_PDCCH_CCE/L)));
%                 if ((find (CCELIST == CCE)))
%                    continue;
%                 end
%                 CCELIST(m+1) = CCE;
%                 CCE_START(i) = CCE;
%                 CCE_L(i) = L;
%                 i = i+1;
%             end
%         end
%         CCE_START = CCE_START(find(CCE_START >= 0));
%         CCE_L = CCE_L(find(CCE_L >= 0));
        

        CCE_aggr_size = [1 2 4 8];
        CCE_START = [];
        CCE_L = [];
        for idx = 1:length(CCE_aggr_size)
            temp_L = CCE_aggr_size(idx);
            temp_numoflenL = floor(N_PDCCH_CCE/temp_L);
            
            CCE_START = [CCE_START 0:temp_L:temp_numoflenL*temp_L-1];
            CCE_L = [CCE_L ones(1,temp_numoflenL) * temp_L];
            
        end
        
        FOUND_CCE_INDEXs = [];
        %now process the CCE
        for cce = 1:length(CCE_START),
            cce_start = CCE_START(cce);
            cce_L = CCE_L(cce);
            
            if (~isempty(find(FOUND_CCE_INDEXs == cce_start)))
                continue; %already found
            end
            cce_softbits = pdcch_symbols_deint_softbits(cce_start*9*8+1:(cce_start+cce_L)*9*8);
            %test it against each size
            
            if (cce_L>=4)
                PDCCH_SIZES = [DCI_FORMAT_1C_LEN DCI_FORMAT_1A_LEN DCI_FORMAT_1_LEN DCI_FORMAT_2A_LEN DCI_FORMAT_2_LEN];%[DCI_FORMAT_1A_LEN];
            else %Format 1C is only used in common search areas which are L=4,8 only
                PDCCH_SIZES = [DCI_FORMAT_1A_LEN DCI_FORMAT_1_LEN DCI_FORMAT_2A_LEN DCI_FORMAT_2_LEN];
            end
            
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
                
                %decide based on pdcch_tb_size what is allowed in the RNTI
                
           
                if (pdcch_tb_size == DCI_FORMAT_1C_LEN && cce_L>=4) %only SI/RA/P
                    SEARCH_RNTIS = [SI_RNTI RA_RNTI P_RNTI];
                elseif (pdcch_tb_size == DCI_FORMAT_1A_LEN && cce_L>=4) %anything
                    SEARCH_RNTIS = [SI_RNTI RA_RNTI P_RNTI Extra_RNTIs];
                else %only C-RNTI/temp C-RNTI
                    SEARCH_RNTIS = [Extra_RNTIs];
                end
             
                
                for rnti = SEARCH_RNTIS %[Extra_RNTIS RA_RNTI SI_RNTI P_RNTI],
                    
                    %check if this RNTI of size CCE_L should be found
                    %cce_start according to 36.213 9.1.1
                    
                    %compute Yk 
                    if (~isempty(find(rnti == [RA_RNTI SI_RNTI P_RNTI]))) %RA/SI/P
                        Yk = 0;
                        NUM_PDCCH_CANDIDATES = [0 0 4 2];
                    else
                        Yk = rnti;
                        for i=0:subframe,
                            Yk = mod((39827 * Yk),65537);
                        end
                        NUM_PDCCH_CANDIDATES = [6 6 2 2];
                    end
                    
                    %find the number of candidates for this L
                    num_pdcch_candidates = NUM_PDCCH_CANDIDATES(find(CCE_aggr_size == cce_L));
                    
                    pdcch_candidates_start = cce_L * (mod(Yk + [0:num_pdcch_candidates-1],floor(N_PDCCH_CCE/cce_L)));                   
                    
                    pdcch_calculated_CRC = mod(lte_crc(pdcch_MAC(1:pdcch_tb_size), crcpoly16) + lte_dec_to_binstring(rnti, 16), 2);
                    pdcch_CRC - pdcch_calculated_CRC;
                    if (sum(abs(pdcch_CRC-pdcch_calculated_CRC)) == 0)
                        fprintf (1, '%d:%d found PDCCH at CCE %d (L=%d) RNTI=%d PDCCH_SIZE=%d\n', frame_no, subframe, cce_start, cce_L, rnti, pdcch_tb_size);
                        
                        %this is a better check - crude power check
                        
                        if (sum(cce_softbits.^2)/length(cce_softbits) < 0.5^2 / 4) %allow 6dB of power tolerance
                           fprintf(1,'!!!!! is probable false detection as the power is 6dB below expected power\n');
                           continue;
                        end
                        
                        %this check doesnt help much anymore as those false
                        %detects will likely be found at some other aggr
                        %level
                        %if (isempty(find(pdcch_candidates_start == cce_start)))
                           %fprintf('1,"!!!! is probable false detection as it not part of the search zone for this rnti\n'); 
                           %continue; 
                        %end
                        
                        %successfully found something at this CCE index. So
                        %add it to the list to avoid doubling up
                        FOUND_CCE_INDEXs = [FOUND_CCE_INDEXs cce_start];
                        
                        pdsch_Qm = -1; %dont decode by default
                        pdsch_VRB_list =[];
                        pdsch_Itbs = -1;
                        pdsch_tbsize = -1; %dont decode by default.
                        pdsch_RV = -1;
                        pdsch_mode = 'skip';
                            
                        if (pdcch_tb_size == DCI_FORMAT_2_LEN)
                            
                            nextfield = 1;
                            if (NDLRB > 10)
                                dci2_resourceallocheader = dab_binval(pdcch_MAC(nextfield:nextfield));
                                nextfield = nextfield + 1;
                            else
                                dci2_resourceallocheader = 0;
                            end
                            
                            dci2_resourcealloc = pdcch_MAC(nextfield:nextfield+ceil(NDLRB/P)-1);
                            nextfield = nextfield + ceil(NDLRB/P);
                            
                            dci2_tpc = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                            
                            if (tdd)
                                dci2_DAI = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                                nextfield = nextfield + 2;
                                HARQ_width = 4;
                            else
                                dci2_DAI = -1;
                                HARQ_width = 3;
                            end
                            
                            dci2_HARQ = dab_binval(pdcch_MAC(nextfield:nextfield+HARQ_width-1));
                            nextfield = nextfield + HARQ_width;
                            
                            dci2_codewordswap = dab_binval(pdcch_MAC(nextfield:nextfield+1-1));
                            nextfield = nextfield + 1;
                            
                            dci2_MCS_cw0 = dab_binval(pdcch_MAC(nextfield:nextfield+5-1));
                            nextfield = nextfield + 5;
                            
                            dci2_NDI_cw0 = dab_binval(pdcch_MAC(nextfield:nextfield+1-1));
                            nextfield = nextfield + 1;
                            
                            dci2_RV_cw0 = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                             
                            dci2_MCS_cw1 = dab_binval(pdcch_MAC(nextfield:nextfield+5-1));
                            nextfield = nextfield + 5;
                            
                            dci2_NDI_cw1 = dab_binval(pdcch_MAC(nextfield:nextfield+1-1));
                            nextfield = nextfield + 1;
                            
                            dci2_RV_cw1 = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                            
                            if (antenna_config_to_num_antennas(antenna_config) == 4)
                                dci2_precode = dab_binval(pdcch_MAC(nextfield:nextfield+6-1));
                                nextfield = nextfield + 6;
                            else
                                dci2_precode = dab_binval(pdcch_MAC(nextfield:nextfield+3-1));
                                nextfield = nextfield + 3;
                            end
                            
                            fprintf('DCI2: allocheader=%d alloc=0x%08X, tpc=%d, DAI=%d HARQ=%d swap=%d precode=%d\n', ...
                                dci2_resourceallocheader, dab_binval(dci2_resourcealloc), dci2_tpc, dci2_DAI,...
                                dci2_HARQ, dci2_codewordswap, dci2_precode);
                            
                            dci2_cw0_enabled = (~((dci2_MCS_cw0 == 0) && (dci2_RV_cw0 == 1)));
                            dci2_cw1_enabled = (~((dci2_MCS_cw1 == 0) && (dci2_RV_cw1 == 1)));
                            
                            fprintf('-->CW0: MCS=%d NDI=%d RV=%d enabled=%d\n', dci2_MCS_cw0, dci2_NDI_cw0, dci2_RV_cw0,dci2_cw0_enabled);
                            fprintf('-->CW1: MCS=%d NDI=%d RV=%d enabled=%d\n', dci2_MCS_cw1, dci2_NDI_cw1, dci2_RV_cw1,dci2_cw1_enabled);
                            
                            %attempt to decode it
                            dci2_VRBs = lte_format01_to_vrbs_122a2b(NDLRB, dci2_resourceallocheader, dci2_resourcealloc, P);
                            
                            if (dci2_cw0_enabled && dci2_cw1_enabled)
                                fprintf('-->MIMO allocation, cannot decode, skipping\n');
                            else
                                %select the codeword
                                if (dci2_cw0_enabled)
                                    dci2_MCS = dci2_MCS_cw0;
                                    pdsch_RV = dci2_RV_cw0;
                                else
                                    dci2_MCS = dci2_MCS_cw1;
                                    pdsch_RV = dci2_RV_cw1;
                                end
                                pdsch_VRB_list = dci2_VRBs;
                                [pdsch_Qm, pdsch_Itbs] = lte_compute_Qm_Itbs(dci2_MCS);
                                pdsch_tbsize = lte_compute_tbsize(length(pdsch_VRB_list), pdsch_Itbs);
                                pdsch_tbsize_orig  = pdsch_tbsize;
                                
                                if (antenna_config_to_num_antennas(antenna_config) == 2)
                                    if (dci2_precode == 0)
                                        pdsch_mode = 'txd';
                                    elseif (dci2_precode >= 1 && dci2_precode <=4)
                                        pdsch_mode = '1layermimo';
                                        pdsch_codebook = dci2_precode - 1;
                                        
                                    elseif (dci2_precode >= 5 && dci2_precode <=6)
                                        fprintf('--> PMI dependent precoder (%d), cannot decode, skipping\n', dci2_precode);
                                        pdsch_tbsize = -1;
                                    else
                                        fprintf('-->unknown precoding type %d, skipping\n', dci2_precode);
                                        pdsch_tbsize = -1;
                                    end
    
                                else
                                    if (dci2a_precode == 0)
                                        pdsch_mode = 'txd';
                                    else %do this later when I have a 4 way signal to play with
                                        fprintf('-->unsupported 4 antenna precoder type %d, skipping\n', dci2_precode);
                                    end
                                end                                
                                fprintf('-->tbsize=%d, modulation=%d mode=%s alloc = %s\n', pdsch_tbsize_orig, pdsch_Qm, pdsch_mode, sprintf('%d ', pdsch_VRB_list));
                            end
                            
                        elseif (pdcch_tb_size == DCI_FORMAT_2A_LEN)
                            
                            nextfield = 1;
                            
                            if (NDLRB > 10)
                                dci2a_resourceallocheader = dab_binval(pdcch_MAC(nextfield:nextfield));
                                nextfield = nextfield + 1;
                            else
                                dci2a_resourceallocheader = 0;
                            end
                            
                            dci2a_resourcealloc = pdcch_MAC(nextfield:nextfield+ceil(NDLRB/P)-1);
                            nextfield = nextfield + ceil(NDLRB/P);
                            
                            dci2a_tpc = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                            
                            if (tdd)
                                dci2a_DAI = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                                nextfield = nextfield + 2;
                                HARQ_width = 4;
                            else
                                dci2a_DAI = -1;
                                HARQ_width = 3;
                            end
                            
                            dci2a_HARQ = dab_binval(pdcch_MAC(nextfield:nextfield+HARQ_width-1));
                            nextfield = nextfield + HARQ_width;
                            
                            dci2a_codewordswap = dab_binval(pdcch_MAC(nextfield:nextfield+1-1));
                            nextfield = nextfield + 1;
                            
                            dci2a_MCS_cw0 = dab_binval(pdcch_MAC(nextfield:nextfield+5-1));
                            nextfield = nextfield + 5;
                            
                            dci2a_NDI_cw0 = dab_binval(pdcch_MAC(nextfield:nextfield+1-1));
                            nextfield = nextfield + 1;
                            
                            dci2a_RV_cw0 = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                             
                            dci2a_MCS_cw1 = dab_binval(pdcch_MAC(nextfield:nextfield+5-1));
                            nextfield = nextfield + 5;
                            
                            dci2a_NDI_cw1 = dab_binval(pdcch_MAC(nextfield:nextfield+1-1));
                            nextfield = nextfield + 1;
                            
                            dci2a_RV_cw1 = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                            
                            if (antenna_config_to_num_antennas(antenna_config) == 4)
                                dci2a_precode = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                                nextfield = nextfield + 2;
                            else
                                dci2a_precode = -1;
                            end
                            
                            %compute enabled CW 36.213 7.1.7.2
                            
                            dci2a_cw0_enabled = (~((dci2a_MCS_cw0 == 0) && (dci2a_RV_cw0 == 1)));
                            dci2a_cw1_enabled = (~((dci2a_MCS_cw1 == 0) && (dci2a_RV_cw1 == 1)));
                            
                            fprintf('DCI2A: allocheader=%d, alloc=0x%08X, tpc=%d, DAI=%d HARQ=%d swap=%d precode=%d\n', ...
                                dci2a_resourceallocheader, dab_binval(dci2a_resourcealloc), dci2a_tpc, dci2a_DAI,...
                                dci2a_HARQ, dci2a_codewordswap, dci2a_precode);
                            
                            fprintf('-->CW0: MCS=%d NDI=%d RV=%d enabled=%d\n', dci2a_MCS_cw0, dci2a_NDI_cw0, dci2a_RV_cw0,dci2a_cw0_enabled);
                            fprintf('-->CW1: MCS=%d NDI=%d RV=%d enabled=%d\n', dci2a_MCS_cw1, dci2a_NDI_cw1, dci2a_RV_cw1,dci2a_cw1_enabled);
                            
                            %attempt to decode it
                            dci2a_VRBs = lte_format01_to_vrbs_122a2b(NDLRB, dci2a_resourceallocheader, dci2a_resourcealloc, P);


                            %pdsch_symbols = lte_extract_prbs(slot0_eq,slot1_eq,NDLRB, dci2a_VRBs, ncellid, subframe*2, ncp, tdd, ...
                            %    antenna_config_to_num_antennas(antenna_config), pdcch_nsymbols);


                            if (dci2a_cw0_enabled && dci2a_cw1_enabled)
                                fprintf('-->MIMO allocation, cannot decode, skipping\n');
                            else
                                %select the codeword
                                if (dci2a_cw0_enabled)
                                    dci2a_MCS = dci2a_MCS_cw0;
                                    pdsch_RV = dci2a_RV_cw0;
                                else
                                    dci2a_MCS = dci2a_MCS_cw1;
                                    pdsch_RV = dci2a_RV_cw1;
                                end
                                pdsch_VRB_list = dci2a_VRBs;
                                [pdsch_Qm, pdsch_Itbs] = lte_compute_Qm_Itbs(dci2a_MCS);
                                pdsch_tbsize = lte_compute_tbsize(length(pdsch_VRB_list), pdsch_Itbs);
                                pdsch_tbsize_orig = pdsch_tbsize;
                                if (antenna_config_to_num_antennas(antenna_config) == 2)
                                    
                                    pdsch_mode = 'txd'; %36.212 5.3.3.1.5A says if single codeword + 2 antennas: TXD
                                else
                                    if (dci2a_precode == 0)
                                        pdsch_mode = 'txd';
                                    elseif (dci2a_precode == 1)
                                        pdsch_mode = '2layercddcycling';
                                    else
                                        fprintf('-->unknown precoding type %d, skipping\n', dci2a_precode);
                                        pdsch_tbsize = -1;
                                    end
                                end
                                fprintf('-->tbsize=%d, modulation=%d mode=%s alloc = %s\n', pdsch_tbsize_orig, pdsch_Qm, pdsch_mode, sprintf('%d ', pdsch_VRB_list));
                            end
                            
                        elseif (pdcch_tb_size == DCI_FORMAT_1A_LEN)
                            
                            nextfield = 1;
                            % if DCI-1A - assume for now
                            dci1A_diff = pdcch_MAC(nextfield:nextfield);
                            nextfield = nextfield + 1;
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
                                  dci0hopidx = dab_binval(pdcch_MAC(nextfield:nextfield+NULhop-1));
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
                                
                                pusch_VRBs = [];

                                [RBstart LCrbs] = lte_riv_to_range_1a1b1d(NDLRB, dci0_resource);
                                pusch_VRBs = RBstart:RBstart+LCrbs-1;
 
                                [pusch_Qm, pusch_Itbs] = lte_compute_Qm_Itbs_uplink(dci0_MCS);
                                pusch_tbsize = lte_compute_tbsize(length(pusch_VRBs), pusch_Itbs);
                                
                                fprintf(1, 'DCI0: Uplink Grant:: hopping=%d hopidx=%d resource=%s, MCS=%d, NDI=%d, TPC=%d, CyclicShift=%d, CQI request=%d tbsize=%d\n', ...
                                dci0_hopping,dci0hopidx,sprintf('%d ', pusch_VRBs),dci0_MCS,dci0_NDI,dci0_TPC,dci0CyclicShift,dci0CQIRequest,pusch_tbsize);

                            else  
                                dci1A_distlocal = pdcch_MAC(nextfield:nextfield);

                                nextfield = nextfield + 1;
                                
                                if (dci1A_distlocal)

                                    if (~isempty(find(rnti == [RA_RNTI SI_RNTI P_RNTI])) || NDLRB<50) %RA/SI/P or NDLRB < 50
                                       dci1A_resource = dab_binval(pdcch_MAC(nextfield:nextfield+ceil(log2(NDLRB*(NDLRB+1)/2))-1));
                                       nextfield = nextfield + ceil(log2(NDLRB*(NDLRB+1)/2));
                                    else
                                       dci1a_gap = pdcch_MAC(nextfield:nextfield);
                                       nextfield = nextfield + 1;
                                       dci1A_resource = dab_binval(pdcch_MAC(nextfield:nextfield+ceil(log2(NDLRB*(NDLRB+1)/2)) -1 -1));
                                       nextfield = nextfield + ceil(log2(NDLRB*(NDLRB+1)/2)) - 1; 
                                    end
                                else
                                    
                                    dci1A_resource = dab_binval(pdcch_MAC(nextfield:nextfield+ceil(log2(NDLRB*(NDLRB+1)/2))-1));
                                    nextfield = nextfield + ceil(log2(NDLRB*(NDLRB+1)/2));
                                end
                                
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

                                fprintf(1, 'DCI1A: Resource=%d, MCS=%d, HARQ=%d, NDI=%d, RV=%d, TPC(NPRB_1A)=%d, TAI=%d\n', ...
                                    dci1A_resource,dci1A_MCS,dci1A_HARQ,dci1A_NDI,dci1A_RV,dci1A_TPC,dci1A_DAI);

                                %attempt to decode it
                                [RBstart Lcrbs] = lte_riv_to_range_1a1b1d(NDLRB, dci1A_resource);


                                %SI/RA/P RNTI are handled differently
                                if (find ([RA_RNTI SI_RNTI P_RNTI] == rnti))
                                    N1APRB = mod(dci1A_TPC, 2) + 2;
                                    pdsch_Qm = 2;
                                    pdsch_Itbs = dci1A_MCS;
                                    pdsch_tbsize = lte_compute_tbsize(N1APRB, pdsch_Itbs);
                                else
                                    [pdsch_Qm, pdsch_Itbs] = lte_compute_Qm_Itbs(dci1A_MCS);
                                    pdsch_tbsize = lte_compute_tbsize(Lcrbs, pdsch_Itbs);
                                end
                                
                                pdsch_mode = 'txd';
                                pdsch_RV = dci1A_RV;
                                pdsch_VRB_list = [RBstart:(RBstart+Lcrbs-1)];
                            end
                        elseif (pdcch_tb_size == DCI_FORMAT_1_LEN)
                            nextfield = 1;
                            
                            if (NDLRB > 10)
                                dci1_resourceallocheader = dab_binval(pdcch_MAC(nextfield:nextfield));
                                nextfield = nextfield + 1;
                            else
                                dci1_resourceallocheader = 0;
                            end
                            
                            dci1_resourcealloc = pdcch_MAC(nextfield:nextfield+ceil(NDLRB/P)-1);
                            nextfield = nextfield + ceil(NDLRB/P);
                            
                            dci1_MCS = dab_binval(pdcch_MAC(nextfield:nextfield+5-1));
                            nextfield = nextfield + 5;
                            
                            if (tdd)
                                HARQ_width = 4;
                            else
                                HARQ_width = 3;
                            end
                            
                            dci1_HARQ = dab_binval(pdcch_MAC(nextfield:nextfield+HARQ_width-1));
                            nextfield = nextfield + HARQ_width;
                            
                            dci1_NDI = dab_binval(pdcch_MAC(nextfield:nextfield+1-1));
                            nextfield = nextfield + 1;
                            
                            dci1_RV = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                            
                            dci1_TPC = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                            nextfield = nextfield + 2;
                            
                             
                            if (tdd)
                                dci1_DAI = dab_binval(pdcch_MAC(nextfield:nextfield+2-1));
                                nextfield = nextfield + 2;
                            else
                                dci1_DAI = -1;
                            end
                            
                            dci1_VRBs = lte_format01_to_vrbs_122a2b(NDLRB, dci1_resourceallocheader, dci1_resourcealloc, P);
                            
                            
                            
                            fprintf(1, 'DCI1: Resourceallocheader=%d, resource=%08X, MCS=%d, HARQ=%d, NDI=%d, RV=%d, TPC(NPRB_1A)=%d, TAI=%d\n', ...
                                    dci1_resourceallocheader,dab_binval(dci1_resourcealloc), dci1_MCS, dci1_HARQ, dci1_NDI, dci1_RV, dci1_TPC, dci1_DAI);
 
                            pdsch_VRB_list = dci1_VRBs;
                            [pdsch_Qm, pdsch_Itbs] = lte_compute_Qm_Itbs(dci1_MCS);
                            pdsch_tbsize = lte_compute_tbsize(length(pdsch_VRB_list), pdsch_Itbs);
                            pdsch_tbsize_orig = pdsch_tbsize;
                            pdsch_RV = dci1_RV;

                            pdsch_mode = 'txd'; %36.212 5.3.3.1.5A says if single codeword + 2 antennas: TXD
                            
                            fprintf('-->tbsize=%d, modulation=%d mode=%s alloc = %s\n', pdsch_tbsize_orig, pdsch_Qm, pdsch_mode, sprintf('%d ', pdsch_VRB_list));
                        else
                            fprintf('Unknown DCI format length = %d\n', pdcch_tb_size);
                        end
                        
                        %check if there is a transport block
                        
                        if (pdsch_tbsize < 0)
                            continue;
                        end
                        
                        %if single antenna, there's no choice but to use
                        %single antenna, but it was already equaliser
                        %earlier
                        if (antenna_config_to_num_antennas(antenna_config) == 1)
                            %FIX ME - optimise the single antenna case as
                            %well into 'on demand' equalisation
                        else
                            if (strcmp(pdsch_mode,'txd'))
                                % equalise in the rest
                                slot0_eq = lte_slot_equalise_txd_partial(slot0_eq,slot0_kvs,slot0_est,NDLRB,ncellid,subframe*2+0,ncp, [pdcch_nsymbols:nsymbols-1]);
                                slot1_eq = lte_slot_equalise_txd_partial(slot1_eq,slot1_kvs,slot1_est,NDLRB,ncellid,subframe*2+1,ncp, [0:nsymbols-1]);                                 
                            elseif (strcmp(pdsch_mode,'1layermimo'))
                                slot0_eq = lte_slot_equalise_singlelayermimo_partial(slot0_eq,slot0_kvs,slot0_est,NDLRB,ncellid,subframe*2+0,ncp, pdsch_codebook, [pdcch_nsymbols:nsymbols-1]);
                                slot1_eq = lte_slot_equalise_singlelayermimo_partial(slot1_eq,slot1_kvs,slot1_est,NDLRB,ncellid,subframe*2+1,ncp, pdsch_codebook, [0:nsymbols-1]);     
                            else
                                fprintf('Unsupported transmission mode: %s, skipping\n', pdsch_mode);
                                continue;
                            end
                        end
                        
                        pdsch_symbols = lte_extract_prbs(slot0_eq,slot1_eq,NDLRB, pdsch_VRB_list , ncellid, subframe*2, ncp, tdd, ...
                        antenna_config_to_num_antennas(antenna_config), pdcch_nsymbols, pdsch_Qm, PB);

                        figure(6);
                        plot(pdsch_symbols, '+');
                       
                        if (pdsch_Qm == 2)
                            pdsch_softbits_sc = lte_demod_soft_qpsk(pdsch_symbols);
                        else
                            pdsch_softbits_sc = lte_demod_soft_qam(pdsch_symbols, pdsch_Qm, antenna_config_to_num_antennas(antenna_config), pdsch_mode, PA_dB);
                        end
                        pdsch_softbits = pdsch_softbits_sc .* (1-2*lte_pdsch_seq(rnti, 0, ncellid, subframe*2, length(pdsch_softbits_sc)));
                        
                        
                        %compute the codeword sizes
                        %we only support 1 layer for MIMO modes, but Tx
                        %diversity nlayers = num antennas
                        if (strcmp(pdsch_mode,'txd'))
                            transportblocklayers = antenna_config_to_num_antennas(antenna_config);
                        else
                            transportblocklayers = 1;
                        end
                        pdsch_codeblocks_soft = lte_codeblock_deconcat(pdsch_softbits,transportblocklayers , pdsch_Qm, pdsch_tbsize);
                        pdsch_codeblocks_sizes = lte_compute_codeblocksize(pdsch_tbsize);
                        fprintf(1, '-->Resource: [%s]\n   pdsch_tbsize: %d (codeblocks input = %s output = %s) coderate=%.3f\n', ...
                            sprintf('%d ', pdsch_VRB_list), pdsch_tbsize, ...
                            sprintf('%d ', pdsch_codeblocks_sizes), ...
                            sprintf('%d ', cellfun('length', pdsch_codeblocks_soft)), (pdsch_tbsize+24)/(length(pdsch_softbits)));
                        
                        %decode each codeblock. No stop early.
                        
                        pdsch_tb_hardbits = [];
                        turbo_errs = [];
                        
                        for c= 0:length(pdsch_codeblocks_sizes)-1,
                            
                            pdsch_softbuffer = zeros(1,3*(pdsch_codeblocks_sizes(c+1)+4)); 
                            pdsch_softbuffer = lte_turbo_deratematch(pdsch_softbuffer, 1e6, pdsch_RV, pdsch_codeblocks_soft{c+1});
                            pdsch_hardbits = lte_turbo_decode_matlab(-pdsch_softbuffer);
                            if (length(pdsch_codeblocks_sizes) > 1)
                                %there is multiple codeblock and hence each
                                %CB has CRC
                                pdsch_codeblock_crc = pdsch_hardbits(end-23:end);
                                pdsch_codeblock_crc_calc = lte_crc(pdsch_hardbits(1:end-24), crcpoly24B);
                                
                                %estimate turbo errs
                                %hack to handle punctured bits, chances of
                                %equalling zero are low with real data
                                punctured_indices = find(pdsch_softbuffer == 0);
                                turbo_errs_indices = find(lte_turbo_encode(pdsch_hardbits, length(pdsch_hardbits)) ~= (pdsch_softbuffer < 0));
                                turbo_errs_indices = setdiff(turbo_errs_indices, punctured_indices);
                                
                                if (sum(abs(pdsch_codeblock_crc - pdsch_codeblock_crc_calc)) == 0)
                                    fprintf(1,'----->codeblock %d: CRC OK turbo errs (%d) = %s\n', c, length(turbo_errs_indices), sprintf('%d ', turbo_errs_indices));
                                else
                                    fprintf(1,'----->codeblock %d: CRC FAIL turbo errs (%d) = %s\n', c, length(turbo_errs_indices), sprintf('%d ', turbo_errs_indices));
                                end

                                %strip the codeblock CRC
                                pdsch_hardbits = pdsch_hardbits(1:end-24);
       
                            else
                                punctured_indices = find(pdsch_softbuffer == 0);
                                turbo_errs_indices = find(lte_turbo_encode(pdsch_hardbits, length(pdsch_hardbits)) ~= (pdsch_softbuffer < 0));
                                turbo_errs_indices = setdiff(turbo_errs_indices, punctured_indices);
                                if (length(turbo_errs_indices) > 0)
                                    fprintf('----->Turbo errors: (%d) %s\n', length(turbo_errs_indices), sprintf('%d ', turbo_errs_indices));
                                end
                            end
                            pdsch_tb_hardbits = [pdsch_tb_hardbits pdsch_hardbits];
                            
                        end
%                         pdsch_softbuffer = zeros(1,3*(pdsch_tbsize+24+4));
%                         pdsch_softbuffer = lte_turbo_deratematch(pdsch_softbuffer, 1e6, pdsch_RV, pdsch_softbits);
%                         pdsch_hardbits = lte_turbo_decode_matlab(-pdsch_softbuffer);
%                         pdsch_crc = pdsch_hardbits(pdsch_tbsize+1:pdsch_tbsize+24);
%                         pdsch_calc_crc = lte_crc(pdsch_hardbits(1:pdsch_tbsize), crcpoly24A);

                        %test the total CRC
                        pdsch_tb_crc = pdsch_tb_hardbits(end-23:end);
                        pdsch_tb_calc_crc = lte_crc(pdsch_tb_hardbits(1:end-24), crcpoly24A);




                        if (sum(abs(pdsch_tb_crc - pdsch_tb_calc_crc)) == 0)

                            fprintf(1,'-->CRC OK,!\n');

                            str = sprintf('%s\\frame%d_%d_rnti%d.bin',path, frame_no,subframe,rnti);
                            %write stripping CRC
                            umts_write_bitstring_file(str, pdsch_tb_hardbits(1:end-24));
                        else
                                fprintf(1,'-->BAD CRC\n');
                                                        
                            continue;
                            
                        end    

                        if (find(RA_RNTI == rnti))
                            RAR_E = 1;
                            RAR_RAPID = -1;
                            RAR_BI = -1;
                            num_RAR_payloads = 0;

                            nextfield = 1;
                            while (RAR_E == 1)
                                RAR_E = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+1-1));
                                nextfield = nextfield + 1;
                                RAR_T = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+1-1));
                                nextfield = nextfield + 1;

                                if (RAR_T == 1) %RAPID
                                    RAR_RAPID = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+6-1));
                                    nextfield = nextfield + 6;
                                    num_RAR_payloads = num_RAR_payloads + 1;
                                    fprintf(1,'RAR: RAPID=%d\n', RAR_RAPID);
                                else
                                    nextfield = nextfield + 2;
                                    RA_BI = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+4-1));
                                    nextfield = nextfield + 4;
                                    fprintf(1,'RAR: BI=%d\n', RAR_BI);
                                end
                            end
                            fprintf(1,'RAR: num payloads = %d\n', num_RAR_payloads);

                            if (num_RAR_payloads * 6*8 + (nextfield-1) > pdsch_tbsize)
                                fprintf(1,'RAR: header size = %d, num payloads = %d but pdsch_tbsize only %d, error, skip\n',...
                                    nextfield, num_RAR_payloads, pdsch_tbsize);
                                continue;
                            end

                            for i=0:num_RAR_payloads-1,
                                nextfield = nextfield + 1; %skip reserved
                                RAR_TA = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+11-1));
                                nextfield = nextfield + 11;
                                RAR_ULgrant = (pdsch_tb_hardbits(nextfield:nextfield+20-1));
                                nextfield = nextfield + 20;
                                RAR_TCRNTI = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+16-1));
                                nextfield = nextfield + 16;
                                
                                ULGrant_hop = RAR_ULgrant(1:1);
                                ULGrant_resource = RAR_ULgrant(2:11);
                                ULGrant_resource_val = dab_binval(ULGrant_resource);
                                ULGrant_mcs = dab_binval(RAR_ULgrant(12:15));
                                ULGrant_tpc = dab_binval(RAR_ULgrant(16:18));
                                ULGrant_uldelay = RAR_ULgrant(19:19);
                                ULGrant_cqireq = RAR_ULgrant(20:20);
                                
                                ULGrant_VRBs = [];
                                if (NDLRB<=44 || ULGrant_hop == 0)
                                    [RBstart LCrbs] = lte_riv_to_range_1a1b1d(NDLRB, ULGrant_resource_val);
                                    ULGrant_VRBs = RBstart:RBstart+LCrbs-1;
                                else
                                    % not supportd
                                end
                                        
                                
                                [pusch_Qm, pusch_Itbs] = lte_compute_Qm_Itbs_uplink(ULGrant_mcs);
                                pusch_tbsize = lte_compute_tbsize(length(ULGrant_VRBs), pusch_Itbs);
                                
                                fprintf('RAR payload %d: TA = %d, ULGrant=%d, TCRNTI=%d\n', i, RAR_TA, ULGrant_resource_val, RAR_TCRNTI);
                                fprintf('ULGrant: hop=%d, resource=%s, mcs=%d, tpc=%d, uldelay=%d, cqireq=%d, tbsize=%d\n', ...
                                    ULGrant_hop,sprintf('%d ', ULGrant_VRBs), ULGrant_mcs, ULGrant_tpc, ULGrant_uldelay, ULGrant_cqireq, pusch_tbsize);
                                

                                if (isempty((find(Extra_RNTIs == RAR_TCRNTI)))),
                                    fprintf('new T_CRNTI = %d, adding\n', RAR_TCRNTI);
                                    %temporarily add it to here as well
                                    %for the rest of the frame
                                    Extra_RNTIs = [Extra_RNTIs RAR_TCRNTI];
                                    NewRNTIS = [NewRNTIS RAR_TCRNTI]; %add to the search list

                                end
                            end

                        elseif (~isempty(find(Extra_RNTIs == rnti))) %normal MAC SDU on CCCH or DCCH

                            nextfield = 1;
                            MAC_E = 1;
                            MAC_LCIDs = [];
                            MAC_lengths_octets = [];
                            MAC_control_LCID_types = [28 29 30];
                            MAC_control_LCID_lengths_octets = [6 1 0]; %contention, Timing advance, DRX command

                            while (MAC_E == 1)

                                nextfield = nextfield + 2; %skip reserved
                                MAC_E = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+1-1));
                                nextfield = nextfield + 1;
                                MAC_LCID = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+5-1));
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
                                    MAC_length_bits = (pdsch_tbsize - (nextfield - 1) - sum(MAC_lengths_octets)*8);

                                    assert(MAC_length_bits >= 0);
                                    assert(mod(MAC_length_bits, 8) == 0);

                                    MAC_lengths_octets = [MAC_lengths_octets MAC_length_bits/8]; 
                                    continue;
                                end

                                MAC_L = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+1-1));
                                nextfield = nextfield + 1;
                                MAC_length_length = 7 + MAC_L*8;
                                MAC_length = dab_binval(pdsch_tb_hardbits(nextfield:nextfield+MAC_length_length-1));
                                nextfield = nextfield + MAC_length_length;

                                MAC_lengths_octets = [MAC_lengths_octets MAC_length];

                            end

                            %now go thru the PDUs
                            for i=1:length(MAC_LCIDs),
                                LCID = MAC_LCIDs(i);
                                MAC_length_octets = MAC_lengths_octets(i);
                                MAC_data = pdsch_tb_hardbits(nextfield:nextfield+MAC_length_octets*8-1);
                                nextfield = nextfield + MAC_length_octets*8;
                                fprintf('LCID %d, length %d\n', LCID, MAC_length_octets);

                                if (LCID == 28) %contention resolution
                                    UEID = dab_binval(MAC_data);
                                    fprintf(1,'-->Contention Resolution UE ID = %08X\n', UEID);
                                elseif (LCID == 29)
                                    TAcmd = dab_binval(MAC_data(3:8));
                                    fprintf(1, '-->TA command %d (delta: %d*16=%dmetres round trip)\n', TAcmd, TAcmd-31, (TAcmd-31)*16/30.72e6*3e8);                                        
                                elseif (LCID == 30) % DRX COMMAND
                                    fprintf(1, '-->DRX Command\n');
                                elseif (LCID == 31)
                                    fprintf(1, '-->Padding\n');
                                elseif (LCID <= 10) %CCCH or DCCH
                                    str = sprintf('%s\\frame%d_%d_rnti%d_MACSDU%d_LCID%d.bin',path, frame_no,subframe,rnti, (i-1), LCID );
                                    fprintf(1, '-->CCCH/DCCH data written to disk file %s\n', str);
                                    umts_write_bitstring_file(str, MAC_data);
                                    
                                    %force AM mode for now.
                                    lte_dump_rlc(path, frame_no,subframe,rnti, (i-1), LCID, 1, -1, MAC_data);
                                    
                                else
                                    fprintf(1', '-->Unknown LCID\n');
                                end

                            end

                        end
                                                if (pdcch_tb_size == DCI_FORMAT_2A_LEN)
                            x = 3;
                                                end
                        
                    end
                end
            end
        end
    

    end
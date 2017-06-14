function lte_dump_rlc(path, frame, subframe, rnti, macsdu, lcid, am_mode, um_seq_bits, payload)

    if (lcid == 0)
        return; %transparent RLC, the MAC layer will dump this.
    end
    
    if (~am_mode)
        return; %not support
    end
    
    assert(mod(length(payload),8) == 0);
    
    nextfield = 1;
    am_DC = payload(nextfield:nextfield+1-1);
    nextfield = nextfield + 1;
    
    if (am_DC == 0) %control PDU
        am_CPT = dab_binval(payload(nextfield:nextfield+3-1));
        nextfield = nextfield + 3;
        
        if (am_CPT ~= 0)
            fprintf(1,'RLC--> control PDU CPT type %d unknown, skipping\n', am_CPT);
            return;
        end
        
        am_ACK_SN = dab_binval(payload(nextfield:nextfield+10-1));
        nextfield = nextfield + 10;
        am_E1 = payload(nextfield:nextfield+1-1);
        nextfield = nextfield + 1;
        am_E2 = 0;
        
        %get the NACKs, if any
        fprintf(1,'RLC--> STATUS PDU ACK SN = %d\n', am_ACK_SN);
        
        while (am_E1)
            am_NACK_SN = dab_binval(payload(nextfield:nextfield+10-1));
            nextfield = nextfield + 10;
            am_E1 = payload(nextfield:nextfield+1-1);
            nextfield = nextfield + 1;
            am_E2 = payload(nextfield:nextfield+1-1);
            nextfield = nextfield + 1;
            
            if (am_E2)
                am_SOstart = dab_binval(payload(nextfield:nextfield+15-1));
                nextfield = nextfield + 15;
                am_SOend = dab_binval(payload(nextfield:nextfield+15-1));
                nextfield = nextfield + 15;                
            end
            
            if (am_E2)
                fprintf(1,'RLC----->NACK_SN=%d SOstart=%d SOend=%d\n', am_NACK_SN, am_SOstart, am_SOend);
            else 
                fprintf(1,'RLC----->NACK_SN=%d\n', am_NACK_SN);
            end
        end
    else %data PDU
        am_RF = payload(nextfield:nextfield+1-1);
        nextfield = nextfield + 1;
        am_P = payload(nextfield:nextfield+1-1);
        nextfield = nextfield + 1;
        am_FI = dab_binval(payload(nextfield:nextfield+2-1));
        nextfield = nextfield + 2;
        am_E = payload(nextfield:nextfield+1-1);
        nextfield = nextfield + 1;     
        am_SN = dab_binval(payload(nextfield:nextfield+10-1));
        nextfield = nextfield + 10;
        
        AM_sdu_sizes = [];
        
        %handle PDU segment
        if (am_RF)
            am_LSF = payload(nextfield:nextfield+1-1);
            nextfield = nextfield + 1;  
            am_SO = dab_binval(payload(nextfield:nextfield+15-1));
            nextfield = nextfield + 15;
        end
        %handle data[]
        
        while (am_E)
            
            am_E = payload(nextfield:nextfield+1-1);
            nextfield = nextfield + 1; 
            am_LI = dab_binval(payload(nextfield:nextfield+11-1));
            nextfield = nextfield + 11;
            
            AM_sdu_sizes = [AM_sdu_sizes am_LI];
            
        end
        
        %adjust for the 4-bit alignment
        if (mod(length(AM_sdu_sizes),2) == 1)
            nextfield = nextfield + 4;
        end
        %nextfield is end of header
        %add the last
        assert(mod(nextfield-1,8) == 0);
        AM_sdu_sizes = [AM_sdu_sizes length(payload)/8-(nextfield-1)/8-sum(AM_sdu_sizes)];
        
        frame_types = {'complete upper layer SDU (1:1)', 'first chunk of upper layer SDU', 'last chunk of upper layer SDU', 'middle chunk of upper layer SDU'};
        frame_firstsdu_complete = [1 1 0 0 ];
        frame_lastsdu_complete = [1 0 1 0];
        
        if (am_RF)
            fprintf(1,'RLC AMD PDU segment------>SN=%d, LSF=%d SO=%d poll=%d, FI=%s sdu sizes = %s\n', am_SN, am_LSF, am_SO, am_P, frame_types{am_FI+1}, sprintf('%d ', AM_sdu_sizes));
        else
            fprintf(1,'RLC AMD PDU------>SN=%d, poll=%d, FI=%s sdu sizes = %s\n', am_SN, am_P, frame_types{am_FI+1}, sprintf('%d ', AM_sdu_sizes));
            
            for sdu = 1:length(AM_sdu_sizes),
                if (sdu == 1 && frame_firstsdu_complete(am_FI+1) ~= 1)
                    fprintf(1,'The first SDU is not complete, cannot dump it out with stateless AM decoder\n');
                    
                elseif (sdu == length(AM_sdu_sizes) && frame_lastsdu_complete(am_FI+1) ~= 1)
                    fprintf(1,'The last SDU is not complete, cannot dump it out with stateless AM decoder\n');
                    ;
                else
                    str = sprintf('%s\\frame%d_%d_rnti%d_MACSDU%d_LCID%d_rlcsdu%d.bin',path, frame,subframe,rnti, macsdu, lcid, sdu );
                    fprintf(1,'Dumping SDU %d size=%d to disk file %s\n', sdu, AM_sdu_sizes(sdu), str ); 
                    umts_write_bitstring_file(str, payload(nextfield:nextfield+AM_sdu_sizes(sdu)*8-1));
                    %assume MAC-I is always present regardless of ciphering
                    %TS 36.321 6.3.4
                    
                    pdcp_payload = payload(nextfield:nextfield+AM_sdu_sizes(sdu)*8-1);
                    if (lcid <= 2) %SRB
                        
                        pdcp_R = pdcp_payload(1:3);
                        pdcp_SN = dab_binval(pdcp_payload(4:8));
                        pdcp_body = pdcp_payload(9:end-32);
                        pdcp_MAC = dab_binval(pdcp_payload(end-31:end));
                        fprintf(1,'-------->PDCP SN=%d MAC=0x%08X\n', pdcp_SN, pdcp_MAC);
                        str = sprintf('%s\\frame%d_%d_rnti%d_MACSDU%d_LCID%d_rlcsdu%d_pdcp%d.bin',path, frame,subframe,rnti, macsdu, lcid, sdu, pdcp_SN );
                        umts_write_bitstring_file(str, pdcp_body);
                    else %DRB; assume 12 bit s/n
                        pdcp_DC = pdcp_payload(1); %handle later, just assume D for now
                        if (pdcp_DC == 0)
                            pdcp_PDUtype = dab_binval(pdcp_payload(2:4));
                            if (pdcp_PDUtype == 0)
                                pdcp_FMS = dab_binval(pdcp_payload(5:16));
                                pdcp_bitmap = [];
                                if (length(pdcp_payload) > 16)
                                    pdcp_bitmap = pdcp_payload(17:end);
                                end
                                fprintf('-------->PDCP Status report FMS=%d, bitmap = %s\n', pdcp_FMS, sprintf('%d ', pdcp_bitmap));
                            else
                                fprintf('-------->Unknown control PDU type %d\n', pdcp_PDUtype);
                            end
                            
                        else
                            pdcp_R = pdcp_payload(2:4);
                            pdcp_SN = dab_binval(pdcp_payload(5:16));
                            pdcp_body = pdcp_payload(17:end-32);
                            pdcp_MAC = dab_binval(pdcp_payload(end-31:end));
                            fprintf(1,'-------->PDCP SN=%d MAC=0x%08X\n', pdcp_SN, pdcp_MAC);
                            str = sprintf('%s\\frame%d_%d_rnti%d_MACSDU%d_LCID%d_rlcsdu%d_pdcp%d.bin',path, frame,subframe,rnti, macsdu, lcid, sdu, pdcp_SN );
                            umts_write_bitstring_file(str, pdcp_body);
                        end
                    end
                        
                end
                %move to the next SDU
                nextfield = nextfield + AM_sdu_sizes(sdu)*8;
            end
        end
        
        
        
    end
end
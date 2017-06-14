function phich_indices = lte_phich_indices( NDLRB, ncellid, pcfich_indices, ncp, tdd, tdd_config, subframe, num_tx_antennas, phich_config_ng, phich_extended, pcfich_value)
%return the k-offset relative to the NDLRB of the start of each PHICH REG
%allowing for the possibility of extended PHICH duration

   
   %compute the number of symbols used for the control region and the PHICH
   if (phich_extended) 
       control_symbols = 3; %ext phich duration, minimum 3 symbols
       if (tdd && (subframe == 1 || subframe == 6))
           phich_symbols = 2;
       else
           phich_symbols = 3;
       end
   else
       control_symbols = pcfich_value; %use the value signalled by PCFICH
       phich_symbols = 1;
   end
   
   KMAX = NDLRB * 12;
   
   %list of REGs for each symbol
   AVAIL_REGS = cell(1,control_symbols);
   
   for l=0:control_symbols-1,
       if (lte_symbol_is_reference(l,ncp,num_tx_antennas))
           AVAIL_REGS{l+1} = 0:6:NDLRB*12-1; %reference symbols - 4 symbols per REG, aligned to 6
       else
           AVAIL_REGS{l+1} = 0:4:NDLRB*12-1; %non reference symbols, 4 symbols per REG, aligned to 4
       end
   end
   
   %remove from the first symbol the PCFICH REGS
   AVAIL_REGS{1} = sort(setdiff(AVAIL_REGS{1}, pcfich_indices));

   %now map according to algorithm

   mapping_units = ceil(phich_config_ng*NDLRB/8); %for ext cyc prefix, its double, then divided by 2, so same
   
   TDD_mi = [ [ 02 01 -1 -1 -1 02 01 -1 -1 -1]; ... %config0
              [ 00 01 -1 -1 01 00 01 -1 -1 01]; ...
              [ 00 00 -1 01 00 00 00 -1 01 00]; ...
              [ 01 00 -1 -1 -1 00 00 00 01 01]; ...
              [ 00 00 -1 -1 00 00 00 00 01 01]; ...
              [ 00 00 -1 00 00 00 00 00 01 00]; ...
              [ 01 01 -1 -1 -1 01 01 -1 -1 01]];
   if (tdd)
      
       m_i = TDD_mi(tdd_config+1, subframe+1);
       
       mapping_units  = m_i * mapping_units;
       
   end
   
   phich_regs = zeros(1,mapping_units*3);
   
   for mapping_unit = 0:mapping_units-1,
       for i=0:2,
           if (tdd && (subframe == 1 || subframe == 6) && phich_extended) %very specific case for the switchpoint frames
                l_i = mod(floor(mapping_unit/2)+i+1, 2);
           else 
                l_i = mod(i,phich_symbols); % = 0 for normal phich duration, else 3 for extended
           end
           n_l_i = length(AVAIL_REGS{l_i+1});
           n_0 = length(AVAIL_REGS{0+1}); %length of symbol 0

           
           if (tdd && (subframe == 1 || subframe == 6) && phich_extended) %very specific case for the switchpoint frames
                n_1 = length(AVAIL_REGS{1+1});
                n_i = mod(floor(ncellid * n_l_i/n_1) + mapping_unit + floor(i*n_l_i/3), n_l_i);
           else    
                n_i = mod(floor(ncellid * n_l_i/n_0) + mapping_unit + floor(i*n_l_i/3), n_l_i);
           end
           
           %PHICH_REGS{l_i+1} = [PHICH_REGS{l_i+1} AVAIL_REGS{l_i+1}(n_i+1)];
           phich_regs(mapping_unit*3+i+1) = AVAIL_REGS{l_i+1}(n_i+1) + l_i * KMAX;
       end
   end
   phich_indices = phich_regs;
   

end


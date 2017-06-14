function pdcch_kindices = lte_pdcch_kindices( NDLRB, ncellid, pcfich_indices, phich_kindices, ncp, num_tx_antennas, phich_extended, pcfich_value)
%return the k-offset relative to the NDLRB of the start of each PDCCH REG
%allowing for the possibility of extended PHICH duration
%in order

   %compute the number of symbols used for the control region and the PHICH
   if (phich_extended) 
       control_symbols = 3; %ext phich duration, minimum 3 symbols
       phich_symbols = 3;
   else
       control_symbols = pcfich_value; %use the value signalled by PCFICH
       phich_symbols = 1;
   end
   
   KMAX = NDLRB * 12;
   
   %list of REGs for each symbol
   AVAIL_REGS = cell(1,control_symbols);
   
   reg_alignment = zeros(1,control_symbols);
   
   for l=0:control_symbols-1,
       if (lte_symbol_is_reference(l,ncp,num_tx_antennas))
           AVAIL_REGS{l+1} = 0:6:NDLRB*12-1; %reference symbols - 4 symbols per REG, aligned to 6
           reg_alignment(l+1) = 6;
       else
           AVAIL_REGS{l+1} = 0:4:NDLRB*12-1; %non reference symbols, 4 symbols per REG, aligned to 4
           reg_alignment(l+1) = 4;
       end
   end
   
   %remove the PCFICH kindices
   AVAIL_REGS{1} = sort(setdiff(AVAIL_REGS{1}, pcfich_indices));
   %remove the PHICH
   NREG = 0;
   for l=0:control_symbols-1,
       %find the used phich this symbol
       idx = find (phich_kindices >= l*KMAX & phich_kindices < (l+1)*KMAX);
       AVAIL_REGS{l+1} = sort(setdiff(AVAIL_REGS{l+1}, mod(phich_kindices(idx), KMAX)));
       NREG = NREG + length(AVAIL_REGS{l+1});
   end
   
   pdcch_kindices = zeros(1,NREG);
   m = 0;
   k = 0;
   for(k=0:2:KMAX-1)
       for (l=0:control_symbols-1),
          if (mod(k,reg_alignment(l+1)) == 0 && length(find(AVAIL_REGS{l+1} == k))) %if the resource element k,l represents a REG and is NOT used for PCFICH/PHICH
              %fprintf (1, '%d,%d is next\n',k,l);
              pdcch_kindices(m+1) = l*KMAX + k;
              m = m+1;
          end
       end
   end
   
end


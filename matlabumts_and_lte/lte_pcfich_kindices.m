function pcfich_kindices = lte_pcfich_kindices( NDLRB, ncellid)
%return the k-offset relative to the NDLRB of the start of each PCFICH REG,
%in order of mapping

  
   pcfich_kindices = [0 floor(1*NDLRB/2)*6 floor(2*NDLRB/2)*6 floor(3*NDLRB/2)*6];
   
   kprime = (12/2) * mod(ncellid, 2*NDLRB);
   
   pcfich_kindices = mod(pcfich_kindices + kprime, NDLRB*12);
   
   
end


function pcfich_indices = lte_pcfich_indices( NDLRB, ncellid)
%no interpolation of symbols, just copy for now

   pcfich_indices = [0:0+5 floor(NDLRB/2)*6:floor(NDLRB/2)*6+5 2*floor(NDLRB/2)*6:2*floor(NDLRB/2)*6+5 3*floor(NDLRB/2)*6:3*floor(NDLRB/2)*6+5];
   
   kprime = (12/2) * mod(ncellid, 2*NDLRB);
   
   pcfich_indices = mod(pcfich_indices + kprime, NDLRB*12);
   
   pcfich_indices = pcfich_indices + (110-NDLRB)/2*12;

   
   %exclude ref sigs
   pcfich_indices=(pcfich_indices(find (mod(pcfich_indices,3) ~= mod(ncellid,3))));
   
   
end





function pbch = lte_pbch_encode( frameno_div_4, NDLRB, PHICH_DURATION, PHICH_RESOURCE)
 

    PHICH_DURATION_LIST = [0 1];
    PHICH_RESOURCE_LIST = [1/6 1/2 1.0 2.0];

    DL_BANDWIDTH_LIST = [6 15 25 50 75 100];
    
    crcpoly=[1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
    
    pbch_bits = zeros(1,24);
    
    phich_duration = find (PHICH_DURATION_LIST == PHICH_DURATION) - 1;
    phich_resource = find (PHICH_RESOURCE_LIST == PHICH_RESOURCE) - 1;
    dl_bandwidth = find(DL_BANDWIDTH_LIST == NDLRB) - 1;
    
    pbch_bits(1:3) = lte_dec_to_binstring(dl_bandwidth, 3);
    pbch_bits(4:4) = lte_dec_to_binstring(phich_duration, 1);
    pbch_bits(5:6) = lte_dec_to_binstring(phich_resource, 2);
    pbch_bits(7:14) = lte_dec_to_binstring(frameno_div_4, 8);
   
    pbch_crc = lte_crc(pbch_bits, crcpoly);
    
    pbch_crc = pbch_crc + zeros(1,16); %single antenna case
    
    pbch = [pbch_bits pbch_crc];
 
end
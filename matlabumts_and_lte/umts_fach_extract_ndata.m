function data_softbits = umts_fach_extract_ndata( FACH_softbits, TFCI_bits_slot )

    FACH_bits_slot = length(FACH_softbits)/15;
    data_bits_slot = FACH_bits_slot-TFCI_bits_slot
    data_softbits = zeros(1,data_bits_slot*15);

    for i = 1:15
        data_softbits(1+(i-1)*data_bits_slot:data_bits_slot+(i-1)*data_bits_slot) = ...
            FACH_softbits(TFCI_bits_slot+1+(i-1)*FACH_bits_slot:FACH_bits_slot+(i-1)*FACH_bits_slot);
    end
        

end


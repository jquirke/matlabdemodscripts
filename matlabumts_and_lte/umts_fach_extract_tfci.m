function tfci_softbits = umts_fach_extract_tfci( FACH_softbits, TFCI_bits_slot )

    tfci_softbits = zeros(1,TFCI_bits_slot*15);
    FACH_bits_slot = length(FACH_softbits)/15;
    for i = 1:15
        tfci_softbits(1+(i-1)*TFCI_bits_slot:TFCI_bits_slot+(i-1)*TFCI_bits_slot) = FACH_softbits(1+(i-1)*FACH_bits_slot:TFCI_bits_slot+(i-1)*FACH_bits_slot);
    end
        

end


function demod_softbits = lte_demod_soft_qpsk( qpsk_symbols )

    demod_softbits = zeros(1,length(qpsk_symbols)*2);
    
    demod_softbits(0+1:2:end) = real(qpsk_symbols);
    demod_softbits(1+1:2:end) = imag(qpsk_symbols);

end
function demod_softbits = lte_demod_soft_bpsk( bpsk_symbols )

    demod_softbits = real(bpsk_symbols) + imag(bpsk_symbols);

end
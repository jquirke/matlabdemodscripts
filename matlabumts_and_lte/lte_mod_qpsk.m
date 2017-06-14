function mod_syms = lte_mod_qpsk( hardbits)

    %NaN is a NIL (0 power) symbol
    
    mod_syms = 1-2*hardbits(1:2:end) + 1i*(1-2*hardbits(2:2:end));
    nan_bitmap = (isnan(mod_syms));
    
    mod_syms(find(nan_bitmap == 1)) = 0;
    mod_syms = mod_syms .* (1-isnan(mod_syms)); %NIL symbols

end
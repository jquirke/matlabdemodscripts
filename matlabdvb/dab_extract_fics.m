%contains only the symbols containing the FIC
function fics = dab_extract_fics(pframe_ficsyms, softbits_per_FIC)
    [rows cols] = size(pframe_ficsyms);
    fics = transpose(reshape(transpose(pframe_ficsyms), softbits_per_FIC, rows*cols/softbits_per_FIC));
end
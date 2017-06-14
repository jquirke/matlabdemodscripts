%contains only the symbols containing the FIC
function cifs = dab_extract_cifs(pframe_ficsyms, softbits_per_CIF)
    [rows cols] = size(pframe_ficsyms);
    cifs = transpose(reshape(transpose(pframe_ficsyms), softbits_per_CIF, rows*cols/softbits_per_CIF));
end
function dab_parse_fig0_14(bytes)
    [nbytes bits_per_bytes] = size(bytes);
   
    cn=dab_binval(bytes(1,1));
    oe=dab_binval(bytes(1,2));
    pd=dab_binval(bytes(1,3));
    ext=dab_binval(bytes(1,5));
    index=1;
    bodyleft=nbytes-1;

    while (index < nbytes)
        subchid=dab_binval(bytes(index+1,1:6));
        fecscheme=dab_binval(bytes(index+1,7:8));
        fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=14 subchid=%d fecscheme=%d\n', cn, oe, pd,  subchid,fecscheme);
      
        bodyleft = bodyleft - 1;
        index = index + 1;
    end
    
end
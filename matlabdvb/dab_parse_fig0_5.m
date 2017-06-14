function dab_parse_fig0_5(bytes)
    [nbytes bits_per_bytes] = size(bytes);
   
    cn=dab_binval(bytes(1,1));
    oe=dab_binval(bytes(1,2));
    pd=dab_binval(bytes(1,3));
    ext=dab_binval(bytes(1,5));
    index=1;
    bodyleft=nbytes-1;

    while (index < nbytes)
        if (bodyleft < 2)
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=5 inadequate amount of bytes left for next subch %d\n',cn,oe,pd);
            break;
        end
        ls=dab_binval(bytes(index+1,1));
        if (ls == 1)
            if (bodyleft < 3)
                fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=5 inadequate amount of bytes left for next subch %d\n',cn,oe,pd);
                break;
            end
            scid=dab_binval([bytes(index+1,5:8) bytes(index+1+1,:)]);
            lang=dab_binval(bytes(index+2+1,:));
        else
            mscfic=dab_binval(bytes(index+1,2));
            subchid=dab_binval(bytes(index+1,3:8));
            lang=dab_binval(bytes(index+1+1,:));
        end
        
        if (ls==1)
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=5 scid=%d lang=%d\n', cn, oe, pd,scid,lang);
        else
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=5 mscfic=%d subchidficid=%d, lang=%d\n', cn,oe,pd,mscfic, subchid, lang);
        end
        
        bodyleft = bodyleft - 2 -1*ls;
        index = index + 2 + 1*ls;
    end
    
end
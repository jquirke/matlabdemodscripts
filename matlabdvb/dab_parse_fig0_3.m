function dab_parse_fig0_3(bytes)
    [nbytes bits_per_bytes] = size(bytes);
   
    cn=dab_binval(bytes(1,1));
    oe=dab_binval(bytes(1,2));
    pd=dab_binval(bytes(1,3));
    ext=dab_binval(bytes(1,5));
    index=1;
    bodyleft=nbytes-1;

    while (index < nbytes)
        if (bodyleft < 5)
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=3 inadequate amount of bytes left for next subch %d\n',cn,oe,pd);
            break;
        end
        scid=dab_binval([bytes(index+1,:) bytes(index+1+1,1:4)]);
        caorgflg=dab_binval(bytes(index+1+1,8));
        dgflag=dab_binval(bytes(index+2+1,1));
        dscty=dab_binval(bytes(index+2+1,3:8));
        subchid=dab_binval(bytes(index+3+1,1:6));
        packetaddr=dab_binval([bytes(index+3+1,7:8) bytes(index+4+1,:)]);
        
        if (caorgflg==1)
            if (bodyleft < 7)
                fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=3 inadequate amount of bytes left for CAorg field %d\n',cn,oe,pd);
                break;
            end    
            caorg=dab_binval([bytes(index+5+1,:) bytes(index+6+1,:)]);            
        end

        if (caorgflg==1)
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=3 scid=%d caorgflg=%d dgflag=%d dscty=%d subchid=%d packetaddr=%d caorg=%d\n', cn,oe,pd,scid,caorgflg,dgflag,dscty,subchid,packetaddr,caorg);
        else
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=3 scid=%d caorgflg=%d dgflag=%d dscty=%d subchid=%d packetaddr=%d\n', cn,oe,pd,scid,caorgflg,dgflag,dscty,subchid,packetaddr);
        end
        bodyleft = bodyleft - 5 - 2*caorgflg;
        index = index + 5 + 2*caorgflg;
    end
    
end
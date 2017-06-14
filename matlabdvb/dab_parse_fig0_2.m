function dab_parse_fig0_2(bytes)
    [nbytes bits_per_bytes] = size(bytes);
   
    cn=dab_binval(bytes(1,1));
    oe=dab_binval(bytes(1,2));
    pd=dab_binval(bytes(1,3));
    ext=dab_binval(bytes(1,5));
    index=1;
    bodyleft=nbytes-1;
    minsizeperservice=(2+2*pd)+1;
    while (index < nbytes)
      
        tempidx = 0;
        
        if (bodyleft < minsizeperservice)
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=2 inadequate amount of bytes left\n',cn,oe,pd);
            break;
        end
        
        if (pd==1)
            sid=dab_binval([bytes(index+tempidx+1,:) bytes(index+tempidx+1+1,:) bytes(index+tempidx+2+1,:) bytes(index+tempidx+3+1,:) ]);
            tempidx = tempidx + 4;
        else
            sid=dab_binval([bytes(index+tempidx+1,:) bytes(index+tempidx+1+1,:)]);
            tempidx = tempidx + 2;
        end
        CAID=dab_binval(bytes(index+tempidx+1,2:4));
        nscomps=dab_binval(bytes(index+tempidx+1,5:8));
        tempidx=tempidx + 1;
        
        if ((bodyleft - tempidx) < 2*nscomps)
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=2 inadequate amount of bytes for all %d service components\n', cn,oe,pd,nscomps);
            break;
        end
        fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=2 sid=0x%08X CAID=%d nscomp=%d\n', cn,oe,pd,sid,CAID,nscomps);       
        for comp=0:nscomps-1,
            tmid=dab_binval(bytes(index+tempidx+1,1:2));
            PSflag=dab_binval(bytes(index+tempidx+1+1,7));
            CAflag=dab_binval(bytes(index+tempidx+1+1,8));          
            switch (tmid)
                case 0
                    ascty=dab_binval(bytes(index+tempidx+1,3:8));
                    subchid=dab_binval(bytes(index+tempidx+1+1,1:6));
                    fprintf('      component %d tmid=%d ascty=%d subchid=%d PSflag=%d CAflag=%d\n', comp,tmid,ascty,subchid,PSflag, CAflag);
                case 1
                    dscty=dab_binval(bytes(index+tempidx+1,3:8));
                    subchid=dab_binval(bytes(index+tempidx+1+1,1:6)); 
                    fprintf('      component %d tmid=%d dscty=%d subchid=%d PSflag=%d CAflag=%d\n', comp,tmid,dscty,subchid,PSflag, CAflag);
                case 2
                    dscty=dab_binval(bytes(index+tempidx+1,3:8));
                    fidcid=dab_binval(bytes(index+tempidx+1+1,1:6)); 
                    fprintf('      component %d tmid=%d dscty=%d fidcid=%d PSflag=%d CAflag=%d\n', comp,tmid,dscty,fidcid,PSflag, CAflag);
                case 3
                    scid=dab_binval([bytes(index+tempidx+1,3:8) bytes(index+tempidx+1+1,1:6)]);
                    fprintf('      component %d tmid=%d scid=%d PSflag=%d CAflag=%d\n', comp,tmid,scid,PSflag, CAflag);
            end

            tempidx = tempidx+2;
        end

        index = index+tempidx;
        bodyleft = bodyleft - tempidx;
        

    
end
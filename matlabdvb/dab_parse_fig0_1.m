function dab_parse_fib0_1(bytes)
    [nbytes bits_per_bytes] = size(bytes);
   
    cn=dab_binval(bytes(1,1));
    oe=dab_binval(bytes(1,2));
    pd=dab_binval(bytes(1,3));
    ext=dab_binval(bytes(1,5));
    index=1;
    bodyleft=nbytes-1;
    protlevelrates = [1/4 3/8 1/2 3/4 ; 4/9 4/7 4/6 4/5];
    while (index < nbytes)
        if (bodyleft < 3)
            fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=1 inadequate amount of bytes left for next subch %d\n');
            break;
        end
        subchid=dab_binval(bytes(index+1,1:6));
        startaddr=dab_binval( [bytes(index+1,7:8) bytes(index+1+1,:)]);
        shortlong=dab_binval(bytes(index+2+1,1));

        fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=1 subchid=%d startaddr=%d shortlong=%d ', cn, oe, pd,  subchid,startaddr,shortlong);
        if (shortlong == 1)
            if (bodyleft < 4)
                fprintf(1,'   FIG0: cn=%d oe=%d pd=%d ext=1 inadequate amount of bytes left for next subch %d\n');
                break;
            end
            option=dab_binval(bytes(index+2+1,2:4));
            protlevel=dab_binval(bytes(index+2+1,5:6));
            subchsize=dab_binval([bytes(index+2+1,7:8) bytes(index+3+1,:) ]);
            if (option == 1 || option == 0)
                optionidx = option;
                fprintf(1,'option=%d protlevel=%d size=%d rate=%0.2f bitrate=%.0fbps\n', option, protlevel, subchsize, protlevelrates(option+1,protlevel+1), 64/.024 * subchsize* protlevelrates(option+1,protlevel+1));
            else
                fprintf(1,'Invalid option value %d\n', option);
            end
        else
            tableswitch=dab_binval(bytes(index+2+1,2));
            tableindex=dab_binval(bytes(index+2+1,3:8));
            fprintf(1,'tableswitch=%d tableindex=%d\n', tableswitch, tableindex);
        end
        
        bodyleft = bodyleft - 3 - 1*shortlong;
        index = index + 3 + 1*shortlong;    
    end
    
end
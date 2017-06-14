function dab_parse_fib(fib)
    
    % transform into bytes
    FIBbytes=transpose(reshape(transpose(fib),8,32));
    offset = 0;
    while (offset <30)
        idx=offset+1;
        type=dab_binval(FIBbytes(idx,1:3));
        len=dab_binval(FIBbytes(idx,4:8));
        if (type == 7 && len == 31) % end marker
            %fprintf(1,'Offset %d: end marker\n', offset);
            return;
        end
        if (offset+1+len > 30)
            %fprintf(1,'Offset %d: Invalid FIG type %d - len %d exceeds FIB length\n', offset, type,len);
            return;
        end

        if (len > 0)
            switch (type)
                case 0
                    dab_parse_fig0(FIBbytes(idx+1:idx+len,:));
                case 1
                    dab_parse_fig1(FIBbytes(idx+1:idx+len,:));
                otherwise
                    fprintf(1,'Offset %d: Unknown FIG type = %d, len = %d\n', offset, type, len);
            end
        end
        offset = offset + 1 + len;
    end
end
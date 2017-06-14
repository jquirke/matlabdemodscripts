function frame_yp = dvb_freq_deint(frame_y, H, symbol_no )

    frame_yp = zeros(1,length(frame_y));
    if (mod(symbol_no, 2) == 0) % even symbol
        for q=0:length(frame_y)-1,
            frame_yp(q+1) = frame_y(H(q+1)+1);
        end
    else % odd symbol
        for q=0:length(frame_y)-1,
            frame_yp(H(q+1)+1) = frame_y(q+1);
        end
    end
        


end


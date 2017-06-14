
function [out, fb] = constituent_encoder_bw(in, K)
    % Define constraint length
    k = 4;

    % Initialize shift register
    for(n=0:k-1)
        s_reg(n+1) = 0;
    end

    g_array  = [1,1,0,1];
    fb_array = [0,0,1,1];

    for(n=0:K-1)
        % Sequence the shift register
        for(m=k:-1:2)
            s_reg(m) = s_reg(m-1);
        end

        % Calculate the feedback bit
        fb(n+1) = 0;
        for(m=0:k-1)
            fb(n+1) = fb(n+1) + s_reg(m+1)*fb_array(m+1);
        end
        fb(n+1) = mod(fb(n+1), 2);

        % Add the next bit to the shift register
        s_reg(1) = mod(fb(n+1) + in(n+1), 2);

        % Calculate the output bit
        out(n+1) = 0;
        for(m=0:k-1)
            out(n+1) = out(n+1) + s_reg(m+1)*g_array(m+1);
        end
        out(n+1) = mod(out(n+1), 2);
    end

    % Trellis termination
    for(n=K:K+3)
        % Sequence the shift register
        for(m=k:-1:2)
            s_reg(m) = s_reg(m-1);
        end

        % Calculate the feedback bit
        fb(n+1) = 0;
        for(m=0:k-1)
            fb(n+1) = fb(n+1) + s_reg(m+1)*fb_array(m+1);
        end
        fb(n+1) = mod(fb(n+1), 2);

        % Add the next bit to the shift register
        s_reg(1) = mod(fb(n+1) + fb(n+1), 2);

        % Calculate the output bit
        out(n+1) = 0;
        for(m=0:k-1)
            out(n+1) = out(n+1) + s_reg(m+1)*g_array(m+1);
        end
        out(n+1) = mod(out(n+1), 2);
    end
        end



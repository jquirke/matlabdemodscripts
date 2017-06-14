function demapped = dvb_test_hard_qpsk_demap(symbol)

%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


    points = [  3+3j 3+1j 1+3j 1+1j ...
                3-3j 3-1j 1-3j 1-1j ...
                -3+3j -3+1j -1+3j -1+1j ...
                -3-3j -3-1j -1-3j -1-1j ];
            
    bits = { [0 0 0 0] [0 0 0 1] [0 0 1 0] [0 0 1 1] ...
        [0 1 0 0] [0 1 0 1] [0 1 1 0] [0 1 1 1] ...
        [1 0 0 0] [1 0 0 1] [1 0 1 0] [1 0 1 1] ...
        [1 1 0 0] [1 1 0 1] [1 1 1 0] [1 1 1 1] };
    
    
   
    normfac = sqrt(( sum(abs(points).^2)/length(points) ));
    
    points = points / normfac;
    
    for carrier = 1:length(symbol)
        
        best = +inf;
        bestidx = -1;
        
        for qam = 1:length(points)
            if ( abs(symbol(carrier) - points(qam)) < best)
                best = abs(symbol(carrier) - points(qam));
                bestidx = qam;
            end
        end
        demapped(carrier,:) = cell2mat(bits(bestidx));
    end


    
end


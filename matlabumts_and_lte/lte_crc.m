function crc = lte_crc(data, poly)
    n=length(poly)-1;
    reg=zeros(1,n);

    for i=1:length(data),
        bit=mod(reg(1)+data(i),2); % msb^data
        reg(1:n-1)=reg(2:n); %shift left
        reg(n) = 0;
        if (bit == 1)
            reg = mod(reg+poly(2:n+1),2);
        end
    end

    %crc=mod(reg+1,2);
    crc=reg;
end

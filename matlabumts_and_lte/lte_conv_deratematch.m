function output = lte_conv_deratematch( softbuffer, D)
%instance of LTE conv deratematcher

    enclength = 3*D;
    output = zeros(1,enclength );
    
    
    remainder = mod(length(softbuffer),enclength );
    for i=0:floor(length(softbuffer)/enclength )-1;
        output = output + softbuffer(i*enclength +1:i*enclength +enclength ); %accumulate
    end
    %accumulate any remainder
    output(1:remainder) = output(1:remainder) + softbuffer(end-remainder+1:end);
    
%     %average
%     output(1:remainder) = output(1:remainder) .* 1/ceil(length(softbuffer)/enclength );
%     if (floor(length(softbuffer)/enclength ) > 0)
%         output(remainder+1:end) = output(remainder+1:end) .* 1/floor(length(softbuffer)/enclength );
%     end

    
end


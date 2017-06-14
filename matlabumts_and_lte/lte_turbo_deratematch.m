function softbuffer = lte_turbo_deratematch( softbuffer, Ncb, rv, inbits)
%instance of LTE conv deratematcher

    D = length(softbuffer)/3;
    E = length(inbits);

    %the map shows where bit i in the input data is mapped to in the
    %softbuffer

    pdsch_map = lte_compute_turbo_codeblock_RV_mapping(D, Ncb, E, rv);
    
    for i=1:length(pdsch_map),
        softbuffer(pdsch_map(i)) = (softbuffer(pdsch_map(i)) + inbits(i));
    end
    
%     %average
%     output(1:remainder) = output(1:remainder) .* 1/ceil(length(softbuffer)/enclength );
%     if (floor(length(softbuffer)/enclength ) > 0)
%         output(remainder+1:end) = output(remainder+1:end) .* 1/floor(length(softbuffer)/enclength );
%     end
  
end


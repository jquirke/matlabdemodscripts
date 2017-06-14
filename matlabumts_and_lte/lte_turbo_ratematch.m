function output = lte_turbo_ratematch( input, CircBufferSize, E, rv)
%turbo ratematchers

    indexes = lte_compute_turbo_codeblock_RV_mapping(length(input)/3, CircBufferSize, E, rv);
    
    output = input(indexes);
end


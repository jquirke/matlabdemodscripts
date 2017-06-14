function output = lte_conv_ratematch( input, E)
%instance of LTE conv ratematcher

    repetitions = floor(E/length(input));

    modulus = mod(E,length(input));
    output = repmat(input, 1, repetitions);
    output = [output input(1:modulus)];
    
end


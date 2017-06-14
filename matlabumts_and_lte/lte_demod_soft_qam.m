function demod_softbits = lte_demod_soft_qam( qam_symbols, Qm, num_tx_antennas, tmmode, PA_dB )


                                    
    if (Qm == 4)                              
        demod = comm.RectangularQAMDemodulator('ModulationOrder', 16, ...
                                                'BitOutput', true, ...
                                               'SymbolMapping', 'Custom', ...
                                               'DecisionMethod', 'Approximate log-likelihood ratio', ...
                                               'VarianceSource', 'Input port',  ...   
                                               'CustomSymbolMapping', [11 10 14 15   9 8 12 13   1 0 4 5   3 2 6 7], ...
                                               'NormalizationMethod', 'Minimum distance between symbols', ...
                                               'MinimumDistance', 2/sqrt(10) );
    elseif (Qm == 6)
        %assert (0); %trap for when it occurs
        
                                                       %used Excel and some regular
                                               %expressions to pull this
                                               %out of the spec. 
        demod = comm.RectangularQAMDemodulator('ModulationOrder', 64, ...
                                                'BitOutput', true, ...
                                               'SymbolMapping', 'Custom', ...
                                               'DecisionMethod', 'Approximate log-likelihood ratio', ...
                                               'VarianceSource', 'Input port', ...
                                               'CustomSymbolMapping', [47 46 42 43 59 58 62 63 45 44 40 41 57 56 60 61 37 36 32 33 49 48 52 53 39 38 34 35 51 50 54 55 7 6 2 3 19 18 22 23 5 4 0 1 17 16 20 21 13 12 8 9 25 24 28 29 15 14 10 11 27 26 30 31], ...
                                               'NormalizationMethod', 'Minimum distance between symbols', ...
                                               'MinimumDistance', 2/sqrt(42) );                                         
    end
    
    %normalize the power.
    
    ref_dB = PA_dB; 
    ref_factor = sqrt(10^(-ref_dB/10)); %power -> voltage factor
    
    qam_symbols = qam_symbols .* ref_factor;
    
    
    variance = 0.2; %FIXME
    demod_softbits = step(demod, qam_symbols.', variance).';
    
                                              
end
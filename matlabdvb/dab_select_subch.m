function subch_coded_data = dab_select_subch(CIFs, startcu, ncus)

    if (startcu >= 864 || startcu+ncus >= 864)
        subch_coded_data = [];
        return;
    end
    subch_coded_data=CIFs(:,startcu*64+1:(startcu+ncus)*64);
end
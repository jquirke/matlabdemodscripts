function [Qm Itbs] = lte_compute_Qm_Itbs_uplink( Imcs)

    Imcs_Qm_tab = [2 2 2 2 2 2 2 2 2 2 2 4 4 4 4 4 4 4 4 4 4 6 6 6 6 6 6 6 6 -1 -1 -1];
    Imcs_Itbs_tab = [0 1 2 3 4 5 6 7 8 9 9 10 11 12 13 14 15 15 16 17 18 19 20 21 22 23 24 25 26 -1 -1 -1];
    
    Qm = Imcs_Qm_tab(Imcs+1);
    Itbs = Imcs_Itbs_tab(Imcs+1);
end
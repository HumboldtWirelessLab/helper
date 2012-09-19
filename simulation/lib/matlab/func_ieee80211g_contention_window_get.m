function [ vector_cw ] =  func_ieee80211g_contention_window_get(greenfield_use)
    if(greenfield_use == 1)
        cw_min = 15; %[slots], see Gast, 2005, chapter 14, ERP Physical Layer Convergence (PLCP), ERP-OFDM Framing
    else
        cw_min = 31; %[slots], see Gast, 2005, chapter 14, ERP Physical Layer Convergence (PLCP), ERP-OFDM Framing
    end
        %contention_window_size_min_802_11_a = 15; %[slots], see Gast, 2005, chapter 14, ERP Physical Layer Convergence (PLCP), ERP-OFDM Framing
    %contention_window_size_min_802_11_b = 31; %[slots], see Gast, 2005, chapter 14, ERP Physical Layer Convergence (PLCP), ERP-OFDM Framing
    %contention_window_size_max = 1023; %[slots], see Gast, 2005, chapter 14, ERP Physical Layer Convergence (PLCP), ERP-OFDM Framing
    %cw_min = 31; %[slots], see Gast, 2005,  chapter 12, The "Original" Direct Sequence PHY, Table 12-4. DS PHY parameters
    cw_max = 1023; %[slots], see Gast, 2005, chapter 14, ERP Physical Layer Convergence (PLCP), ERP-OFDM Framing
    vector_cw = zeros(1,7);
    for i=0:1:size(vector_cw,2)-1
        vector_cw(1,i+1) = min((2^i * (cw_min + 1))-1,cw_max); %[slots], see Walke et al, IEEE 802-Wireless Systems, page 99
    end
end
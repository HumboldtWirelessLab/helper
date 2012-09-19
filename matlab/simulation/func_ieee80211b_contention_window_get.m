function [ vector_cw ] =  func_ieee80211b_contention_window_get()
    cw_min = 31; %[slots], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY, Table 12-9. HR/DSSS PHY parameters
    cw_max = 1023; %[slots], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY, Table 12-9. HR/DSSS PHY parameters
    vector_cw = zeros(1,7);
    for i=0:1:size(vector_cw,2)-1
        vector_cw(1,i+1) = min((2^i * (cw_min + 1))-1,cw_max); %[slots], see Walke et al, IEEE 802-Wireless Systems, page 99
    end

    %contention_window_size_min = 31; %[slots], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY, Table 12-9. HR/DSSS PHY parameters
    %contention_window_size_max = 1023; %[slots], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY, Table 12-9. HR/DSSS PHY parameters
end


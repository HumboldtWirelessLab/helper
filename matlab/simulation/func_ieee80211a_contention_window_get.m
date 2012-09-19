function [ vector_cw ] =  func_ieee80211a_contention_window_get()
    cw_min = 15; %[slots], see Gast, 2005, chapter 13, Characteristics of the OFDM PHY, Table 13-5. OFDM PHY parameter
    cw_max = 1023; %[slots], see Gast, 2005, chapter 13, Characteristics of the OFDM PHY, Table 13-5. OFDM PHY parameter
    vector_cw = zeros(1,7);
    for i=0:1:size(vector_cw,2)-1
        vector_cw(1,i+1) = min((2^i * (cw_min + 1))-1,cw_max); %[slots], see Walke et al, IEEE 802-Wireless Systems, page 99
    end
end
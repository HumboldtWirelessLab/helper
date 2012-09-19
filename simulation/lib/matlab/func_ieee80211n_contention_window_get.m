function [ vector_cw ] =  func_ieee80211n_contention_window_get()
    cw_min = 15;%[slots], see Perahia and Stacey, 2008, page 188 
    cw_max = 1023;%[slots], see Perahia and Stacey, 2008, page 188 

    vector_cw = zeros(1,7);
    for i=0:1:size(vector_cw,2)-1
        vector_cw(1,i+1) = min((2^i * (cw_min + 1))-1,cw_max); %[slots], see Walke et al, IEEE 802-Wireless Systems, page 99
    end
end
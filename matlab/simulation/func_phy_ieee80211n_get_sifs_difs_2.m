function [sifs_time, difs_time,slot_time ] = func_phy_ieee80211n_get_sifs_difs_2()
    sifs_time = 16e-6; %[sec]; 16 microseconds, see Perahia and Stacey, 2008, page 187
    slot_time = 9e-6; %[sec], 9 microseconds,  see Perahia and Stacey, 2008, page 187
    difs_time = 2 * slot_time + sifs_time; %[sec], see Perahia and Stacey, 2008, page 187 
end
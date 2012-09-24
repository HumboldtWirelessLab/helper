function [sifs_time, difs_time,slot_time ] = func_phy_ieee80211_get_sifs_difs()
% see Gast, chapter 12, "The "Originally" Direct Sequence PHY"; Table 12-4 DS PhY parameters
    slot_time = 20e-6; %[sec], 20 microseconds
    sifs_time = 10e-6; %[sec], 10 microseconds; The SIFS is used to derive the value of the other interframe spaces (DIFS, PIFS, and EIFS).
    difs_time = 2 * slot_time + sifs_time; %[sec], 50 microseconds, see http://www.oreillynet.com/wireless/2003/08/08/wireless_throughput.html
end


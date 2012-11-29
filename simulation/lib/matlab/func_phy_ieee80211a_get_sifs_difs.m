function [sifs_time, difs_time,slot_time ] = func_phy_ieee80211a_get_sifs_difs()
sifs_time = 16e-6; %[sec], 16 microseconds, see Gast, 2005, chapter 13, Characteristics of the OFDM PHY, Table 13-5. OFDM PHY parameter
slot_time = 9e-6; %[sec], 9 microseconds,  see Gast, 2005, chapter 13, Characteristics of the OFDM PHY, Table 13-5. OFDM PHY parameter
difs_time = 2 * slot_time + sifs_time; %[sec], 34 microseconds, see http://www.oreillynet.com/wireless/2003/08/08/wireless_throughput.html, see IEEE 802 Wireless Systems, page 86 
end
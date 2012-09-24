function [sifs_time, difs_time,slot_time ] = func_phy_ieee80211b_get_sifs_difs_2()
slot_time = 20e-6; %[sec], 20 microseconds, see Gast, 2005, chapter 12, High Rate Direct Sequence PHY, Table 12-9. HR/DSSS PHY parameters
sifs_time = 10e-6; %[sec], 10 microseconds; see Gast, 2005, chapter 12, High Rate Direct Sequence PHY, Table 12-9. HR/DSSS PHY parameters
difs_time = 2 * slot_time + sifs_time; %[sec], 50 microseconds, see http://www.oreillynet.com/wireless/2003/08/08/wireless_throughput.html and ieee 802 Wireless Systems, page 86
end
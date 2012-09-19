function [sifs_time, difs_time,slot_time ] = func_phy_ieee80211g_get_sifs_difs_2(greenfield_on)
    if (greenfield_on == 1) 
        slot_time = 9e-6; %[sec], 9 microseconds,  chapter 14, ERP Physical Medium Dependent (PMD) Layer, Table 14-3. ERP PHY parameters
    else
        slot_time = 20e-6; %[sec], 20 microseconds,  chapter 14, ERP Physical Medium Dependent (PMD) Layer, Table 14-3. ERP PHY parameters
    end
    sifs_time = 10e-6; %[sec], 10 microseconds, see Gast, 2005, chapter 14, ERP Physical Medium Dependent (PMD) Layer, Table 14-3. ERP PHY parameters
    %difs_time_802_11_a = 2 * slot_time_802_11_a + sifs_time; %[sec], see http://www.oreillynet.com/wireless/2003/08/08/wireless_throughput.html and ieee 802 Wireless Systems, page 86
    difs_time = 2 *  slot_time + sifs_time; %[sec], see http://www.oreillynet.com/wireless/2003/08/08/wireless_throughput.html and ieee 802 Wireless Systems, page 86
end
function [plcp_framing_bits,plcp_framing_duration, output_xml] = func_phy_ieee80211b(rate,mac_frame,greenfield)
    
    byte = 8; %[bit]
    kbps = 1000;%[bit/second] Umrechnungsfaktor := 1 Mb/s (Mbps) = 1000 kb/s
    Mbps = kbps * 1000;%[bit/second] Umrechnungsfaktor := 1 Mb/s (Mbps) = 1000 kb/s = 1000000 Bit/seconds

    mac_frame_min = 0; %[bytes], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY, Table 12-9. HR/DSSS PHY parameters
    mac_frame_max = 4095; %[bytes], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY, Table 12-9. HR/DSSS PHY parameters
    plcp_framing_bits = mac_frame * byte;
    plcp_framing_duration = 0;
    output_xml=  sprintf('<pclp-80211b/> \n');
    
    if ((mac_frame >= mac_frame_min && mac_frame <= mac_frame_max)|| mac_frame > 0) % TODO: Fragmentation to be in the specification
        plcp_preamble_sync_long = 16; %[Byte]
        plcp_preamble_sync_short = 7; %[Byte], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY (HR/DSSS), figure 12-17. HR/DSSS PLCP framing
        plcp_preamble_sfd = 2; %[Byte]; sfd:= Start Frame Delimiter
        plcp_header_signal = 1; %[Byte]
        plcp_header_service = 1; %[Byte]
        plcp_header_length = 2; %[Byte]
        plcp_header_crc = 2; %[Byte]
        if (greenfield == 1 && rate >= 2)   
            plcp_preamble = plcp_preamble_sync_short + plcp_preamble_sfd; %[Bytes]; plcp_preamble_short can only be used for 2, 5.5 and 11 Mbps
        else
            plcp_preamble = plcp_preamble_sync_long + plcp_preamble_sfd; %[Bytes] plcp_preamble_long can be used for 1, 2, 5.5, 11 Mbps
        end

        plcp_header = plcp_header_signal + plcp_header_service + plcp_header_length + plcp_header_crc; %[bytes]

        bits_per_symbol_dbpsk = 1; %  DPSK; see Gast, 2005, chapter 12, Differential Phase Shift Keying
        bits_per_symbol = bits_per_symbol_dbpsk;
        
        second = 1000000; %[microseconds]; 1 seconds = 1000000 microseconds
        transmitted_symbols_per_seconds=bits_per_symbol_dbpsk * second; %[symbols], see Gast, 2005, chapter 12, The "Original" Direct Sequence PHY, Transmission at 1.0 Mbps
    
        rate_preamble = transmitted_symbols_per_seconds * bits_per_symbol  / Mbps;
        if (greenfield == 1 && rate >= 2)  
            bits_per_symbol_dqpsk= 2; %DQPSK; see Gast, 2005, chapter 12, Differential Quadrature Phase Shift Keying
            bits_per_symbol = bits_per_symbol_dqpsk;
            rate_header = transmitted_symbols_per_seconds * bits_per_symbol  / Mbps;
        else 
            rate_header = rate_preamble;
        end

        plcp_preamble_duration = ((plcp_preamble * byte) / (rate_preamble * Mbps)); %[seconds], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY (HR/DSSS), figure 12-17. HR/DSSS PLCP framing
        plcp_header_duration = ((plcp_header * byte) / (rate_header * Mbps)); %[seconds], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY (HR/DSSS), figure 12-17. HR/DSSS PLCP framing
        plcp_preamble_header_duration = plcp_preamble_duration + plcp_header_duration; %[seconds]
        if(rate == 2)
            bits_per_symbol_dqpsk= 2; %DQPSK; see Gast, 2005, chapter 12, Differential Quadrature Phase Shift Keying
            bits_per_symbol = bits_per_symbol_dqpsk;
        elseif (rate == 5.5)
            bits_per_symbol = 4; %CCK, see Gast, 2005, chapter 12, Complementary Code Keying, bits per code word, throughput = 5.5 Mbps
            transmitted_symbols_per_seconds = 1375000; %[symbols], see Gast, 2005, chapter 12, Complementary Code Keying
        elseif (rate == 11)
            bits_per_symbol = 8; %CCK, see Gast, 2005, chapter 12, Complementary Code Keying, bits per code word, , throughput = 11 Mbps
            transmitted_symbols_per_seconds = 1375000; %[symbols], see Gast, 2005, chapter 12, Complementary Code Keying
        end
        rate_data = transmitted_symbols_per_seconds * bits_per_symbol  / Mbps;
        plcp_data_duration = ((mac_frame * byte) / (rate_data * Mbps));
        plcp_framing_duration = plcp_preamble_header_duration + plcp_data_duration;
        plcp_framing_bits = (mac_frame * byte) + (plcp_preamble * byte) + (plcp_header * byte);

   %output_xml_1=  sprintf('<pclp-80211b-long preamble="%d" header="%d" preamble_duration="%d" header_duration="%d" rate_header="%d" rate_preamble="%d"/> \n', plcp_preamble_long * byte, plcp_header * byte, plcp_preamble_long_duration, plcp_header_long_duration,rate_dbpsk,rate_dbpsk );
    %output_xml_2=  sprintf('<pclp-80211b-short preamble="%d" header="%d" preamble_duration="%d" header_duration="%d" rate_header="%d" rate_preamble="%d"/> \n', plcp_preamble_short * byte, plcp_header * byte, plcp_preamble_short_duration, plcp_header_short_duration,rate_dqpsk,rate_dbpsk );
    %output_xml = sprintf('%s%s',output_xml_1, output_xml_2);
    end
end


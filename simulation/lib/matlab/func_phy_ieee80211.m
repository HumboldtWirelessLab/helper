function [plcp_80211_framing_bits,plcp_framing_duration, output_xml] = func_phy_ieee80211(rate,frame_mac)
    % 802.11 Physical Layer
    byte = 8; %[bit]
    kbps = 1000;%[bit/second] Umrechnungsfaktor := 1 Mb/s (Mbps) = 1000 kb/s
    Mbps = kbps * 1000;%[bit/second] Umrechnungsfaktor := 1 Mb/s (Mbps) = 1000 kb/s = 1000000 Bit/seconds
    % see Gast,2005, Kapitel 12, The "Original" Direct Sequence PHY->Figure 12-14. DS PLCP framing
    plcp_mac_frame_min = 4; %[bytes], see Gast, 2005,  chapter 12, The "Original" Direct Sequence PHY, Table 12-4. DS PHY parameters
    plcp_mac_frame_max = 8191; %[bytes], see Gast, 2005,  chapter 12, The "Original" Direct Sequence PHY, Table 12-4. DS PHY parameters
    plcp_80211_framing_bits = frame_mac * byte;
    plcp_framing_duration = 0;
    output_xml='<plcp-80211 /> \n';
    if ((frame_mac >= plcp_mac_frame_min && frame_mac <= plcp_mac_frame_max)|| mac_frame > 0) % TODO: Fragmentation to be in the specification
        plcp_preamble_sync = 16; %[Byte]
        plcp_preamble_sfd = 2; %[Byte]; sfd:= Start Frame Delimiter
        plcp_header_signal = 1; %[Byte]
        plcp_header_service = 1; %[Byte]
        plcp_header_length = 2; %[Byte]
        plcp_header_crc = 2; %[Byte]



        plcp_preamble = plcp_preamble_sync + plcp_preamble_sfd; %[Bytes] plcp_preamble can be used for 1, 2, 5.5, 11 Mbps
        plcp_header = plcp_header_signal + plcp_header_service + plcp_header_length + plcp_header_crc; %[bytes]

        
        bits_per_symbol_dbpsk = 1; %  DPSK; see Gast, 2005, chapter 12, Differential Phase Shift Keying
        bits_per_symbol = bits_per_symbol_dbpsk;
        
        second = 1000000; %[microseconds]; 1 seconds = 1000000 microseconds
        dbpsk_transmitted_symbols_per_seconds=bits_per_symbol_dbpsk * second; %[symbols], see Gast, 2005, chapter 12, The "Original" Direct Sequence PHY, Transmission at 1.0 Mbps
        rate_preamble = dbpsk_transmitted_symbols_per_seconds * bits_per_symbol  / Mbps;
        
        if(rate == 2)
            bits_per_symbol_dqpsk= 2; %DQPSK; see Gast, 2005, chapter 12, Differential Quadrature Phase Shift Keying
            bits_per_symbol = bits_per_symbol_dqpsk;
        end
        rate_data = dbpsk_transmitted_symbols_per_seconds * bits_per_symbol  / Mbps;

        plcp_preamble_duration = ((plcp_preamble * byte) / (rate_preamble * Mbps)); %[seconds], see Gast, 2005,  chapter 12, The "Original" Direct Sequence PHY, Table 12-4. DS PHY parameters
        plcp_header_duration = ((plcp_header * byte) / (rate_preamble * Mbps)); %[seconds], see Gast, 2005,  chapter 12, The "Original" Direct Sequence PHY, Table 12-4. DS PHY parameters
        plcp_preamble_header_duration = plcp_preamble_duration + plcp_header_duration; %[seconds]
        plcp_data_duration = ((frame_mac * byte) / (rate_data * Mbps));%[seconds]
        plcp_framing_duration = plcp_preamble_header_duration + plcp_data_duration;%[seconds]
        %output_xml=  sprintf('<pclp-80211 preamble="%d" header="%d" preamble_duration="%d" header_duration="%d" rate_header="%d" rate_preamble="%d"/> \n', plcp_preamble * byte, plcp_header * byte, plcp_preamble_duration, plcp_header_duration,rate_dbpsk,rate_dbpsk );
        plcp_80211_framing_bits = (frame_mac * byte) + (plcp_preamble * byte) + (plcp_header * byte);
    end
end


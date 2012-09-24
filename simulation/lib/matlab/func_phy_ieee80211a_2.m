function [plcp_framing_bits,plcp_framing_duration, output_xml] = func_phy_ieee80211a_2(rate,mac_frame)
    % 802.11a
    mac_frame_length_min = 0;%[bytes]
    mac_frame_length_max = 4095; %[bytes], see Gast, 2005, chapter 13, Characteristics of the OFDM PHY, Table 13-5. OFDM PHY parameters
    output_xml =  sprintf('<PLCP-80211a /> \n');
    byte = 8; % one byte has 8 bits
    plcp_framing_bits = mac_frame * byte;
    plcp_framing_duration = 0;
    if (mac_frame >=mac_frame_length_min && mac_frame <= mac_frame_length_max && rate > 0 && rate <= 72)
        % ---------------------------------- OFDM-TIMES  ---------------------------------------------------------------------------------
        time_symbol =4e-6;%[sec], 4 microseconds, see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; OFDM Parameter choice for 802.11a
        time_integration = 3.2e-6; %[sec], 3.2 microseconds, see Gast, 2005, chapter 13, OFDM as applied by 802.11a; OFDM Parameter choice for 802.11a
        time_guard = time_symbol - time_integration; %[sec], 800 ns, see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; OFDM Parameter choice for 802.11a
        %subcarrier_spacing = (1/time_integration) / 1000000; % [MHz], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; OFDM Parameter choice for 802.11a; MHz := eine Million Schwingungen/Vorgänge pro Sekunde, see http://de.wikipedia.org/wiki/Hertz_%28Einheit%29

        % ---------------------------------- OFDM-Subcarriers  ---------------------------------------------------------------------------------
        number_of_subcarriers_total = 52; % for each 20 MHz channel, see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Structure of an Operating Channel
        number_of_subcarriers_pilot = 4; % see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Structure of an Operating Channel
        number_of_subcarriers_data = number_of_subcarriers_total - number_of_subcarriers_pilot; % see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Structure of an Operating Channel

        % ---------------------------------- OFDM-Modulation  ---------------------------------------------------------------------------------
        number_bits_per_channel = 0;
        if (rate == 6 || rate == 9)
            number_bits_per_channel = 1; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Figure 13-9. Constellations used by 802.11a
        elseif (rate == 12 || rate == 18)
            number_bits_per_channel = 2; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Figure 13-9. Constellations used by 802.11a
        elseif (rate == 24 || rate == 36)
            number_bits_per_channel = 4; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Figure 13-9. Constellations used by 802.11a
        elseif (rate == 48 || rate == 54 || rate == 72)
            number_bits_per_channel = 6; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Figure 13-9. Constellations used by 802.11a
        end

        radio_channel_capacity_total = number_of_subcarriers_data * number_bits_per_channel; %[bits]; coded_bits_per_symbol, see Gast 2005, chapter 13, Table 13-3. Encoding details for different OFDM data rates

        % ---------------------------------- OFDM-Forward Error Correction (FEC) ---------------------------------------------------------------------------------
        %fec_constraint_length = 7; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
        fec_coding_rate = 0;
        if(rate == 6 || rate == 12 || rate == 24)
            fec_coding_rate = 1/2; % coding rate (R) determines how many redundant bits are addded; transmits one data bit for every two code bits; see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
        elseif (rate == 48)
            fec_coding_rate = 2/3; %see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
        elseif  (rate == 9 || rate == 18 || rate == 36 || rate == 54)
            fec_coding_rate = 3/4; %see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
        end
        % ---------------------------------- OFDM-PLCP  ---------------------------------------------------------------------------------
        plcp_preamble_training_sequence_short = 10; %[symbols]; see Gast, 2005, OFDM PLCP; Preamble; !!! attention: not OFDM-symbols, see IEEE 802 Wireless Systems, page 81 !!!
        plcp_preamble_training_sequence_long = 2; %[symbols]; see Gast, 2005, OFDM PLCP; Preamble; !!! attention: not OFDM-symbols, see IEEE 802 Wireless Systems, page 81 !!!
        ofdm_plcp_header_signal_rate = 4; %[bits]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_reserved = 1; %[bit]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_length = 12; %[bit]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_parity = 1; %[bit]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_tail= 6; %[bits]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_service=16; %[bits]; see Gast, 2005, OFDM PLCP; Figure 13-14. OFDM PLCP framing format

        ofdm_plcp_header_signal = (ofdm_plcp_header_signal_rate + ofdm_plcp_header_signal_reserved + ofdm_plcp_header_signal_length + ofdm_plcp_header_signal_parity + ofdm_plcp_header_signal_tail); %[bits]

        ofdm_plcp_data = ofdm_plcp_header_signal_service + (mac_frame * byte) + ofdm_plcp_header_signal_tail ; %[bits]; see Gast, 2005, chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format

        pclp_preamble_short_duration = plcp_preamble_training_sequence_short * time_guard; %[sec]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-15. Preamble and frame start
        plcp_preamble_long_duration = (plcp_preamble_training_sequence_long *  time_integration) + (2 * time_guard); %[sec]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-15. Preamble and frame start

        plcp_preamble_duration = pclp_preamble_short_duration + plcp_preamble_long_duration; %[sec]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-15. Preamble and frame start and see Gast, 2005, chapter 13, Characteristics of the OFDM PHY, Table 13-5. OFDM PHY parameter
        % ---------------------------------- OFDM Data-Bits per Symbol (depend of the modulation)  ---------------------------------------------------------------------------------
        if (fec_coding_rate > 0)
            data_bits_per_symbol = radio_channel_capacity_total * fec_coding_rate; %[bits], speed 6 [Mbps], see Gast, 2005, chapter 13, OFDM PMD, Table 13-3. Encoding details for different OFDM data rates
        else
            data_bits_per_symbol = radio_channel_capacity_total;
        end
        % ---------------------------------- OFDM Pad-Bits for PLCP-Data  ---------------------------------------------------------------------------------
        pad_bits = data_bits_per_symbol - mod(ofdm_plcp_data,data_bits_per_symbol); %[Bits], see Gast, 2005, chapter 13,Transmission and Reception
        % ---------------------------------- OFDM PLCP-Data and Pad-Bits for different data rates (only data_bits_per_symbol) ---------------------------------------------------------------------------------
        ofdm_plcp_data = ofdm_plcp_data + pad_bits; % [Bits], see Gast, 2005, chapter 13, OFDM PLCP, Figure 13-14. OFDM PLCP framing format

        % ---------------------------------- OFDM-Rates (depend of the Data-Bits per Symbol)  ---------------------------------------------------------------------------------
        kb = 1000;%[byte]
        mb = kb * 1000;%[byte]
        phy_symbol_rate = 1 / (time_symbol); % [symbols per second], see Gast, 2005, chapter 13, OFDM PMD
        rate =(phy_symbol_rate * data_bits_per_symbol) / mb; %[Mbps], see Gast, 2005, chapter 13, OFDM PMD, Table 13-3. Encoding details for different OFDM data rates
        %---------------------- OFDM-Header-Duration  -----------------------------------
        rate_header = 6;
        plcp_header_duration = ofdm_plcp_header_signal / (rate_header * mb); %[sec]
        %---------------------- OFDM-Data-Duration (only data_bits_per_symbol) -----------------------------------
        plcp_data_duration = ofdm_plcp_data / (rate * mb); %[sec]

        plcp_framing_duration = plcp_preamble_duration + plcp_header_duration + plcp_data_duration; %[sec]
        plcp_framing_bits = ofdm_plcp_header_signal + ofdm_plcp_data; % [bits] plcp_preamble_bits are not included
        %matrix = [[rate_6; rate_9; rate_12; rate_18; rate_24; rate_36; rate_48; rate_54; rate_72],[plcp_data_6_mbps_duration; plcp_data_9_mbps_duration;plcp_data_12_mbps_duration;plcp_data_18_mbps_duration; plcp_data_24_mbps_duration; plcp_data_36_mbps_duration; plcp_data_48_mbps_duration;plcp_data_54_mbps_duration;plcp_data_72_mbps_duration]];
        %output_xml =  sprintf('<PLCP-80211a preamble="%d" header_signal="%d" data="%d" header_with_coding_rate="%d" pad_bits="%d" mac_frame_length_max="%d" preamble_duration="%f" duration_header_with_coding_rate="%f" rate_header="%d"/> \n',plcp_preamble, ofdm_plcp_header_signal, ofdm_plcp_data_mbps_6 ,ofdm_plcp_header_with_coding_rate, pad_bits_mbps_6, mac_frame_length_max, plcp_preamble_duration, plcp_header_duration,rate_6);
    end
end


function [plcp_framing_bits,plcp_framing_duration, output_xml] = func_phy_ieee80211g(rate,mac_frame,greenfield, dsss_ofdm_use)
%ieee 802.11g, be careful, because sifs are shorter then 802.11a therefore exist an signal-extension

    mac_frame_length_min = 1; %[bytes], see 802.11g Standard, page 17, Table 123A TXVECTOR parameters
    mac_frame_length_max = 4095; %[bytes], see Gast, 2005, see Gast, 2005, chapter 14, ERP Physical Medium Dependent (PMD) Layer, Table 14-3. ERP PHY parameters
    byte = 8; %[bit]   
    kbps = 1000;%[bit/second] Umrechnungsfaktor := 1 Mb/s (Mbps) = 1000 kb/s
    Mbps = kbps * 1000;%[bit/second] Umrechnungsfaktor := 1 Mb/s (Mbps) = 1000 kb/s = 1000000 Bit/seconds
    %matrix_dsss_ofdm = 0;
    %matrix_erp_pbcc = 0;
    output_xml =  sprintf('<plcp-80211g /> \n');
    signal_extension = 6e-6;%[sec], 6 microseconds idle time after a frame was transmitted, see Gast, 2005, chapter 14, ERP Physical Layer Convergence (PLCP), ERP-OFDM Framing 
    % Initialization of the function return values
    plcp_framing_bits = mac_frame * byte;
    plcp_framing_duration = 0; 
 if ((mac_frame >= mac_frame_length_min && mac_frame <= mac_frame_length_max) || mac_frame > 0) % TODO: Fragmentation to be in the specification



% HR-DSSS-Phy
if (rate == 1 || rate == 2 || rate == 5.5 || rate == 11 || rate == 22 || rate == 33)


    plcp_preamble_sync_long = 16; %[Byte]
    plcp_preamble_sync_short = 7; %[Byte], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY (HR/DSSS), figure 12-17. HR/DSSS PLCP framing

    plcp_preamble_sfd = 2; %[Byte]; sfd:= Start Frame Delimiter
    plcp_header_signal = 1; %[Byte]
    plcp_header_service = 1; %[Byte]
    plcp_header_length = 2; %[Byte]
    plcp_header_crc = 2; %[Byte]
 %----------- Short and Long ERP-Preamble--------------------------------
 
    if (greenfield == 1 && rate >= 2)   
        plcp_preamble = plcp_preamble_sync_short + plcp_preamble_sfd; %[Bytes]; plcp_preamble_short can only be used for 2, 5.5 and 11 Mbps
    else
        plcp_preamble = plcp_preamble_sync_long + plcp_preamble_sfd; %[Bytes] plcp_preamble_long can be used for 1, 2, 5.5, 11 Mbps
    end
    %plcp_preamble_long = plcp_preamble_sync_long + plcp_preamble_sfd; %[Bytes] plcp_preamble can be used for 1, 2, 5.5, 11 Mbps
    %plcp_preamble_short = plcp_preamble_sync_short + plcp_preamble_sfd; %[Bytes]; plcp_preamble_short can only be used for 2, 5.5 and 11 Mbps

    %---------- ERP-Header -------------------------------------------------------
    plcp_header = plcp_header_signal + plcp_header_service + plcp_header_length + plcp_header_crc; %[bytes]

        bits_per_symbol_dbpsk = 1; %  DPSK; see Gast, 2005, chapter 12, Differential Phase Shift Keying
        bits_per_symbol = bits_per_symbol_dbpsk;
        
        second = 1000000; %[microseconds]; 1 seconds = 1000000 microseconds
        transmitted_symbols_per_seconds=bits_per_symbol_dbpsk * second; %[symbols/sec], see Gast, 2005, chapter 12, The "Original" Direct Sequence PHY, Transmission at 1.0 Mbps
    
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
        clock_switching = 0;
        if(rate == 2)
            bits_per_symbol_dqpsk= 2; %DQPSK; see Gast, 2005, chapter 12, Differential Quadrature Phase Shift Keying
            bits_per_symbol = bits_per_symbol_dqpsk;
        elseif (rate == 5.5)
            bits_per_symbol = 4; %CCK, see Gast, 2005, chapter 12, Complementary Code Keying, bits per code word, throughput = 5.5 Mbps
            transmitted_symbols_per_seconds = 1375000; %[symbols/sec], see Gast, 2005, chapter 12, Complementary Code Keying
        elseif (rate == 11)
            bits_per_symbol = 8; %CCK, see Gast, 2005, chapter 12, Complementary Code Keying, bits per code word, , throughput = 11 Mbps
            transmitted_symbols_per_seconds = 1375000; %[symbols/sec], see Gast, 2005, chapter 12, Complementary Code Keying
        elseif (rate == 22)
            transmitted_symbols_per_seconds = 1375000; %[symbols/sec], see Gast, 2005, chapter 12, Complementary Code Keying
             bits_per_symbol = 16; %CCK, see Gast, 2005, chapter 14, ERP Physical Layer Convergence (PLCP), PBCC coding, bits per code word, , throughput = 22 Mbps
        elseif (rate == 33)
            transmitted_symbols_per_seconds = 1650000; %[symbols/sec],  see Gast, 2005, chapter 14, ERP Physical Layer Convergence (PLCP), PBCC coding, bits per code word, , throughput = 33 Mbps
            bits_per_symbol = 20;
            clock_switching = 1e-6;%[sec], 1 [microsecond] Clock switching see 802.11g-2003.pdf, Figure 153E-33 Mbit/s clock switching
        end
         
            
        rate_data = transmitted_symbols_per_seconds * bits_per_symbol  / Mbps;
        plcp_data_duration = ((mac_frame * byte) / (rate_data * Mbps));%[sec]
        plcp_framing_duration = plcp_preamble_header_duration + clock_switching + plcp_data_duration;%[sec]
        plcp_framing_bits = (mac_frame * byte) + (plcp_preamble * byte) + (plcp_header * byte);%[bits]
%DSSS-OFDM (like 802.11b: Short- and Long-Preamble),  see 802.11g Standard, page 22, Figure 153A Long preamble PPDU format for DSSS-OFDM and page 23 Figure 153B Short preamble PPDU format for DSSS-OFDM
 elseif (rate >= 6  && rate <= 72 && dsss_ofdm_use == 0)
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

        radio_channel_capacity_total = number_of_subcarriers_data * number_bits_per_channel; %[coded_bits/symbol]; coded_bits_per_symbol, see Gast 2005, chapter 13, Table 13-3. Encoding details for different OFDM data rates

        % ---------------------------------- OFDM-Forward Error Correction (FEC) ---------------------------------------------------------------------------------
        %fec_constraint_length = 7; %[bits], see Gast, 2005, chrate > 0 && rate <= 72)apter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
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
            data_bits_per_symbol = radio_channel_capacity_total * fec_coding_rate; %[bits/symbol], speed 6 [Mbps], see Gast, 2005, chapter 13, OFDM PMD, Table 13-3. Encoding details for different OFDM data rates
        else
            data_bits_per_symbol = radio_channel_capacity_total; %[bits/symbol]
        end
        % ---------------------------------- OFDM Pad-Bits for PLCP-Data  ---------------------------------------------------------------------------------
        pad_bits = data_bits_per_symbol - mod(ofdm_plcp_data,data_bits_per_symbol); %[Bits], see Gast, 2005, chapter 13,Transmission and Reception
        % ---------------------------------- OFDM PLCP-Data and Pad-Bits for different data rates (only data_bits_per_symbol) ---------------------------------------------------------------------------------
        ofdm_plcp_data = ofdm_plcp_data + pad_bits; % [Bits], see Gast, 2005, chapter 13, OFDM PLCP, Figure 13-14. OFDM PLCP framing format

        % ---------------------------------- OFDM-Rates (depend of the Data-Bits per Symbol)  ---------------------------------------------------------------------------------
        %kb = 1000;%[byte]
        %mb = kb * 1000;%[byte]
        phy_symbol_rate = 1 / (time_symbol); % [symbols per second], see Gast, 2005, chapter 13, OFDM PMD
        rate =(phy_symbol_rate * data_bits_per_symbol) / Mbps; %[Mbps], see Gast, 2005, chapter 13, OFDM PMD, Table 13-3. Encoding details for different OFDM data rates
        %---------------------- OFDM-Header-Duration  -----------------------------------
        rate_header = 6;
        plcp_header_duration = ofdm_plcp_header_signal / (rate_header * Mbps); %[sec]
        %---------------------- OFDM-Data-Duration (only data_bits_per_symbol) -----------------------------------
        plcp_data_duration = ofdm_plcp_data / (rate * Mbps); %[sec]

        plcp_framing_duration = plcp_preamble_duration + plcp_header_duration + plcp_data_duration + signal_extension; %[sec]
        plcp_framing_bits = ofdm_plcp_header_signal + ofdm_plcp_data; % [bits] plcp_preamble_bits are not included
 elseif (rate >= 6  && rate <= 72 && dsss_ofdm_use == 1)

     byte = 8; %[bit]   
    %kb = 1000;%[byte]   
    %mb = kb * 1000;%[byte]

    plcp_preamble_sync_long = 16; %[Byte]
    plcp_preamble_sync_short = 7; %[Byte], see Gast, 2005, chapter 12, High Rate Direct Sequence PHY (HR/DSSS), figure 12-17. HR/DSSS PLCP framing

    plcp_preamble_sfd = 2; %[Byte]; sfd:= Start Frame Delimiter
    plcp_header_signal = 1; %[Byte]
    plcp_header_service = 1; %[Byte]
    plcp_header_length = 2; %[Byte]
    plcp_header_crc = 2; %[Byte]
 %----------- Short and Long ERP-Preamble--------------------------------
 
    if (greenfield == 1 && rate >= 2)   
        plcp_preamble = plcp_preamble_sync_short + plcp_preamble_sfd; %[Bytes]; plcp_preamble_short can only be used for 2, 5.5 and 11 Mbps
    else
        plcp_preamble = plcp_preamble_sync_long + plcp_preamble_sfd; %[Bytes] plcp_preamble_long can be used for 1, 2, 5.5, 11 Mbps
    end

    %---------- ERP-Header -------------------------------------------------------
    plcp_header = plcp_header_signal + plcp_header_service + plcp_header_length + plcp_header_crc; %[bytes]

        bits_per_symbol_dbpsk = 1; %  DPSK; see Gast, 2005, chapter 12, Differential Phase Shift Keying
        bits_per_symbol = bits_per_symbol_dbpsk;
        
        second = 1000000; %[microseconds]; 1 seconds = 1000000 microseconds
        transmitted_symbols_per_seconds=bits_per_symbol_dbpsk * second; %[symbols/sec], see Gast, 2005, chapter 12, The "Original" Direct Sequence PHY, Transmission at 1.0 Mbps
    
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
        plcp_preamble_duration = plcp_preamble_duration + plcp_header_duration; %[seconds]
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
        %fec_constraint_length = 7; %[bits], see Gast, 2005, chrate > 0 && rate <= 72)apter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
        fec_coding_rate = 0;
        if(rate == 6 || rate == 12 || rate == 24)
            fec_coding_rate = 1/2; % coding rate (R) determines how many redundant bits are addded; transmits one data bit for every two code bits; see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
        elseif (rate == 48)
            fec_coding_rate = 2/3; %see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
        elseif  (rate == 9 || rate == 18 || rate == 36 || rate == 54)
            fec_coding_rate = 3/4; %see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
        end
        % ---------------------------------- OFDM-PLCP  ---------------------------------------------------------------------------------
        %plcp_preamble_training_sequence_short = 10; %[symbols]; see Gast, 2005, OFDM PLCP; Preamble; !!! attention: not OFDM-symbols, see IEEE 802 Wireless Systems, page 81 !!!
        plcp_preamble_training_sequence_long = 2; %[symbols]; see Gast, 2005, OFDM PLCP; Preamble; !!! attention: not OFDM-symbols, see IEEE 802 Wireless Systems, page 81 !!!
        ofdm_plcp_header_signal_rate = 4; %[bits]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_reserved = 1; %[bit]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_length = 12; %[bit]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_parity = 1; %[bit]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_tail= 6; %[bits]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
        ofdm_plcp_header_signal_service=16; %[bits]; see Gast, 2005, OFDM PLCP; Figure 13-14. OFDM PLCP framing format

        ofdm_plcp_header_signal = (ofdm_plcp_header_signal_rate + ofdm_plcp_header_signal_reserved + ofdm_plcp_header_signal_length + ofdm_plcp_header_signal_parity + ofdm_plcp_header_signal_tail); %[bits]

        ofdm_plcp_data = ofdm_plcp_header_signal_service + (mac_frame * byte) + ofdm_plcp_header_signal_tail ; %[bits]; see Gast, 2005, chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format

        %pclp_preamble_short_duration = plcp_preamble_training_sequence_short * time_guard; %[sec]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-15. Preamble and frame start
        plcp_preamble_long_duration = (plcp_preamble_training_sequence_long *  time_integration) + (2 * time_guard); %[sec]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-15. Preamble and frame start

        plcp_preamble_duration = plcp_preamble_duration  + plcp_preamble_long_duration; %[sec]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-15. Preamble and frame start and see Gast, 2005, chapter 13, Characteristics of the OFDM PHY, Table 13-5. OFDM PHY parameter
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
        %kb = 1000;%[byte]
        %mb = kb * 1000;%[byte]
        phy_symbol_rate = 1 / (time_symbol); % [symbols per second], see Gast, 2005, chapter 13, OFDM PMD
        rate =(phy_symbol_rate * data_bits_per_symbol) / Mbps; %[Mbps], see Gast, 2005, chapter 13, OFDM PMD, Table 13-3. Encoding details for different OFDM data rates
        %---------------------- OFDM-Header-Duration  -----------------------------------
        rate_header = 6;
        plcp_header_duration = (ofdm_plcp_header_signal / (rate_header * Mbps)); %[sec]
        %---------------------- OFDM-Data-Duration (only data_bits_per_symbol) -----------------------------------
        plcp_data_duration = ofdm_plcp_data / (rate * Mbps); %[sec]

        plcp_framing_duration = plcp_preamble_duration + plcp_header_duration + plcp_data_duration + signal_extension; %[sec]
        plcp_framing_bits = ofdm_plcp_header_signal + ofdm_plcp_data; % [bits] plcp_preamble_bits are not included
end

end


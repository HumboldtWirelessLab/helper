% mcs;  mcs index number is mapped to the data rate
% short_guard_interval; 0:= off, 1:= on for use
% bandwidth;  0:= 20 MHz; 1:=40MHz
% greenfield;  0:= off; 1:=on
function [plcp_framing_bits,plcp_framing_duration, output_xml] = func_phy_ieee80211n_2(mcs,mac_frame,short_guard_interval, bandwidth,greenfield )
    mac_frame_length_min = 0;  %[bytes], see Perahia and Stacey, 2008, page 78
    mac_frame_length_max = 65535; %[bytes], see Perahia and Stacey, 2008, page 78
    plcp_framing_duration = 0;
    %mac_frame = 0;
    output_xml=  sprintf('<pclp-80211n/> \n');
    byte = 8; % one byte has 8 bits
    plcp_framing_bits = mac_frame * byte;

if (mac_frame >=mac_frame_length_min && mac_frame <= mac_frame_length_max)
    mcs_check = 0;
    number_of_spatial_streams = 0;
    if(mcs >= 0 && mcs <= 7)
        number_of_spatial_streams = 1;
        mcs_check = mcs;
    elseif (mcs >= 8 && mcs <= 15)
        number_of_spatial_streams = 2;
        mcs_check = mcs - 8;
    elseif (mcs >= 16 && mcs <= 23)
        number_of_spatial_streams = 3;
        mcs_check = mcs - 16;
    elseif (mcs >=24 && mcs <= 31)
        number_of_spatial_streams = 4;
        mcs_check = mcs - 24;
    end
% ---------------------------------- OFDM-Forward Error Correction (FEC) --------------------------------------------------------------------------------- 
number_bits_per_channel_qam_bpsk = 1; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Figure 13-9. Constellations used by 802.11a
number_bits_per_channel_qpsk = 2; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Figure 13-9. Constellations used by 802.11a
number_bits_per_channel_qam_16 = 4; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Figure 13-9. Constellations used by 802.11a
number_bits_per_channel_qam_64 = 6; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Figure 13-9. Constellations used by 802.11a
number_bits_per_channel = 0;
fec_coding_rate  = 0;
if(mcs_check == 0)
    fec_coding_rate = 1/2;%see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
    number_bits_per_channel = number_bits_per_channel_qam_bpsk;
elseif (mcs_check == 1)
 fec_coding_rate = 1/2;%see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
 number_bits_per_channel = number_bits_per_channel_qpsk;
elseif (mcs_check == 2)
    fec_coding_rate = 3/4;%see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
     number_bits_per_channel = number_bits_per_channel_qpsk;
elseif (mcs_check == 3)
    fec_coding_rate = 1/2;%see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
    number_bits_per_channel = number_bits_per_channel_qam_16;
elseif (mcs_check == 4)
    fec_coding_rate = 3/4;%see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
    number_bits_per_channel = number_bits_per_channel_qam_16;
elseif (mcs_check == 5)
    fec_coding_rate = 2/3;%see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
    number_bits_per_channel = number_bits_per_channel_qam_64;
elseif (mcs_check == 6)
    fec_coding_rate = 3/4;%see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Forward error correction with convolutional coding
    number_bits_per_channel = number_bits_per_channel_qam_64;
elseif (mcs_check == 7)
    fec_coding_rate = 5/6; %see Perahia and Stacey, 2008, page 78
    number_bits_per_channel = number_bits_per_channel_qam_64;
end

% ---------------------------------- OFDM-TIMES  ---------------------------------------------------------------------------------


time_integration = 3.2e-6; %[sec], 3.2 microseconds, see Gast, 2005, chapter 13, OFDM as applied by 802.11a; OFDM Parameter choice for 802.11a
if(short_guard_interval == 0)
    time_guard = 0.8e-6; %[sec], 800 ns, see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; OFDM Parameter choice for 802.11a
elseif(short_guard_interval == 0)
    time_guard = 0.4e-6; % [sec], 400ns, short guard interval  see Perahia and Stacey, 2008, page 131
end
time_symbol =time_integration + time_guard;%[sec], 4 microseconds, see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; OFDM Parameter choice for 802.11a
%subcarrier_spacing = (1/time_integration) / 1000000; % [MHz], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; OFDM Parameter choice for 802.11a; MHz := eine Million Schwingungen/Vorgänge pro Sekunde, see http://de.wikipedia.org/wiki/Hertz_%28Einheit%29


% ---------------------------------- OFDM-PLCP- Preamble (mixture, see see Perahia and Stacey, 2008, page 71, Figure 4.10 Mixed format preamble)  ---------------------------------------------------------------------------------

ofdm_plcp_preamble_training_sequence_short = 10; %[symbols]; see Gast, 2005, OFDM PLCP; Preamble; !!! attention: not OFDM-symbols, see IEEE 802 Wireless Systems, page 81 !!!
ofdm_plcp_preamble_training_sequence_long = 2; %[symbols]; see Gast, 2005, OFDM PLCP; Preamble; !!! attention: not OFDM-symbols, see IEEE 802 Wireless Systems, page 81 !!!
%ofdm_plcp_preamble = ofdm_plcp_preamble_training_sequence_short + ofdm_plcp_preamble_training_sequence_long; %[symbols]; see Gast, 2005, OFDM PLCP; Figure 13-14. OFDM PLCP framing format; !!! attention: not OFDM-symbols, see IEEE 802 Wireless Systems, page 81 !!!
ofdm_pclp_preamble_short_duration = ofdm_plcp_preamble_training_sequence_short * time_guard; %[sec]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-15. Preamble and frame start
ofdm_plcp_preamble_long_duration = (ofdm_plcp_preamble_training_sequence_long *  time_integration) + (2 * time_guard); %[sec]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-15. Preamble and frame start
ofdm_plcp_preamble_duration = ofdm_pclp_preamble_short_duration + ofdm_plcp_preamble_long_duration; %[sec]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-15. Preamble and frame start and see Gast, 2005, chapter 13, Characteristics of the OFDM PHY, Table 13-5. OFDM PHY parameter

ofdm_plcp_header_signal_rate = 4; %[bits]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
ofdm_plcp_header_signal_reserved = 1; %[bit]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
ofdm_plcp_header_signal_length = 12; %[bit]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
ofdm_plcp_header_signal_parity = 1; %[bit]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
ofdm_plcp_header_signal_tail= 6; %[bits]; see Gast, 2005,chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format
ofdm_plcp_header_signal_service=16; %[bits]; see Gast, 2005, OFDM PLCP; Figure 13-14. OFDM PLCP framing format

ofdm_plcp_header_signal = (ofdm_plcp_header_signal_rate + ofdm_plcp_header_signal_reserved + ofdm_plcp_header_signal_length + ofdm_plcp_header_signal_parity + ofdm_plcp_header_signal_tail); %[bits]


% ---------------------------------- OFDM-Subcarriers  ---------------------------------------------------------------------------------
ofdm_number_of_subcarriers_total = 52; % for each 20 MHz channel, see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Structure of an Operating Channel
ofdm_number_of_subcarriers_pilot = 4; % see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Structure of an Operating Channel
ofdm_number_of_subcarriers_data = ofdm_number_of_subcarriers_total - ofdm_number_of_subcarriers_pilot; % see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Structure of an Operating Channel

% ---------------------------------- OFDM-Modulation  ---------------------------------------------------------------------------------
ofdm_number_bits_per_channel_qam_bpsk = 1; %[bits], see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Figure 13-9. Constellations used by 802.11a
ofdm_number_bits_per_channel = ofdm_number_bits_per_channel_qam_bpsk;
ofdm_radio_channel_capacity_total = ofdm_number_of_subcarriers_data * ofdm_number_bits_per_channel; %[bits]; coded_bits_per_symbol, see Gast 2005, chapter 13, Table 13-3. Encoding details for different OFDM data rates
% ---------------------------------- OFDM Data-Bits per Symbol (depend of the modulation)  ---------------------------------------------------------------------------------
fec_coding_rate_1_2 = 1/2;
ofdm_data_bits_per_symbol_6 = ofdm_radio_channel_capacity_total * fec_coding_rate_1_2; %[bits], speed 6 [Mbps], see Gast, 2005, chapter 13, OFDM PMD, Table 13-3. Encoding details for different OFDM data rates

% ---------------------------------- OFDM-Rates (depend of the Data-Bits per Symbol)  ---------------------------------------------------------------------------------
kb = 1000;%[byte]
mb = kb * 1000;%[byte]
ofdm_phy_symbol_rate = 1 / (time_symbol); % [symbols per second], see Gast, 2005, chapter 13, OFDM PMD
rate_6 =(ofdm_phy_symbol_rate * ofdm_data_bits_per_symbol_6) / mb; %[Mbps], see Gast, 2005, chapter 13, OFDM PMD, Table 13-3. Encoding details for different OFDM data rates
ofdm_plcp_header_signal_duration_6_mbps = ofdm_plcp_header_signal / (rate_6 * mb);%[sec]

% ---------------------------------- 802.11n legacy-preamble  ---------------------------------------------------------------------------------
legacy_preamble_duration = ofdm_plcp_preamble_duration + ofdm_plcp_header_signal_duration_6_mbps; %[sec], see Perahia and Stacey, 2008, page 71, Figure 4.10 Mixed format preamble





% ---------------------------------- High Throughput-Portion of the mixed format preamble, see Perahia and Stacey, 2008, page 77, chapter 4.2.2  ---------------------------------------------------------------------------------
%time_short_guard = 0.0000004; % [sec], 400 ns, see Perahia and Stacey, 2008, page 79
%number_of_subcarriers_total_20_mhz = 56; % for each 20 MHz channel, see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Structure of an Operating Channel
%number_of_subcarriers_pilot_20_mhz = 4; % see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Structure of an Operating Channel
%number_of_subcarriers_data_20_mhz = number_of_subcarriers_total_20_mhz - number_of_subcarriers_pilot_20_mhz; % see Gast, 2005, chapter 13, OFDM as applied bay 802.11a; Structure of an Operating Channel


number_of_subcarriers_total_40_mhz = 128; % for each 40 MHz channel, see Perahia and Stacey, 2008, page 102
number_of_subcarriers_null_40_mhz = 14;% [channels], see Perahia and Stacey, 2008, page 102
number_of_subcarriers_pilot_40_mhz = 6;% [channels], see Perahia and Stacey, 2008, page 102
number_of_subcarriers_data_40_mhz = number_of_subcarriers_total_40_mhz - number_of_subcarriers_null_40_mhz - number_of_subcarriers_pilot_40_mhz;% [channels], see Perahia and Stacey, 2008, page 102




ofdm_number_of_coded_bits = number_of_subcarriers_data_40_mhz * number_bits_per_channel; %[bits]
data_bits_per_symbol = ofdm_number_of_coded_bits * fec_coding_rate; %[bits]


% ---------------------------------- OFDM-Rates (depend of the Data-Bits per Symbol)  ---------------------------------------------------------------------------------
phy_symbol_rate = 1 / (time_symbol); % [symbols per second], see Gast, 2005, chapter 13, OFDM PMD
rate =(phy_symbol_rate * data_bits_per_symbol) / mb; %[Mbps], see Gast, 2005, chapter 13, OFDM PMD, Table 13-3. Encoding details for different OFDM data rates

rate = rate * number_of_spatial_streams; %MIMO

% ---------------------------------- High Throughput Signal Field (ht_sig)  ---------------------------------------------------------------------------------
ht_sig_1_mcs = 7;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_1_cdw_20_40 = 1;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_1_length = 16;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_1 = ht_sig_1_mcs + ht_sig_1_cdw_20_40 + ht_sig_1_length; %[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2. 
ht_sig_2_smoothing = 1;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_2_not_sounding = 1;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_2_reserved_one = 1;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_2_aggregation = 1;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_2_stbc = 2;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_2_fec_coding = 1;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_2_short_gi = 1;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_2_number_of_extension_spatial_streams = 2;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2. 
ht_sig_2_crc = 8;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_2_signal_tail = 6;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2
ht_sig_2 = ht_sig_2_smoothing + ht_sig_2_not_sounding + ht_sig_2_reserved_one + ht_sig_2_aggregation + ht_sig_2_stbc + ht_sig_2_fec_coding + ht_sig_2_short_gi +  ht_sig_2_number_of_extension_spatial_streams + ht_sig_2_crc + ht_sig_2_signal_tail;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2. Reproduced with permission from IEEE (2007b)


ht_sig = ht_sig_1 + ht_sig_2;%[bit], see Perahia and Stacey, 2008, page 78, Figure 4.16 Format of HT-SIG1 and HT-SIG2. 

%ht_sig_with_coding_rate = (ht_sig / fec_coding_rate_1_2); %[bits], see Perahia and Stacey, 2008, page 80

ht_sig_duration = ht_sig / (rate_6 * mb);%[sec], see Perahia and Stacey, 2008, page 80; ht_sig:= High Throughput Signal Field


ht_stf_duration = 4e-6; %[sec], 4 microseconds, see Perahia and Stacey, 2008, page 82; ht_stf:= High Throughput Short Training Field


ht_ltf_duration = 4e-6;%[sec], 4 microseconds, see  Perahia and Stacey, 2008, page 82; ht_ltf:=High Throughput Long Training Field
ht_ltf_duration_total = 0;
%number_of_ht_ltf = 0;
if (number_of_spatial_streams == 3) % see  Perahia and Stacey, 2008, page 82
    number_of_ht_ltf = number_of_spatial_streams + 1;
else
     number_of_ht_ltf = number_of_spatial_streams;
end
for i=1:1: number_of_ht_ltf
    ht_ltf_duration_total = ht_ltf_duration_total + ht_ltf_duration; %[sec]; see Perahia and Stacey, 2008, page 82
end
if (bandwidth == 0 && greenfield == 0)
% ----------------------------------Mixed format preamble  for 20 MHz ---------------------------------------------------------------------------------

    ht_preamble_duration = ht_sig_duration + ht_stf_duration +ht_ltf_duration_total;%[sec],see Perahia and Stacey, 2008, page 71; Figure 4.10 Mixed format preamble
    preamble_duration = legacy_preamble_duration + ht_preamble_duration;%[sec],see Perahia and Stacey, 2008, page 71; Figure 4.10 Mixed format preamble
% ----------------------------------Mixed format preamble  for 40 MHz ---------------------------------------------------------------------------------
elseif(bandwidth == 1 && greenfield == 0)
    ht_preamble_duration_40_mhz = (2 * ht_sig_duration) + ht_stf_duration + ht_ltf_duration_total;%[sec],see Perahia and Stacey, 2008, page 105; Figure 5.4 40MHz mixed mode preamble.
    %preamble_duration_40_mhz = (2 * legacy_preamble_duration )+ ht_preamble_duration_40_mhz; %[sec],see Perahia and Stacey, 2008, page 105; Figure 5.4 40MHz mixed mode preamble.
    preamble_duration = (2 * legacy_preamble_duration )+ ht_preamble_duration_40_mhz; %[sec],see Perahia and Stacey, 2008, page 105; Figure 5.4 40MHz mixed mode preamble.
% ----------------------------------Greenfield format preamble ---------------------------------------------------------------------------------
elseif (greenfield == 1)
    ht_stf_gf_duration = 8e-6; %[sec]; see see  Perahia and Stacey, 2008, page 123; Figure 5.16 Greenfield format preamble
    ht_ltf1_gf_duration = 2 * ht_ltf_duration;%[sec]; see see  Perahia and Stacey, 2008, page 123; Figure 5.16 Greenfield format preamble
    %preample_duration_gf = ht_stf_gf_duration + ht_ltf1_gf_duration + ht_sig_duration + (ht_ltf_duration_total - ht_ltf_duration);%[sec]; see see  Perahia and Stacey, 2008, page 123; Figure 5.16 Greenfield format preamble
    preamble_duration = ht_stf_gf_duration + ht_ltf1_gf_duration + ht_sig_duration + (ht_ltf_duration_total - ht_ltf_duration);%[sec]; see see  Perahia and Stacey, 2008, page 123; Figure 5.16 Greenfield format preamble
end
% ---------------------------------- Payload  ---------------------------------------------------------------------------------

byte = 8; % one byte has 8 bits
ofdm_plcp_data = ofdm_plcp_header_signal_service + (mac_frame * byte) + ofdm_plcp_header_signal_tail ; %[bits]; see Gast, 2005, chapter 13, OFDM PLCP; Figure 13-14. OFDM PLCP framing format

% ---------------------------------- OFDM Pad-Bits for PLCP-Data  ---------------------------------------------------------------------------------
pad_bits = data_bits_per_symbol - mod(ofdm_plcp_data,data_bits_per_symbol); %[Bits], see Gast, 2005, chapter 13,Transmission and Reception




% ---------------------------------- OFDM PLCP-Data and Pad-Bits for different data rates (only data_bits_per_symbol) ---------------------------------------------------------------------------------
plcp_data = ofdm_plcp_data + pad_bits; % [Bits], see Gast, 2005, chapter 13, OFDM PLCP, Figure 13-14. OFDM PLCP framing format



plcp_data_duration = plcp_data / (rate * mb); 
plcp_framing_bits = plcp_data;
plcp_framing_duration = preamble_duration + plcp_data_duration;%[sec],see Perahia and Stacey, 2008, page 71; Figure 4.10 Mixed format preamble
%frame_duration_20_mhz = preamble_duration + plcp_data_duration;%[sec],see Perahia and Stacey, 2008, page 71; Figure 4.10 Mixed format preamble
%frame_duration_40_mhz = preamble_duration_40_mhz + plcp_data_duration;%[sec],see Perahia and Stacey, 2008, page 105; Figure 5.4 40MHz mixed mode preamble.
%frame_duration_gf = preample_duration_gf + plcp_data_duration;%[sec]; see see  Perahia and Stacey, 2008, page 123; Figure 5.16 Greenfield format preamble



%cw_min = 15;%[slots], see Perahia and Stacey, 2008, page 188 
%cw_max = 1023;%[slots], see Perahia and Stacey, 2008, page 188 

end


end


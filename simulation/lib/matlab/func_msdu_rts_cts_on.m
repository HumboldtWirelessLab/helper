function [matrix_result,vector_rates_data,vector_msdu_sizes] = func_msdu_rts_cts_on()
    letter_of_standards = {'original','a','b','g','n'};
    [ vector_rates_80211 ]  = func_rates_standard_supported(letter_of_standards{1,4});
    vector_rates_data = [1,6,24,54];
    vector_rates_ack = min(vector_rates_80211);
    vector_rates_rts = min(vector_rates_80211);%vector_rates_80211a_mandatory;%[1,2];
    vector_rates_cts=  min(vector_rates_80211);%vector_rates_80211a_mandatory;%[1,2];
    vector_packet_loss_upper_limit = [0.1, 0.2, 0.3, 0.4, 0.5];
    vector_msdu_sizes = [500, 1500, 3000, 8000];
    use_ism_bandwith_ghz = 0;
    use_greenfield = 1;
    use_dsss_ofdm = 0;
    use_short_guard_interval = 0;
    use_bandwidth_40_MHz = 0;
    number_of_antennas = 1;
    is_Address4_requiered = 0;
    matrix_result = zeros(size(vector_rates_data,2),size(vector_msdu_sizes,2));
        %% Calculation of Bandwith (2.4 GHz, 5 GHz or both)
    is_ism_5_ghz = 0;
    is_ism_2_4_and_5_ghz = 0;
    if (use_ism_bandwith_ghz == 1)
        is_ism_5_ghz = 1;
    elseif (use_ism_bandwith_ghz == 2)
        is_ism_2_4_and_5_ghz = 1;
    else
        is_ism_2_4_ghz = 1;
    end
    %% Throughput calculation starts here
    for index_rates=1:1:size(vector_rates_data,2)
        for index_msdu=1:1:size(vector_msdu_sizes,2)
   %% ------------------ MAC-Layer calculation: overhead and msdu_size [bits]  -------------------
            % MAC-Frame IEEE 802.11 und IEEE 802.11a/b/g
            [frame_mac, frame_rts, frame_cts, frame_ack] = func_ieee_80211_mac(vector_msdu_sizes(1,index_msdu),is_Address4_requiered);
   %% Calculate for each rate and msdu-size the phy-layer duration for each MAC-Packet
            % Different physical layers IEEE 802.11 and IEEE 802.11a/b/g/n
            [duration_plcp_framing_mac, time_sifs, time_difs, time_slot, output_xml_frame_mac ] = func_layer_phy(vector_rates_data(1,index_rates), frame_mac, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz, use_greenfield, use_dsss_ofdm, use_short_guard_interval, use_bandwidth_40_MHz, number_of_antennas);
            [duration_plcp_framing_ack] = func_layer_phy(vector_rates_ack(1,1), frame_ack, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval,use_bandwidth_40_MHz,number_of_antennas);
            [duration_plcp_framing_rts] = func_layer_phy(vector_rates_rts(1,1), frame_rts, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval, use_bandwidth_40_MHz,number_of_antennas);
            [duration_plcp_framing_cts] = func_layer_phy( vector_rates_cts(1,1), frame_cts, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,use_dsss_ofdm,use_short_guard_interval, use_bandwidth_40_MHz,number_of_antennas);
   %% Calculate for each rate and msdu-size the physical layer duration for each MAC-Packet
            first_time = 0;
            for index_packet_loss_upper_limit=1:1:size(vector_packet_loss_upper_limit,2)
                dauer_rts_cts =  duration_plcp_framing_rts + 2 * time_difs * (1-vector_packet_loss_upper_limit(1,index_packet_loss_upper_limit)) + duration_plcp_framing_cts * (1-vector_packet_loss_upper_limit(1,index_packet_loss_upper_limit));               
                if (duration_plcp_framing_mac > dauer_rts_cts && first_time == 0)
                    matrix_result(index_rates,index_msdu) = vector_packet_loss_upper_limit(1,index_packet_loss_upper_limit);
                    first_time = 1;
                end
            end
        end
    end
end


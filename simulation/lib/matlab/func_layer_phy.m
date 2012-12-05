function [plcp_framing_duration,time_sifs, time_difs, time_slot, output_xml ] = func_layer_phy( rate_data, frame_data, is_ism_2_4_ghz, is_ism_5_ghz, is_ism_2_4_and_5_ghz,use_greenfield,dsss_ofdm_use,is_short_guard_interval, bandwidth,number_of_antennas)
%--------------------------- IEEE 802.11 - DSSS -----------------------------------
            %if ((~isempty(find(vector_rates_80211 == vector_rates(1,index_rates), 1))) && greenfield_use == 0 && is_ism_2_4_ghz == 1)
            %if ((~isempty(find(vector_rates_80211 == vector_rates(1,index_rates), 1))) && greenfield_use == 0 && use_802_11 == 1)
            [ vector_rates_80211 ]  = func_rates_standard_supported( ' ' );
            [ vector_rates_80211b ] = func_rates_standard_supported( 'b' );
            [ vector_rates_80211a ] = func_rates_standard_supported( 'a' );
            [ vector_rates_80211g ] = func_rates_standard_supported( 'g' );
            [ vector_rates_80211n ] = func_rates_standard_supported( 'n' );
            % time_sifs, time_difs, time_slot,vector_contention_window_standard,plcp_framing_bits,
            if ((~isempty(find(vector_rates_80211 == rate_data, 1)))  && use_greenfield == 0 && is_ism_2_4_ghz == 1) % && use_802_11 == 1)
                [time_sifs, time_difs, time_slot] = func_phy_ieee80211_get_sifs_difs();
                %[ vector_contention_window_standard ] =  func_ieee80211_contention_window_get();
                [plcp_framing_bits,plcp_framing_duration, output_xml_1] = func_phy_ieee80211(rate_data,frame_data);
                %[plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211(rate_ack,frame_ack);
                %[plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211(rate_rts,frame_rts);
                %[plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211(rate_cts,frame_cts);
            %--------------------------- IEEE 802.11b - HRDSSS -----------------------------------
            %elseif ((~isempty(find(vector_rates_80211b == vector_rates(1,index_rates), 1))) && is_ism_2_4_ghz == 1)
            elseif ((~isempty(find(vector_rates_80211b == rate_data, 1))) && is_ism_2_4_ghz == 1)
                [time_sifs, time_difs, time_slot ] = func_phy_ieee80211b_get_sifs_difs();
                %[ vector_contention_window_standard ] =  func_ieee80211b_contention_window_get();
                [plcp_framing_bits,plcp_framing_duration, output_xml_1] = func_phy_ieee80211b(rate_data,frame_data,use_greenfield);
                %[plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211b(rate_ack,frame_ack,greenfield_use_80211b);
                %[plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211b(rate_rts,frame_rts,greenfield_use_80211b);
                %[plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211b(rate_cts,frame_cts,greenfield_use_80211b);
            %--------------------------- IEEE 802.11a - OFDM -----------------------------------
            %elseif ((~isempty(find(vector_rates_80211a == vector_rates(1,index_rates), 1))) && is_ism_5_ghz == 1)
            elseif ((~isempty(find(vector_rates_80211a == rate_data, 1))) && is_ism_5_ghz == 1)
                [time_sifs, time_difs, time_slot ] = func_phy_ieee80211a_get_sifs_difs();
                %[ vector_contention_window_standard ] =  func_ieee80211a_contention_window_get();
                [plcp_framing_bits,plcp_framing_duration, output_xml_1] = func_phy_ieee80211a(rate_data,frame_data);
                %[plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211a(rate_ack,frame_ack);
                %[plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211a(rate_rts,frame_rts);
                %[plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211a(rate_cts,frame_cts);
            %--------------------------- IEEE 802.11g - OFDM %----------------------------------- 
            %elseif ((~isempty(find(vector_rates_80211g == vector_rates(1,index_rates), 1))) && is_ism_2_4_ghz == 1)
            elseif ((~isempty(find(vector_rates_80211g == rate_data, 1))) && is_ism_2_4_ghz == 1)
                [time_sifs, time_difs, time_slot ] = func_phy_ieee80211g_get_sifs_difs(use_greenfield); % If the network consists only of 802.11g stations, the slot time may be shortened from the 802.11b-compatible value to the shorter value used in 802.11a.; see Gast,2005,ERP Physical Medium Dependent (PMD) Layer; Characteristics of the ERP PHY
                %[ vector_contention_window_standard ] =  func_ieee80211g_contention_window_get(use_greenfield);
                [plcp_framing_bits,plcp_framing_duration, output_xml_1] = func_phy_ieee80211g(rate_data,frame_data,use_greenfield, dsss_ofdm_use);
                %[plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211g(rate_ack,frame_ack,greenfield_use, dsss_ofdm_use);
                %[plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211g(rate_rts,frame_rts,greenfield_use, dsss_ofdm_use);
                %[plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211g(rate_cts,frame_cts,greenfield_use, dsss_ofdm_use);
            %--------------------------- IEEE 802.11n - OFDM -----------------------------------
            %elseif ((~isempty(find(vector_rates_80211g == vector_rates(1,index_rates), 1))) && is_ism_2_4_and_5_ghz == 1)
            elseif ((~isempty(find(vector_rates_80211n == rate_data, 1))) && is_ism_2_4_and_5_ghz == 1)
                mcs_index_data = func_80211n_mapping_data_rate_2_mcs_index(rate_data,number_of_antennas);
                %mcs_index_ack = func_80211n_mapping_data_rate_2_mcs_index(rate_ack,number_of_antennas);
                %mcs_index_rts = func_80211n_mapping_data_rate_2_mcs_index(rate_rts,number_of_antennas);
                %mcs_index_cts = func_80211n_mapping_data_rate_2_mcs_index(rate_cts,number_of_antennas);
                [time_sifs, time_difs, time_slot ] = func_phy_ieee80211n_get_sifs_difs();
                %[ vector_contention_window_standard ] =  func_ieee80211n_contention_window_get();

                [plcp_framing_bits,plcp_framing_duration, output_xml_1] = func_phy_ieee80211n(mcs_index_data,frame_data,is_short_guard_interval, bandwidth,use_greenfield );
                %[plcp_framing_ack_bits,plcp_framing_ack_duration, output_xml_ack] = func_phy_ieee80211n(mcs_index_ack,frame_ack,short_guard_interval, bandwidth,greenfield );
                %[plcp_framing_bits_rts,plcp_framing_duration_rts, output_xml_rts] = func_phy_ieee80211n(mcs_index_rts,frame_rts,greenfield_use, dsss_ofdm_use);
                %[plcp_framing_bits_cts,plcp_framing_duration_cts, output_xml_cts] = func_phy_ieee80211n(mcs_index_cts,frame_cts,greenfield_use, dsss_ofdm_use);
            else
                time_sifs = 0;
                time_difs = 0;
                time_slot = 0;
                plcp_framing_duration = 0;
                plcp_framing_bits = 0;
                output_xml_1 = ' ';

                %plcp_framing_ack_duration = 0;
                %plcp_framing_duration_rts = 0;
                %plcp_framing_duration_cts = 0;
            end
            output_xml=  sprintf('%s\n <plcp_framing_bits> %d </plcp_framing_bits>\n',output_xml_1,plcp_framing_bits);


end


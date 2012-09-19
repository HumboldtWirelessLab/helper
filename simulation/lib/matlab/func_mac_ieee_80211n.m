%-------------ieee_80211n_mac-Function----------------------------------
% msdu:= msdu from LLC (Logic Link Control)-Layer (higher layer)
    % IEEE 802.3 LLC (see 802.11n-2009-specification.pdf,Seite 37 and 
    % Tannenbaum,Computernetzwerke, Seite 309ff)
%-----------------------------------------------------------------------

function [mpdu,output_xml] = func_mac_ieee_80211n(msdu, is_Address4_requiered, is_ht_required,is_frame_body_8_kb,is_a_msdu_used, number_of_msdus_in_a_msdus, is_a_mpdu_used, number_of_mpdus_in_a_mpdus)
    output_xml = ' ';
    mac_frame_body_size_max = 7955; %[Byte],see Perahia and Stacey, 2008, page 267, Figure Figure 11.1 MAC frame format. Reproduced with permission from IEEE (2007b)
    if (msdu >= 0 && msdu <= mac_frame_body_size_max) 
    %---------- Mac-Frame-Format; see 802.11n-2009-Spec, Seite 12; 7.1.2 General frame format ---------------
        mac_frame_control = 2; %[Bytes]
        mac_frame_duration_id = 2; %[Bytes]
        mac_frame_address_1 = 6; %[Bytes]
        mac_frame_address_2 = 6; %[Bytes]
        mac_frame_address_3 = 6; %[Bytes]
        mac_frame_sequence_control = 2; %[Bytes]
        mac_frame_address_4 = 6; %[Bytes]
        mac_frame_qos_control = 2; %[Bytes]
        mac_frame_ht_control = 4; %[Bytes]
        
        mac_frame_fcs = 4; %[Bytes]
    
        mac_frame_header = mac_frame_control + mac_frame_duration_id + mac_frame_address_1 + mac_frame_address_2 + mac_frame_address_3 +  mac_frame_sequence_control;%[Bytes]
  
        if (is_Address4_requiered == 1)
            mac_frame_header = mac_frame_header + mac_frame_address_4;
        end
        if (is_a_msdu_used == 0) % A-MSDU is off
            mpdu = mac_frame_header + msdu + mac_frame_fcs;
        else
            %---- A-MSDU (Aggregated MAC Service Data Unit); see 802.11n-2009-Spec,Seite 12; 7.1.2 General frame format --------
            if (is_frame_body_8_kb == 1)
                a_msdu_size_max = 7935; % [Bytes]; 8 KB
            else
                a_msdu_size_max = 3839; % [Bytes]; 4 KB
            end
            %---------A-MSDU is embedded in a QoS-Data-Frame (see 802.11n-2009-Spec,Seite 35)----------------------
            a_msdu_mac_header = mac_frame_header + mac_frame_qos_control;

            % HT-Controlfield is required:
            % - if the frame is an Control-Wrapper-Frame (see see Perahia and Stacey, 2008, page 281)
            % - if the HT-Control-Field is an QoS-Data-Frame and "when the
            % Order Bit in the Frame Control field is set and the frame is
            % sent in a high throughput PHY, i. e. HT-Greenfield format or
            % HT mixed format" (see see Perahia and Stacey, 2008, page 282)
            if (is_ht_required == 1)
                a_msdu_mac_header = a_msdu_mac_header  + mac_frame_ht_control;
            end
    
            [a_msdu, subframes_in_a_msdu_max, a_msdu_subframe_header, a_msdu_subframe_pad_bytes] = func_number_of_subframes_in_a_msdu_2(a_msdu_size_max, msdu,  number_of_msdus_in_a_msdus);
    
            %a_msdu_subframe_single_size = a_msdu_mac_header + a_msdu_subframe_header + msdu;
            mpdu =   a_msdu_mac_header + a_msdu + mac_frame_fcs;

            ratio_frame_a_msdu_max = (a_msdu/ a_msdu_size_max)* 100; % ratio between current and max frame [%]
        end
    
    %----------------A-MPDU (Aggregated MAC Protocol Data Unit)----------------
    
          
         if (is_a_mpdu_used)
            %[a_mpdu_frame, a_mpdu_subframe,  a_mpdu_subframe_padding, number_of_msdus_in_a_mpdu] = func_a_mpdu_calculation_2(mac_frame_a_msdu, number_of_a_mpdus);
            [a_mpdu_frame, a_mpdu_subframe,  a_mpdu_subframe_padding , number_of_mpdus_in_a_mpdus,ratio_current_max] = func_a_mpdu_calculation_2(mpdu, number_of_mpdus_in_a_mpdus);
            if (a_mpdu_frame > 0)
                mpdu = a_mpdu_frame;
            end
         end
    
        %a_mpdu_frame_subframe_single_1 = a_mpdu_subframe_delimiter + qos_data_frame_current_1;
  %a_mpdu_frame_subframe_single_2 = a_mpdu_subframe_delimiter + qos_data_frame_current_2;
  
        %a_mpdu_frame_subframe_single = a_mpdu_subframe_delimiter + a_mpdu_per_msdu_limit;
        %a_mpdu_subframe_padding_max = mod(a_mpdu_per_msdu_limit, 4); %[Bytes] padding = [0,...,3] and boundary = 32 Bit = 4 Bytes
        %a_mpdu_subframe_max = a_mpdu_subframe_delimiter + a_mpdu_per_msdu_limit + a_mpdu_subframe_padding_max; %[Bytes]; see 802.11n-2009-Spec,Seite 88
        %number_of_msdus_in_a_mpdu_max = floor(a_mpdu_total_limit / a_mpdu_subframe_max);
        %a_mpdu_frame_max = ((number_of_msdus_in_a_mpdu_max - 1) *  a_mpdu_subframe_max) + a_mpdu_frame_subframe_single;
    
        %ratio_frame_a_mpdu_max = (a_mpdu_frame_max / a_mpdu_total_limit)* 100; % ratio between current and max frame [%]
        %ratio_frame_a_mpdu_current_max_1 = (a_mpdu_frame_1 / a_mpdu_total_limit) * 100;
        output_xml = sprintf('%d %d %d %d %d %d %d %d %d',subframes_in_a_msdu_max, a_msdu_subframe_header,a_msdu_subframe_pad_bytes, a_mpdu_subframe, a_mpdu_subframe_padding, number_of_msdus_in_a_mpdu,ratio_frame_a_msdu_max,number_of_mpdus_in_a_mpdus,ratio_current_max);
    end
end






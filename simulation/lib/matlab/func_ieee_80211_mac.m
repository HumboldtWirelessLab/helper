function [mac_frame, rts_frame, cts_frame, ack_frame] = ieee_80211_mac(msdu, is_Address4_requiered)
% 802.11 MAC Layer (general) for 802.11 a/b/g

    % MAC-Header; see Gast, 2005, chapter 4, Data Frames, Figure 4-1. Generic data frame
    mac_header_frame_control = 2; %[Bytes]
    mac_header_duration_id = 2;%[Bytes]
    mac_header_address1 = 6; %[Bytes]
    mac_header_address2 = 6; %[Bytes]
    mac_header_address3 = 6; %[Bytes]
    mac_header_sequence_control = 2; %[Bytes]
    mac_header_address4 = 6; %[Bytes]
    mac_frame_fcs = 4;
    
    if (is_Address4_requiered)
        mac_frame_header = mac_header_frame_control + mac_header_duration_id + mac_header_address1 + mac_header_address2 + mac_header_address3 + mac_header_sequence_control + mac_header_address4;
    else
    %hint: the click router software did not implemented address4
        mac_frame_header = mac_header_frame_control + mac_header_duration_id + mac_header_address1 + mac_header_address2 + mac_header_address3 + mac_header_sequence_control;
    end
    mac_frame_body_maximum = 2312; %Frame-Body-Maximum-Size = 2312; in excel sheet max = 2304 bytes without 8 Byte LLC (maybe)
    
    
    if (msdu > mac_frame_body_maximum)
        %Muss fragmentiert werden
    end
    
    mac_frame = mac_frame_header + msdu + mac_frame_fcs; %total MAC-Frame
    
    rts_frame = mac_header_frame_control + mac_header_duration_id + mac_header_address1 +  mac_header_address2 + mac_frame_fcs;% see Gast, 2005, chapter 4, Control Frames, Request to Send (RTS), Figure 4-13. RTS frame
    
    cts_frame = mac_header_frame_control + mac_header_duration_id + mac_header_address1 + mac_frame_fcs; % see Gast, 2005, chapter 4, Control Frames, Clear to Send (CTS), Figure 4-15. CTS frame
    
    ack_frame = mac_header_frame_control + mac_header_duration_id + mac_header_address1 + mac_frame_fcs;% see Gast, 2005, chapter 4, Control Frames, Acknowledgment (ACK), Figure 4-17. ACK frame
    
end
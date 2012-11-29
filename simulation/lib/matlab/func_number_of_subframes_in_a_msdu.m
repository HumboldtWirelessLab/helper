function [a_msdu, subframes_in_a_msdu_max, a_msdu_subframe_header, a_msdu_subframe_pad_bytes] = func_number_of_subframes_in_a_msdu(a_msdu_size_max, msdu,  number_of_a_msdus)
 %------ A-MSDU-Subframe; see 802.11n-2009-Spec,Seite 36; 7.2.2.2 A-MSDU format --------------
    %------------Todo-Start: maybe it could be for that reason?? TODO:Check out--------
    msdu_size_max_802_11 = 2312; %[Bytes] for genereal 802.11 MAC-Frame-Body-Maximum-Size = 2312
    msdu_size_max = msdu_size_max_802_11 - 8; % in the 802.11n-2009-Specifiaction, Seite 37, msdu_maximum = 2304
    %--------Todo-End-------------------------------------------------------------------
    a_msdu = -1;
    subframes_in_a_msdu_max = -1;
    a_msdu_subframe_header = -1;
    a_msdu_subframe_pad_bytes =-1;
    
    if (msdu >= 0 && msdu <= msdu_size_max && a_msdu_size_max >= msdu) % see max MSDU size for 802.11n
       
    
    a_msdu_subframe_header_destination_address = 6;%[Bytes]
    a_msdu_subframe_header_source_address = 6;%[Bytes]
    a_msdu_subframe_header_length = 2;%[Bytes]
    
    % MSDU := Mac Service Data Unit; received from Logical Link Control
    % (LLC)-Sub-Layer
    %Next Generation Wireless LANs: Throughput, Robustness, and Reliability in
    %802.11n, Kapitel 8.2.1, Seite 209
    a_msdu_subframe_header = a_msdu_subframe_header_destination_address + a_msdu_subframe_header_source_address + a_msdu_subframe_header_length; %[Bytes] total = 14 Bytes
    %a_msdu_header and msdu is padded with 0 till 3 Bytes to round the
    %frame to a 32-Bit word boundary (see Next Generation Wireless LANs:
    %Throughput, Robustness, and Reliability in 802.11n, Seite 209) and
    %802.11n-2009-Specification, Seite 37
    a_msdu_subframe = a_msdu_subframe_header + msdu;
    a_msdu_subframe_pad_bytes = mod(a_msdu_subframe, 4); %[Bytes] padding = [0,...,3] and boundary = 32 Bit = 4 Bytes
    a_msdu_subframe_padding = a_msdu_subframe + a_msdu_subframe_pad_bytes;
    
    subframes_in_a_msdu_max =  floor(a_msdu_size_max / a_msdu_subframe_padding); % number of msdu with current size in a-msdu
    a_msdu_subframe_size_max = ((subframes_in_a_msdu_max - 1) *  a_msdu_subframe_padding) + a_msdu_subframe;
    if (number_of_a_msdus >= subframes_in_a_msdu_max)
        a_msdu = a_msdu_subframe_size_max;
    else
        a_msdu = ((number_of_a_msdus - 1) * a_msdu_subframe_padding) + a_msdu_subframe;
    end
    else 
         %fragmentationn bzw. Fehler, da diese Größe nicht spezifiziert ist
    end
end
function [a_mpdu_frame, a_mpdu_subframe,  a_mpdu_subframe_padding , number_of_mpdus_in_a_mpdus,ratio_current_max] = func_a_mpdu_calculation(mpdu, number_of_mpdus_in_a_mpdus)
    a_mpdu_total_limit =  65535; %[Bytes]; 64KB ; there are the following max. length: 8191, 16393, 32767, 65535 [Bytes] (see see Perahia and Stacey, 2008, page 294)
    a_mpdu_per_msdu_limit =  4095; % [Bytes]; see 802.11n-2009-Spec, Seite 90; Note 2
    a_mpdu_subframe_delimiter = 4; %[Bytes]; see 802.11n-2009-Spec,Seite 88
    
    a_mpdu_subframe_padding = -1;
    a_mpdu_subframe = -1;
    a_mpdu_frame = -1;
    
    if (mpdu >= 0 && mpdu <= a_mpdu_per_msdu_limit)    

        %--------------------------------------
        if (mpdu <=  a_mpdu_per_msdu_limit) % there is a constraint of the MSDU-Size in A-MPDU; see 802.11n-2009-Spec, Seite 90; Note 2
            a_mpdu_subframe_padding = mod(mpdu, 4); %[Bytes] padding = [0,...,3] and boundary = 32 Bit = 4 Bytes
            a_mpdu_subframe = a_mpdu_subframe_delimiter + mpdu + a_mpdu_subframe_padding; %[Bytes]; see 802.11n-2009-Spec,Seite 88
            number_of_mpdus_in_a_mpdu_max = floor(a_mpdu_total_limit / a_mpdu_subframe);
            
            a_mpdu_frame_size_max = number_of_mpdus_in_a_mpdu_max *  a_mpdu_subframe;
            
            if (number_of_mpdus_in_a_mpdus >= number_of_mpdus_in_a_mpdu_max)
                a_mpdu_frame = a_mpdu_frame_size_max;
                number_of_mpdus_in_a_mpdus = number_of_mpdus_in_a_mpdu_max;
            else
                a_mpdu_frame = number_of_mpdus_in_a_mpdus *  a_mpdu_subframe;
            end
            ratio_current_max = (a_mpdu_frame/ a_mpdu_frame_size_max)* 100; % ratio between current and max frame [%]
        end
    end
end


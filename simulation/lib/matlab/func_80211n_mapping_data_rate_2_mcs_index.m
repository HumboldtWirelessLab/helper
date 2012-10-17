%calculate the mcs_index according to data_rate and number_of_antennas for
%IEEE 802.11n
function [ mcs_index ] = func_80211n_mapping_data_rate_2_mcs_index(data_rate, number_of_antennas)
                  
 matrix_data_rates = func_80211n_data_rates_supported_get();
    mcs_index = -1;
    test_value = find(matrix_data_rates == data_rate);
    test_size_row = size(matrix_data_rates,1);
    if (size(test_value,1) == 1)
        if (test_value > test_size_row)
            mcs_index = mod(test_value,test_size_row) - 1;
        else
            mcs_index = test_value - 1;
        end
    elseif (size(test_value,1) > 1)
        switch number_of_antennas
            case 1
                row_min = 0;
                row_max = 7;
            case 2
                row_min = 8;
                row_max = 15;
            case 3 
                row_min = 16;
                row_max = 23;
            case 4
                row_min = 24;
                row_max = 31;
            otherwise
                row_min = 24;
                row_max = 31;
        end
        mcs_index_values = mod(test_value,test_size_row);
        for i =1:1:size(mcs_index_values,1)
            if (mcs_index_values(i) > row_min && mcs_index_values(i) <= row_max)
                mcs_index = mcs_index_values(i) - 1;
            end
        end
        if (mcs_index == -1)
            mcs_index = min(mcs_index_values) -1;
        end
    end
end

	

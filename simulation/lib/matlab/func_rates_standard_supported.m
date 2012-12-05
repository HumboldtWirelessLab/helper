function [ vector_rates ] = func_rates_standard_supported( letter_of_standard )
%------------ Supported rates for each Standard ----------------------------------------
    vector_rates_80211 = [1,2];
    vector_rates_80211b_hr_dsss = [5.5,11];
    vector_rates_80211a_mandatory = [6,12,24];
    vector_rates_80211a_optional = [9,18,36,48,54,72];
    switch letter_of_standard
        case{'b'}
            vector_rates = [vector_rates_80211,vector_rates_80211b_hr_dsss];
        case{'a'}
            vector_rates = sort([vector_rates_80211a_mandatory,vector_rates_80211a_optional]);
        case{'g'}
            vector_rates_80211g_erp_pbcc = [22,33];
            vector_rates_80211g_erp_ofdm = vector_rates_80211a;
            vector_rates = sort([vector_rates_80211,vector_rates_80211b_hr_dsss,vector_rates_80211g_erp_pbcc, vector_rates_80211g_erp_ofdm]);
        case{'n'}
            [matrix_data_rates_80211n ] = func_80211n_data_rates_supported_get();
            vector_rates = unique(matrix_data_rates_80211n)';
        otherwise
            vector_rates =vector_rates_80211;
    end

end


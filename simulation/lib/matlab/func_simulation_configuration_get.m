function [number_of_simulation] = func_simulation_configuration_get(folder_name,filename)
        filename_csv = sprintf('%s/%s',folder_name,filename);
        number_of_simulation = csvread(filename_csv);
end


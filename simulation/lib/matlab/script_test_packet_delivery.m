close all;
clear all; 
folder_name = 'messungen/v1';
filename = 'sim_packets_delivery_counter_global.csv';
filename_csv = sprintf('%s/%s',folder_name,filename);
matrix_2D = csvread(filename_csv);
number_of_simulations = 100;
matrix_packets_delivered = matrix_2D ./ number_of_simulations;


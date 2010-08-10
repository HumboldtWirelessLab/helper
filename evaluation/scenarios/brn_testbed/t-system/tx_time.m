% tx duration in musec
function y = tx_time(bitrate, mac_sz_bytes)

    bits = (mac_sz_bytes + 4) * 8; % add CRC

    switch (bitrate)
        case 1
            y = 144 + 48 + bits/bitrate;
        case 2
            y = 72 + 24 + bits/bitrate;
        case {5.5, 11}
            y = 72 + 24 + ceil(bits/bitrate);
        case {6, 9, 12, 18, 24, 36, 48, 54}
            y = 16+4+ceil(bits/(bitrate*4))*4;
        otherwise
            disp(strcat('Wrong bitrate: ', num2str(bitrate)));
            y = 0;
    end
end
% connection stuff
host = '192.168.5.197'; %'localhost';
port = 60001;

scrsz = get(0,'ScreenSize');
figure('Position',[100 scrsz(4)/2-100 scrsz(3)/2 scrsz(4)/2]);
h = gcf;
set(h,'RendererMode','Manual')  %  If you don't do this, the surface plot
set(h,'Renderer','OpenGL')      %    will draw VERY slowly.

numDataSrc = 38;
numTraces = 100;
f = zeros(numDataSrc, numTraces);

[X,Y] = meshgrid(1:numTraces, 1:numDataSrc);
h = surfc(X,Y,f);
zlim([0 100]);
colormap hsv;
set(h,'ZDataSource','f');
%set(h, 'EdgeColor', 'None');
%alpha(0.5);
shading interp;
%view(80+180,40+20)
xlabel('Time');
ylabel('Node');
zlabel('Channel Load (%)');
colorbar;    
set(gcf,'CloseRequestFcn', 'delete(gcf), input_socket.close');

% init TCP connection
import java.net.Socket
import java.io.*

try
    % throws if unable to connect
    input_socket = Socket(host, port);

    % get a buffered data input stream from the socket
    input_stream   = input_socket.getInputStream;
    d_input_stream = DataInputStream(input_stream);

    fprintf(1, 'Connected to server %s\n', host);
catch
    if ~isempty(input_socket)
        input_socket.close;
    end
end

try
    while(1)
        % read data from the socket - wait a short time first
        pause(0.02);
        bytes_available = input_stream.available;
        %fprintf(1, 'Reading %d bytes\n', bytes_available);

        if (bytes_available == 0)
            continue;
        end
        
        message = zeros(1, bytes_available, 'uint8');
        for i = 1:bytes_available
            message(i) = d_input_stream.readByte;
        end

        % pick-up the last
        idx = find(message == 127);
        if (size(idx,1) > 1)
            newdata = message(idx(end-1)+1:idx(end)-1);
        else
            newdata = message(1:idx(end)-1);
        end
        newdata = newdata';

        if (~isempty(newdata) && size(newdata,1) == numDataSrc)
            f = circshift(f',1)';
            f(:,1) = newdata;
            refreshdata;
        end
    end
catch Exp
    Exp.message
    disp('closing ...');
end

% cleanup
input_socket.close;

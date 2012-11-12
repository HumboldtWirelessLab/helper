function [ganttResponse] = ganttlab(varargin)
%GANTTLAB Interface to psgantt
%
% gantt = ganttlab(xml,css,datatype,width)
%   gantt    - gantt chart in requested datatype
%   xml, css - xml and css string in char data type
%   datatype - requested datatype of gantt chart
%   width    - width of image
%
% config = ganttlab('config','datatype')
%   config   - return available datatypes in cell matrix


%   Author(s):  M. Kutil
%   Copyright (c) 2006 CTU FEE
%   $Revision: 727 $  $Date: 2007-03-13 16:34:55 +0100 (út, 13 III 2007) $

% This file is part of Scheduling Toolbox.
%
% Scheduling Toolbox is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 2 of the
% License, or (at your option) any later version.
%
% Scheduling Toolbox is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Scheduling Toolbox; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
% USA

cnf.serverurl = 'http://rtime.felk.cvut.cz/psgantt/service/index.php';

ni = nargin;
switch ni
    case 4,
        % call psgantt from server

        %xmlE=base64encode(xml);
        %cssE=base64encode(css);
        xmlE     = varargin{1};
        cssE     = varargin{2};
        datatype = varargin{3};
        width    = varargin{4};

        values = {xmlE,cssE,datatype,width};
        names =  {'XML','CSS','datatype','width'};
        types =  {'int','int','int','int'};

        % Create the message, make the call, and convert the response into a variable.
        soapMessage = createSoapMessage( ...
            'urn:psGanttService', ...
            'psgantt', ...
            values,names,types,'rpc');
        try
            response = callSoapService( ...
                cnf.serverurl, ...
                'urn:psGanttService#psGanttService#psgantt', ...
                soapMessage);
        catch
            msgstruct = lasterror;
            error_msg = strread(msgstruct.message,'%s','delimiter','');
            msgstruct.message=error_msg{2:end};
            msgstruct.identifier = 'TORSCHE:ganttlab:serverError';
            error(msgstruct.identifier, '%s', msgstruct.message);            
        end
        outputInt = parseSoapResponse(response);
        outputStatus = outputInt(1);
        outputInt = outputInt(2:end);
        if strcmp(outputStatus,'0')
            msgstruct.message = outputInt;
            msgstruct.identifier = 'TORSCHE:ganttlab:serverError';
            error(msgstruct.identifier, '%s', msgstruct.message);
        end
        ganttResponse = base64decode(outputInt);

    case 2,
        % call psganttconfig from server
        switch varargin{1}
            case 'config',
                key = varargin{2};

                values = {key};
                names =  {'key'};
                types =  {'int'};

                % Create the message, make the call, and convert the response into a variable.
                soapMessage = createSoapMessage( ...
                    'urn:psGanttService', ...
                    'psganttconfig', ...
                    values,names,types,'rpc');
                response = callSoapService( ...
                    cnf.serverurl, ...
                    'urn:psGanttService#psGanttService#psganttconfig', ...
                    soapMessage);
                outputInt = parseSoapResponse(response);
                try
                    ganttResponse = eval(outputInt);
                catch
                    error('TORSCHE:ganttlab:serverError','Invalid data type response.')
                end
        end
    otherwise,
        error('TORSCHE:ganttlab:syntax','Invalid number of input arguments.')
end
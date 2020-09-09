function [data]= WiDAQ(IPAddress,Period, col_num)
% Author: 
%     Ahmad Bashaireh
%
% Purpose:
%     This function collects data transmitted to the PC through TCP/IP
%     server
%     (the PC should be connected to the server)
%     Also, one data column can be plotted in "real-time"
%
% Usage:
%     Inputs:
%       - IPAddress: IP address of the server (as a string)
%                     the default is '192.168.1.1'
%       - Period: amount of time to collect data in seconds
%                   (-1 for unlimited, stop by closing the graph or clicking
%                   on it)
%       - col_num: index of column to be plotted in "real-time"
%     Outputs:
%       - data: matrix contains the received data
%
% Last modified 3/25/2017

%% close connections if previously open
snew = instrfind;
if (~isempty(snew))
    for inst = snew
        if strfind(inst.Name,IPAddress)
            fclose(inst);
        end
    end
end

%% create and open TCP/IP object
TCPObject = tcpip(IPAddress,80,'NetworkRole', 'client');
TCPObject.InputBufferSize = 2^10;
% open the TCP/IP object
fopen(TCPObject);

%% get first data point
% discard first lint
fgetl(TCPObject);
data =str2num(fgetl(TCPObject));

%% check if we have proper data and parameters
% are we getting data?
if isempty(data)
    fprintf('Could not read from the server!\n')
    clean_up(TCPObject)
    fprintf('Exiting!')
    return
end
% do we have the required col. to plot?
if col_num > size(data,2)
    fprintf('Warning: Col. to be plotted exceeds matrix dimensions!\n')
    fprintf('\tCol. 1 will be plotted\n')
    col_num = 1;
end

%% Set up the figure window
figureHandle = figure('NumberTitle','off',...
    'Name','LaunchPad Data',...
    'Color',[0 0 0],'Visible','off');

% Set axes
axesHandle = axes('Parent',figureHandle,...
    'YGrid','on',...
    'YColor',[0.9725 0.9725 0.9725],...
    'XGrid','on',...
    'XColor',[0.9725 0.9725 0.9725],...
    'Color',[0 0 0]);

hold on;

%% some initializations
% flag for stopping data acquistion
stop_acq=0;
% link a click on the graph to the flag
set(axesHandle,'ButtonDownFcn',@(h,e)(eval('stop_acq=1')))


% are we limited by time or not?!
if Period == -1
    Period = inf;
end

%start timer
tic;
toc_first = toc;
time = toc;

% plot first data point
plotHandle = plot(axesHandle,toc,data(1,col_num),'Marker','.','LineWidth',1,'Color',[0 1 0]);

%% Collect data
count = 1;
while (toc<Period+toc_first)
    % if graph is closed or clicked on; stop
    if ~ishandle(axesHandle) || (stop_acq==1)
        break
    end
    time(count) = toc-toc_first; % read time elapsed
    data(count,:) = str2num(fgetl(TCPObject));  % get one line of data
    % update plot
    set(plotHandle,'YData',data(:,col_num),'XData',time);
    set(figureHandle,'Visible','on');
    count = count +1;
    pause(0.001);
end

clean_up(TCPObject)
end

%% Clean up the TCP/IP object
function [] = clean_up(CommObject)
fclose(CommObject);
delete(CommObject);
clear CommObject;
end

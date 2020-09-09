% open wifi connection
% Address:192.168.1.1, port:3553
udp_o = udp('192.168.1.1',3553);
fopen(udp_o)

% Commands
% direction1 speed2 direction2 speed1
% 1: 75, 2:75
fwrite(udp_o,[170,85,170,0])
pause(5.5)
% Stop
fwrite(udp_o,[170,255,170,255])

% NOTE:  We have to use the ?inverted? PWM strategy ? 
%    255 represents ?OFF?
%      0 represents completely ?ON?
%    170 represents forwards
%    187 represents backwards


% close the connection
fclose(udp_o); 

function [G] = channel_G(N,M,dis,frequency)
% N number of receiver
% M number of transmitter

hBS = 15; % Altura estación base (m)
hRIS = 6;
LOS = 1; % LOS para enlace planificado BS-RIS

G = ones(N,M);
PL_dB = calculate_pathloss_3GPP_UMi(dis, frequency, hBS, hRIS, LOS);
%PL_dB = PL_dB + 10*2.2*log10(dis); usando misma pendiente que en el paper 2.2
PL_linear = 10^(-PL_dB/10);

% Factor de corrección para igualar modelo original (opcional)
% PL_linear = PL_linear * 27.4699;  % +14.39 dB - Descomenta para igualar modelo original

G = sqrt(PL_linear) * G;

end

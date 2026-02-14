function [F] = channel_F(N,M,dis,frequency)
% N number of receiver
% M number of transmitter

% Generar fading Rayleigh con fases aleatorias (como en el modelo original)
%F = zeros(N,M);
%F = raylrnd(1,N,M);
F = ones(N,M);

%for aa=1:N
%    for bb=1:M
%       F(aa,bb) = F(aa,bb)*exp(1j*2*pi*rand());
%    end
%end

hRIS = 6;        % Altura RIS (m) - en edificios
hMS = 1.5;
LOS = 1;

PL_dB = calculate_pathloss_3GPP_UMi(dis, frequency, hRIS, hMS, LOS);
%PL_dB = PL_dB + 10*2.8*log10(dis); usando misma pendiente que en el paper 2.8

PL_linear = 10^(-PL_dB/10);
% antenna_gain_linear = 10^(3/10);  % 3 dBi
% F = sqrt(antenna_gain_linear) * F;
F = sqrt(PL_linear) * F;
end


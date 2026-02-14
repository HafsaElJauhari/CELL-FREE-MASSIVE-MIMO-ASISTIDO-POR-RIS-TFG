function [F] = channel_F_NLOS(N,M,dis,frequency)
% Canal F (RIS → Usuario) con NLOS
% Simula escenario donde hay obstrucciones o distancia muy larga
% N number of receiver
% M number of transmitter

hRIS = 6;        % Altura RIS (m) - en edificios
hMS = 1.5;       % Altura usuario (m)
LOS = 0;         % NLOS - Sin línea de visión directa

% Generar fading Rayleigh (multipath sin componente dominante)
F = zeros(N,M);
F = raylrnd(1,N,M);
for aa=1:N
    for bb=1:M
       F(aa,bb) = F(aa,bb)*exp(1j*2*pi*rand());
    end
end

% Path loss 3GPP para NLOS
PL_dB = calculate_pathloss_3GPP_UMi(dis, frequency, hRIS, hMS, LOS);
PL_linear = 10^(-PL_dB/10);

% Factor de corrección para igualar modelo original (opcional)
% PL_linear = PL_linear * 1.9815;  % +2.97 dB - Descomenta para igualar modelo original

F = sqrt(PL_linear) * F;
end


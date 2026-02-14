function [G] = channel_G_NLOS(N,M,dis,frequency)
% Canal G (BS → RIS) con NLOS
% Simula escenario con obstrucciones entre BS y RIS
% N number of receiver
% M number of transmitter

hBS = 3; % Altura estación base (m)
hRIS = 6;
LOS = 0; % NLOS - Enlace obstruido (no planificado)

% Agregar fading Rayleigh para NLOS (como en canal H)
G = zeros(N,M);
G = raylrnd(1,N,M);
for aa=1:N
    for bb=1:M
       G(aa,bb) = G(aa,bb)*exp(1j*2*pi*rand());
    end
end

PL_dB = calculate_pathloss_3GPP_UMi(dis, frequency, hBS, hRIS, LOS);
PL_linear = 10^(-PL_dB/10);

% Factor de corrección para igualar modelo original (opcional)
% PL_linear = PL_linear * 27.4699;  % +14.39 dB - Descomenta para igualar modelo original

G = sqrt(PL_linear) * G;

end


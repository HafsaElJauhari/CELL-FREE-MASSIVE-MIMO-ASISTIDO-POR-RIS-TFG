function [H] = channel_H(N,M,dis,frequency)
% N number of receiver
% M number of transmitter

hBS = 15;         % Altura estación base (m)
hMS = 1.5;        % Altura usuario (m)
LOS = 0; % NLOS

H = zeros(N,M);
H=raylrnd(1,N,M);

PL_dB = calculate_pathloss_3GPP_UMi(dis, frequency, hBS, hMS, LOS);
%PL_dB = PL_dB + 10*3.5*log10(dis); usando misma pendiente que en el paper 3.5
PL_linear = 10^(-PL_dB/10);

% Factor de corrección para igualar modelo original (opcional)
% PL_linear = PL_linear * 2.8573;  % +4.56 dB - Descomenta para igualar modelo original

for aa=1:N
    for bb=1:M
       H(aa,bb) = H(aa,bb)*exp(1j*2*pi*rand());
    end
end

H = sqrt(PL_linear) * H;
end

% H = √(ωBu/(1 + ωBu)) × HLoS + √(1/(1 + ωBu)) × HNLoS
%ωBu: Factor Rician para el enlace BS→Usuario
%HLoS: Componente de línea de vista
%HNLoS: Componente Rayleigh (sin línea de vista)

% Wbu = 0 (paper) sin linea de visión directa -> factor rician = 0
% HNLoS=raylrnd(1,N,M);

% H = HNLoS * √(1/(1 + ωBu)) = HNLoS

% H_total = H_fading × √L(d) 

% P_rx = P_tx × L(d)
%|H|² ∝ L(d) Entonces: |H| ∝ √L(d)



% ¿porque hay LoS?
% Co = -30 db = 10^-3 -->  10^(C₀[dB]/10)
% do = 1m 

% L(d) = C₀ × (d/d₀)^(-κ)
% L(d) = 10^(-3) × d^(-κ)


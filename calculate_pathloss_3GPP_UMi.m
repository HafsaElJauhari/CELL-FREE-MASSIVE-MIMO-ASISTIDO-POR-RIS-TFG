function PL = calculate_pathloss_3GPP_UMi(distance, frequency, hBS, hMS, LOS)
% Calcula path loss según 3GPP TR38.901 UMi
% distance: distancia 2D (metros)
% frequency: frecuencia (Hz)
% hBS: altura BS (metros)
% hMS: altura móvil (metros)
% LOS: 1 para LOS, 0 para NLOS
c = 3e8; % Velocidad de la luz

% Calcular la distancia de punto de ruptura
hBS_prime = hBS - 1;
hMS_prime = hMS - 1;

% Constantes
d_bp = (4 * hBS_prime * hMS_prime * frequency) / c;

if LOS == 1 %LOS
    if distance <= d_bp
        PL = 32.4 + 21*log10(distance) + 20*log10(frequency/1e9);
    else
        PL = 32.4 + 40*log10(distance) + 20*log10(frequency/1e9) - 9.5*log10((d_bp)^2 + (hBS - hMS)^2);
    end
else % NLOS
    PL = 35.3*log10(distance) + 22.4 + 21.3*log10(frequency/1e9) - 0.3*(hMS - 1.5);
end

% holografic mimo

% estacion - Ris - usuario, RIS MAS CERCA DE LA ESTACION BASE, y usuarios
% mas alejados

%ris de media a 50 m de la estacion base, 50 metros mas alla los usuarios
% capitulo 9 -> multiportadora, block fading, 4 portadoras de respuesta
% fija independientes


% todos los usuarios estan juntos, 2 en una punta y 2 en otra punta, la
% configuracion de las RIS debería ser otra: RIS atienda a unas dos y la
% otra RIS a los otros dos
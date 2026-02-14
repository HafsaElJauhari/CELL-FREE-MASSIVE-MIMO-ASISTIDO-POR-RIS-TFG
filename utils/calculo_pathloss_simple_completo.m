L = 80;
N_ris = 100;
B = 5;  % Número de estaciones base
R = 2;  % Número de RIS
hBS = 15;      % Altura estación base (m)
hRIS = 6;     % Altura RIS (m)
hUE = 1.5;    % Altura usuario (m)
frequencies = [1.5e9, 3.5e9, 8e9, 15e9]; % Hz
freq_names = {'1.5 GHz', '3.5 GHz', '8 GHz', '15 GHz'};
% Posiciones BS (líneas 8-12 de Position_generate_RIS_near_BS.m)
BS_position = zeros(B, 2);
BS_position(1,:) = [60, -200];
BS_position(2,:) = [70, -200];
BS_position(3,:) = [80, -200];
BS_position(4,:) = [90, -200];
BS_position(5,:) = [100, -200];
% Posiciones RIS (líneas 16-17 de Position_generate_RIS_near_BS.m)
RIS_position = zeros(R, 2);
RIS_position(1,:) = [79, -1];
RIS_position(2,:) = [81, -1];
% Posición usuario (aproximación)
UE_position = [L, 0]; % posicion en 60 m los usuarios, posicion optimo, subir la potencia de transmaision para poder comparar resultados, aumentar en proporcion

Dis_BStoRIS = zeros(B, R);
fprintf('  BS → RIS:\n');
for b = 1:B
    for r = 1:R
        dist_2D = sqrt((RIS_position(r,1) - BS_position(b,1))^2 + ...
                       (RIS_position(r,2) - BS_position(b,2))^2);
        Dis_BStoRIS(b,r) = sqrt(dist_2D^2 + (hRIS - hBS)^2);
        fprintf('    BS%d → RIS%d: %.2f m\n', b, r, Dis_BStoRIS(b,r));
    end
end

Dis_BStoUser = zeros(B, 1);
fprintf('\n  BS → Usuario:\n');
for b = 1:B
    dist_2D = sqrt((UE_position(1) - BS_position(b,1))^2 + ...
                   (UE_position(2) - BS_position(b,2))^2);
    Dis_BStoUser(b) = sqrt(dist_2D^2 + (hBS - hUE)^2);
    fprintf('    BS%d → UE: %.2f m\n', b, Dis_BStoUser(b));
end

Dis_RIStoUser = zeros(R, 1);
fprintf('\n  RIS → Usuario:\n');
for r = 1:R
    dist_2D = sqrt((UE_position(1) - RIS_position(r,1))^2 + ...
                   (UE_position(2) - RIS_position(r,2))^2);
    Dis_RIStoUser(r) = sqrt(dist_2D^2 + (hRIS - hUE)^2);
    fprintf('    RIS%d → UE: %.2f m\n', r, Dis_RIStoUser(r));
end

Ganancia_RIS_dB = 10*log10(N_ris^2);
fprintf('GANANCIA DE LA RIS:\n');
fprintf('  • N = %d elementos → Ganancia = %.1f dB\n', N_ris, Ganancia_RIS_dB);
fprintf('  • Fórmula: 10×log₁₀(N²)\n\n');

for f_idx = 1:length(frequencies)
    freq = frequencies(f_idx);
    freq_name = freq_names{f_idx};
    
    % 1) Path-loss directo para cada BS
    PL_direct = zeros(B, 1);
    fprintf('1) PATH-LOSS DIRECTO (BS → UE, NLOS):\n');
    for b = 1:B
        PL_direct(b) = calculate_pathloss_3GPP_UMi(Dis_BStoUser(b), freq, hBS, hUE, 0);
        fprintf('   BS%d → UE: %.2f dB (dist = %.2f m)\n', b, PL_direct(b), Dis_BStoUser(b));
    end
    PL_direct_avg = mean(PL_direct);
    fprintf('   → Promedio: %.2f dB\n\n', PL_direct_avg);
    
    % 2) Path-loss reflejado para cada BS-RIS combinación
    PL_reflejado_efectivo = zeros(B, R);
    fprintf('2) PATH-LOSS REFLEJADO (BS → RIS → UE, LOS+LOS):\n');
    for b = 1:B
        for r = 1:R
            % BS → RIS
            PL_BS_RIS = calculate_pathloss_3GPP_UMi(Dis_BStoRIS(b,r), freq, hBS, hRIS, 1);

            % RIS → UE
            PL_RIS_UE = calculate_pathloss_3GPP_UMi(Dis_RIStoUser(r), freq, hRIS, hUE, 1);

            % Path-loss total sin ganancia RIS
            PL_total_sin_ganancia = PL_BS_RIS + PL_RIS_UE;

            % Path-loss efectivo CON ganancia RIS
            PL_reflejado_efectivo(b,r) = PL_total_sin_ganancia;

            fprintf('   BS%d → RIS%d → UE:\n', b, r);
            fprintf('     • PL(BS%d→RIS%d) = %.2f dB (%.2f m)\n', b, r, PL_BS_RIS, Dis_BStoRIS(b,r));
            fprintf('     • PL(RIS%d→UE) = %.2f dB (%.2f m)\n', r, PL_RIS_UE, Dis_RIStoUser(r));
            fprintf('     • PL total (sin ganancia RIS) = %.2f + %.2f = %.2f dB\n', ...
                PL_BS_RIS, PL_RIS_UE, PL_total_sin_ganancia);
            fprintf('     • PL efectivo (sin aplicar ganancia RIS) = %.2f dB\n', ...
                PL_reflejado_efectivo(b,r));
        end
    end
    PL_reflejado_avg = mean(PL_reflejado_efectivo(:));
    fprintf('   → Promedio: %.2f dB\n\n', PL_reflejado_avg);
end

%añadir grafica numero de ris vs distancias
% barrido de la posicion del RIS en base a donde esten las RIS
%ris a la altura del usuario 80
% si probamos a mover el usuario, me va a bajar en el resto de posiciones
% diferente de 80
% colocar las ris en 60 y 80

% primer garfica: -200, 79, 81, --> pico mas alto en 80
% segunda grafica, colocar RIS mas separadas 40 y 80 --> bajada entre
% medias, lo mejor es en 40 y 80 --> usar un unico usuario que lo moveré 40
% y 120 (cada 10 metros), ris en 70 y 90 --> puntos buenos 70 y 90 (pero un poco menos
% buenos)

% varios usuarios alrededor del 40, --> con que estimes el canal para uno
% te sirve porque te ahorras la estimacion de los otros 9. Si sabes por
% cualquier otro mecanimso que tienes 10 usuarios cerca y con esa
% estimacion configuras el resto
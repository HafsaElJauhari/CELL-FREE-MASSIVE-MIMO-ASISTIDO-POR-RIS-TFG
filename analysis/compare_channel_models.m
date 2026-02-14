% Script para comparar el modelo de canal ORIGINAL vs ACTUAL (3GPP UMi)
clear; clc;

%% ==================== PARÁMETROS DE SIMULACIÓN ====================
% Usar los mismos parámetros que en main.m
B = 5;           % Número de BS
R = 2;           % Número de RIS
K = 4;           % Número de usuarios
P = 4;           % Subportadoras
N_ris = 100;     % Elementos por RIS
BS_antennas = 2; % Antenas por BS
User_antennas = 2; % Antenas por usuario

% Distancia de prueba
dist_test = 80;  % metros (puedes cambiar esto)

% Frecuencia de prueba
frequency = 3.5e9; % 3.5 GHz (puedes cambiar esto)

fprintf('=================================================================\n');
fprintf('COMPARACIÓN: MODELO ORIGINAL vs MODELO 3GPP UMi\n');
fprintf('=================================================================\n');
fprintf('Parámetros: B=%d, R=%d, K=%d, P=%d, N_ris=%d\n', B, R, K, P, N_ris);
fprintf('Distancia de prueba: %d m\n', dist_test);
fprintf('Frecuencia: %.2f GHz\n\n', frequency/1e9);

%% ==================== GENERAR POSICIONES ====================
[Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate(B, R, K, dist_test);

fprintf('Distancias generadas:\n');
fprintf('  BS->RIS: min=%.2f m, max=%.2f m, mean=%.2f m\n', ...
    min(Dis_BStoRIS(:)), max(Dis_BStoRIS(:)), mean(Dis_BStoRIS(:)));
fprintf('  BS->User: min=%.2f m, max=%.2f m, mean=%.2f m\n', ...
    min(Dis_BStoUser(:)), max(Dis_BStoUser(:)), mean(Dis_BStoUser(:)));
fprintf('  RIS->User: min=%.2f m, max=%.2f m, mean=%.2f m\n\n', ...
    min(Dis_RIStoUser(:)), max(Dis_RIStoUser(:)), mean(Dis_RIStoUser(:)));

%% ==================== MODELO ORIGINAL ====================
fprintf('Generando canales con MODELO ORIGINAL...\n');
tic;
[H_bkp_orig, F_rkp_orig, G_brp_orig] = Channel_generate_original(...
    B, R, K, P, N_ris, BS_antennas, User_antennas, ...
    Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser);
t_orig = toc;

%% ==================== MODELO ACTUAL (3GPP UMi) ====================
fprintf('Generando canales con MODELO 3GPP UMi...\n');
tic;
[H_bkp_new, F_rkp_new, G_brp_new] = Channel_generate(...
    B, R, K, P, N_ris, BS_antennas, User_antennas, ...
    Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser, frequency);
t_new = toc;

fprintf('Tiempo modelo original: %.4f s\n', t_orig);
fprintf('Tiempo modelo 3GPP: %.4f s\n\n', t_new);

%% ==================== ANÁLISIS Y COMPARACIÓN ====================
fprintf('=================================================================\n');
fprintf('COMPARACIÓN DE MAGNITUDES DE CANAL\n');
fprintf('=================================================================\n\n');

% --- Canal H (BS -> Usuario) ---
fprintf('--- CANAL H (BS -> Usuario) ---\n');
H_orig_mag = abs(H_bkp_orig);
H_new_mag = abs(H_bkp_new);

fprintf('ORIGINAL:\n');
fprintf('  Min: %.6e, Max: %.6e, Mean: %.6e, Std: %.6e\n', ...
    min(H_orig_mag(:)), max(H_orig_mag(:)), mean(H_orig_mag(:)), std(H_orig_mag(:)));

fprintf('3GPP UMi:\n');
fprintf('  Min: %.6e, Max: %.6e, Mean: %.6e, Std: %.6e\n', ...
    min(H_new_mag(:)), max(H_new_mag(:)), mean(H_new_mag(:)), std(H_new_mag(:)));

ratio_H = mean(H_new_mag(:)) / mean(H_orig_mag(:));
fprintf('  Ratio (Nuevo/Original): %.4f\n', ratio_H);
fprintf('  Diferencia en dB: %.2f dB\n\n', 20*log10(ratio_H));

% --- Canal F (RIS -> Usuario) ---
fprintf('--- CANAL F (RIS -> Usuario) ---\n');
F_orig_mag = abs(F_rkp_orig);
F_new_mag = abs(F_rkp_new);

fprintf('ORIGINAL:\n');
fprintf('  Min: %.6e, Max: %.6e, Mean: %.6e, Std: %.6e\n', ...
    min(F_orig_mag(:)), max(F_orig_mag(:)), mean(F_orig_mag(:)), std(F_orig_mag(:)));

fprintf('3GPP UMi:\n');
fprintf('  Min: %.6e, Max: %.6e, Mean: %.6e, Std: %.6e\n', ...
    min(F_new_mag(:)), max(F_new_mag(:)), mean(F_new_mag(:)), std(F_new_mag(:)));

ratio_F = mean(F_new_mag(:)) / mean(F_orig_mag(:));
fprintf('  Ratio (Nuevo/Original): %.4f\n', ratio_F);
fprintf('  Diferencia en dB: %.2f dB\n\n', 20*log10(ratio_F));

% --- Canal G (BS -> RIS) ---
fprintf('--- CANAL G (BS -> RIS) ---\n');
G_orig_mag = abs(G_brp_orig);
G_new_mag = abs(G_brp_new);

fprintf('ORIGINAL:\n');
fprintf('  Min: %.6e, Max: %.6e, Mean: %.6e, Std: %.6e\n', ...
    min(G_orig_mag(:)), max(G_orig_mag(:)), mean(G_orig_mag(:)), std(G_orig_mag(:)));

fprintf('3GPP UMi:\n');
fprintf('  Min: %.6e, Max: %.6e, Mean: %.6e, Std: %.6e\n', ...
    min(G_new_mag(:)), max(G_new_mag(:)), mean(G_new_mag(:)), std(G_new_mag(:)));

ratio_G = mean(G_new_mag(:)) / mean(G_orig_mag(:));
fprintf('  Ratio (Nuevo/Original): %.4f\n', ratio_G);
fprintf('  Diferencia en dB: %.2f dB\n\n', 20*log10(ratio_G));

%% ==================== ANÁLISIS DE PATH LOSS ====================
fprintf('=================================================================\n');
fprintf('ANÁLISIS DE PATH LOSS POR DISTANCIAS\n');
fprintf('=================================================================\n\n');

% Seleccionar una distancia representativa para análisis detallado
dis_example = mean(Dis_BStoUser(:));
fprintf('Ejemplo con distancia BS->User: %.2f m\n\n', dis_example);

% --- Canal H (NLOS) ---
fprintf('--- Canal H (BS -> Usuario, NLOS) ---\n');
PL_orig_H = 10^(-3) * dis_example^(-3.5);
fprintf('ORIGINAL: L(d) = 10^-3 × d^-3.5 = %.6e\n', PL_orig_H);

hBS = 3; hMS = 1.5; LOS_H = 0;
PL_dB_new_H = calculate_pathloss_3GPP_UMi(dis_example, frequency, hBS, hMS, LOS_H);
PL_new_H = 10^(-PL_dB_new_H/10);
fprintf('3GPP UMi: PL = %.2f dB → L(d) = %.6e\n', PL_dB_new_H, PL_new_H);
fprintf('Diferencia: %.2f dB\n\n', 10*log10(PL_new_H/PL_orig_H));

% --- Canal F (LOS/NLOS) ---
dis_example_F = mean(Dis_RIStoUser(:));
fprintf('--- Canal F (RIS -> Usuario, LOS) ---\n');
fprintf('Ejemplo con distancia RIS->User: %.2f m\n', dis_example_F);
PL_orig_F = 2*10^(-3) * dis_example_F^(-2.8);
fprintf('ORIGINAL: L(d) = 2×10^-3 × d^-2.8 = %.6e\n', PL_orig_F);

hRIS = 6; hMS = 1.5; LOS_F = 1;
PL_dB_new_F = calculate_pathloss_3GPP_UMi(dis_example_F, frequency, hRIS, hMS, LOS_F);
PL_new_F = 10^(-PL_dB_new_F/10);
fprintf('3GPP UMi: PL = %.2f dB → L(d) = %.6e\n', PL_dB_new_F, PL_new_F);
fprintf('Diferencia: %.2f dB\n\n', 10*log10(PL_new_F/PL_orig_F));

% --- Canal G (LOS) ---
dis_example_G = mean(Dis_BStoRIS(:));
fprintf('--- Canal G (BS -> RIS, LOS) ---\n');
fprintf('Ejemplo con distancia BS->RIS: %.2f m\n', dis_example_G);
PL_orig_G = 2*10^(-3) * dis_example_G^(-2.2);
fprintf('ORIGINAL: L(d) = 2×10^-3 × d^-2.2 = %.6e\n', PL_orig_G);

hBS = 3; hRIS = 6; LOS_G = 1;
PL_dB_new_G = calculate_pathloss_3GPP_UMi(dis_example_G, frequency, hBS, hRIS, LOS_G);
PL_new_G = 10^(-PL_dB_new_G/10);
fprintf('3GPP UMi: PL = %.2f dB → L(d) = %.6e\n', PL_dB_new_G, PL_new_G);
fprintf('Diferencia: %.2f dB\n\n', 10*log10(PL_new_G/PL_orig_G));

%% ==================== GRÁFICAS COMPARATIVAS ====================
fprintf('=================================================================\n');
fprintf('Generando gráficas comparativas...\n');
fprintf('=================================================================\n\n');

figure('Position', [100, 100, 1400, 800]);

% --- Subplot 1: Histogramas de |H| ---
subplot(2,3,1);
histogram(H_orig_mag(:), 50, 'Normalization', 'pdf', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
hold on;
histogram(H_new_mag(:), 50, 'Normalization', 'pdf', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
xlabel('|H| (magnitud)');
ylabel('Densidad de probabilidad');
title('Canal H (BS → Usuario)');
legend('Original', '3GPP UMi');
grid on;

% --- Subplot 2: Histogramas de |F| ---
subplot(2,3,2);
histogram(F_orig_mag(:), 50, 'Normalization', 'pdf', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
hold on;
histogram(F_new_mag(:), 50, 'Normalization', 'pdf', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
xlabel('|F| (magnitud)');
ylabel('Densidad de probabilidad');
title('Canal F (RIS → Usuario)');
legend('Original', '3GPP UMi');
grid on;

% --- Subplot 3: Histogramas de |G| ---
subplot(2,3,3);
histogram(G_orig_mag(:), 50, 'Normalization', 'pdf', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
hold on;
histogram(G_new_mag(:), 50, 'Normalization', 'pdf', 'FaceAlpha', 0.5, 'EdgeColor', 'none');
xlabel('|G| (magnitud)');
ylabel('Densidad de probabilidad');
title('Canal G (BS → RIS)');
legend('Original', '3GPP UMi');
grid on;

% --- Subplot 4: Path Loss vs Distancia (H) ---
subplot(2,3,4);
dist_range = linspace(10, 200, 100);
PL_orig_H_range = 10^(-3) * dist_range.^(-3.5);
PL_new_H_range = zeros(size(dist_range));
for i = 1:length(dist_range)
    PL_dB = calculate_pathloss_3GPP_UMi(dist_range(i), frequency, 3, 1.5, 0);
    PL_new_H_range(i) = 10^(-PL_dB/10);
end
semilogy(dist_range, PL_orig_H_range, 'b-', 'LineWidth', 2);
hold on;
semilogy(dist_range, PL_new_H_range, 'r--', 'LineWidth', 2);
xlabel('Distancia (m)');
ylabel('Path Loss (lineal)');
title('Path Loss - Canal H (NLOS)');
legend('Original (d^{-3.5})', '3GPP UMi');
grid on;

% --- Subplot 5: Path Loss vs Distancia (F) ---
subplot(2,3,5);
PL_orig_F_range = 2*10^(-3) * dist_range.^(-2.8);
PL_new_F_range = zeros(size(dist_range));
for i = 1:length(dist_range)
    PL_dB = calculate_pathloss_3GPP_UMi(dist_range(i), frequency, 6, 1.5, 1);
    PL_new_F_range(i) = 10^(-PL_dB/10);
end
semilogy(dist_range, PL_orig_F_range, 'b-', 'LineWidth', 2);
hold on;
semilogy(dist_range, PL_new_F_range, 'r--', 'LineWidth', 2);
xlabel('Distancia (m)');
ylabel('Path Loss (lineal)');
title('Path Loss - Canal F (LOS)');
legend('Original (d^{-2.8})', '3GPP UMi');
grid on;

% --- Subplot 6: Path Loss vs Distancia (G) ---
subplot(2,3,6);
PL_orig_G_range = 2*10^(-3) * dist_range.^(-2.2);
PL_new_G_range = zeros(size(dist_range));
for i = 1:length(dist_range)
    PL_dB = calculate_pathloss_3GPP_UMi(dist_range(i), frequency, 3, 6, 1);
    PL_new_G_range(i) = 10^(-PL_dB/10);
end
semilogy(dist_range, PL_orig_G_range, 'b-', 'LineWidth', 2);
hold on;
semilogy(dist_range, PL_new_G_range, 'r--', 'LineWidth', 2);
xlabel('Distancia (m)');
ylabel('Path Loss (lineal)');
title('Path Loss - Canal G (LOS)');
legend('Original (d^{-2.2})', '3GPP UMi');
grid on;

sgtitle(sprintf('Comparación de Modelos de Canal (f = %.2f GHz, L = %d m)', frequency/1e9, dist_test), ...
    'FontSize', 14, 'FontWeight', 'bold');

fprintf('¡Análisis completado!\n\n');
fprintf('=================================================================\n');
fprintf('CONCLUSIONES:\n');
fprintf('=================================================================\n');
fprintf('1. Modelo ORIGINAL: Path loss simple con exponentes fijos\n');
fprintf('2. Modelo 3GPP UMi: Path loss realista según estándar 3GPP\n');
fprintf('3. Las diferencias principales están en:\n');
fprintf('   - Magnitudes de los canales (ratios mostrados arriba)\n');
fprintf('   - Dependencia con la frecuencia (3GPP)\n');
fprintf('   - Transiciones LOS/NLOS más realistas (3GPP)\n');
fprintf('=================================================================\n\n');


%% ==================== FUNCIONES AUXILIARES (MODELO ORIGINAL) ====================
function [H_bkp, F_rkp, G_brp] = Channel_generate_original(B, R, K, P, N_ris, BS_antennas, User_antennas, Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser)
    H_bkp = zeros(B, K, P, BS_antennas, User_antennas);
    F_rkp = zeros(R, K, P, N_ris, User_antennas);
    G_brp = zeros(B, R, P, N_ris, BS_antennas);
    
    for b = 1:B
        for k = 1:K
            for p = 1:P
                H_bkp(b, k, p, :, :) = channel_H_original(BS_antennas, User_antennas, Dis_BStoUser(b, k));
            end
        end
    end
    
    for r = 1:R
        for k = 1:K
            for p = 1:P
                F_rkp(r, k, p, :, :) = channel_F_original(N_ris, User_antennas, Dis_RIStoUser(r, k));
            end
        end
    end
    
    for b = 1:B
        for r = 1:R
            for p = 1:P
                G_brp(b, r, p, :, :) = channel_G_original(N_ris, BS_antennas, Dis_BStoRIS(b, r));
            end
        end
    end
end

function [H] = channel_H_original(N, M, dis)
    % N number of receiver
    % M number of transmitter
    H = zeros(N, M);
    H = raylrnd(1, N, M);
    for aa = 1:N
        for bb = 1:M
            H(aa, bb) = H(aa, bb) * exp(1j * 2 * pi * rand());
        end
    end
    a = 10^(-3) * dis^(-3.5);
    a = sqrt(a);
    H = a * H;
end

function [F] = channel_F_original(N, M, dis)
    % N number of receiver
    % M number of transmitter
    F = zeros(N, M);
    F = raylrnd(1, N, M);
    for aa = 1:N
        for bb = 1:M
            F(aa, bb) = F(aa, bb) * exp(1j * 2 * pi * rand());
        end
    end
    a = 2 * 10^(-3) * dis^(-2.8); % 3dBi antenna gain
    F = sqrt(a) * F;
end

function [G] = channel_G_original(N, M, dis)
    % N number of receiver
    % M number of transmitter
    G = ones(N, M);
    a = 2 * 10^(-3) * dis^(-2.2);
    a = sqrt(a);
    G = a * G;
end


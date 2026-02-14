% Test de escenario PERFECTAMENTE SIMÉTRICO
% ==================================================
% Configuración simétrica:
%   - 2 BS con 1 antena cada una en (60, -200) y (100, -200)
%   - 2 RIS en (60, 1) y (100, 1)
%   - Usuarios con 1 antena
%   - Solo evaluar d=60 y d=100
% ==================================================
% Si el algoritmo es correcto, d=60 y d=100 deberían dar el MISMO resultado
% ==================================================

clear;

% Cargar CVX
addpath('/Users/hafsa.eljauhari@feverup.com/Documents/MATLAB/cvx');
cvx_setup;

tic

Iteration = 40;  % Suficientes iteraciones para promediar varianza estadística
dist = [60, 100];  % Solo estos dos puntos

% Barrido de frecuencias
frequencies = [3.5e9, 8e9, 15e9];
freq_names = {'3.5 GHz', '8 GHz', '15 GHz'};

% Almacenamiento de resultados
R_sum_sel_all = zeros(length(dist), Iteration, length(frequencies));
R_sum_nosel_all = zeros(length(dist), Iteration, length(frequencies));
R_sum_noRIS_all = zeros(length(dist), Iteration, length(frequencies));

% Tasas individuales por usuario
R_k_nosel_all = zeros(length(dist), Iteration, length(frequencies), 2);
R_k_sel_all = zeros(length(dist), Iteration, length(frequencies), 2);

% ======================================================
% PARÁMETROS DEL SISTEMA - ESCENARIO SIMÉTRICO
% ======================================================
B = 2;               % 2 BS (simétrico)
BS_antennas = 1;     % 1 antena por BS
User_antennas = 1;   % 1 antena por usuario
P_max = 0.005;
K = 2;               % 2 usuarios
P = 4;               % Subportadoras
R = 2;               % 2 RIS
N_ris_values = [64, 256, 900];  % Elementos RIS por frecuencia
sigma2 = 1e-11;

fprintf('===============================================\n');
fprintf('  TEST ESCENARIO PERFECTAMENTE SIMÉTRICO\n');
fprintf('===============================================\n');
fprintf('\n');
fprintf('Configuración:\n');
fprintf('  - BS: 2 estaciones en (60,-200) y (100,-200)\n');
fprintf('  - BS_antennas: %d\n', BS_antennas);
fprintf('  - RIS: 2 superficies en (60,1) y (100,1)\n');
fprintf('  - Usuarios: 2 con %d antena(s)\n', User_antennas);
fprintf('  - Puntos evaluados: d = [60, 100] m\n');
fprintf('  - Iteraciones: %d\n', Iteration);
fprintf('\n');
fprintf('Escenario:\n');
fprintf('  y=-200:  BS1(60)────────BS2(100)\n');
fprintf('  y=1:     RIS1(60)───────RIS2(100)\n');
fprintf('  y=0:     U1(d)──────────U2(120-d)\n');
fprintf('\n');
fprintf('Expectativa: d=60 y d=100 deben dar el MISMO resultado\n');
fprintf('===============================================\n\n');

for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    N_ris = N_ris_values(freq_idx);
    fprintf('\n=== Frecuencia: %.2f GHz (N=%d) ===\n', frequency/1e9, N_ris);
    
    for a = 1:length(dist)
        current_dist = dist(a);
        [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_simetrico(B, R, K, current_dist);
        fprintf('Punto d=%dm (U1 en x=%d, U2 en x=%d)\n', current_dist, current_dist, 120-current_dist);
        
        for b = 1:Iteration
            if mod(b, 10) == 0
                fprintf('  Iteración %d/%d\n', b, Iteration);
            end
            
            % Generación de canales
            [H_bkp, F_rkp, G_brp] = Channel_generate(B, R, K, P, N_ris, BS_antennas, User_antennas, Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser, frequency);
            
            % Inicialización
            [W_init, Theta_init] = W_Theta_intialize(P_max, B, K, P, R, N_ris, BS_antennas);
            
            % Sin RIS
            W_noRIS = W_init;
            [~, R_sum_noRIS] = MyAlgorithm_noRIS(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp, F_rkp, G_brp, W_noRIS);
            
            % Sin selección
            W_nosel = W_init;
            Theta_nosel = Theta_init;
            [~, ~, R_sum_nosel, R_k_nosel] = MyAlgorithm(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp, F_rkp, G_brp, W_nosel, Theta_nosel);
            
            % Con selección
            W_sel = W_init;
            Theta_sel = Theta_init;
            [~, ~, R_sum_sel, R_k_sel] = MyAlgorithm_sel(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp, F_rkp, G_brp, W_sel, Theta_sel);
            
            R_sum_noRIS_all(a, b, freq_idx) = R_sum_noRIS;
            R_sum_nosel_all(a, b, freq_idx) = R_sum_nosel;
            R_sum_sel_all(a, b, freq_idx) = R_sum_sel;
            R_k_nosel_all(a, b, freq_idx, :) = R_k_nosel;
            R_k_sel_all(a, b, freq_idx, :) = R_k_sel;
        end
    end
end

% Calcular promedios
R_sum_sel_mean = zeros(length(dist), length(frequencies));
R_sum_nosel_mean = zeros(length(dist), length(frequencies));
R_sum_noRIS_mean = zeros(length(dist), length(frequencies));
R_sum_sel_std = zeros(length(dist), length(frequencies));
R_sum_nosel_std = zeros(length(dist), length(frequencies));

for freq_idx = 1:length(frequencies)
    R_sum_sel_mean(:, freq_idx) = mean(R_sum_sel_all(:, :, freq_idx), 2);
    R_sum_nosel_mean(:, freq_idx) = mean(R_sum_nosel_all(:, :, freq_idx), 2);
    R_sum_noRIS_mean(:, freq_idx) = mean(R_sum_noRIS_all(:, :, freq_idx), 2);
    R_sum_sel_std(:, freq_idx) = std(R_sum_sel_all(:, :, freq_idx), 0, 2);
    R_sum_nosel_std(:, freq_idx) = std(R_sum_nosel_all(:, :, freq_idx), 0, 2);
end

% Mostrar resultados
fprintf('\n\n===============================================\n');
fprintf('          RESULTADOS (%d iteraciones)\n', Iteration);
fprintf('===============================================\n');

for freq_idx = 1:length(frequencies)
    fprintf('\n--- %s (N=%d) ---\n', freq_names{freq_idx}, N_ris_values(freq_idx));
    fprintf('  d(m) | Sin RIS  | Sin sel  | Con sel  | Std sel\n');
    fprintf('-------|----------|----------|----------|--------\n');
    for a = 1:length(dist)
        fprintf('  %3d  | %8.4f | %8.4f | %8.4f | %6.4f\n', ...
            dist(a), R_sum_noRIS_mean(a, freq_idx), R_sum_nosel_mean(a, freq_idx), ...
            R_sum_sel_mean(a, freq_idx), R_sum_sel_std(a, freq_idx));
    end
end

% ===============================================
% VERIFICACIÓN DE SIMETRÍA (d=60 vs d=100)
% ===============================================
fprintf('\n===============================================\n');
fprintf('   VERIFICACIÓN SIMETRÍA (d=60 vs d=100)\n');
fprintf('===============================================\n');
fprintf('\nSi los valores son iguales, el algoritmo es simétrico.\n\n');

fprintf('Frecuencia | Método     |   d=60   |  d=100   | Dif %%  | ¿OK?\n');
fprintf('-----------|------------|----------|----------|--------|------\n');

all_symmetric = true;
for freq_idx = 1:length(frequencies)
    idx_60 = 1;
    idx_100 = 2;
    
    % Sin selección
    val_60_nosel = R_sum_nosel_mean(idx_60, freq_idx);
    val_100_nosel = R_sum_nosel_mean(idx_100, freq_idx);
    dif_nosel = 100 * abs(val_60_nosel - val_100_nosel) / max(val_60_nosel, val_100_nosel);
    sym_nosel = dif_nosel < 5;
    
    % Con selección
    val_60_sel = R_sum_sel_mean(idx_60, freq_idx);
    val_100_sel = R_sum_sel_mean(idx_100, freq_idx);
    dif_sel = 100 * abs(val_60_sel - val_100_sel) / max(val_60_sel, val_100_sel);
    sym_sel = dif_sel < 5;
    
    if dif_nosel > 5 || dif_sel > 5
        all_symmetric = false;
    end
    
    fprintf('%10s | Sin sel    | %8.4f | %8.4f | %5.1f%% | %s\n', ...
        freq_names{freq_idx}, val_60_nosel, val_100_nosel, dif_nosel, iif(sym_nosel, 'OK', 'FALLO'));
    fprintf('%10s | Con sel    | %8.4f | %8.4f | %5.1f%% | %s\n', ...
        '', val_60_sel, val_100_sel, dif_sel, iif(sym_sel, 'OK', 'FALLO'));
    fprintf('-----------|------------|----------|----------|--------|------\n');
end

fprintf('\n===============================================\n');
if all_symmetric
    fprintf('  ✓ TODAS LAS PRUEBAS PASARON: Simetría verificada\n');
else
    fprintf('  ✗ ALGUNAS PRUEBAS FALLARON: Revisar algoritmo\n');
end
fprintf('===============================================\n');

fprintf('\n¡Simulación completada!\n');
toc
save('resultados_escenario_simetrico.mat');
fprintf('Resultados guardados en: resultados_escenario_simetrico.mat\n');

%% ======================================================
%% FUNCIÓN AUXILIAR: Posiciones simétricas
%% ======================================================
function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_simetrico(B, R, K, current_dist)
    Dis_BStoRIS = zeros(B, R);
    Dis_BStoUser = zeros(B, K);
    Dis_RIStoUser = zeros(R, K);
    
    hBS = 15; hRIS = 6; hUE = 1.5;
    
    % ======================================================
    % CONFIGURACIÓN SIMÉTRICA
    % ======================================================
    % 2 BS simétricas
    BS_position = [60 -200; 100 -200];  % BS1 en x=60, BS2 en x=100
    
    % 2 RIS simétricas (cerca de usuarios, en y=1)
    RIS_position = [60 1; 100 1];  % RIS1 en x=60, RIS2 en x=100
    
    % Usuarios simétricos: U1 en d, U2 en 120-d
    % d=60: U1(60,0), U2(60,0) - ambos en centro
    % d=100: U1(100,0), U2(20,0) - intercambiados respecto a d=20
    user_position = [current_dist 0; 120-current_dist 0];
    
    % Calcular distancias BS-RIS
    for b = 1:B
        for r = 1:R
            Dis_BStoRIS(b, r) = sqrt(sum((BS_position(b,:)-RIS_position(r,:)).^2) + (hRIS-hBS)^2);
        end
    end
    
    % Calcular distancias BS-Usuario
    for b = 1:B
        for k = 1:K
            Dis_BStoUser(b, k) = sqrt(sum((BS_position(b,:)-user_position(k,:)).^2) + (hBS-hUE)^2);
        end
    end
    
    % Calcular distancias RIS-Usuario
    for r = 1:R
        for k = 1:K
            Dis_RIStoUser(r, k) = sqrt(sum((RIS_position(r,:)-user_position(k,:)).^2) + (hRIS-hUE)^2);
        end
    end
end

%% Función auxiliar inline if
function result = iif(condition, true_val, false_val)
    if condition
        result = true_val;
    else
        result = false_val;
    end
end


% Simulación de selección vs no selección - SOLO PUNTOS DE RIS
% Puntos: d=20, d=60, d=100 (para verificar simetría y puntos RIS)
% Con 40 iteraciones para resultados estables
clear;
tic

Iteration = 40;
dist = [20, 60, 100];  % Solo estos puntos (RIS en x=60 y x=100)

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

% Parámetros del sistema
B = 5;
BS_antennas = 2;
User_antennas = 2;
P_max = 0.005;
K = 2;
P = 4;
R = 2;
N_ris_values = [64, 256, 900];
sigma2 = 1e-11;

fprintf('=== SIMULACIÓN PUNTOS RIS (40 iteraciones) ===\n');
fprintf('Puntos evaluados: d = [20, 60, 100] m\n');
fprintf('Posiciones RIS: x=60 y x=100\n\n');

for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    N_ris = N_ris_values(freq_idx);
    fprintf('\n=== Frecuencia: %.2f GHz (N=%d) ===\n', frequency/1e9, N_ris);
    
    for a = 1:length(dist)
        current_dist = dist(a);
        [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_selection(B, R, K, current_dist);
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
fprintf('\n\n========== RESULTADOS FINALES (%d iteraciones) ==========\n', Iteration);

for freq_idx = 1:length(frequencies)
    fprintf('\n--- %s (N=%d) ---\n', freq_names{freq_idx}, N_ris_values(freq_idx));
    fprintf('  d(m) | Sin RIS  | Sin sel  | Con sel  | Dif sel%% \n');
    fprintf('-------|----------|----------|----------|----------\n');
    for a = 1:length(dist)
        dif_sel = 100 * (R_sum_sel_mean(a, freq_idx) - R_sum_noRIS_mean(a, freq_idx)) / R_sum_noRIS_mean(a, freq_idx);
        fprintf('  %3d  | %8.4f | %8.4f | %8.4f | %+7.1f%%\n', ...
            dist(a), R_sum_noRIS_mean(a, freq_idx), R_sum_nosel_mean(a, freq_idx), ...
            R_sum_sel_mean(a, freq_idx), dif_sel);
    end
end

% Verificar simetría d=20 vs d=100
fprintf('\n========== VERIFICACIÓN SIMETRÍA (d=20 vs d=100) ==========\n');
fprintf('Freq     | d=20 sel | d=100 sel | Dif %%  | ¿Simétrico?\n');
fprintf('---------|----------|-----------|--------|------------\n');
for freq_idx = 1:length(frequencies)
    idx_20 = 1;  % d=20
    idx_100 = 3; % d=100
    val_20 = R_sum_sel_mean(idx_20, freq_idx);
    val_100 = R_sum_sel_mean(idx_100, freq_idx);
    dif = 100 * abs(val_20 - val_100) / max(val_20, val_100);
    sym = dif < 10;
    fprintf('%8s | %8.4f | %9.4f | %5.1f%% | %s\n', ...
        freq_names{freq_idx}, val_20, val_100, dif, string(sym));
end

fprintf('\n¡Simulación completada!\n');
toc
save('resultados_puntos_RIS.mat');
fprintf('Resultados guardados en: resultados_puntos_RIS.mat\n');

%% Función auxiliar
function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_selection(B, R, K, current_dist)
    Dis_BStoRIS = zeros(B, R);
    Dis_BStoUser = zeros(B, K);
    Dis_RIStoUser = zeros(R, K);
    
    hBS = 15; hRIS = 6; hUE = 1.5;
    
    BS_position = [60 -200; 70 -200; 80 -200; 90 -200; 100 -200];
    RIS_position = [60 -1; 100 -1];
    user_position = [current_dist 0; 120-current_dist 0];
    
    for b = 1:B
        for r = 1:R
            Dis_BStoRIS(b, r) = sqrt(sum((BS_position(b,:)-RIS_position(r,:)).^2) + (hRIS-hBS)^2);
        end
        for k = 1:K
            Dis_BStoUser(b, k) = sqrt(sum((BS_position(b,:)-user_position(k,:)).^2) + (hBS-hUE)^2);
        end
    end
    
    for r = 1:R
        for k = 1:K
            Dis_RIStoUser(r, k) = sqrt(sum((RIS_position(r,:)-user_position(k,:)).^2) + (hRIS-hUE)^2);
        end
    end
end


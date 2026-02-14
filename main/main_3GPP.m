clear;
tic

%% ==================== PARÁMETROS DEL SISTEMA ====================
Iteration = 10;         % Número de repeticiones Monte Carlo
dist = [0:10:160];      % Distancia L (m) del centro del grupo de usuarios
% dist = 120;           % (Ejemplo para un solo punto)

% Parámetro NUEVO: Frecuencia de trabajo
frequency = 2.4e9;      % 2.4 GHz (típica para comunicaciones inalámbricas)
% frequency = 3.5e9;    % 3.5 GHz (banda 5G)
% frequency = 28e9;     % 28 GHz (mmWave)

% Matrices de resultados
R_sum         = zeros(length(dist), Iteration); % Ideal RIS case (3GPP)
R_sum_Bench   = zeros(length(dist), Iteration); % Without direct link (3GPP)
R_sum_noRIS   = zeros(length(dist), Iteration); % Without RIS (3GPP)
R_sum_original = zeros(length(dist), Iteration); % Modelo original para comparación

%% ==================== CONFIGURACIÓN DEL SISTEMA ====================
B = 5;              % Número de BS
BS_antennas = 2;    % Antenas por BS (M)
User_antennas = 2;  % Antenas por usuario (U)
P_max = 0.001;      % Potencia máx. por BS (W) (= 0 dBm)
K = 4;              % Número de usuarios
P = 4;              % Subportadoras
R = 2;              % Número de RIS
N_ris = 100;        % Elementos por RIS (N)
sigma2 = 1e-11;     % Potencia de ruido

fprintf('=== SIMULACIÓN RIS CELL-FREE CON MODELOS 3GPP TR38.901 ===\n');
fprintf('Frecuencia: %.2f GHz\n', frequency/1e9);
fprintf('Comparando: Ideal RIS (3GPP) / Without Direct Link (3GPP) / Without RIS (3GPP) / Original\n\n');

%% ==================== SIMULACIÓN PRINCIPAL ====================
for a = 1:length(dist) 
    % Generar posiciones geométricas (misma función que el original)
    [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate(B, R, K, dist(a));
    
    fprintf('Punto L=%dm (%d/%d)\n', dist(a), a, length(dist));
    
    for b = 1:Iteration             
        %% ----- 1) Generación de canales con modelos 3GPP -----
        [H_bkp_3GPP, F_rkp_3GPP, G_brp_3GPP] = Channel_generate_3GPP(...
            B, R, K, P, N_ris, BS_antennas, User_antennas, ...
            Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser, frequency);
        
        %% ----- 2) Generación de canales con modelo original (comparación) -----
        [H_bkp_orig, F_rkp_orig, G_brp_orig] = Channel_generate(...
            B, R, K, P, N_ris, BS_antennas, User_antennas, ...
            Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser);     
        
        %% ----- 3) Inicialización de W (BS) y Θ (RIS) -----
        [W, Theta] = W_Theta_intialize(P_max, B, K, P, R, N_ris, BS_antennas);   
        
        %% ----- 4) ALGORITMOS CON MODELOS 3GPP -----
        
        % (A) Without RIS: solo canal directo H con 3GPP
        [W_noRIS, R_sum_noRIS(a,b)] = MyAlgorithm_noRIS(...
            B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, ...
            H_bkp_3GPP, F_rkp_3GPP, G_brp_3GPP, W);
        
        % (B) Without direct link: H=0, solo RIS con 3GPP
        [~, ~, R_sum_Bench(a,b)] = MyAlgorithm_Bench(...
            B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, ...
            0*H_bkp_3GPP, F_rkp_3GPP, G_brp_3GPP, W, Theta); 
        
        % (C) Ideal RIS case: framework propuesto con 3GPP
        [W_ideal, Theta_ideal, R_sum(a,b)] = MyAlgorithm(...
            B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, ...
            H_bkp_3GPP, F_rkp_3GPP, G_brp_3GPP, W, Theta); 
        
        %% ----- 5) ALGORITMO CON MODELO ORIGINAL (COMPARACIÓN) -----
        [W_orig, Theta_orig, R_sum_original(a,b)] = MyAlgorithm(...
            B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, ...
            H_bkp_orig, F_rkp_orig, G_brp_orig, W, Theta);
    end
end

%% ==================== PROMEDIO SOBRE REPETICIONES ====================
R_sum_mean         = mean(R_sum,         2); % Ideal RIS (3GPP)
R_sum_Bench_mean   = mean(R_sum_Bench,   2); % Without direct link (3GPP)
R_sum_noRIS_mean   = mean(R_sum_noRIS,   2); % Without RIS (3GPP)
R_sum_original_mean = mean(R_sum_original, 2); % Modelo original

%% ==================== GUARDAR RESULTADOS ====================
save(['results_3GPP_' num2str(frequency/1e9) 'GHz.mat'], ...
     'dist', 'frequency', 'R_sum_mean', 'R_sum_Bench_mean', ...
     'R_sum_noRIS_mean', 'R_sum_original_mean');

%% ==================== GRÁFICA COMPARATIVA ====================
figure; hold on; box on; grid on;

% Modelos 3GPP
plot(dist, R_sum_mean,         '-p',  'LineWidth', 2, 'MarkerSize', 8);
plot(dist, R_sum_Bench_mean,   ':*',  'LineWidth', 2, 'MarkerSize', 8);
plot(dist, R_sum_noRIS_mean,   '--^', 'LineWidth', 2, 'MarkerSize', 8);

% Modelo original para comparación
plot(dist, R_sum_original_mean, '-.o', 'LineWidth', 1.5, 'MarkerSize', 6, 'Color', [0.5 0.5 0.5]);

legend('Ideal RIS (3GPP)', 'Without Direct Link (3GPP)', ...
       'Without RIS (3GPP)', 'Ideal RIS (Original)', ...
       'Location', 'best');

xlabel('Distance ${\it L}$ (m)', 'Interpreter', 'latex');
ylabel('Weighted sum-rate (bit/s/Hz)', 'Interpreter', 'latex');
title(sprintf('Comparison: 3GPP UMi vs Original Models (f = %.1f GHz)', frequency/1e9));
set(gca, 'FontName', 'Times', 'FontSize', 12);

%% ==================== ANÁLISIS DE RESULTADOS ====================
fprintf('\n=== ANÁLISIS DE RESULTADOS ===\n');
fprintf('Frecuencia: %.2f GHz\n', frequency/1e9);
fprintf('Distancia de referencia: L = %d m\n', dist(end));

% Comparación en la distancia máxima
idx_max = length(dist);
fprintf('\nRendimiento en L = %dm:\n', dist(idx_max));
fprintf('  Ideal RIS (3GPP):        %.3f bit/s/Hz\n', R_sum_mean(idx_max));
fprintf('  Without Direct Link:     %.3f bit/s/Hz\n', R_sum_Bench_mean(idx_max));
fprintf('  Without RIS:             %.3f bit/s/Hz\n', R_sum_noRIS_mean(idx_max));
fprintf('  Ideal RIS (Original):    %.3f bit/s/Hz\n', R_sum_original_mean(idx_max));

% Ganancia del modelo 3GPP vs Original
gain_3GPP = R_sum_mean(idx_max) / R_sum_original_mean(idx_max);
fprintf('\nGanancia 3GPP vs Original: %.2fx (%.1f dB)\n', ...
        gain_3GPP, 10*log10(gain_3GPP));

toc

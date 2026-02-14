% Test de simetría para 2 usuarios - Solo puntos d=20 y d=100
% Estos puntos deberían dar el mismo R_sum (posiciones intercambiadas)
clear;
tic

Iteration = 5;  % Pocas iteraciones para test rápido
dist = [20, 100];  % Solo estos dos puntos

% Una sola frecuencia para test rápido
frequencies = [3.5e9];
freq_names = {'3.5 GHz'};

% Almacenamiento de resultados
R_sum_sel_all = zeros(length(dist), Iteration, length(frequencies));
R_sum_nosel_all = zeros(length(dist), Iteration, length(frequencies));

% Parámetros del sistema
B = 5;
BS_antennas = 2;
User_antennas = 2;
P_max = 0.005;
K = 2;  % 2 usuarios
P = 4;
R = 2;
N_ris_values = [64];
sigma2 = 1e-11;

for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    N_ris = N_ris_values(freq_idx);
    fprintf('\n=== Frecuencia: %.2f GHz ===\n', frequency/1e9);
    
    for a = 1:length(dist)
        current_dist = dist(a);
        [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_test(B, R, K, current_dist);
        fprintf('Punto d=%dm: U1 en x=%d, U2 en x=%d\n', current_dist, current_dist, 120-current_dist);
        
        for b = 1:Iteration
            fprintf('  Iteración %d/%d\n', b, Iteration);
            
            % Generación de canales
            [H_bkp, F_rkp, G_brp] = Channel_generate(B, R, K, P, N_ris, BS_antennas, User_antennas, Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser, frequency);
            
            % Inicialización
            [W_init, Theta_init] = W_Theta_intialize(P_max, B, K, P, R, N_ris, BS_antennas);
            
            % Sin selección
            W_nosel = W_init;
            Theta_nosel = Theta_init;
            [~, ~, R_sum_nosel, ~] = MyAlgorithm(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp, F_rkp, G_brp, W_nosel, Theta_nosel);
            
            % Con selección (algoritmo óptimo corregido)
            W_sel = W_init;
            Theta_sel = Theta_init;
            [~, ~, R_sum_sel, ~] = MyAlgorithm_sel(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp, F_rkp, G_brp, W_sel, Theta_sel);
            
            R_sum_nosel_all(a, b, freq_idx) = R_sum_nosel;
            R_sum_sel_all(a, b, freq_idx) = R_sum_sel;
        end
    end
end

% Calcular promedios
R_sum_sel_mean = mean(R_sum_sel_all, 2);
R_sum_nosel_mean = mean(R_sum_nosel_all, 2);

% Mostrar resultados
fprintf('\n\n========== RESULTADOS ==========\n');
fprintf('Posiciones:\n');
fprintf('  d=20:  U1 en x=20,  U2 en x=100\n');
fprintf('  d=100: U1 en x=100, U2 en x=20\n');
fprintf('  (Son las mismas posiciones físicas, solo intercambiadas)\n\n');

fprintf('--- Con selección (algoritmo ÓPTIMO) ---\n');
fprintf('  d=20:  R_sum = %.4f\n', R_sum_sel_mean(1));
fprintf('  d=100: R_sum = %.4f\n', R_sum_sel_mean(2));
fprintf('  Diferencia: %.4f (%.2f%%)\n', abs(R_sum_sel_mean(1)-R_sum_sel_mean(2)), ...
    100*abs(R_sum_sel_mean(1)-R_sum_sel_mean(2))/max(R_sum_sel_mean));

fprintf('\n--- Sin selección ---\n');
fprintf('  d=20:  R_sum = %.4f\n', R_sum_nosel_mean(1));
fprintf('  d=100: R_sum = %.4f\n', R_sum_nosel_mean(2));
fprintf('  Diferencia: %.4f (%.2f%%)\n', abs(R_sum_nosel_mean(1)-R_sum_nosel_mean(2)), ...
    100*abs(R_sum_nosel_mean(1)-R_sum_nosel_mean(2))/max(R_sum_nosel_mean));

fprintf('\n--- ¿Es simétrico? ---\n');
tol = 0.10;  % Tolerancia 10%
es_simetrico_sel = abs(R_sum_sel_mean(1)-R_sum_sel_mean(2))/max(R_sum_sel_mean) < tol;
es_simetrico_nosel = abs(R_sum_nosel_mean(1)-R_sum_nosel_mean(2))/max(R_sum_nosel_mean) < tol;
fprintf('  Con selección:  %s\n', string(es_simetrico_sel));
fprintf('  Sin selección:  %s\n', string(es_simetrico_nosel));

toc
save('resultados_test_simetria_2usuarios.mat');
fprintf('\nResultados guardados en: resultados_test_simetria_2usuarios.mat\n');

%% Función auxiliar
function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_test(B, R, K, current_dist)
    Dis_BStoRIS = zeros(B, R);
    Dis_BStoUser = zeros(B, K);
    Dis_RIStoUser = zeros(R, K);
    
    hBS = 15; hRIS = 6; hUE = 1.5;
    
    BS_position = [60 -200; 70 -200; 80 -200; 90 -200; 100 -200];
    RIS_position = [60 -1; 100 -1];
    user_position = [current_dist 0; 120-current_dist 0];  % U1 en d, U2 en 120-d
    
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


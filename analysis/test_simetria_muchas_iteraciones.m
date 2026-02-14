% Test de simetría con MUCHAS iteraciones
clear;
tic

Iteration = 30;  % Más iteraciones
dist = [20, 100];


B = 5; BS_antennas = 2; User_antennas = 2; P_max = 0.005;
K = 2; P = 4; R = 2; N_ris = 64; sigma2 = 1e-11;
frequency = 3.5e9;

R_sum_sel_all = zeros(length(dist), Iteration);
R_sum_nosel_all = zeros(length(dist), Iteration);


for a = 1:length(dist)
    current_dist = dist(a);
    fprintf('Punto d=%dm (U1 en x=%d, U2 en x=%d)\n', current_dist, current_dist, 120-current_dist);
    
    % Calcular distancias
    hBS = 15; hRIS = 6; hUE = 1.5;
    BS_position = [60 -200; 70 -200; 80 -200; 90 -200; 100 -200];
    RIS_position = [60 -1; 100 -1];
    user_position = [current_dist 0; 120-current_dist 0];
    
    Dis_BStoRIS = zeros(B, R);
    Dis_BStoUser = zeros(B, K);
    Dis_RIStoUser = zeros(R, K);
    
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
    
    for b = 1:Iteration
        if mod(b, 10) == 0
            fprintf('  Iteración %d/%d\n', b, Iteration);
        end
        
        [H_bkp, F_rkp, G_brp] = Channel_generate(B, R, K, P, N_ris, BS_antennas, User_antennas, Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser, frequency);
        [W_init, Theta_init] = W_Theta_intialize(P_max, B, K, P, R, N_ris, BS_antennas);
        
        [~, ~, R_sum_nosel, ~] = MyAlgorithm(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp, F_rkp, G_brp, W_init, Theta_init);
        [~, ~, R_sum_sel, ~] = MyAlgorithm_sel(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp, F_rkp, G_brp, W_init, Theta_init);
        
        R_sum_nosel_all(a, b) = R_sum_nosel;
        R_sum_sel_all(a, b) = R_sum_sel;
    end
end

% Resultados
fprintf('                    |   d=20    |   d=100   | Diferencia\n');
fprintf('--------------------|-----------|-----------|------------\n');

mean_nosel_20 = mean(R_sum_nosel_all(1,:));
mean_nosel_100 = mean(R_sum_nosel_all(2,:));
mean_sel_20 = mean(R_sum_sel_all(1,:));
mean_sel_100 = mean(R_sum_sel_all(2,:));

std_nosel_20 = std(R_sum_nosel_all(1,:));
std_nosel_100 = std(R_sum_nosel_all(2,:));
std_sel_20 = std(R_sum_sel_all(1,:));
std_sel_100 = std(R_sum_sel_all(2,:));

fprintf('Sin selección media | %9.4f | %9.4f | %9.4f (%.2f%%)\n', ...
    mean_nosel_20, mean_nosel_100, abs(mean_nosel_20-mean_nosel_100), ...
    100*abs(mean_nosel_20-mean_nosel_100)/max(mean_nosel_20, mean_nosel_100));
fprintf('Sin selección std   | %9.4f | %9.4f |\n', std_nosel_20, std_nosel_100);

fprintf('Con selección media | %9.4f | %9.4f | %9.4f (%.2f%%)\n', ...
    mean_sel_20, mean_sel_100, abs(mean_sel_20-mean_sel_100), ...
    100*abs(mean_sel_20-mean_sel_100)/max(mean_sel_20, mean_sel_100));
fprintf('Con selección std   | %9.4f | %9.4f |\n', std_sel_20, std_sel_100);

fprintf('\n========== DIAGNÓSTICO ==========\n');
tol = 0.10;  % 10% tolerancia
diff_sel = abs(mean_sel_20 - mean_sel_100) / max(mean_sel_20, mean_sel_100);
diff_nosel = abs(mean_nosel_20 - mean_nosel_100) / max(mean_nosel_20, mean_nosel_100);

if diff_sel < tol
    fprintf('✓ Con selección: SIMÉTRICO (diferencia < 10%%)\n');
else
    fprintf('✗ Con selección: NO SIMÉTRICO (diferencia = %.1f%%)\n', 100*diff_sel);
end

if diff_nosel < tol
    fprintf('✓ Sin selección: SIMÉTRICO (diferencia < 10%%)\n');
else
    fprintf('✗ Sin selección: NO SIMÉTRICO (diferencia = %.1f%%)\n', 100*diff_nosel);
end

toc
exit;




Punto d=20m (U1 en x=20, U2 en x=100)
  Iteración 10/30
  Iteración 20/30
  Iteración 30/30
Punto d=100m (U1 en x=100, U2 en x=20)
  Iteración 10/30
  Iteración 20/30
  Iteración 30/30
                    |   d=20    |   d=100   | Diferencia
--------------------|-----------|-----------|------------
Sin selección media |    0.7649 |    0.7679 |    0.0030 (0.39%)
Sin selección std   |    0.0722 |    0.0585 |
Con selección media |    0.6246 |    0.6070 |    0.0176 (2.82%)
Con selección std   |    0.1459 |    0.1656 |

Con selección: SIMÉTRICO (diferencia < 10%)
Sin selección: SIMÉTRICO (diferencia < 10%)

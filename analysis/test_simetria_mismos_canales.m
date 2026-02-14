% Test de simetría usando los MISMOS canales
% Intercambiamos los usuarios manualmente para ver si el algoritmo es simétrico
clear;

fprintf('=== TEST DE SIMETRÍA CON MISMOS CANALES ===\n\n');

% Parámetros
B = 5; BS_antennas = 2; User_antennas = 2; P_max = 0.005;
K = 2; P = 4; R = 2; N_ris = 64; sigma2 = 1e-11;
frequency = 3.5e9;

% Posiciones: U1 en x=20, U2 en x=100
fprintf('Escenario original: U1 en x=20, U2 en x=100\n');
fprintf('Escenario intercambiado: U1 en x=100, U2 en x=20\n\n');

hBS = 15; hRIS = 6; hUE = 1.5;
BS_position = [60 -200; 70 -200; 80 -200; 90 -200; 100 -200];
RIS_position = [60 -1; 100 -1];

% Posición original: U1 en x=20, U2 en x=100
user_position_orig = [20 0; 100 0];

% Calcular distancias originales
Dis_BStoRIS = zeros(B, R);
Dis_BStoUser_orig = zeros(B, K);
Dis_RIStoUser_orig = zeros(R, K);

for b = 1:B
    for r = 1:R
        Dis_BStoRIS(b, r) = sqrt(sum((BS_position(b,:)-RIS_position(r,:)).^2) + (hRIS-hBS)^2);
    end
    for k = 1:K
        Dis_BStoUser_orig(b, k) = sqrt(sum((BS_position(b,:)-user_position_orig(k,:)).^2) + (hBS-hUE)^2);
    end
end
for r = 1:R
    for k = 1:K
        Dis_RIStoUser_orig(r, k) = sqrt(sum((RIS_position(r,:)-user_position_orig(k,:)).^2) + (hRIS-hUE)^2);
    end
end

% Generar canales UNA SOLA VEZ
fprintf('Generando canales...\n');
[H_bkp_orig, F_rkp_orig, G_brp] = Channel_generate(B, R, K, P, N_ris, BS_antennas, User_antennas, Dis_BStoRIS, Dis_BStoUser_orig, Dis_RIStoUser_orig, frequency);

% Inicializar W y Theta
[W_init, Theta_init] = W_Theta_intialize(P_max, B, K, P, R, N_ris, BS_antennas);

%% CASO A: Canales originales (U1 en x=20, U2 en x=100)
fprintf('\n--- CASO A: U1(x=20), U2(x=100) ---\n');
[~, ~, R_sum_nosel_A, R_k_nosel_A] = MyAlgorithm(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp_orig, F_rkp_orig, G_brp, W_init, Theta_init);
[~, ~, R_sum_sel_A, R_k_sel_A] = MyAlgorithm_sel(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp_orig, F_rkp_orig, G_brp, W_init, Theta_init);

fprintf('Sin selección: R_sum = %.4f (U1=%.4f, U2=%.4f)\n', R_sum_nosel_A, R_k_nosel_A(1), R_k_nosel_A(2));
fprintf('Con selección: R_sum = %.4f (U1=%.4f, U2=%.4f)\n', R_sum_sel_A, R_k_sel_A(1), R_k_sel_A(2));

%% CASO B: Intercambiar canales de usuarios (simula U1 en x=100, U2 en x=20)
fprintf('\n--- CASO B: Intercambiar U1 <-> U2 ---\n');

% Intercambiar canales de usuarios en H_bkp
H_bkp_swap = H_bkp_orig;
H_bkp_swap(:, 1, :, :, :) = H_bkp_orig(:, 2, :, :, :);
H_bkp_swap(:, 2, :, :, :) = H_bkp_orig(:, 1, :, :, :);

% Intercambiar canales de usuarios en F_rkp
F_rkp_swap = F_rkp_orig;
F_rkp_swap(:, 1, :, :, :) = F_rkp_orig(:, 2, :, :, :);
F_rkp_swap(:, 2, :, :, :) = F_rkp_orig(:, 1, :, :, :);

[~, ~, R_sum_nosel_B, R_k_nosel_B] = MyAlgorithm(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp_swap, F_rkp_swap, G_brp, W_init, Theta_init);
[~, ~, R_sum_sel_B, R_k_sel_B] = MyAlgorithm_sel(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp_swap, F_rkp_swap, G_brp, W_init, Theta_init);

fprintf('Sin selección: R_sum = %.4f (U1=%.4f, U2=%.4f)\n', R_sum_nosel_B, R_k_nosel_B(1), R_k_nosel_B(2));
fprintf('Con selección: R_sum = %.4f (U1=%.4f, U2=%.4f)\n', R_sum_sel_B, R_k_sel_B(1), R_k_sel_B(2));

%% COMPARACIÓN
fprintf('\n========== COMPARACIÓN ==========\n');
fprintf('                    | Caso A    | Caso B    | Diferencia\n');
fprintf('--------------------|-----------|-----------|------------\n');
fprintf('Sin selección R_sum | %9.4f | %9.4f | %10.4f (%.2f%%)\n', ...
    R_sum_nosel_A, R_sum_nosel_B, abs(R_sum_nosel_A - R_sum_nosel_B), ...
    100*abs(R_sum_nosel_A - R_sum_nosel_B)/max(R_sum_nosel_A, R_sum_nosel_B));
fprintf('Con selección R_sum | %9.4f | %9.4f | %10.4f (%.2f%%)\n', ...
    R_sum_sel_A, R_sum_sel_B, abs(R_sum_sel_A - R_sum_sel_B), ...
    100*abs(R_sum_sel_A - R_sum_sel_B)/max(R_sum_sel_A, R_sum_sel_B));

fprintf('\n========== DIAGNÓSTICO ==========\n');
tol = 0.01;  % 1% tolerancia
if abs(R_sum_sel_A - R_sum_sel_B)/max(R_sum_sel_A, R_sum_sel_B) < tol
    fprintf('✓ Con selección: SIMÉTRICO (diferencia < 1%%)\n');
    fprintf('  El algoritmo es correcto.\n');
else
    fprintf('✗ Con selección: NO SIMÉTRICO (diferencia > 1%%)\n');
    fprintf('  HAY UN BUG en el algoritmo.\n');
end

if abs(R_sum_nosel_A - R_sum_nosel_B)/max(R_sum_nosel_A, R_sum_nosel_B) < tol
    fprintf('✓ Sin selección: SIMÉTRICO (diferencia < 1%%)\n');
else
    fprintf('✗ Sin selección: NO SIMÉTRICO\n');
end

%% Verificar qué RIS selecciona en cada caso
fprintf('\n========== SELECCIÓN DE RIS ==========\n');
[S_k_r_A, ~, ~] = RISselection(B, BS_antennas, User_antennas, K, P, R, N_ris, sigma2, H_bkp_orig, F_rkp_orig, G_brp, W_init, Theta_init);
[S_k_r_B, ~, ~] = RISselection(B, BS_antennas, User_antennas, K, P, R, N_ris, sigma2, H_bkp_swap, F_rkp_swap, G_brp, W_init, Theta_init);

fprintf('Caso A (U1 en x=20, U2 en x=100):\n');
fprintf('  U1 selecciona RIS: %d\n', find(S_k_r_A(1,:)));
fprintf('  U2 selecciona RIS: %d\n', find(S_k_r_A(2,:)));

fprintf('Caso B (U1 en x=100, U2 en x=20):\n');
fprintf('  U1 selecciona RIS: %d\n', find(S_k_r_B(1,:)));
fprintf('  U2 selecciona RIS: %d\n', find(S_k_r_B(2,:)));

fprintf('\nSi es simétrico, las selecciones deberían ser espejo:\n');
fprintf('  Caso A: U1→RIS_a, U2→RIS_b\n');
fprintf('  Caso B: U1→RIS_b, U2→RIS_a (intercambiado)\n');

exit;


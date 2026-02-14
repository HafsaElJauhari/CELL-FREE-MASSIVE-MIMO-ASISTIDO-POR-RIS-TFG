clear;
tic
Iteration=10;                          % Número de repeticiones por punto
dist = 0:10:120;                       % Barrido de posiciones del usuario

% Barrido de frecuencias
frequencies = [3.5e9, 8e9, 15e9];
freq_names = {'3.5 GHz', '8 GHz', '15 GHz'};

% Almacenamiento de resultados
R_sum_sel_all     = zeros(length(dist), Iteration, length(frequencies));
R_sum_nosel_all   = zeros(length(dist), Iteration, length(frequencies));
R_sum_noRIS_all   = zeros(length(dist), Iteration, length(frequencies));

% Tasas individuales por usuario (en este caso solo 1 usuario)
% Dimensiones: (dist, Iteration, frequencies, K)
R_k_nosel_all     = zeros(length(dist), Iteration, length(frequencies), 1);  % K=1 usuario
R_k_sel_all       = zeros(length(dist), Iteration, length(frequencies), 1);  % K=1 usuario

% Parámetros del sistema
B=5;                 % Número de BS
BS_antennas = 2;     % Antenas por BS
User_antennas = 2;   % Antenas por usuario
P_max = 0.005;       % Potencia máx. por BS (W)
K=1;                 % UN SOLO USUARIO en el escenario
P=4;                 % Subportadoras
R=2;                 % Número de RIS
N_ris_values = [64, 256, 900]; % Elementos por RIS según frecuencia
sigma2 = 1e-11;      % Potencia de ruido

for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    N_ris = N_ris_values(freq_idx);
    fprintf('\n=== Frecuencia: %.2f GHz ===\n', frequency/1e9);
    fprintf('Comparación (Selección vs. Sin selección) - 1 Usuario\n');

    for a=1:length(dist)
        current_dist = dist(a);
        [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_1user(B,R,K,current_dist);
        fprintf('Punto L=%dm (%d/%d)\n', current_dist, a, length(dist));

        for b=1:Iteration
% ----- 1) Generación de canales -----
            [H_bkp,F_rkp,G_brp] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS,Dis_BStoUser,Dis_RIStoUser,frequency);
% ----- 2) Inicialización común de W y Theta -----
            [W_init,Theta_init] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);

            W_noRIS = W_init;
            [~,R_sum_noRIS] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_noRIS);

            W_nosel = W_init;
            Theta_nosel = Theta_init;
            [~,~,R_sum_nosel,R_k_nosel] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_nosel,Theta_nosel);

            W_sel = W_init;
            Theta_sel = Theta_init;
            [~,~,R_sum_sel,R_k_sel] = MyAlgorithm_sel(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_sel,Theta_sel);

            R_sum_noRIS_all(a,b,freq_idx) = R_sum_noRIS;
            R_sum_nosel_all(a,b,freq_idx) = R_sum_nosel;
            R_sum_sel_all(a,b,freq_idx)   = R_sum_sel;
            R_k_nosel_all(a,b,freq_idx,:) = R_k_nosel;  % Tasa del usuario (sin selección)
            R_k_sel_all(a,b,freq_idx,:)   = R_k_sel;    % Tasa del usuario (con selección)
        end
    end
end

% Promedio sobre repeticiones
R_sum_sel_mean     = zeros(length(dist), length(frequencies));
R_sum_nosel_mean   = zeros(length(dist), length(frequencies));
R_sum_noRIS_mean   = zeros(length(dist), length(frequencies));

% Promedios de tasa del usuario
R_k_nosel_mean     = zeros(length(dist), length(frequencies), K);
R_k_sel_mean       = zeros(length(dist), length(frequencies), K);

for freq_idx = 1:length(frequencies)
    R_sum_sel_mean(:,freq_idx)     = mean(R_sum_sel_all(:,:,freq_idx), 2);
    R_sum_nosel_mean(:,freq_idx)   = mean(R_sum_nosel_all(:,:,freq_idx), 2);
    R_sum_noRIS_mean(:,freq_idx)   = mean(R_sum_noRIS_all(:,:,freq_idx), 2);
    
    % Promedio de tasa del usuario
    for k = 1:K
        R_k_nosel_mean(:,freq_idx,k) = mean(R_k_nosel_all(:,:,freq_idx,k), 2);
        R_k_sel_mean(:,freq_idx,k)   = mean(R_k_sel_all(:,:,freq_idx,k), 2);
    end
end

% Guardar todos los resultados
fprintf('\n¡Simulación completada!\n');
toc
save('resultados_selection_vs_no_selection_1user.mat');
fprintf('Resultados guardados en: resultados_selection_vs_no_selection_1user.mat\n');

%% Función auxiliar: posiciones del escenario (1 usuario)
function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_1user(B,R,K,current_dist)
Dis_BStoRIS = zeros(B, R);
Dis_BStoUser = zeros(B, K);
Dis_RIStoUser = zeros(R, K);

hBS = 15;
hRIS = 6;
hUE = 1.5;

BS_position = zeros(B, 2);
BS_position(1, :) = [60 -200];
BS_position(2, :) = [70 -200];
BS_position(3, :) = [80 -200];
BS_position(4, :) = [90 -200];
BS_position(5, :) = [100 -200];

RIS_position = zeros(R, 2);
RIS_position(1, :) = [60 -1];
RIS_position(2, :) = [100 -1];

% Solo 1 usuario
user_position = zeros(K, 2);
user_position(1, :) = [current_dist 0];

for b = 1:B
    for r = 1:R
        BS_position_temp = reshape(BS_position(b, :), 2, 1);
        RIS_position_temp = reshape(RIS_position(r, :), 2, 1);
        Dis_BStoRIS(b, r) = sqrt(distance(BS_position_temp, RIS_position_temp)^2 + (hRIS - hBS)^2);
    end
end

for b = 1:B
    for k = 1:K
        BS_position_temp = reshape(BS_position(b, :), 2, 1);
        user_position_temp = reshape(user_position(k, :), 2, 1);
        Dis_BStoUser(b, k) = sqrt(distance(BS_position_temp, user_position_temp)^2 + (hBS - hUE)^2);
    end
end

for r = 1:R
    for k = 1:K
        user_position_temp = reshape(user_position(k, :), 2, 1);
        RIS_position_temp = reshape(RIS_position(r, :), 2, 1);
        Dis_RIStoUser(r, k) = sqrt(distance(RIS_position_temp, user_position_temp)^2 + (hRIS - hUE)^2);
    end
end
end


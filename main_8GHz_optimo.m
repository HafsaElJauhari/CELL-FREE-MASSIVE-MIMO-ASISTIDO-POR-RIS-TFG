% Simulación 8 GHz - Selección ÓPTIMA
% 50 iteraciones, guarda resultados sin mostrar
clear;
tic

Iteration = 50;
dist = 0:10:120;
frequency = 8e9;
N_ris = 256;

% Almacenamiento
R_sum_sel_all = zeros(length(dist), Iteration);
R_sum_nosel_all = zeros(length(dist), Iteration);
R_sum_noRIS_all = zeros(length(dist), Iteration);
R_k_nosel_all = zeros(length(dist), Iteration, 2);
R_k_sel_all = zeros(length(dist), Iteration, 2);

% Parámetros
B = 5; BS_antennas = 2; User_antennas = 2; P_max = 0.005;
K = 2; P = 4; R = 2; sigma2 = 1e-11;

for a = 1:length(dist)
    current_dist = dist(a);
    [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_selection(B,R,K,current_dist);
    
    for b = 1:Iteration
        rng(a*1000 + b);  % Semilla reproducible por (distancia, iteración)
        [H_bkp,F_rkp,G_brp] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS,Dis_BStoUser,Dis_RIStoUser,frequency);
        [W_init,Theta_init] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);
        
        [~,R_sum_noRIS] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init);
        [~,~,R_sum_nosel,R_k_nosel] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init,Theta_init);
        [~,~,R_sum_sel,R_k_sel] = MyAlgorithm_sel(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init,Theta_init);
        
        R_sum_noRIS_all(a,b) = R_sum_noRIS;
        R_sum_nosel_all(a,b) = R_sum_nosel;
        R_sum_sel_all(a,b) = R_sum_sel;
        R_k_nosel_all(a,b,:) = R_k_nosel;
        R_k_sel_all(a,b,:) = R_k_sel;
    end
end

% Promedios
R_sum_sel_mean = mean(R_sum_sel_all, 2);
R_sum_nosel_mean = mean(R_sum_nosel_all, 2);
R_sum_noRIS_mean = mean(R_sum_noRIS_all, 2);
R_k_nosel_mean = squeeze(mean(R_k_nosel_all, 2));
R_k_sel_mean = squeeze(mean(R_k_sel_all, 2));

toc
save('resultados_8GHz_optimo.mat');

%% Función auxiliar
function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_selection(B,R,K,current_dist)
Dis_BStoRIS = zeros(B, R); Dis_BStoUser = zeros(B, K); Dis_RIStoUser = zeros(R, K);
hBS = 15; hRIS = 6; hUE = 1.5;
BS_position = [60 -200; 70 -200; 80 -200; 90 -200; 100 -200];
RIS_position = [60 -1; 100 -1];
user_position = [current_dist 0; 120-current_dist 0];
for b = 1:B
    for r = 1:R
        Dis_BStoRIS(b,r) = sqrt(sum((BS_position(b,:)-RIS_position(r,:)).^2) + (hRIS-hBS)^2);
    end
    for k = 1:K
        Dis_BStoUser(b,k) = sqrt(sum((BS_position(b,:)-user_position(k,:)).^2) + (hBS-hUE)^2);
    end
end
for r = 1:R
    for k = 1:K
        Dis_RIStoUser(r,k) = sqrt(sum((RIS_position(r,:)-user_position(k,:)).^2) + (hRIS-hUE)^2);
    end
end
end


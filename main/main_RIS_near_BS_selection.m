clear;
tic
Iteration=10;                     % Número de repeticiones
dist = 0:10:120;                  % Barrido simétrico de posiciones

frequencies = [3.5e9, 8e9, 15e9];
freq_names = {'3.5 GHz', '8 GHz', '15 GHz'};

R_sum_sel_all     = zeros(length(dist), Iteration, length(frequencies));
R_sum_nosel_all   = zeros(length(dist), Iteration, length(frequencies));
R_sum_noRIS_all   = zeros(length(dist), Iteration, length(frequencies));

B = 5;
BS_antennas = 2;
User_antennas = 2;
P_max = 0.005;
K = 2;                 % Dos usuarios (UE1 y UE2)
P = 4;
R = 2;
N_ris_values = [64, 256, 900];
sigma2 = 1e-11;

for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    N_ris = N_ris_values(freq_idx);
    fprintf('\n=== Frecuencia: %.2f GHz ===\n', frequency/1e9);
    fprintf('Escenario RIS pegada a BS (Selección vs. Sin selección vs. Sin RIS)\n');

    for a = 1:length(dist)
        current_dist = dist(a);
        [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_RIS_near_BS_selection(B,R,K,current_dist);
        fprintf('Punto L=%dm (%d/%d)\n', current_dist, a, length(dist));

        for b = 1:Iteration
            [H_bkp,F_rkp,G_brp] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS,Dis_BStoUser,Dis_RIStoUser,frequency);
            [W_init,Theta_init] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);

            [~,R_sum_noRIS] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init);
            [~,~,R_sum_nosel] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init,Theta_init);
            [~,~,R_sum_sel]   = MyAlgorithm_sel(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init,Theta_init);

            R_sum_noRIS_all(a,b,freq_idx) = R_sum_noRIS;
            R_sum_nosel_all(a,b,freq_idx) = R_sum_nosel;
            R_sum_sel_all(a,b,freq_idx)   = R_sum_sel;
        end
    end
end

R_sum_sel_mean     = zeros(length(dist), length(frequencies));
R_sum_nosel_mean   = zeros(length(dist), length(frequencies));
R_sum_noRIS_mean   = zeros(length(dist), length(frequencies));

for freq_idx = 1:length(frequencies)
    R_sum_sel_mean(:,freq_idx)     = mean(R_sum_sel_all(:,:,freq_idx), 2);
    R_sum_nosel_mean(:,freq_idx)   = mean(R_sum_nosel_all(:,:,freq_idx), 2);
    R_sum_noRIS_mean(:,freq_idx)   = mean(R_sum_noRIS_all(:,:,freq_idx), 2);
end

fprintf('Generando gráficas...\n');
figure('Position', [100, 100, 1400, 500]);
tiledlayout(1, length(frequencies), 'TileSpacing', 'compact', 'Padding', 'compact');

color_sel   = [0.0000 0.4470 0.7410];
color_nosel = [0.8500 0.3250 0.0980];
color_noRIS = [0.3000 0.3000 0.3000];

for freq_idx = 1:length(frequencies)
    nexttile(freq_idx);
    hold on; box on; grid on;

    plot(dist, R_sum_sel_mean(:,freq_idx),   '-o', 'LineWidth', 1.5, 'Color', color_sel,   'MarkerFaceColor', color_sel);
    plot(dist, R_sum_nosel_mean(:,freq_idx), '--^', 'LineWidth', 1.5, 'Color', color_nosel,'MarkerFaceColor', color_nosel);
    plot(dist, R_sum_noRIS_mean(:,freq_idx), ':s', 'LineWidth', 1.5, 'Color', color_noRIS,'MarkerFaceColor', color_noRIS);

    legend('Con selección', 'Sin selección', 'Sin RIS', 'Location', 'best');
    xlabel('Posición ${\it L}$ (m)','Interpreter','latex');
    ylabel('Weighted sum-rate (bit/s/Hz)','Interpreter','latex');
    title(sprintf('Frecuencia: %s', freq_names{freq_idx}));
    set(gca,'FontName','Times','FontSize',10);
end

sgtitle('Comparativa de tasas con RIS adosadas a las BS', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('\n¡Simulación completada!\n');
toc

function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_RIS_near_BS_selection(B,R,K,current_dist)
Dis_BStoRIS = zeros(B,R);
Dis_BStoUser = zeros(B,K);
Dis_RIStoUser = zeros(R,K);

hBS = 15;
hRIS = 6;
hUE = 1.5;

BS_position = zeros(B,2);
BS_position(1,:) = [40 -200];
BS_position(2,:) = [60 -200];
BS_position(3,:) = [80 -200];
BS_position(4,:) = [100 -200];
BS_position(5,:) = [120 -200];

RIS_position = zeros(R,2);
RIS_position(1,:) = [60 -199];  % Adosada a la BS en 60 m
RIS_position(2,:) = [100 -199]; % Adosada a la BS en 100 m

user_position = zeros(K,2);
user_position(1,:) = [current_dist 0];          % Usuario en barrido
user_position(2,:) = [120-current_dist 0];      % Usuario complementario

for b = 1:B
    for r = 1:R
        BS_temp = reshape(BS_position(b,:),2,1);
        RIS_temp = reshape(RIS_position(r,:),2,1);
        Dis_BStoRIS(b,r) = sqrt(distance(BS_temp,RIS_temp)^2 + (hRIS - hBS)^2);
    end
end

for b = 1:B
    for k = 1:K
        BS_temp = reshape(BS_position(b,:),2,1);
        user_temp = reshape(user_position(k,:),2,1);
        Dis_BStoUser(b,k) = sqrt(distance(BS_temp,user_temp)^2 + (hBS - hUE)^2);
    end
end

for r = 1:R
    for k = 1:K
        user_temp = reshape(user_position(k,:),2,1);
        RIS_temp = reshape(RIS_position(r,:),2,1);
        Dis_RIStoUser(r,k) = sqrt(distance(RIS_temp,user_temp)^2 + (hRIS - hUE)^2);
    end
end
end


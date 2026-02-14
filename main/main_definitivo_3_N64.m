clear;
tic
Iteration=10;    % 40 - Numero de repeticiones
dist = 40:10:120; % Distancias L (m) del usuario

% MODO 2: Barrido de frecuencias (ACTIVO)
frequencies = [3.5e9, 8e9, 15e9]; % 3.5, 8, 15 GHz
freq_names = {'3.5 GHz', '8 GHz', '15 GHz'};

% Matrices para almacenar resultados de cada frecuencia
R_sum_all         = zeros(length(dist), Iteration, length(frequencies)); 
R_sum_noRIS_all   = zeros(length(dist), Iteration, length(frequencies));

B=5;          % Numero de BS
BS_antennas = 2; % Antenas por BS (M)
User_antennas = 2;% Antenas por usuario (U)
P_max = 0.005;   % Potencia mx. por BS (W) (= 7 dBm) - Ajustado para compensar path loss 3GPP UMi
K=1;           % Unico usuario fijo
P=4;           % Subportadoras optimizan para todo el escenario y no para una ris en concreto
R=2;           % Numero de RIS
N_ris_fixed = 64; % Elementos por RIS para todas las frecuencias
sigma2 = 1e-11;  % Potencia de ruido

%% ==================== BUCLE PARA MÚLTIPLES FRECUENCIAS (ACTIVO) ====================
for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    N_ris = N_ris_fixed; % Elementos de la RIS constantes
    fprintf('\n=== Frecuencia: %.2f GHz ===\n', frequency/1e9);
    fprintf('Simulacion (curvas: Ideal RIS / Without RIS)\n');

    for a=1:length(dist) 
       [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate_RIS7090(B,R,K,dist(a));
        fprintf('Punto L=%dm (%d/%d)\n', dist(a), a, length(dist));

        for b=1:Iteration             
% ----- 1) Generación de canales (BS-user, RIS-user, BS-RIS) -----
            [ H_bkp,F_rkp,G_brp ] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS, Dis_BStoUser,Dis_RIStoUser, frequency);     
% ----- 2) Inicialización de W (BS) y Theta (RIS) -----
            [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);   
% (A) Without RIS: solo canal directo H y precodificación multiusuario
            [W,R_sum_noRIS_all(a,b,freq_idx)] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W);
% (B) Without direct link: fuerza H=0 y usa solo trayectorias vía RIS (opcional)
            %[~,~,R_sum_Bench(a,b)] = MyAlgorithm_Bench(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,0*H_bkp,F_rkp,G_brp,W,Theta); 
% (D) Ideal RIS case (marco propuesto, caso ideal del paper)
            [W,Theta,R_sum_all(a,b,freq_idx)] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
        end
    end
end

% ===== PROMEDIO PARA MÚLTIPLES FRECUENCIAS (ACTIVO) =====
R_sum_mean_all        = zeros(length(dist), length(frequencies));
R_sum_noRIS_mean_all  = zeros(length(dist), length(frequencies));

for freq_idx = 1:length(frequencies)
    R_sum_mean_all(:,freq_idx)        = mean(R_sum_all(:,:,freq_idx), 2);
    R_sum_noRIS_mean_all(:,freq_idx)  = mean(R_sum_noRIS_all(:,:,freq_idx), 2);
end

%% ==================== GRÁFICA PARA MÚLTIPLES FRECUENCIAS (ACTIVO) ====================
fprintf('Generando gráficas...\n');
figure('Position', [100, 100, 1400, 500]);
tiledlayout(1, length(frequencies), 'TileSpacing', 'compact', 'Padding', 'compact');

% Colores para las curvas
colors = {'b', 'r', 'g'};

for freq_idx = 1:length(frequencies)
    nexttile(freq_idx);
    hold on; box on; grid on;

    % Graficar curvas para esta frecuencia
    plot(dist, R_sum_mean_all(:,freq_idx),        '-p', 'LineWidth', 1.5, 'Color', colors{freq_idx});
    plot(dist, R_sum_noRIS_mean_all(:,freq_idx),  '--^','LineWidth', 1.5, 'Color', colors{freq_idx});

    % Configurar subplot
    legend('Ideal RIS case', 'Without RIS', 'Location', 'best');
    xlabel('Distance ${\it L}$ (m)','Interpreter','latex');
    ylabel('Weighted sum-rate (bit/s/Hz)','Interpreter','latex');
    title(sprintf('Frecuencia: %s', freq_names{freq_idx}));
    set(gca,'FontName','Times','FontSize',10);
end

% Ajustar espaciado entre subplots
sgtitle('Rendimiento RIS vs. sin RIS con N_{RIS}=64 en todas las frecuencias', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('\n¡Simulación completada!\n');
toc



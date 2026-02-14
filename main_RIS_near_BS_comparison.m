clear;
tic
Iteration=10;    % Número de repeticiones
dist = [0:20:160];  % Distancias L (m)

% Definir las frecuencias para el barrido
frequencies = [1.5e9, 3.5e9, 8e9, 15e9]; % 1.5, 3.5, 8, 15 GHz
freq_names = {'1.5 GHz', '3.5 GHz', '8 GHz', '15 GHz'};

% Número de elementos RIS escalado con frecuencia
% A mayor frecuencia → menor λ → más elementos en misma área física
N_ris_array = [100, 100, 100, 100]; % Escala aproximadamente con (f/f_base)^2
% 1.5 GHz: 100 elementos
% 3.5 GHz: 225 elementos (×2.33 en frecuencia → ×5.44 en área → 225)
% 8.0 GHz: 500 elementos (×5.33 en frecuencia → 500)
% 15 GHz:  900 elementos (×10 en frecuencia → 900)

fprintf('Configuración de elementos RIS por frecuencia:\n');
for i = 1:length(frequencies)
    fprintf('  %.1f GHz: N_ris = %d elementos\n', frequencies(i)/1e9, N_ris_array(i));
end
fprintf('\n');

% Matrices para almacenar resultados de cada frecuencia
R_sum_all         = zeros(length(dist), Iteration, length(frequencies)); % Ideal RIS case
R_sum_noRIS_all   = zeros(length(dist), Iteration, length(frequencies)); % Without RIS

B=5;          % Número de BS
BS_antennas = 2; % Antenas por BS (M)
User_antennas = 2;% Antenas por usuario (U)
P_max = 0.005;   % Potencia máx. por BS (W) (= 7 dBm)
K=4;          % Número de usuarios
P=4;          % Subportadoras
R=2;          % Número de RIS
sigma2 = 1e-11;  % Potencia de ruido

%% ==================== BUCLE PARA MÚLTIPLES FRECUENCIAS ====================
for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    N_ris = N_ris_array(freq_idx); % Elementos RIS para esta frecuencia
    
    fprintf('\n=== Frecuencia: %.2f GHz | N_ris = %d elementos ===\n', frequency/1e9, N_ris);
    fprintf('Simulacion (curvas: Ideal RIS / Without RIS)\n');
    
    for a=1:length(dist) 
       [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate_RIS_near_BS(B,R,K,dist(a));
        fprintf('Punto L=%dm (%d/%d)\n', dist(a), a, length(dist));
        
        for b=1:Iteration             
% ----- 1) Generación de canales (BS-user, RIS-user, BS-RIS) -----
            [ H_bkp,F_rkp,G_brp ] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS, Dis_BStoUser,Dis_RIStoUser, frequency);     
% ----- 2) Inicialización de W (BS) y Theta (RIS) -----
            [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);   
% (A) Without RIS: solo canal directo H y precodificación multiusuario
            [W,R_sum_noRIS_all(a,b,freq_idx)] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W);
% (D) Ideal RIS case (marco propuesto, caso ideal del paper)
            [W,Theta,R_sum_all(a,b,freq_idx)] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
        end
    end
end

%% ==================== Promedio sobre repeticiones ====================
fprintf('\nCalculando promedios...\n');
R_sum_mean_all        = zeros(length(dist), length(frequencies)); % Ideal RIS
R_sum_noRIS_mean_all  = zeros(length(dist), length(frequencies)); % Without RIS

for freq_idx = 1:length(frequencies)
    R_sum_mean_all(:,freq_idx)        = mean(R_sum_all(:,:,freq_idx), 2); % Ideal RIS
    R_sum_noRIS_mean_all(:,freq_idx)  = mean(R_sum_noRIS_all(:,:,freq_idx), 2); % Without RIS
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save('main_RIS_near_BS.mat','dist','R_sum_mean_all','R_sum_noRIS_mean_all');

%% ==================== Gráfica final ====================
fprintf('Generando gráficas...\n');
figure('Position', [100, 100, 1400, 800]);

% Colores para las curvas
colors = {'b', 'r', 'g', 'm'};

for freq_idx = 1:length(frequencies)
    subplot(2, 2, freq_idx);
    hold on; box on; grid on;
    
    % Graficar curvas para esta frecuencia
    plot(dist, R_sum_mean_all(:,freq_idx),        '-p', 'LineWidth', 1.5, 'Color', colors{freq_idx});
    plot(dist, R_sum_noRIS_mean_all(:,freq_idx),  '--^','LineWidth', 1.5, 'Color', colors{freq_idx});
    
    % Configurar subplot
    legend('Ideal RIS case', 'Without RIS', 'Location', 'best');
    xlabel('Distance ${\it L}$ (m)','Interpreter','latex');
    ylabel('Weighted sum-rate (bit/s/Hz)','Interpreter','latex');
    title(sprintf('%s (N_{RIS}=%d)', freq_names{freq_idx}, N_ris_array(freq_idx)));
    set(gca,'FontName','Times','FontSize',10);
end

sgtitle('Nuevo Escenario: RIS cerca de BS (Y=-30) | Elementos RIS escalan con frecuencia', 'FontSize', 14, 'FontWeight', 'bold');
fprintf('\n¡Simulación completada!\n');
toc


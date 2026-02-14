clear;
tic
Iteration=10;    % 40 - Numero de repeticiones
%dist=[0:10:160]; % Distancia L (m) del centro del grupo de usuarios
dist = [0:20:160];
% dist=120;      % (Ejemplo para un solo punto)

% ==================== CONFIGURACIÓN DE FRECUENCIA ====================
% MODO 1: Una sola frecuencia (COMENTADO - Descomentar para usar)
% frequency = 3.5e9;  % Cambiar a 1.5e9, 8e9, o 15e9 si quieres probar otra
% freq_name = sprintf('%.1f GHz', frequency/1e9);
% R_sum_all         = zeros(length(dist), Iteration); % Ideal RIS case
% R_sum_noRIS_all   = zeros(length(dist), Iteration); % Without RIS

% MODO 2: Barrido de frecuencias (ACTIVO)
frequencies = [1.5e9, 3.5e9, 8e9, 15e9]; % 1.5, 3.5, 8, 15 GHz
freq_names = {'1.5 GHz', '3.5 GHz', '8 GHz', '15 GHz'};

% Matrices para almacenar resultados de cada frecuencia
R_sum_all         = zeros(length(dist), Iteration, length(frequencies)); 
R_sum_noRIS_all   = zeros(length(dist), Iteration, length(frequencies));

B=5;          % Numero de BS
BS_antennas = 2; % Antenas por BS (M)
User_antennas = 2;% Antenas por usuario (U)
P_max = 0.005;   % Potencia mx. por BS (W) (= 7 dBm) - Ajustado para compensar path loss 3GPP UMi
K=4;           % Nmero de usuarios asignar la ris a un usuario y optimizarla para ese usuario
P=4;           % Subportadoras optimizan para todo el escenario y no para una ris en concreto, configurar la ris Y LA PRECODIFICACI07N (optimizacin paper vs sandra)
R=2;           % Nmero de RIS
N_ris = 100;     % Elementos por RIS (N)
sigma2 = 1e-11;  % Potencia de ruido

%% ==================== SIMULACIÓN PARA UNA SOLA FRECUENCIA (COMENTADO) ====================
% Descomentar este bloque si quieres usar el MODO 1 (frecuencia única)
% fprintf('\n=== Frecuencia: %s ===\n', freq_name);
% fprintf('Simulacion (curvas: Ideal RIS / Without RIS)\n\n');
% 
% for a=1:length(dist) 
%    [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate(B,R,K,dist(a)); 
%     fprintf('Punto L=%dm (%d/%d)\n', dist(a), a, length(dist));
%     
%     for b=1:Iteration             
% % ----- 1) Generación de canales (BS-user, RIS-user, BS-RIS) -----
%         [ H_bkp,F_rkp,G_brp ] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS, Dis_BStoUser,Dis_RIStoUser, frequency);     
% % ----- 2) Inicialización de W (BS) y Theta (RIS) -----
%         [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);   
% % (A) Without RIS: solo canal directo H y precodificación multiusuario
%         [W,R_sum_noRIS_all(a,b)] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W);
% % (D) Ideal RIS case (marco propuesto, caso ideal del paper)
%         [W,Theta,R_sum_all(a,b)] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
%     end
% end

%% ==================== BUCLE PARA MÚLTIPLES FRECUENCIAS (ACTIVO) ====================
for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    fprintf('\n=== Frecuencia: %.2f GHz ===\n', frequency/1e9);
    fprintf('Simulacion (curvas: Ideal RIS / Without RIS)\n');
    
    for a=1:length(dist) 
       [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate(B,R,K,dist(a));
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

%% ==================== Promedio sobre repeticiones ====================
fprintf('\nCalculando promedios...\n');

% ===== PROMEDIO PARA UNA SOLA FRECUENCIA (COMENTADO) =====
% Descomentar si usas MODO 1 (frecuencia única)
% R_sum_mean        = mean(R_sum_all, 2); % Ideal RIS
% R_sum_noRIS_mean  = mean(R_sum_noRIS_all, 2); % Without RIS
% gain_RIS = R_sum_mean ./ R_sum_noRIS_mean;
% 
% fprintf('\n=================================================================\n');
% fprintf('RESULTADOS - Frecuencia: %s\n', freq_name);
% fprintf('=================================================================\n');
% fprintf('┌──────────┬──────────────┬──────────────┬──────────────┐\n');
% fprintf('│ Dist (m) │  With RIS    │  Without RIS │  Ganancia    │\n');
% fprintf('│          │  (bit/s/Hz)  │  (bit/s/Hz)  │     (x)      │\n');
% fprintf('├──────────┼──────────────┼──────────────┼──────────────┤\n');
% for i = 1:length(dist)
%     fprintf('│   %3d    │    %6.3f    │    %6.3f    │    %5.2fx    │\n', ...
%         dist(i), R_sum_mean(i), R_sum_noRIS_mean(i), gain_RIS(i));
% end
% fprintf('└──────────┴──────────────┴──────────────┴──────────────┘\n\n');

% ===== PROMEDIO PARA MÚLTIPLES FRECUENCIAS (ACTIVO) =====
R_sum_mean_all        = zeros(length(dist), length(frequencies));
R_sum_noRIS_mean_all  = zeros(length(dist), length(frequencies));

for freq_idx = 1:length(frequencies)
    R_sum_mean_all(:,freq_idx)        = mean(R_sum_all(:,:,freq_idx), 2);
    R_sum_noRIS_mean_all(:,freq_idx)  = mean(R_sum_noRIS_all(:,:,freq_idx), 2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save('main_clean.mat','dist','R_sum_mean_all','R_sum_noRIS_mean_all');

%% ==================== GRÁFICA PARA UNA SOLA FRECUENCIA (COMENTADO) ====================
% Descomentar si usas MODO 1 (frecuencia única)
% fprintf('Generando gráfica...\n');
% figure('Position', [100, 100, 800, 600]);
% hold on; box on; grid on;
% 
% plot(dist, R_sum_mean,        '-o', 'LineWidth', 2.5, 'MarkerSize', 8, 'Color', 'b');
% plot(dist, R_sum_noRIS_mean,  '--^', 'LineWidth', 2.5, 'MarkerSize', 8, 'Color', 'r');
% 
% legend('Ideal RIS case', 'Without RIS', 'Location', 'best', 'FontSize', 12);
% xlabel('Distance ${\it L}$ (m)', 'Interpreter', 'latex', 'FontSize', 14);
% ylabel('Weighted sum-rate (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 14);
% title(sprintf('Rendimiento del Sistema con canal F con LOS = 1 - Frecuencia: %s', freq_name), 'FontSize', 14, 'FontWeight', 'bold');
% set(gca, 'FontName', 'Times', 'FontSize', 12);

%% ==================== GRÁFICA PARA MÚLTIPLES FRECUENCIAS (ACTIVO) ====================
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
    title(sprintf('Frecuencia: %s', freq_names{freq_idx}));
    set(gca,'FontName','Times','FontSize',10);
end

% Ajustar espaciado entre subplots
sgtitle('Comparación de Rendimiento por Frecuencia', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('\n¡Simulación completada!\n');
toc
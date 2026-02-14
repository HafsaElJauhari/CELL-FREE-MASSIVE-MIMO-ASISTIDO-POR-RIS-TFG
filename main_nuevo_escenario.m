% main_nuevo_escenario.m
% NUEVO ESCENARIO: Canal BS → RIS con NLOS (obstruido)
% Solo para frecuencia 3.5 GHz para ver el impacto

clear;
tic
fprintf('=================================================================\n');
fprintf('NUEVO ESCENARIO: Canal BS → RIS (G) con NLOS\n');
fprintf('=================================================================\n');
fprintf('Comparación:\n');
fprintf('  - Escenario BASE: Canal G con LOS (enlace planificado)\n');
fprintf('  - Escenario NUEVO: Canal G con NLOS (enlace obstruido)\n\n');

Iteration=10;    % Número de repeticiones
dist = [0:20:160];  % Distancias L (m)

% Frecuencia única para comparación
frequency = 3.5e9;  % 3.5 GHz
freq_name = '3.5 GHz';

% Matrices para almacenar resultados
R_sum_LOS         = zeros(length(dist), Iteration); % Canal G LOS (base)
R_sum_noRIS_LOS   = zeros(length(dist), Iteration); 
R_sum_NLOS        = zeros(length(dist), Iteration); % Canal G NLOS (nuevo)
R_sum_noRIS_NLOS  = zeros(length(dist), Iteration);

B=5;          % Número de BS
BS_antennas = 2; % Antenas por BS (M)
User_antennas = 2;% Antenas por usuario (U)
P_max = 0.005;   % Potencia máx. por BS (W) (= 7 dBm)
K=4;          % Número de usuarios
P=4;          % Subportadoras
R=2;          % Número de RIS
N_ris = 100;  % Elementos por RIS (N)
sigma2 = 1e-11;  % Potencia de ruido

%% ==================== ESCENARIO BASE: Canal G con LOS ====================
fprintf('Ejecutando ESCENARIO BASE (Canal G LOS)...\n');

for a=1:length(dist) 
   [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate(B,R,K,dist(a)); 
    fprintf('  Punto L=%dm (%d/%d)\n', dist(a), a, length(dist));
    
    for b=1:Iteration             
% ----- 1) Generación de canales -----
        H_bkp = zeros(B,K,P,BS_antennas,User_antennas);
        F_rkp = zeros(R,K,P,N_ris,User_antennas);
        G_brp = zeros(B,R,P,N_ris,BS_antennas);
        
        % Canal H (BS → Usuario, NLOS)
        for bb=1:B
            for kk=1:K
                for pp=1:P
                    H_bkp(bb,kk,pp,:,:) = channel_H(BS_antennas,User_antennas,Dis_BStoUser(bb,kk),frequency);             
                end
            end
        end
        
        % Canal F (RIS → Usuario, LOS)
        for rr=1:R
            for kk=1:K
                for pp=1:P
                    F_rkp(rr,kk,pp,:,:) = channel_F(N_ris,User_antennas,Dis_RIStoUser(rr,kk),frequency);
                end
            end
        end
        
        % Canal G (BS → RIS, LOS) - ESCENARIO BASE
        for bb=1:B
            for rr=1:R
                for pp=1:P
                    G_brp(bb,rr,pp,:,:) = channel_G(N_ris,BS_antennas,Dis_BStoRIS(bb,rr),frequency);
                end
            end
        end
        
% ----- 2) Inicialización -----
        [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);   
        
% ----- 3) Algoritmos -----
        [W,R_sum_noRIS_LOS(a,b)] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W);
        [W,Theta,R_sum_LOS(a,b)] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
    end
end

%% ==================== NUEVO ESCENARIO: Canal G con NLOS ====================
fprintf('\nEjecutando NUEVO ESCENARIO (Canal G NLOS)...\n');

for a=1:length(dist) 
   [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate(B,R,K,dist(a)); 
    fprintf('  Punto L=%dm (%d/%d)\n', dist(a), a, length(dist));
    
    for b=1:Iteration             
% ----- 1) Generación de canales -----
        H_bkp = zeros(B,K,P,BS_antennas,User_antennas);
        F_rkp = zeros(R,K,P,N_ris,User_antennas);
        G_brp = zeros(B,R,P,N_ris,BS_antennas);
        
        % Canal H (BS → Usuario, NLOS)
        for bb=1:B
            for kk=1:K
                for pp=1:P
                    H_bkp(bb,kk,pp,:,:) = channel_H(BS_antennas,User_antennas,Dis_BStoUser(bb,kk),frequency);             
                end
            end
        end
        
        % Canal F (RIS → Usuario, LOS)
        for rr=1:R
            for kk=1:K
                for pp=1:P
                    F_rkp(rr,kk,pp,:,:) = channel_F(N_ris,User_antennas,Dis_RIStoUser(rr,kk),frequency);
                end
            end
        end
        
        % Canal G (BS → RIS, NLOS) - NUEVO ESCENARIO
        for bb=1:B
            for rr=1:R
                for pp=1:P
                    G_brp(bb,rr,pp,:,:) = channel_G_NLOS(N_ris,BS_antennas,Dis_BStoRIS(bb,rr),frequency);
                end
            end
        end
        
% ----- 2) Inicialización -----
        [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);   
        
% ----- 3) Algoritmos -----
        [W,R_sum_noRIS_NLOS(a,b)] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W);
        [W,Theta,R_sum_NLOS(a,b)] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
    end
end

%% ==================== Promedio sobre repeticiones ====================
fprintf('\nCalculando promedios...\n');

R_sum_mean_LOS        = mean(R_sum_LOS, 2);
R_sum_noRIS_mean_LOS  = mean(R_sum_noRIS_LOS, 2);
R_sum_mean_NLOS       = mean(R_sum_NLOS, 2);
R_sum_noRIS_mean_NLOS = mean(R_sum_noRIS_NLOS, 2);

% Calcular ganancia del RIS en cada escenario
gain_RIS_LOS  = R_sum_mean_LOS ./ R_sum_noRIS_mean_LOS;
gain_RIS_NLOS = R_sum_mean_NLOS ./ R_sum_noRIS_mean_NLOS;

% Calcular degradación por NLOS
degradacion_withRIS = (R_sum_mean_LOS - R_sum_mean_NLOS) ./ R_sum_mean_LOS * 100;
degradacion_noRIS   = (R_sum_noRIS_mean_LOS - R_sum_noRIS_mean_NLOS) ./ R_sum_noRIS_mean_LOS * 100;

%% ==================== Mostrar resultados en tablas ====================
fprintf('\n=================================================================\n');
fprintf('COMPARACIÓN DE RESULTADOS - Frecuencia: %s\n', freq_name);
fprintf('=================================================================\n\n');

fprintf('┌──────────┬───────────────────────────┬───────────────────────────┐\n');
fprintf('│ Dist (m) │   ESCENARIO BASE (G LOS)  │  NUEVO ESCENARIO (G NLOS) │\n');
fprintf('│          ├─────────────┬─────────────┼─────────────┬─────────────┤\n');
fprintf('│          │  With RIS   │ Without RIS │  With RIS   │ Without RIS │\n');
fprintf('│          │  (bit/s/Hz) │  (bit/s/Hz) │  (bit/s/Hz) │  (bit/s/Hz) │\n');
fprintf('├──────────┼─────────────┼─────────────┼─────────────┼─────────────┤\n');
for i = 1:length(dist)
    fprintf('│   %3d    │    %6.3f   │    %6.3f   │    %6.3f   │    %6.3f   │\n', ...
        dist(i), R_sum_mean_LOS(i), R_sum_noRIS_mean_LOS(i), ...
        R_sum_mean_NLOS(i), R_sum_noRIS_mean_NLOS(i));
end
fprintf('└──────────┴─────────────┴─────────────┴─────────────┴─────────────┘\n\n');

fprintf('┌──────────┬──────────────┬──────────────┬───────────────┐\n');
fprintf('│ Dist (m) │ Ganancia RIS │ Ganancia RIS │  Degradación  │\n');
fprintf('│          │   (G LOS)    │  (G NLOS)    │   (G NLOS)    │\n');
fprintf('├──────────┼──────────────┼──────────────┼───────────────┤\n');
for i = 1:length(dist)
    fprintf('│   %3d    │    %5.2fx   │    %5.2fx   │    %5.1f%%    │\n', ...
        dist(i), gain_RIS_LOS(i), gain_RIS_NLOS(i), degradacion_withRIS(i));
end
fprintf('└──────────┴──────────────┴──────────────┴───────────────┘\n\n');

%% ==================== Análisis del impacto ====================
fprintf('=================================================================\n');
fprintf('ANÁLISIS DEL IMPACTO DE CAMBIAR CANAL G DE LOS A NLOS\n');
fprintf('=================================================================\n\n');

% Promedios globales
avg_degrad_withRIS = mean(degradacion_withRIS);
avg_degrad_noRIS = mean(degradacion_noRIS);
avg_gain_LOS = mean(gain_RIS_LOS);
avg_gain_NLOS = mean(gain_RIS_NLOS);

fprintf('DEGRADACIÓN PROMEDIO por cambiar G de LOS a NLOS:\n');
fprintf('  • Con RIS:     %.1f%% de pérdida\n', avg_degrad_withRIS);
fprintf('  • Sin RIS:     %.1f%% de pérdida\n\n', avg_degrad_noRIS);

fprintf('GANANCIA DEL RIS:\n');
fprintf('  • Canal G LOS:  %.2fx\n', avg_gain_LOS);
fprintf('  • Canal G NLOS: %.2fx\n\n', avg_gain_NLOS);

if avg_degrad_withRIS > 20
    fprintf('❌ IMPACTO CRÍTICO: La obstrucción BS-RIS degrada >20%% el rendimiento\n');
elseif avg_degrad_withRIS > 10
    fprintf('⚠️  IMPACTO ALTO: La obstrucción BS-RIS degrada ~%.0f%% el rendimiento\n', avg_degrad_withRIS);
else
    fprintf('✓ IMPACTO MODERADO: La obstrucción BS-RIS degrada ~%.0f%% el rendimiento\n', avg_degrad_withRIS);
end

fprintf('\n=================================================================\n\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save('main_nuevo_escenario.mat','dist','R_sum_mean_LOS','R_sum_noRIS_mean_LOS','R_sum_mean_NLOS','R_sum_noRIS_mean_NLOS');

%% ==================== Gráficas comparativas ====================
fprintf('Generando gráficas comparativas...\n');

figure('Position', [100, 100, 1400, 600]);

% Subplot 1: Comparación With RIS
subplot(1,2,1);
hold on; box on; grid on;
plot(dist, R_sum_mean_LOS,  '-o', 'LineWidth', 2.5, 'MarkerSize', 8, 'Color', 'b', 'DisplayName', 'Canal G LOS (base)');
plot(dist, R_sum_mean_NLOS, '--s', 'LineWidth', 2.5, 'MarkerSize', 8, 'Color', 'r', 'DisplayName', 'Canal G NLOS (nuevo)');
legend('Location', 'best', 'FontSize', 11);
xlabel('Distance ${\it L}$ (m)', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('Weighted sum-rate (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 13);
title('Con RIS: Impacto de Canal G (LOS vs NLOS)', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times', 'FontSize', 11);

% Subplot 2: Comparación completa (ambos escenarios, con y sin RIS)
subplot(1,2,2);
hold on; box on; grid on;
plot(dist, R_sum_mean_LOS,        '-o',  'LineWidth', 2, 'MarkerSize', 7, 'Color', 'b', 'DisplayName', 'G LOS + RIS');
plot(dist, R_sum_noRIS_mean_LOS,  '--o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [0.5 0.5 1], 'DisplayName', 'G LOS sin RIS');
plot(dist, R_sum_mean_NLOS,       '-s',  'LineWidth', 2, 'MarkerSize', 7, 'Color', 'r', 'DisplayName', 'G NLOS + RIS');
plot(dist, R_sum_noRIS_mean_NLOS, '--s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', [1 0.5 0.5], 'DisplayName', 'G NLOS sin RIS');
legend('Location', 'best', 'FontSize', 10);
xlabel('Distance ${\it L}$ (m)', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('Weighted sum-rate (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 13);
title('Comparación Completa de Escenarios', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times', 'FontSize', 11);

sgtitle(sprintf('Impacto de Canal BS-RIS (G): LOS vs NLOS - Frecuencia: %s', freq_name), ...
    'FontSize', 15, 'FontWeight', 'bold');

% Gráfica adicional: Degradación por distancia
figure('Position', [100, 150, 700, 500]);
hold on; box on; grid on;
plot(dist, degradacion_withRIS, '-o', 'LineWidth', 2.5, 'MarkerSize', 8, 'Color', [0.8 0.2 0.2]);
yline(avg_degrad_withRIS, '--k', 'LineWidth', 1.5, 'Label', sprintf('Promedio: %.1f%%', avg_degrad_withRIS));
xlabel('Distance ${\it L}$ (m)', 'Interpreter', 'latex', 'FontSize', 13);
ylabel('Degradación (%)', 'Interpreter', 'latex', 'FontSize', 13);
title('Degradación por Canal G NLOS (respecto a G LOS)', 'FontSize', 13, 'FontWeight', 'bold');
set(gca, 'FontName', 'Times', 'FontSize', 11);
ylim([0 max(degradacion_withRIS)*1.2]);

fprintf('\n¡Simulación completada!\n');
fprintf('=================================================================\n');
toc




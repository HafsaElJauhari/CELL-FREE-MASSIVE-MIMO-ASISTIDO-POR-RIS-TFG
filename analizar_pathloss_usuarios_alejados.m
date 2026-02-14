% analizar_pathloss_usuarios_alejados.m
% Script para calcular path-loss con usuarios MUY ALEJADOS
% Verificar si a distancias grandes el camino reflejado es mejor que el directo

clear;
close all;

fprintf('=================================================================\n');
fprintf('ANÁLISIS DE PATH-LOSS: Usuarios MUY ALEJADOS\n');
fprintf('=================================================================\n\n');

%% ==================== CONFIGURACIÓN DEL ESCENARIO ====================
% Alturas
hBS = 3;      % Altura estación base (m)
hRIS = 6;     % Altura RIS (m)
hUE = 1.5;    % Altura usuario (m)

% Posiciones base (según Position_generate_RIS_near_BS.m)
% BS en Y=-50, RIS en Y=-30

% NUEVAS DISTANCIAS: Usuarios MUCHO MÁS ALEJADOS
dist_array = [50:50:500]; % De 50m hasta 500m de la BS

% Frecuencias a analizar
frequencies = [1.5e9, 3.5e9, 8e9, 15e9]; % Hz
freq_names = {'1.5 GHz', '3.5 GHz', '8 GHz', '15 GHz'};

%% ==================== CÁLCULO DE DISTANCIAS 3D ====================
fprintf('Cálculo de distancias para usuarios alejados:\n');
fprintf('┌──────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐\n');
fprintf('│  L (m)   │  d_direct    │  d_BS→RIS    │  d_RIS→UE    │ d_reflected  │ Ratio d_ref/ │\n');
fprintf('│          │   (BS→UE)    │              │              │   (total)    │   d_direct   │\n');
fprintf('├──────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤\n');

% Almacenar distancias
d_direct_array = zeros(length(dist_array), 1);
d_BS_RIS_array = zeros(length(dist_array), 1);
d_RIS_UE_array = zeros(length(dist_array), 1);
d_reflected_total = zeros(length(dist_array), 1);

for idx = 1:length(dist_array)
    L = dist_array(idx);
    
    % Posiciones aproximadas
    BS_pos = [0, -50];
    RIS_pos = [60, -30];
    UE_pos = [L, 0];  % Usuario en (L, 0)
    
    % Distancia BS → UE (directo) en 3D
    dist_2D_direct = norm(UE_pos - BS_pos);
    d_direct = sqrt(dist_2D_direct^2 + (hBS - hUE)^2);
    
    % Distancia BS → RIS en 3D (constante)
    dist_2D_BS_RIS = norm(RIS_pos - BS_pos);
    d_BS_RIS = sqrt(dist_2D_BS_RIS^2 + (hRIS - hBS)^2);
    
    % Distancia RIS → UE en 3D
    dist_2D_RIS_UE = norm(UE_pos - RIS_pos);
    d_RIS_UE = sqrt(dist_2D_RIS_UE^2 + (hRIS - hUE)^2);
    
    % Distancia total reflejada
    d_reflected = d_BS_RIS + d_RIS_UE;
    
    % Ratio
    ratio = d_reflected / d_direct;
    
    % Guardar
    d_direct_array(idx) = d_direct;
    d_BS_RIS_array(idx) = d_BS_RIS;
    d_RIS_UE_array(idx) = d_RIS_UE;
    d_reflected_total(idx) = d_reflected;
    
    fprintf('│   %3d    │   %7.2f m   │   %7.2f m   │   %7.2f m   │   %7.2f m   │    %5.2f     │\n', ...
        L, d_direct, d_BS_RIS, d_RIS_UE, d_reflected, ratio);
end

fprintf('└──────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘\n\n');

%% ==================== CÁLCULO DE PATH-LOSS POR FRECUENCIA ====================

for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    freq_name = freq_names{freq_idx};
    
    fprintf('\n=================================================================\n');
    fprintf('FRECUENCIA: %s (%.2f GHz)\n', freq_name, frequency/1e9);
    fprintf('=================================================================\n\n');
    
    % Almacenar path-loss para esta frecuencia
    PL_direct_dB = zeros(length(dist_array), 1);
    PL_BS_RIS_dB = zeros(length(dist_array), 1);
    PL_RIS_UE_dB = zeros(length(dist_array), 1);
    PL_reflected_total_dB = zeros(length(dist_array), 1);
    
    % Calcular path-loss para cada distancia
    for idx = 1:length(dist_array)
        % Path-loss directo BS → UE (NLOS)
        PL_direct_dB(idx) = calculate_pathloss_3GPP_UMi(d_direct_array(idx), frequency, hBS, hUE, 0);
        
        % Path-loss BS → RIS (LOS)
        PL_BS_RIS_dB(idx) = calculate_pathloss_3GPP_UMi(d_BS_RIS_array(idx), frequency, hBS, hRIS, 1);
        
        % Path-loss RIS → UE (LOS)
        PL_RIS_UE_dB(idx) = calculate_pathloss_3GPP_UMi(d_RIS_UE_array(idx), frequency, hRIS, hUE, 1);
        
        % Path-loss total reflejado (suma en dB)
        PL_reflected_total_dB(idx) = PL_BS_RIS_dB(idx) + PL_RIS_UE_dB(idx);
    end
    
    % Diferencia de path-loss (positivo = camino reflejado es mejor)
    PL_difference = PL_direct_dB - PL_reflected_total_dB;
    
    % Mostrar tabla
    fprintf('Comparación de Path-Loss:\n');
    fprintf('┌──────────┬──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐\n');
    fprintf('│  L (m)   │  PL_direct   │  PL_BS→RIS   │  PL_RIS→UE   │ PL_reflected │  Diferencia  │\n');
    fprintf('│          │   (NLOS)     │    (LOS)     │    (LOS)     │   (total)    │  (dB mejor)  │\n');
    fprintf('├──────────┼──────────────┼──────────────┼──────────────┼──────────────┼──────────────┤\n');
    
    for idx = 1:length(dist_array)
        fprintf('│   %3d    │   %6.2f dB  │   %6.2f dB  │   %6.2f dB  │   %6.2f dB  │   %+6.2f dB │', ...
            dist_array(idx), PL_direct_dB(idx), PL_BS_RIS_dB(idx), PL_RIS_UE_dB(idx), ...
            PL_reflected_total_dB(idx), PL_difference(idx));
        
        if PL_difference(idx) > 0
            fprintf(' ✓ │\n'); % Reflejado es mejor
        else
            fprintf(' ✗ │\n'); % Directo es mejor
        end
    end
    
    fprintf('└──────────┴──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘\n\n');
    
    % Análisis de resultados
    avg_difference = mean(PL_difference);
    num_mejor = sum(PL_difference > 0);
    max_difference = max(PL_difference);
    idx_max = find(PL_difference == max_difference, 1);
    
    fprintf('ANÁLISIS:\n');
    fprintf('  • Diferencia promedio: %+.2f dB\n', avg_difference);
    fprintf('  • Diferencia máxima: %+.2f dB (en L=%d m)\n', max_difference, dist_array(idx_max));
    fprintf('  • Puntos donde reflejado es mejor: %d/%d (%.0f%%)\n\n', ...
        num_mejor, length(dist_array), 100*num_mejor/length(dist_array));
    
    if avg_difference > 10
        fprintf('  ✓✓ El camino reflejado es SIGNIFICATIVAMENTE mejor (>10 dB en promedio)\n');
    elseif avg_difference > 5
        fprintf('  ✓ El camino reflejado es NOTABLEMENTE mejor (5-10 dB en promedio)\n');
    elseif avg_difference > 0
        fprintf('  ~ El camino reflejado es LIGERAMENTE mejor (<5 dB en promedio)\n');
    else
        fprintf('  ✗ El camino reflejado NO es mejor (path-loss peor que directo)\n');
    end
    
    % Guardar para gráfica
    if freq_idx == 1
        PL_all_direct = zeros(length(dist_array), length(frequencies));
        PL_all_reflected = zeros(length(dist_array), length(frequencies));
        PL_all_difference = zeros(length(dist_array), length(frequencies));
    end
    
    PL_all_direct(:, freq_idx) = PL_direct_dB;
    PL_all_reflected(:, freq_idx) = PL_reflected_total_dB;
    PL_all_difference(:, freq_idx) = PL_difference;
end

%% ==================== GRÁFICAS ====================
fprintf('\n=================================================================\n');
fprintf('Generando gráficas...\n');
fprintf('=================================================================\n\n');

% Gráfica 1: Path-loss vs distancia para todas las frecuencias
figure('Position', [100, 100, 1400, 800]);

for freq_idx = 1:length(frequencies)
    subplot(2, 2, freq_idx);
    hold on; box on; grid on;
    
    plot(dist_array, PL_all_direct(:, freq_idx), '-o', 'LineWidth', 2, 'MarkerSize', 7, ...
        'DisplayName', 'Directo (BS→UE, NLOS)');
    plot(dist_array, PL_all_reflected(:, freq_idx), '-s', 'LineWidth', 2, 'MarkerSize', 7, ...
        'DisplayName', 'Reflejado (BS→RIS→UE, LOS+LOS)');
    
    xlabel('Distance {\it L} (m)', 'Interpreter', 'tex', 'FontSize', 11);
    ylabel('Path-loss (dB)', 'Interpreter', 'tex', 'FontSize', 11);
    title(sprintf('%s', freq_names{freq_idx}), 'FontSize', 12, 'FontWeight', 'bold');
    legend('Location', 'best', 'FontSize', 10);
    set(gca, 'FontName', 'Times', 'FontSize', 10);
end

sgtitle('Usuarios Alejados: Path-Loss Directo vs Reflejado', 'FontSize', 14, 'FontWeight', 'bold');

% Gráfica 2: Diferencia de path-loss (ventaja del camino reflejado)
figure('Position', [100, 150, 1000, 600]);
hold on; box on; grid on;

colors = {'b', 'r', 'g', 'm'};
for freq_idx = 1:length(frequencies)
    plot(dist_array, PL_all_difference(:, freq_idx), '-o', 'LineWidth', 2.5, 'MarkerSize', 8, ...
        'Color', colors{freq_idx}, 'DisplayName', freq_names{freq_idx});
end

yline(0, '--k', 'LineWidth', 1.5, 'Label', 'Sin ventaja');
yline(5, ':k', 'LineWidth', 1, 'Label', 'Ventaja marginal (5 dB)');
yline(10, ':k', 'LineWidth', 1, 'Label', 'Ventaja significativa (10 dB)');

xlabel('Distance {\it L} (m)', 'Interpreter', 'tex', 'FontSize', 12);
ylabel('Ventaja del camino reflejado (dB)', 'Interpreter', 'tex', 'FontSize', 12);
title('Ventaja de Path-Loss: Reflejado vs Directo (Usuarios Alejados)', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 11);
set(gca, 'FontName', 'Times', 'FontSize', 11);
grid minor;

%% ==================== RESUMEN FINAL ====================
fprintf('\n=================================================================\n');
fprintf('RESUMEN FINAL - USUARIOS ALEJADOS\n');
fprintf('=================================================================\n\n');

fprintf('Ventaja promedio del camino reflejado por frecuencia:\n');
fprintf('┌──────────────┬──────────────────┬──────────────────┬─────────────────┐\n');
fprintf('│  Frecuencia  │  Ventaja (dB)    │ Ventaja Máxima   │   Evaluación    │\n');
fprintf('│              │   (promedio)     │      (dB)        │                 │\n');
fprintf('├──────────────┼──────────────────┼──────────────────┼─────────────────┤\n');

for freq_idx = 1:length(frequencies)
    avg_diff = mean(PL_all_difference(:, freq_idx));
    max_diff = max(PL_all_difference(:, freq_idx));
    fprintf('│  %9s   │     %+6.2f dB    │    %+6.2f dB    │', freq_names{freq_idx}, avg_diff, max_diff);
    
    if avg_diff > 10
        fprintf('   Excelente   │\n');
    elseif avg_diff > 5
        fprintf('     Buena     │\n');
    elseif avg_diff > 0
        fprintf('   Marginal    │\n');
    else
        fprintf('  Insuficiente │\n');
    end
end

fprintf('└──────────────┴──────────────────┴──────────────────┴─────────────────┘\n\n');

% Encontrar la distancia óptima (máxima ventaja promedio sobre todas las frecuencias)
avg_diff_all_freq = mean(PL_all_difference, 2);
[max_avg_diff, idx_opt] = max(avg_diff_all_freq);
dist_opt = dist_array(idx_opt);

fprintf('DISTANCIA ÓPTIMA:\n');
fprintf('  • Distancia L óptima: %d m\n', dist_opt);
fprintf('  • Ventaja promedio en esa distancia: %+.2f dB\n\n', max_avg_diff);

fprintf('CONCLUSIÓN:\n');
if max_avg_diff > 10
    fprintf('  ✓✓ EXCELENTE: Con usuarios alejados, el camino reflejado es significativamente mejor.\n');
    fprintf('     Recomendación: Usar dist >= %d m en las simulaciones.\n', dist_opt);
elseif max_avg_diff > 5
    fprintf('  ✓ BUENO: Con usuarios alejados, el camino reflejado tiene ventaja apreciable.\n');
    fprintf('     Recomendación: Usar dist >= %d m en las simulaciones.\n', dist_opt);
elseif max_avg_diff > 0
    fprintf('  ~ MARGINAL: La ventaja del camino reflejado es pequeña incluso con usuarios alejados.\n');
    fprintf('     Considerar: Revisar el posicionamiento de la RIS.\n');
else
    fprintf('  ✗ INSUFICIENTE: Incluso con usuarios alejados, el camino reflejado no es mejor.\n');
    fprintf('     Problema: Revisar la geometría del escenario.\n');
end

fprintf('\n=================================================================\n');
fprintf('Análisis completado.\n');
fprintf('=================================================================\n');


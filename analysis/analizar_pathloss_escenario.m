% analizar_pathloss_escenario.m
% Script para calcular analíticamente el path-loss del camino directo vs reflejado
% y verificar si el camino reflejado (LOS+LOS) es realmente mejor que el directo (NLOS)

clear;
close all;

fprintf('=================================================================\n');
fprintf('ANÁLISIS DE PATH-LOSS: Camino Directo vs Reflejado\n');
fprintf('=================================================================\n\n');

%% ==================== CONFIGURACIÓN DEL ESCENARIO ====================
% Alturas
hBS = 3;      % Altura estación base (m)
hRIS = 6;     % Altura RIS (m)
hUE = 1.5;    % Altura usuario (m)

% Posiciones (según Position_generate_RIS_near_BS.m)
% BS en Y=-50, RIS en Y=-30, Usuarios alrededor de Y≈0 (depende de dist)

% Frecuencias a analizar
frequencies = [1.5e9, 3.5e9, 8e9, 15e9]; % Hz
freq_names = {'1.5 GHz', '3.5 GHz', '8 GHz', '15 GHz'};

% Distancias L (distancia BS-Usuario en eje X)
dist_array = [0:20:160]; % metros

%% ==================== CÁLCULO DE DISTANCIAS 3D ====================
% Para cada distancia L, calcular las distancias reales en 3D

fprintf('Cálculo de distancias para cada punto L:\n');
fprintf('┌──────────┬──────────────┬──────────────┬──────────────┬──────────────┐\n');
fprintf('│  L (m)   │  d_direct    │  d_BS→RIS    │  d_RIS→UE    │ d_reflected  │\n');
fprintf('│          │   (BS→UE)    │              │              │   (total)    │\n');
fprintf('├──────────┼──────────────┼──────────────┼──────────────┼──────────────┤\n');

% Almacenar distancias
d_direct_array = zeros(length(dist_array), 1);
d_BS_RIS_array = zeros(length(dist_array), 1);
d_RIS_UE_array = zeros(length(dist_array), 1);
d_reflected_total = zeros(length(dist_array), 1);

for idx = 1:length(dist_array)
    L = dist_array(idx);
    
    % Posiciones aproximadas (tomando BS más cercana y RIS más cercana)
    % BS posición: (0, -50)
    % RIS posición: (60, -30)
    % UE posición: (L, 0) aproximadamente
    
    BS_pos = [0, -50];
    RIS_pos = [60, -30];
    UE_pos = [L, 0];
    
    % Distancia BS → UE (directo) en 3D
    dist_2D_direct = norm(UE_pos - BS_pos);
    d_direct = sqrt(dist_2D_direct^2 + (hBS - hUE)^2);
    
    % Distancia BS → RIS en 3D
    dist_2D_BS_RIS = norm(RIS_pos - BS_pos);
    d_BS_RIS = sqrt(dist_2D_BS_RIS^2 + (hRIS - hBS)^2);
    
    % Distancia RIS → UE en 3D
    dist_2D_RIS_UE = norm(UE_pos - RIS_pos);
    d_RIS_UE = sqrt(dist_2D_RIS_UE^2 + (hRIS - hUE)^2);
    
    % Distancia total reflejada
    d_reflected = d_BS_RIS + d_RIS_UE;
    
    % Guardar
    d_direct_array(idx) = d_direct;
    d_BS_RIS_array(idx) = d_BS_RIS;
    d_RIS_UE_array(idx) = d_RIS_UE;
    d_reflected_total(idx) = d_reflected;
    
    fprintf('│   %3d    │   %7.2f m   │   %7.2f m   │   %7.2f m   │   %7.2f m   │\n', ...
        L, d_direct, d_BS_RIS, d_RIS_UE, d_reflected);
end

fprintf('└──────────┴──────────────┴──────────────┴──────────────┴──────────────┘\n\n');

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
    
    fprintf('ANÁLISIS:\n');
    fprintf('  • Diferencia promedio: %+.2f dB\n', avg_difference);
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

sgtitle('Comparación de Path-Loss: Camino Directo vs Reflejado', 'FontSize', 14, 'FontWeight', 'bold');

% Gráfica 2: Diferencia de path-loss (ventaja del camino reflejado)
figure('Position', [100, 150, 1000, 600]);
hold on; box on; grid on;

colors = {'b', 'r', 'g', 'm'};
for freq_idx = 1:length(frequencies)
    plot(dist_array, PL_all_difference(:, freq_idx), '-o', 'LineWidth', 2, 'MarkerSize', 7, ...
        'Color', colors{freq_idx}, 'DisplayName', freq_names{freq_idx});
end

yline(0, '--k', 'LineWidth', 1.5, 'Label', 'Sin ventaja');
xlabel('Distance {\it L} (m)', 'Interpreter', 'tex', 'FontSize', 12);
ylabel('Ventaja del camino reflejado (dB)', 'Interpreter', 'tex', 'FontSize', 12);
title('Ventaja de Path-Loss: Reflejado vs Directo', 'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 11);
set(gca, 'FontName', 'Times', 'FontSize', 11);
grid minor;

%% ==================== RESUMEN FINAL ====================
fprintf('\n=================================================================\n');
fprintf('RESUMEN FINAL\n');
fprintf('=================================================================\n\n');

fprintf('Ventaja promedio del camino reflejado por frecuencia:\n');
fprintf('┌──────────────┬──────────────────┬─────────────────┐\n');
fprintf('│  Frecuencia  │  Ventaja (dB)    │   Evaluación    │\n');
fprintf('├──────────────┼──────────────────┼─────────────────┤\n');

for freq_idx = 1:length(frequencies)
    avg_diff = mean(PL_all_difference(:, freq_idx));
    fprintf('│  %9s   │     %+6.2f dB    │', freq_names{freq_idx}, avg_diff);
    
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

fprintf('└──────────────┴──────────────────┴─────────────────┘\n\n');

fprintf('INTERPRETACIÓN:\n');
fprintf('  • Si la ventaja es positiva y >5 dB: El camino reflejado es mejor\n');
fprintf('  • Si la ventaja es pequeña (<5 dB): La mejora es marginal\n');
fprintf('  • Si la ventaja es negativa: El camino directo es mejor (problema)\n\n');

fprintf('NOTA: Para que la RIS proporcione ganancia significativa en la simulación,\n');
fprintf('      el camino reflejado debe tener MEJOR path-loss que el directo.\n');
fprintf('      Idealmente, la ventaja debería ser >5-10 dB.\n\n');

fprintf('=================================================================\n');
fprintf('Análisis completado.\n');
fprintf('=================================================================\n');


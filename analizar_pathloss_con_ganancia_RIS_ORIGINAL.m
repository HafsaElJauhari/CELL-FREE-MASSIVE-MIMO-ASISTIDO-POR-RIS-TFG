% analizar_pathloss_con_ganancia_RIS_ORIGINAL.m
% Script para calcular path-loss CON ganancia RIS usando las DISTANCIAS ORIGINALES
% dist = [0:20:160] como en tus simulaciones
%
% Path-loss efectivo reflejado = PL_BS→RIS + PL_RIS→UE - Ganancia_RIS

clear;
close all;

fprintf('=================================================================\n');
fprintf('ANÁLISIS CON DISTANCIAS ORIGINALES: Path-Loss + Ganancia RIS\n');
fprintf('=================================================================\n\n');

%% ==================== CONFIGURACIÓN DEL ESCENARIO ====================
% Alturas
hBS = 3;      % Altura estación base (m)
hRIS = 6;     % Altura RIS (m)
hUE = 1.5;    % Altura usuario (m)

% DISTANCIAS ORIGINALES de tus simulaciones
dist_array = [0:20:160]; % Igual que en tus códigos

% Frecuencias a analizar
frequencies = [1.5e9, 3.5e9, 8e9, 15e9]; % Hz
freq_names = {'1.5 GHz', '3.5 GHz', '8 GHz', '15 GHz'};

% TAMAÑOS DE RIS a analizar
N_ris_array = [100, 225, 500, 1000, 2000];
fprintf('Tamaños de RIS a analizar:\n');
for i = 1:length(N_ris_array)
    N = N_ris_array(i);
    ganancia = 10*log10(N^2);
    fprintf('  N = %4d elementos → Ganancia de array = %.1f dB\n', N, ganancia);
end
fprintf('\n');

%% ==================== CÁLCULO DE DISTANCIAS 3D ====================
fprintf('Configuración del escenario (ORIGINAL):\n');
fprintf('  BS: (0, -50), altura = %.1f m\n', hBS);
fprintf('  RIS: (60, -30), altura = %.1f m\n', hRIS);
fprintf('  UE: (L, 0), altura = %.1f m\n', hUE);
fprintf('  Distancias L: %d:%d:%d metros\n\n', dist_array(1), dist_array(2)-dist_array(1), dist_array(end));

fprintf('┌──────────┬──────────────┬──────────────┬──────────────┬──────────────┐\n');
fprintf('│  L (m)   │  d_direct    │  d_BS→RIS    │  d_RIS→UE    │ d_reflected  │\n');
fprintf('│          │   (BS→UE)    │              │              │   (total)    │\n');
fprintf('├──────────┼──────────────┼──────────────┼──────────────┼──────────────┤\n');

% Almacenar distancias
d_direct_array = zeros(length(dist_array), 1);
d_BS_RIS_array = zeros(length(dist_array), 1);
d_RIS_UE_array = zeros(length(dist_array), 1);

for idx = 1:length(dist_array)
    L = dist_array(idx);
    
    % Posiciones
    BS_pos = [0, -50];
    RIS_pos = [60, -30];
    UE_pos = [L, 0];
    
    % Distancias 3D
    dist_2D_direct = norm(UE_pos - BS_pos);
    d_direct_array(idx) = sqrt(dist_2D_direct^2 + (hBS - hUE)^2);
    
    dist_2D_BS_RIS = norm(RIS_pos - BS_pos);
    d_BS_RIS_array(idx) = sqrt(dist_2D_BS_RIS^2 + (hRIS - hBS)^2);
    
    dist_2D_RIS_UE = norm(UE_pos - RIS_pos);
    d_RIS_UE_array(idx) = sqrt(dist_2D_RIS_UE^2 + (hRIS - hUE)^2);
    
    d_reflected_total = d_BS_RIS_array(idx) + d_RIS_UE_array(idx);
    
    fprintf('│   %3d    │   %7.2f m   │   %7.2f m   │   %7.2f m   │   %7.2f m   │\n', ...
        L, d_direct_array(idx), d_BS_RIS_array(idx), d_RIS_UE_array(idx), d_reflected_total);
end

fprintf('└──────────┴──────────────┴──────────────┴──────────────┴──────────────┘\n\n');

%% ==================== ANÁLISIS POR FRECUENCIA Y TAMAÑO RIS ====================

% Para guardar resultados globales
PL_all_difference = zeros(length(dist_array), length(N_ris_array), length(frequencies));
PL_all_direct = zeros(length(dist_array), length(frequencies));

for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    freq_name = freq_names{freq_idx};
    
    fprintf('\n=================================================================\n');
    fprintf('FRECUENCIA: %s (%.2f GHz)\n', freq_name, frequency/1e9);
    fprintf('=================================================================\n\n');
    
    % Calcular path-loss base (sin ganancia RIS)
    PL_direct_dB = zeros(length(dist_array), 1);
    PL_BS_RIS_dB = zeros(length(dist_array), 1);
    PL_RIS_UE_dB = zeros(length(dist_array), 1);
    
    for idx = 1:length(dist_array)
        % Path-loss directo BS → UE (NLOS)
        PL_direct_dB(idx) = calculate_pathloss_3GPP_UMi(d_direct_array(idx), frequency, hBS, hUE, 0);
        
        % Path-loss BS → RIS (LOS)
        PL_BS_RIS_dB(idx) = calculate_pathloss_3GPP_UMi(d_BS_RIS_array(idx), frequency, hBS, hRIS, 1);
        
        % Path-loss RIS → UE (LOS)
        PL_RIS_UE_dB(idx) = calculate_pathloss_3GPP_UMi(d_RIS_UE_array(idx), frequency, hRIS, hUE, 1);
    end
    
    PL_all_direct(:, freq_idx) = PL_direct_dB;
    
    % Analizar para cada tamaño de RIS
    for n_idx = 1:length(N_ris_array)
        N_ris = N_ris_array(n_idx);
        ganancia_RIS = 10*log10(N_ris^2);
        
        fprintf('─────────────────────────────────────────────────────────────────\n');
        fprintf('N_RIS = %d elementos (Ganancia de array = %.1f dB)\n', N_ris, ganancia_RIS);
        fprintf('─────────────────────────────────────────────────────────────────\n\n');
        
        % Path-loss efectivo del camino reflejado (con ganancia RIS)
        PL_reflected_efectivo_dB = PL_BS_RIS_dB + PL_RIS_UE_dB - ganancia_RIS;
        
        % Diferencia (positivo = reflejado mejor)
        PL_difference = PL_direct_dB - PL_reflected_efectivo_dB;
        
        % Guardar
        PL_all_difference(:, n_idx, freq_idx) = PL_difference;
        
        % Tabla
        fprintf('┌──────────┬──────────────┬──────────────┬──────────────┐\n');
        fprintf('│  L (m)   │  PL_direct   │ PL_reflected │  Diferencia  │\n');
        fprintf('│          │   (NLOS)     │  (efectivo)  │  (dB mejor)  │\n');
        fprintf('├──────────┼──────────────┼──────────────┼──────────────┤\n');
        
        for idx = 1:length(dist_array)
            fprintf('│   %3d    │   %6.2f dB  │   %6.2f dB  │   %+6.2f dB │', ...
                dist_array(idx), PL_direct_dB(idx), PL_reflected_efectivo_dB(idx), PL_difference(idx));
            
            if PL_difference(idx) > 0
                fprintf(' ✓ │\n');
            else
                fprintf(' ✗ │\n');
            end
        end
        
        fprintf('└──────────┴──────────────┴──────────────┴──────────────┘\n\n');
        
        % Análisis
        avg_difference = mean(PL_difference);
        num_mejor = sum(PL_difference > 0);
        max_difference = max(PL_difference);
        idx_max = find(PL_difference == max_difference, 1);
        
        fprintf('ANÁLISIS:\n');
        fprintf('  • Diferencia promedio: %+.2f dB\n', avg_difference);
        fprintf('  • Diferencia máxima: %+.2f dB (en L=%d m)\n', max_difference, dist_array(idx_max));
        fprintf('  • Puntos con ventaja: %d/%d (%.0f%%)\n\n', ...
            num_mejor, length(dist_array), 100*num_mejor/length(dist_array));
        
        if avg_difference > 10
            fprintf('  ✓✓ EXCELENTE: Ganancia significativa (>10 dB promedio)\n');
        elseif avg_difference > 5
            fprintf('  ✓ BUENO: Ganancia apreciable (5-10 dB promedio)\n');
        elseif avg_difference > 0
            fprintf('  ~ MARGINAL: Ganancia pequeña (<5 dB promedio)\n');
        else
            fprintf('  ✗ INSUFICIENTE: Sin ganancia (necesitas más elementos RIS)\n');
        end
        fprintf('\n');
    end
end

%% ==================== RESUMEN FINAL ====================
fprintf('\n=================================================================\n');
fprintf('RESUMEN FINAL: Ganancia promedio por N_RIS y frecuencia\n');
fprintf('=================================================================\n\n');

fprintf('┌──────────────┬');
for n_idx = 1:length(N_ris_array)
    fprintf('──────────────┬');
end
fprintf('\n│  Frecuencia  │');
for n_idx = 1:length(N_ris_array)
    fprintf('   N=%4d    │', N_ris_array(n_idx));
end
fprintf('\n├──────────────┼');
for n_idx = 1:length(N_ris_array)
    fprintf('──────────────┼');
end
fprintf('\n');

for freq_idx = 1:length(frequencies)
    fprintf('│  %9s   │', freq_names{freq_idx});
    for n_idx = 1:length(N_ris_array)
        avg_diff = mean(PL_all_difference(:, n_idx, freq_idx));
        fprintf(' %+6.2f dB   │', avg_diff);
    end
    fprintf('\n');
end

fprintf('└──────────────┴');
for n_idx = 1:length(N_ris_array)
    fprintf('──────────────┴');
end
fprintf('\n\n');

%% ==================== COMPARACIÓN CON TU SIMULACIÓN ====================
fprintf('=================================================================\n');
fprintf('COMPARACIÓN CON TUS SIMULACIONES (N_RIS = 1000)\n');
fprintf('=================================================================\n\n');

n_idx_1000 = find(N_ris_array == 1000);
if ~isempty(n_idx_1000)
    fprintf('Ventaja teórica del camino reflejado con N=1000:\n\n');
    fprintf('┌──────────────┬──────────────────┬────────────────────────────┐\n');
    fprintf('│  Frecuencia  │  Ventaja (dB)    │      Interpretación        │\n');
    fprintf('├──────────────┼──────────────────┼────────────────────────────┤\n');
    
    for freq_idx = 1:length(frequencies)
        avg_diff = mean(PL_all_difference(:, n_idx_1000, freq_idx));
        fprintf('│  %9s   │     %+6.2f dB    │', freq_names{freq_idx}, avg_diff);
        
        if avg_diff > 5
            fprintf(' Deberías ver ganancia   │\n');
        elseif avg_diff > 2
            fprintf(' Ganancia marginal       │\n');
        elseif avg_diff > 0
            fprintf(' Ganancia muy pequeña    │\n');
        else
            fprintf(' NO hay ganancia (!)     │\n');
        end
    end
    
    fprintf('└──────────────┴──────────────────┴────────────────────────────┘\n\n');
    
    fprintf('OBSERVACIÓN:\n');
    fprintf('Si en tus simulaciones NO ves ganancia apreciable a 8 GHz y 15 GHz,\n');
    fprintf('es porque el path-loss del camino reflejado es prácticamente igual\n');
    fprintf('o incluso peor que el directo a esas frecuencias con N=1000.\n\n');
end

%% ==================== GRÁFICAS ====================
fprintf('Generando gráficas con distancias originales...\n\n');

% Gráfica 1: Comparación de todas las frecuencias con N=1000
figure('Position', [100, 100, 1000, 700]);

subplot(2,1,1);
hold on; box on; grid on;
colors_freq = {'b', 'r', 'g', 'm'};
n_idx_plot = find(N_ris_array == 1000);

for freq_idx = 1:length(frequencies)
    plot(dist_array, PL_all_direct(:, freq_idx), '--', 'LineWidth', 1.5, 'Color', colors_freq{freq_idx}, ...
        'DisplayName', sprintf('Directo %s', freq_names{freq_idx}));
end

xlabel('Distance {\it L} (m)', 'Interpreter', 'tex', 'FontSize', 11);
ylabel('Path-loss (dB)', 'Interpreter', 'tex', 'FontSize', 11);
title('Path-Loss del Camino Directo (NLOS)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 9);
set(gca, 'FontName', 'Times', 'FontSize', 10);

subplot(2,1,2);
hold on; box on; grid on;

for freq_idx = 1:length(frequencies)
    plot(dist_array, PL_all_difference(:, n_idx_plot, freq_idx), '-o', 'LineWidth', 2, ...
        'MarkerSize', 6, 'Color', colors_freq{freq_idx}, 'DisplayName', freq_names{freq_idx});
end

yline(0, '--k', 'LineWidth', 1.5, 'Label', 'Sin ventaja');
yline(5, ':k', 'LineWidth', 1, 'Label', '5 dB');

xlabel('Distance {\it L} (m)', 'Interpreter', 'tex', 'FontSize', 11);
ylabel('Ventaja del camino reflejado (dB)', 'Interpreter', 'tex', 'FontSize', 11);
title('Ventaja con N=1000 elementos (Distancias Originales)', 'FontSize', 12, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 10);
set(gca, 'FontName', 'Times', 'FontSize', 10);
grid minor;

% Gráfica 2: Ventaja vs N_RIS para cada frecuencia
figure('Position', [150, 150, 1000, 600]);
hold on; box on; grid on;

for freq_idx = 1:length(frequencies)
    avg_gains = zeros(length(N_ris_array), 1);
    for n_idx = 1:length(N_ris_array)
        avg_gains(n_idx) = mean(PL_all_difference(:, n_idx, freq_idx));
    end
    plot(N_ris_array, avg_gains, '-o', 'LineWidth', 2.5, 'MarkerSize', 8, ...
        'Color', colors_freq{freq_idx}, 'DisplayName', freq_names{freq_idx});
end

yline(0, '--k', 'LineWidth', 1.5, 'Label', 'Sin ventaja');
yline(5, ':k', 'LineWidth', 1, 'Label', 'Ganancia apreciable (5 dB)');
yline(10, ':k', 'LineWidth', 1, 'Label', 'Ganancia significativa (10 dB)');

xlabel('Número de elementos RIS (N)', 'Interpreter', 'tex', 'FontSize', 12);
ylabel('Ventaja promedio (dB)', 'Interpreter', 'tex', 'FontSize', 12);
title('Ganancia de la RIS vs Número de Elementos (Distancias Originales)', ...
    'FontSize', 13, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 11);
set(gca, 'FontName', 'Times', 'FontSize', 11);
grid minor;

%% ==================== RECOMENDACIONES ====================
fprintf('=================================================================\n');
fprintf('RECOMENDACIONES PARA TU TUTOR\n');
fprintf('=================================================================\n\n');

fprintf('Con las distancias originales (0-160 m) y N_RIS=1000:\n\n');

n_idx_1000 = find(N_ris_array == 1000);
for freq_idx = 1:length(frequencies)
    avg_diff = mean(PL_all_difference(:, n_idx_1000, freq_idx));
    fprintf('  %s: %+.2f dB de ventaja promedio\n', freq_names{freq_idx}, avg_diff);
end

fprintf('\nPROBLEMA IDENTIFICADO:\n');
fprintf('  A frecuencias altas (≥8 GHz), la ventaja es muy pequeña o negativa.\n');
fprintf('  Esto explica por qué no ves mejora apreciable en las simulaciones.\n\n');

fprintf('SOLUCIONES PROPUESTAS:\n');
fprintf('  1. Usar solo frecuencias bajas (1.5 y 3.5 GHz) donde SÍ hay ventaja\n');
fprintf('  2. Aumentar N_RIS a 2000 elementos para todas las frecuencias\n');
fprintf('  3. Escalar N_RIS con f² para mantener ganancia constante\n\n');

% Calcular N mínimo para ganancia >5 dB en cada frecuencia
fprintf('Número mínimo de elementos RIS para ganancia >5 dB:\n\n');
for freq_idx = 1:length(frequencies)
    fprintf('  %s: ', freq_names{freq_idx});
    found = false;
    for n_idx = 1:length(N_ris_array)
        avg_diff = mean(PL_all_difference(:, n_idx, freq_idx));
        if avg_diff > 5 && ~found
            fprintf('N ≥ %d elementos\n', N_ris_array(n_idx));
            found = true;
        end
    end
    if ~found
        fprintf('N > %d elementos (necesitas más)\n', N_ris_array(end));
    end
end

fprintf('\n=================================================================\n');
fprintf('Análisis completado con distancias originales (0-160 m).\n');
fprintf('=================================================================\n');


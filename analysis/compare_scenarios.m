% compare_scenarios.m
% Script para comparar cuantitativamente dos escenarios
% Carga los datos de dos simulaciones y los compara

clear; clc;

fprintf('=================================================================\n');
fprintf('COMPARACIÓN CUANTITATIVA DE ESCENARIOS\n');
fprintf('=================================================================\n\n');

%% ==================== CARGAR DATOS ====================
% Necesitas tener los datos guardados de cada simulación
% Opción 1: Cargar desde .mat files
% load('main_clean.mat');  % Escenario original
% load('main_RIS_near_BS.mat'); % Escenario nuevo

% Opción 2: Usar variables del workspace (si acabas de ejecutar)
% Asume que tienes en workspace:
% - R_sum_mean_escenario1, R_sum_noRIS_mean_escenario1 (Escenario 1)
% - R_sum_mean_escenario2, R_sum_noRIS_mean_escenario2 (Escenario 2)
% - dist (vector de distancias)

fprintf('INSTRUCCIONES DE USO:\n');
fprintf('1. Ejecuta primero el escenario 1 y guarda las variables:\n');
fprintf('   R_sum_1 = R_sum_mean_all(:,freq_idx);\n');
fprintf('   R_sum_noRIS_1 = R_sum_noRIS_mean_all(:,freq_idx);\n\n');
fprintf('2. Ejecuta el escenario 2 y guarda las variables:\n');
fprintf('   R_sum_2 = R_sum_mean_all(:,freq_idx);\n');
fprintf('   R_sum_noRIS_2 = R_sum_noRIS_mean_all(:,freq_idx);\n\n');
fprintf('3. Vuelve a ejecutar este script\n\n');

% Verificar que existen las variables necesarias
if ~exist('R_sum_1', 'var') || ~exist('R_sum_2', 'var')
    fprintf('⚠️  Faltan datos. Necesitas definir las variables:\n');
    fprintf('   - R_sum_1 (escenario 1 con RIS)\n');
    fprintf('   - R_sum_noRIS_1 (escenario 1 sin RIS)\n');
    fprintf('   - R_sum_2 (escenario 2 con RIS)\n');
    fprintf('   - R_sum_noRIS_2 (escenario 2 sin RIS)\n');
    fprintf('   - dist (vector de distancias)\n\n');
    
    % Datos de ejemplo para demostración
    fprintf('Usando datos de EJEMPLO para demostración...\n\n');
    dist = [0:20:160];
    R_sum_1 = [10, 9.5, 9, 8.5, 8, 7.5, 7, 6.5, 6]';
    R_sum_noRIS_1 = [7, 6.8, 6.5, 6.2, 6, 5.8, 5.5, 5.2, 5]';
    R_sum_2 = [11, 10.5, 10, 9.5, 9, 8.5, 8, 7.5, 7]';
    R_sum_noRIS_2 = [7.2, 7, 6.7, 6.4, 6.2, 6, 5.7, 5.4, 5.2]';
end

%% ==================== MÉTODO 1: Diferencia punto a punto ====================
fprintf('=================================================================\n');
fprintf('MÉTODO 1: Diferencia punto a punto\n');
fprintf('=================================================================\n\n');

diff_withRIS = R_sum_2 - R_sum_1;
diff_noRIS = R_sum_noRIS_2 - R_sum_noRIS_1;

fprintf('Diferencia en cada punto (Escenario 2 - Escenario 1):\n\n');
fprintf('┌──────────┬───────────────┬───────────────┐\n');
fprintf('│ Dist (m) │  Con RIS      │  Sin RIS      │\n');
fprintf('│          │  (bit/s/Hz)   │  (bit/s/Hz)   │\n');
fprintf('├──────────┼───────────────┼───────────────┤\n');
for i = 1:length(dist)
    fprintf('│   %3d    │   %+6.3f     │   %+6.3f     │\n', ...
        dist(i), diff_withRIS(i), diff_noRIS(i));
end
fprintf('└──────────┴───────────────┴───────────────┘\n\n');

fprintf('Interpretación:\n');
fprintf('  • Valores POSITIVOS: Escenario 2 es mejor\n');
fprintf('  • Valores NEGATIVOS: Escenario 1 es mejor\n\n');

%% ==================== MÉTODO 2: Promedio global ====================
fprintf('=================================================================\n');
fprintf('MÉTODO 2: Rendimiento promedio global\n');
fprintf('=================================================================\n\n');

avg_withRIS_1 = mean(R_sum_1);
avg_noRIS_1 = mean(R_sum_noRIS_1);
avg_withRIS_2 = mean(R_sum_2);
avg_noRIS_2 = mean(R_sum_noRIS_2);

fprintf('Rendimiento promedio:\n');
fprintf('┌──────────────┬───────────────┬───────────────┐\n');
fprintf('│ Escenario    │  Con RIS      │  Sin RIS      │\n');
fprintf('│              │  (bit/s/Hz)   │  (bit/s/Hz)   │\n');
fprintf('├──────────────┼───────────────┼───────────────┤\n');
fprintf('│ Escenario 1  │    %6.3f     │    %6.3f     │\n', avg_withRIS_1, avg_noRIS_1);
fprintf('│ Escenario 2  │    %6.3f     │    %6.3f     │\n', avg_withRIS_2, avg_noRIS_2);
fprintf('├──────────────┼───────────────┼───────────────┤\n');
fprintf('│ Diferencia   │   %+6.3f     │   %+6.3f     │\n', avg_withRIS_2-avg_withRIS_1, avg_noRIS_2-avg_noRIS_1);
fprintf('└──────────────┴───────────────┴───────────────┘\n\n');

%% ==================== MÉTODO 3: Área bajo la curva (AUC) ====================
fprintf('=================================================================\n');
fprintf('MÉTODO 3: Área bajo la curva (AUC)\n');
fprintf('=================================================================\n\n');

% Usar trapz (regla del trapecio) para calcular integral
AUC_withRIS_1 = trapz(dist, R_sum_1);
AUC_noRIS_1 = trapz(dist, R_sum_noRIS_1);
AUC_withRIS_2 = trapz(dist, R_sum_2);
AUC_noRIS_2 = trapz(dist, R_sum_noRIS_2);

fprintf('Área bajo la curva (mayor = mejor rendimiento acumulado):\n');
fprintf('┌──────────────┬───────────────┬───────────────┐\n');
fprintf('│ Escenario    │  Con RIS      │  Sin RIS      │\n');
fprintf('├──────────────┼───────────────┼───────────────┤\n');
fprintf('│ Escenario 1  │    %8.1f   │    %8.1f   │\n', AUC_withRIS_1, AUC_noRIS_1);
fprintf('│ Escenario 2  │    %8.1f   │    %8.1f   │\n', AUC_withRIS_2, AUC_noRIS_2);
fprintf('├──────────────┼───────────────┼───────────────┤\n');
fprintf('│ Diferencia   │   %+8.1f   │   %+8.1f   │\n', AUC_withRIS_2-AUC_withRIS_1, AUC_noRIS_2-AUC_noRIS_1);
fprintf('└──────────────┴───────────────┴───────────────┘\n\n');

fprintf('Interpretación:\n');
fprintf('  • AUC mide el rendimiento acumulado en todo el rango\n');
fprintf('  • Métrica robusta que pondera todos los puntos\n\n');

%% ==================== MÉTODO 4: Ganancia porcentual ====================
fprintf('=================================================================\n');
fprintf('MÉTODO 4: Ganancia porcentual (%% de mejora)\n');
fprintf('=================================================================\n\n');

gain_percent_withRIS = ((avg_withRIS_2 - avg_withRIS_1) / avg_withRIS_1) * 100;
gain_percent_noRIS = ((avg_noRIS_2 - avg_noRIS_1) / avg_noRIS_1) * 100;

fprintf('Ganancia del Escenario 2 respecto a Escenario 1:\n');
fprintf('┌──────────────┬───────────────┐\n');
fprintf('│              │  Ganancia (%%) │\n');
fprintf('├──────────────┼───────────────┤\n');
fprintf('│ Con RIS      │    %+6.2f%%   │\n', gain_percent_withRIS);
fprintf('│ Sin RIS      │    %+6.2f%%   │\n', gain_percent_noRIS);
fprintf('└──────────────┴───────────────┘\n\n');

if abs(gain_percent_withRIS) < 1
    fprintf('✓ Diferencia MÍNIMA (<1%%): Escenarios prácticamente iguales\n');
elseif abs(gain_percent_withRIS) < 5
    fprintf('✓ Diferencia PEQUEÑA (1-5%%): Mejora marginal\n');
elseif abs(gain_percent_withRIS) < 15
    fprintf('⚠️  Diferencia MODERADA (5-15%%): Mejora notable\n');
else
    fprintf('🎯 Diferencia SIGNIFICATIVA (>15%%): Mejora importante\n');
end

if gain_percent_withRIS > 0
    fprintf('→ Escenario 2 es MEJOR\n\n');
else
    fprintf('→ Escenario 1 es MEJOR\n\n');
end

%% ==================== RESUMEN Y RECOMENDACIÓN ====================
fprintf('=================================================================\n');
fprintf('RESUMEN Y RECOMENDACIÓN\n');
fprintf('=================================================================\n\n');

% Determinar ganador basado en múltiples métricas
score_2 = 0;
if avg_withRIS_2 > avg_withRIS_1, score_2 = score_2 + 1; end
if AUC_withRIS_2 > AUC_withRIS_1, score_2 = score_2 + 1; end
if mean(diff_withRIS) > 0, score_2 = score_2 + 1; end

fprintf('Métricas clave:\n');
fprintf('  1. Promedio:  Escenario %d (%.3f vs %.3f bit/s/Hz)\n', ...
    (avg_withRIS_2 > avg_withRIS_1) + 1, max(avg_withRIS_1, avg_withRIS_2), min(avg_withRIS_1, avg_withRIS_2));
fprintf('  2. AUC:       Escenario %d (%.1f vs %.1f)\n', ...
    (AUC_withRIS_2 > AUC_withRIS_1) + 1, max(AUC_withRIS_1, AUC_withRIS_2), min(AUC_withRIS_1, AUC_withRIS_2));
fprintf('  3. Ganancia:  %+.2f%%\n\n', gain_percent_withRIS);

if score_2 >= 2
    fprintf('🏆 GANADOR: Escenario 2\n');
    fprintf('   → Mejor en %d de 3 métricas\n\n', score_2);
else
    fprintf('🏆 GANADOR: Escenario 1\n');
    fprintf('   → Mejor en %d de 3 métricas\n\n', 3-score_2);
end

fprintf('RECOMENDACIÓN:\n');
fprintf('  • Usa el PROMEDIO para comparación simple\n');
fprintf('  • Usa el AUC para métrica más robusta\n');
fprintf('  • Usa GANANCIA %% para comunicar resultados\n');
fprintf('=================================================================\n\n');

%% ==================== GRÁFICA COMPARATIVA ====================
figure('Position', [100, 100, 1400, 500]);

% Subplot 1: Comparación directa
subplot(1,3,1);
hold on; box on; grid on;
plot(dist, R_sum_1, '-o', 'LineWidth', 2, 'MarkerSize', 7, 'Color', 'b', 'DisplayName', 'Escenario 1 con RIS');
plot(dist, R_sum_2, '-s', 'LineWidth', 2, 'MarkerSize', 7, 'Color', 'r', 'DisplayName', 'Escenario 2 con RIS');
legend('Location', 'best');
xlabel('Distance (m)');
ylabel('Weighted sum-rate (bit/s/Hz)');
title('Comparación Directa');
set(gca, 'FontName', 'Times', 'FontSize', 11);

% Subplot 2: Diferencia absoluta
subplot(1,3,2);
hold on; box on; grid on;
bar(dist, diff_withRIS, 'FaceColor', [0.3 0.6 0.8]);
yline(0, 'k--', 'LineWidth', 1);
xlabel('Distance (m)');
ylabel('Diferencia (bit/s/Hz)');
title(sprintf('Diferencia (Esc2 - Esc1)\nPromedio: %+.3f', mean(diff_withRIS)));
set(gca, 'FontName', 'Times', 'FontSize', 11);

% Subplot 3: Ganancia porcentual por punto
subplot(1,3,3);
hold on; box on; grid on;
gain_percent_points = ((R_sum_2 - R_sum_1) ./ R_sum_1) * 100;
bar(dist, gain_percent_points, 'FaceColor', [0.8 0.4 0.3]);
yline(0, 'k--', 'LineWidth', 1);
yline(gain_percent_withRIS, 'b--', 'LineWidth', 1.5, 'Label', sprintf('Promedio: %.1f%%', gain_percent_withRIS));
xlabel('Distance (m)');
ylabel('Ganancia (%)');
title('Ganancia Porcentual');
set(gca, 'FontName', 'Times', 'FontSize', 11);

sgtitle('Comparación Cuantitativa de Escenarios', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('Gráficas generadas.\n\n');



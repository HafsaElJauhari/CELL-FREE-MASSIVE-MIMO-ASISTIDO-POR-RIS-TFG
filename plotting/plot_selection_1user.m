%% Script para dibujar resultados de selección vs no selección (1 usuario)
clear; close all;

% Cargar resultados
load('resultados_selection_vs_no_selection_1user.mat');

% Filtrar datos para rango 40-120 m
idx_range = dist >= 40 & dist <= 120;
dist_plot = dist(idx_range);

%% Figura 1: Frecuencia 3.5 GHz
figure('Position', [100 100 700 500]);
hold on;
grid on;
box on;

freq_idx = 1;
data_sel = R_sum_sel_mean(idx_range, freq_idx);
data_nosel = R_sum_nosel_mean(idx_range, freq_idx);
data_noRIS = R_sum_noRIS_mean(idx_range, freq_idx);

plot(dist_plot, data_sel, '-o', ...
    'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0.0 0.4 0.8], ...
    'Color', [0.0 0.4 0.8], 'DisplayName', 'Con selecci\''on RIS');

plot(dist_plot, data_nosel, '--s', ...
    'LineWidth', 1.5, 'MarkerSize', 6, ...
    'Color', [0.8 0.2 0.2], 'DisplayName', 'Sin selecci\''on RIS');

plot(dist_plot, data_noRIS, ':^', ...
    'LineWidth', 1.5, 'MarkerSize', 6, ...
    'Color', [0.2 0.6 0.2], 'DisplayName', 'Sin RIS');

xlabel('Distancia del usuario, $d$ (m)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Tasa suma (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'best', 'FontSize', 10, 'Interpreter', 'latex');
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
xlim([40 120]);
hold off;

savefig('figura_3p5GHz_1usuario.fig');
print('figura_3p5GHz_1usuario', '-dpng', '-r300');
print('figura_3p5GHz_1usuario', '-djpeg', '-r300');
fprintf('Figura 3.5 GHz guardada.\n');

%% Figura 2: Frecuencia 8 GHz
figure('Position', [150 150 700 500]);
hold on;
grid on;
box on;

freq_idx = 2;
data_sel = R_sum_sel_mean(idx_range, freq_idx);
data_nosel = R_sum_nosel_mean(idx_range, freq_idx);
data_noRIS = R_sum_noRIS_mean(idx_range, freq_idx);

plot(dist_plot, data_sel, '-o', ...
    'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0.0 0.4 0.8], ...
    'Color', [0.0 0.4 0.8], 'DisplayName', 'Con selecci\''on RIS');

plot(dist_plot, data_nosel, '--s', ...
    'LineWidth', 1.5, 'MarkerSize', 6, ...
    'Color', [0.8 0.2 0.2], 'DisplayName', 'Sin selecci\''on RIS');

plot(dist_plot, data_noRIS, ':^', ...
    'LineWidth', 1.5, 'MarkerSize', 6, ...
    'Color', [0.2 0.6 0.2], 'DisplayName', 'Sin RIS');

xlabel('Distancia del usuario, $d$ (m)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Tasa suma (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'best', 'FontSize', 10, 'Interpreter', 'latex');
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
xlim([40 120]);
hold off;

savefig('figura_8GHz_1usuario.fig');
print('figura_8GHz_1usuario', '-dpng', '-r300');
print('figura_8GHz_1usuario', '-djpeg', '-r300');
fprintf('Figura 8 GHz guardada.\n');

%% Figura 3: Frecuencia 15 GHz
figure('Position', [200 200 700 500]);
hold on;
grid on;
box on;

freq_idx = 3;
data_sel = R_sum_sel_mean(idx_range, freq_idx);
data_nosel = R_sum_nosel_mean(idx_range, freq_idx);
data_noRIS = R_sum_noRIS_mean(idx_range, freq_idx);

plot(dist_plot, data_sel, '-o', ...
    'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', [0.0 0.4 0.8], ...
    'Color', [0.0 0.4 0.8], 'DisplayName', 'Con selecci\''on RIS');

plot(dist_plot, data_nosel, '--s', ...
    'LineWidth', 1.5, 'MarkerSize', 6, ...
    'Color', [0.8 0.2 0.2], 'DisplayName', 'Sin selecci\''on RIS');

plot(dist_plot, data_noRIS, ':^', ...
    'LineWidth', 1.5, 'MarkerSize', 6, ...
    'Color', [0.2 0.6 0.2], 'DisplayName', 'Sin RIS');

xlabel('Distancia del usuario, $d$ (m)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Tasa suma (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'best', 'FontSize', 10, 'Interpreter', 'latex');
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
xlim([40 120]);
hold off;

savefig('figura_15GHz_1usuario.fig');
print('figura_15GHz_1usuario', '-dpng', '-r300');
print('figura_15GHz_1usuario', '-djpeg', '-r300');
fprintf('Figura 15 GHz guardada.\n');

%% Figura 4: Comparación de todas las frecuencias (solo con selección)
figure('Position', [250 250 700 500]);
hold on;
grid on;
box on;

colors = [0.0 0.4 0.8; 0.8 0.2 0.2; 0.2 0.6 0.2];
markers = {'o', 's', '^'};

for freq_idx = 1:length(frequencies)
    data_sel = R_sum_sel_mean(idx_range, freq_idx);
    plot(dist_plot, data_sel, ...
        'LineStyle', '-', 'Marker', markers{freq_idx}, ...
        'LineWidth', 1.5, 'MarkerSize', 6, ...
        'Color', colors(freq_idx,:), 'MarkerFaceColor', colors(freq_idx,:), ...
        'DisplayName', sprintf('$f = %.1f$ GHz, $N = %d$', frequencies(freq_idx)/1e9, N_ris_values(freq_idx)));
end

xlabel('Distancia del usuario, $d$ (m)', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Tasa suma (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'best', 'FontSize', 10, 'Interpreter', 'latex');
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
xlim([40 120]);
hold off;

savefig('comparacion_frecuencias_con_seleccion.fig');
print('comparacion_frecuencias_con_seleccion', '-dpng', '-r300');
print('comparacion_frecuencias_con_seleccion', '-djpeg', '-r300');
fprintf('Figura comparación frecuencias guardada.\n');

%% Mostrar estadísticas
fprintf('\n=== Resumen de resultados (rango 40-120 m) ===\n');
for freq_idx = 1:length(frequencies)
    data_sel = R_sum_sel_mean(idx_range, freq_idx);
    data_nosel = R_sum_nosel_mean(idx_range, freq_idx);
    data_noRIS = R_sum_noRIS_mean(idx_range, freq_idx);
    
    fprintf('\nFrecuencia: %.1f GHz (N=%d elementos RIS)\n', frequencies(freq_idx)/1e9, N_ris_values(freq_idx));
    fprintf('  Tasa suma promedio con selección:    %.2f bit/s/Hz\n', mean(data_sel));
    fprintf('  Tasa suma promedio sin selección:    %.2f bit/s/Hz\n', mean(data_nosel));
    fprintf('  Tasa suma promedio sin RIS:          %.2f bit/s/Hz\n', mean(data_noRIS));
    
    ganancia_sel = (mean(data_sel) - mean(data_noRIS)) / mean(data_noRIS) * 100;
    ganancia_nosel = (mean(data_nosel) - mean(data_noRIS)) / mean(data_noRIS) * 100;
    fprintf('  Ganancia con selección vs sin RIS: %.1f%%\n', ganancia_sel);
    fprintf('  Ganancia sin selección vs sin RIS: %.1f%%\n', ganancia_nosel);
end

fprintf('\n=== Figuras guardadas ===\n');
fprintf('- figura_3p5GHz_1usuario.fig / .png / .jpg\n');
fprintf('- figura_8GHz_1usuario.fig / .png / .jpg\n');
fprintf('- figura_15GHz_1usuario.fig / .png / .jpg\n');
fprintf('- comparacion_frecuencias_con_seleccion.fig / .png / .jpg\n');

% Script para dibujar resultados de puntos RIS (2 usuarios)
clear; close all;

% Cargar resultados
load('resultados_puntos_RIS.mat');

%% Figura 1: Comparación por frecuencia (barras)
figure('Position', [100 100 900 500]);

% Preparar datos para barras
datos_sel = R_sum_sel_mean';      % (freq x dist)
datos_nosel = R_sum_nosel_mean';
datos_noRIS = R_sum_noRIS_mean';

x = 1:length(frequencies);
width = 0.25;

hold on;
grid on;
box on;

% Barras para cada punto d
colors_d = [0.2 0.6 0.8; 0.8 0.4 0.2; 0.2 0.7 0.3];  % Colores por distancia

b1 = bar(x - width, datos_sel, width, 'FaceColor', 'flat');
b2 = bar(x, datos_nosel, width, 'FaceColor', 'flat');
b3 = bar(x + width, datos_noRIS, width, 'FaceColor', 'flat');

% Colores
for i = 1:length(dist)
    b1(i).FaceColor = colors_d(i,:);
    b2(i).FaceColor = colors_d(i,:) * 0.7;
    b3(i).FaceColor = colors_d(i,:) * 0.4;
end

xlabel('Frecuencia', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Tasa suma (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 14);
set(gca, 'XTick', x, 'XTickLabel', freq_names, 'FontSize', 12, 'TickLabelInterpreter', 'latex');

legend_entries = {};
for i = 1:length(dist)
    legend_entries{end+1} = sprintf('$d=%d$ m, Con sel.', dist(i));
end
legend(b1, legend_entries, 'Location', 'northeast', 'Interpreter', 'latex', 'FontSize', 10);

hold off;

savefig('figura_puntos_RIS_barras.fig');
print('figura_puntos_RIS_barras', '-dpng', '-r300');
print('figura_puntos_RIS_barras', '-djpeg', '-r300');

%% Figura 2: Una figura por frecuencia
for freq_idx = 1:length(frequencies)
    figure('Position', [100+50*freq_idx 100+50*freq_idx 700 500]);
    hold on;
    grid on;
    box on;
    
    x_pos = 1:length(dist);
    
    bar_width = 0.25;
    bar(x_pos - bar_width, R_sum_sel_mean(:, freq_idx), bar_width, ...
        'FaceColor', [0.0 0.4 0.8], 'DisplayName', 'Con selecci\''on RIS');
    bar(x_pos, R_sum_nosel_mean(:, freq_idx), bar_width, ...
        'FaceColor', [0.8 0.2 0.2], 'DisplayName', 'Sin selecci\''on RIS');
    bar(x_pos + bar_width, R_sum_noRIS_mean(:, freq_idx), bar_width, ...
        'FaceColor', [0.2 0.6 0.2], 'DisplayName', 'Sin RIS');
    
    % Añadir barras de error
    errorbar(x_pos - bar_width, R_sum_sel_mean(:, freq_idx), R_sum_sel_std(:, freq_idx), ...
        'k', 'LineStyle', 'none', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    errorbar(x_pos, R_sum_nosel_mean(:, freq_idx), R_sum_nosel_std(:, freq_idx), ...
        'k', 'LineStyle', 'none', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    
    xlabel('Distancia $d$ (m)', 'Interpreter', 'latex', 'FontSize', 14);
    ylabel('Tasa suma (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 14);
    
    % Etiquetas del eje X
    dist_labels = cell(1, length(dist));
    for i = 1:length(dist)
        dist_labels{i} = sprintf('%d', dist(i));
    end
    set(gca, 'XTick', x_pos, 'XTickLabel', dist_labels, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
    
    legend('Location', 'best', 'FontSize', 10, 'Interpreter', 'latex');
    hold off;
    
    filename = sprintf('figura_puntos_RIS_%sGHz', strrep(freq_names{freq_idx}, ' ', ''));
    filename = strrep(filename, '.', 'p');
    savefig([filename '.fig']);
    print(filename, '-dpng', '-r300');
    print(filename, '-djpeg', '-r300');
    fprintf('Figura %s guardada.\n', filename);
end

%% Figura 3: Verificación de simetría (d=20 vs d=100)
figure('Position', [300 300 700 500]);
hold on;
grid on;
box on;

idx_20 = find(dist == 20);
idx_100 = find(dist == 100);

x_freq = 1:length(frequencies);

% Con selección
plot(x_freq, R_sum_sel_mean(idx_20, :), '-o', ...
    'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', [0.0 0.4 0.8], ...
    'Color', [0.0 0.4 0.8], 'DisplayName', '$d=20$ m (Con sel.)');
plot(x_freq, R_sum_sel_mean(idx_100, :), '--s', ...
    'LineWidth', 2, 'MarkerSize', 10, 'MarkerFaceColor', [0.8 0.2 0.2], ...
    'Color', [0.8 0.2 0.2], 'DisplayName', '$d=100$ m (Con sel.)');

xlabel('Frecuencia', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('Tasa suma (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 14);
set(gca, 'XTick', x_freq, 'XTickLabel', freq_names, 'FontSize', 12, 'TickLabelInterpreter', 'latex');
legend('Location', 'best', 'FontSize', 11, 'Interpreter', 'latex');
hold off;

savefig('figura_simetria_d20_d100.fig');
print('figura_simetria_d20_d100', '-dpng', '-r300');
print('figura_simetria_d20_d100', '-djpeg', '-r300');
fprintf('Figura simetría guardada.\n');

%% Mostrar estadísticas
fprintf('\n=== RESUMEN DE RESULTADOS ===\n');
for freq_idx = 1:length(frequencies)
    fprintf('\n%s (N=%d):\n', freq_names{freq_idx}, N_ris_values(freq_idx));
    for a = 1:length(dist)
        fprintf('  d=%3dm: Sin RIS=%.3f, Sin sel=%.3f, Con sel=%.3f\n', ...
            dist(a), R_sum_noRIS_mean(a, freq_idx), ...
            R_sum_nosel_mean(a, freq_idx), R_sum_sel_mean(a, freq_idx));
    end
end

fprintf('\n=== VERIFICACIÓN SIMETRÍA d=20 vs d=100 ===\n');
for freq_idx = 1:length(frequencies)
    val_20 = R_sum_sel_mean(idx_20, freq_idx);
    val_100 = R_sum_sel_mean(idx_100, freq_idx);
    dif = 100 * abs(val_20 - val_100) / max(val_20, val_100);
    fprintf('%s: d=20=%.4f, d=100=%.4f, Dif=%.1f%%\n', ...
        freq_names{freq_idx}, val_20, val_100, dif);
end

fprintf('\n=== FIGURAS GUARDADAS ===\n');
fprintf('- figura_puntos_RIS_barras.fig/.png/.jpg\n');
fprintf('- figura_puntos_RIS_3p5GHz.fig/.png/.jpg\n');
fprintf('- figura_puntos_RIS_8GHz.fig/.png/.jpg\n');
fprintf('- figura_puntos_RIS_15GHz.fig/.png/.jpg\n');
fprintf('- figura_simetria_d20_d100.fig/.png/.jpg\n');


%% Script para graficar resultados comparativos
% Genera figuras profesionales para 3.5 GHz y 8 GHz

clear; close all;

%% Cargar resultados 3.5 GHz
data_optimo_35 = load('resultados_3_5GHz_optimo.mat');
data_greedy_35 = load('resultados_3_5GHz_greedy.mat');

%% Cargar resultados 8 GHz
data_optimo_8 = load('resultados_8GHz_optimo.mat');
data_greedy_8 = load('resultados_8GHz_greedy.mat');

%% Configuración de colores (estilo paper)
color_noRIS = [0.13 0.55 0.13];        % Verde oscuro
color_nosel = [0.70 0.13 0.13];        % Rojo/marrón
color_greedy = [0 0.45 0.74];          % Azul
color_optimo = [0.49 0.18 0.56];       % Púrpura

linewidth = 1;
markersize = 6;

%% Figura 1: 3.5 GHz
figure('Position', [100, 100, 560, 420], 'Color', 'w');

dist = data_optimo_35.dist;

R_noRIS_35 = data_optimo_35.R_sum_noRIS_mean;
R_nosel_35 = data_optimo_35.R_sum_nosel_mean;
R_greedy_35 = data_greedy_35.R_sum_sel_mean;
R_optimo_35 = data_optimo_35.R_sum_sel_mean;

plot(dist, R_noRIS_35, ':^', 'Color', color_noRIS, 'LineWidth', linewidth, ...
    'MarkerSize', markersize, 'MarkerFaceColor', 'none');
hold on;
plot(dist, R_nosel_35, '--s', 'Color', color_nosel, 'LineWidth', linewidth, ...
    'MarkerSize', markersize, 'MarkerFaceColor', 'none');
plot(dist, R_greedy_35, '-o', 'Color', color_greedy, 'LineWidth', linewidth, ...
    'MarkerSize', markersize, 'MarkerFaceColor', 'none');
plot(dist, R_optimo_35, '-d', 'Color', color_optimo, 'LineWidth', linewidth, ...
    'MarkerSize', markersize, 'MarkerFaceColor', 'none');
hold off;

xlabel('Distancia del usuario, {\itd} (m)', 'FontSize', 11, 'Interpreter', 'tex');
ylabel('Tasa suma (bit/s/Hz)', 'FontSize', 11);
grid on;
set(gca, 'FontSize', 10, 'GridColor', [0.7 0.7 0.7], 'GridAlpha', 1, ...
    'GridLineStyle', '-', 'MinorGridLineStyle', 'none', 'TickDir', 'in');

leg = legend({'Sin RIS', 'Sin selección RIS', 'Selección greedy', 'Selección óptima'}, ...
    'Location', 'northeast', 'FontSize', 9);
set(leg, 'Box', 'on', 'EdgeColor', [0.5 0.5 0.5]);

box on;
xlim([min(dist) max(dist)]);

saveas(gcf, 'figura_comparativa_3_5GHz.fig');
saveas(gcf, 'figura_comparativa_3_5GHz.png');
print(gcf, 'figura_comparativa_3_5GHz', '-depsc2');

%% Figura 2: 8 GHz
figure('Position', [150, 150, 560, 420], 'Color', 'w');

dist_8 = data_optimo_8.dist;

R_noRIS_8 = data_optimo_8.R_sum_noRIS_mean;
R_nosel_8 = data_optimo_8.R_sum_nosel_mean;
R_greedy_8 = data_greedy_8.R_sum_sel_mean;
R_optimo_8 = data_optimo_8.R_sum_sel_mean;

plot(dist_8, R_noRIS_8, ':^', 'Color', color_noRIS, 'LineWidth', linewidth, ...
    'MarkerSize', markersize, 'MarkerFaceColor', 'none');
hold on;
plot(dist_8, R_nosel_8, '--s', 'Color', color_nosel, 'LineWidth', linewidth, ...
    'MarkerSize', markersize, 'MarkerFaceColor', 'none');
plot(dist_8, R_greedy_8, '-o', 'Color', color_greedy, 'LineWidth', linewidth, ...
    'MarkerSize', markersize, 'MarkerFaceColor', 'none');
plot(dist_8, R_optimo_8, '-d', 'Color', color_optimo, 'LineWidth', linewidth, ...
    'MarkerSize', markersize, 'MarkerFaceColor', 'none');
hold off;

xlabel('Distancia del usuario, {\itd} (m)', 'FontSize', 11, 'Interpreter', 'tex');
ylabel('Tasa suma (bit/s/Hz)', 'FontSize', 11);
grid on;
set(gca, 'FontSize', 10, 'GridColor', [0.7 0.7 0.7], 'GridAlpha', 1, ...
    'GridLineStyle', '-', 'MinorGridLineStyle', 'none', 'TickDir', 'in');

leg = legend({'Sin RIS', 'Sin selección RIS', 'Selección greedy', 'Selección óptima'}, ...
    'Location', 'northeast', 'FontSize', 9);
set(leg, 'Box', 'on', 'EdgeColor', [0.5 0.5 0.5]);

box on;
xlim([min(dist_8) max(dist_8)]);

saveas(gcf, 'figura_comparativa_8GHz.fig');
saveas(gcf, 'figura_comparativa_8GHz.png');
print(gcf, 'figura_comparativa_8GHz', '-depsc2');

fprintf('\nFiguras guardadas.\n');

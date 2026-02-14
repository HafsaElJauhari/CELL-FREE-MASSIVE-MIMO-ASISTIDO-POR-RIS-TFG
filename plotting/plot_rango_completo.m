% Plot con rango completo 0-120 para ver los 3 picos
% Carga resultados de 2 usuarios

load('resultados_selection_vs_no_selection.mat');

dist = 0:10:120;
freq_names = {'3.5 GHz', '8 GHz', '15 GHz'};
N_values = [64, 256, 900];

for freq_idx = 1:3
    figure('Position', [100 100 700 500]);
    
    plot(dist, R_sum_sel_mean(:, freq_idx), '-o', 'Color', [0 0.4470 0.7410], ...
        'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', 'Con selección RIS');
    hold on;
    plot(dist, R_sum_nosel_mean(:, freq_idx), '--s', 'Color', [0.8500 0.3250 0.0980], ...
        'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', 'Sin selección RIS');
    plot(dist, R_sum_noRIS_mean(:, freq_idx), ':^', 'Color', [0.4660 0.6740 0.1880], ...
        'LineWidth', 1.5, 'MarkerSize', 6, 'DisplayName', 'Sin RIS');
    hold off;
    
    xlabel('Distancia del usuario 1, $d$ (m)', 'Interpreter', 'latex', 'FontSize', 11);
    ylabel('Tasa suma (bit/s/Hz)', 'Interpreter', 'latex', 'FontSize', 11);
    legend('Location', 'best', 'Interpreter', 'latex', 'FontSize', 9);
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 10);
    grid on;
    box on;
    xlim([0 120]);  % RANGO COMPLETO
    
    % Marcar posiciones de las RIS (sin aparecer en leyenda)
    hold on;
    xline(60, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'HandleVisibility', 'off');
    xline(100, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 1, 'HandleVisibility', 'off');
    hold off;
    
    % Guardar
    filename = sprintf('figura_%s_2usuarios_completo', strrep(freq_names{freq_idx}, ' ', ''));
    filename = strrep(filename, '.', 'p');
    savefig([filename '.fig']);
    saveas(gcf, [filename '.png']);
    saveas(gcf, [filename '.jpg']);
    
    fprintf('Guardada: %s\n', filename);
end

fprintf('\n¡Gráficas con rango completo generadas!\n');


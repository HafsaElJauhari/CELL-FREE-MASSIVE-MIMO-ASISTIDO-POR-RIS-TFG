%% plot_selection_results.m
% Recrea las gráficas de comparación (selección vs. sin selección vs. sin RIS)
% a partir de los resultados guardados en un archivo .mat.

% Ajusta el nombre del fichero si lo guardaste con otro distinto.
resultadosFile = 'resultados_selection.mat';
if ~isfile(resultadosFile)
    error('No se encuentra el fichero %s. Comprueba el nombre o la ruta.', resultadosFile);
end

load(resultadosFile, ...
    'dist', 'frequencies', ...
    'R_sum_sel_mean', 'R_sum_nosel_mean', 'R_sum_noRIS_mean');

fprintf('Resultados cargados desde %s\n', resultadosFile);

%% Parámetros de la figura (idénticos al bloque del main original)
figure('Position', [100, 100, 1400, 500]);
tiledlayout(1, length(frequencies), 'TileSpacing', 'compact', 'Padding', 'compact');

color_sel   = [0.0000 0.4470 0.7410];
color_nosel = [0.8500 0.3250 0.0980];
color_noRIS = [0.3000 0.3000 0.3000];

for freq_idx = 1:length(frequencies)
    nexttile(freq_idx);
    hold on; box on; grid on;

    plot(dist, real(R_sum_sel_mean(:,freq_idx)),     '-o', 'LineWidth', 1.5, 'Color', color_sel,   'MarkerFaceColor', color_sel);
    plot(dist, real(R_sum_nosel_mean(:,freq_idx)),   '--^', 'LineWidth', 1.5, 'Color', color_nosel,'MarkerFaceColor', color_nosel);
    plot(dist, real(R_sum_noRIS_mean(:,freq_idx)),   ':s', 'LineWidth', 1.5, 'Color', color_noRIS,'MarkerFaceColor', color_noRIS);

    legend('Con selección', 'Sin selección', 'Sin RIS', 'Location', 'best');
    xlabel('Posición (m)','Interpreter','latex');
    ylabel('Weighted sum-rate (bit/s/Hz)','Interpreter','latex');
    title(sprintf('Frecuencia: %.2f GHz', frequencies(freq_idx)/1e9));
    set(gca,'FontName','Times','FontSize',10);
end

sgtitle('Comparativa de tasas ponderadas con y sin selección RIS', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('Figura generada correctamente.\n');


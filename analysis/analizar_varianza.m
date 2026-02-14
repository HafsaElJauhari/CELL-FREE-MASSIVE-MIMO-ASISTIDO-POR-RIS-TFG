% Análisis de varianza en los puntos RIS
clear;
load('resultados_selection_vs_no_selection_1user.mat');

fprintf('=== ANÁLISIS DE VARIANZA (1 Usuario) ===\n\n');

idx_60 = find(dist == 60);
idx_100 = find(dist == 100);

for f = 1:length(frequencies)
    fprintf('Frecuencia: %.1f GHz (N=%d)\n', frequencies(f)/1e9, N_ris_values(f));
    
    % Datos de las 10 iteraciones para d=60 y d=100
    data_60 = R_sum_sel_all(idx_60, :, f);
    data_100 = R_sum_sel_all(idx_100, :, f);
    
    fprintf('  d=60:  media=%.4f, std=%.4f, min=%.4f, max=%.4f\n', ...
        mean(data_60), std(data_60), min(data_60), max(data_60));
    fprintf('  d=100: media=%.4f, std=%.4f, min=%.4f, max=%.4f\n', ...
        mean(data_100), std(data_100), min(data_100), max(data_100));
    
    % Test estadístico informal
    overlap = (mean(data_60) - std(data_60)) < (mean(data_100) + std(data_100)) && ...
              (mean(data_100) - std(data_100)) < (mean(data_60) + std(data_60));
    if overlap
        fprintf('  -> Las distribuciones SE SOLAPAN (diferencia puede ser ruido)\n');
    else
        fprintf('  -> Las distribuciones NO se solapan (diferencia significativa)\n');
    end
    fprintf('\n');
end

fprintf('=== DATOS CRUDOS DE LAS 10 ITERACIONES (15 GHz) ===\n');
f = 3;  % 15 GHz
fprintf('Iteración |   d=60   |   d=100  |\n');
fprintf('----------|----------|----------|\n');
for i = 1:Iteration
    fprintf('    %2d    | %8.4f | %8.4f |\n', i, R_sum_sel_all(idx_60, i, f), R_sum_sel_all(idx_100, i, f));
end

exit;


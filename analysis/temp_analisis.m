% Script temporal para analizar resultados
load('resultados_selection_vs_no_selection_1user.mat');
fprintf('\n=== RESULTADOS 1 USUARIO ===\n');
fprintf('Distancias: %s\n', mat2str(dist));
fprintf('Frecuencias: %s GHz\n', mat2str(frequencies/1e9));
fprintf('N_ris: %s\n', mat2str(N_ris_values));
fprintf('\n--- Rango 40-120m ---\n');
idx = dist >= 40 & dist <= 120;
for f=1:3
    fprintf('\nFrecuencia %.1f GHz (N=%d):\n', frequencies(f)/1e9, N_ris_values(f));
    fprintf('  Con seleccion:   media=%.2f, min=%.2f, max=%.2f\n', mean(R_sum_sel_mean(idx,f)), min(R_sum_sel_mean(idx,f)), max(R_sum_sel_mean(idx,f)));
    fprintf('  Sin seleccion:   media=%.2f, min=%.2f, max=%.2f\n', mean(R_sum_nosel_mean(idx,f)), min(R_sum_nosel_mean(idx,f)), max(R_sum_nosel_mean(idx,f)));
    fprintf('  Sin RIS:         media=%.2f, min=%.2f, max=%.2f\n', mean(R_sum_noRIS_mean(idx,f)), min(R_sum_noRIS_mean(idx,f)), max(R_sum_noRIS_mean(idx,f)));
    ganancia_sel = (mean(R_sum_sel_mean(idx,f)) - mean(R_sum_noRIS_mean(idx,f))) / mean(R_sum_noRIS_mean(idx,f)) * 100;
    ganancia_nosel = (mean(R_sum_nosel_mean(idx,f)) - mean(R_sum_noRIS_mean(idx,f))) / mean(R_sum_noRIS_mean(idx,f)) * 100;
    mejora_sel = (mean(R_sum_sel_mean(idx,f)) - mean(R_sum_nosel_mean(idx,f))) / mean(R_sum_nosel_mean(idx,f)) * 100;
    fprintf('  Ganancia RIS con seleccion vs sin RIS: %.1f%%\n', ganancia_sel);
    fprintf('  Ganancia RIS sin seleccion vs sin RIS: %.1f%%\n', ganancia_nosel);
    fprintf('  Mejora seleccion vs sin seleccion: %.1f%%\n', mejora_sel);
end

fprintf('\n\n--- Datos detallados por distancia (40-120m) ---\n');
fprintf('dist(m) | 3.5GHz_sel | 3.5GHz_nosel | 8GHz_sel | 8GHz_nosel | 15GHz_sel | 15GHz_nosel\n');
fprintf('--------|------------|--------------|----------|------------|-----------|------------\n');
dist_range = dist(idx);
for i = 1:length(dist_range)
    d_idx = find(dist == dist_range(i));
    fprintf('%7d | %10.2f | %12.2f | %8.2f | %10.2f | %9.2f | %11.2f\n', ...
        dist_range(i), R_sum_sel_mean(d_idx,1), R_sum_nosel_mean(d_idx,1), ...
        R_sum_sel_mean(d_idx,2), R_sum_nosel_mean(d_idx,2), ...
        R_sum_sel_mean(d_idx,3), R_sum_nosel_mean(d_idx,3));
end
exit;


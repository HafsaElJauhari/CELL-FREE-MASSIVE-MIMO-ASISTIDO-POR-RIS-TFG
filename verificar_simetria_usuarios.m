% Verificar simetría: d=20 vs d=100 deberían dar igual suma
clear;
load('resultados_selection_vs_no_selection.mat');

fprintf('=== VERIFICACIÓN DE SIMETRÍA ===\n');
fprintf('d=20:  U1 en x=20,  U2 en x=100\n');
fprintf('d=100: U1 en x=100, U2 en x=20\n');
fprintf('La suma debería ser IGUAL (posiciones intercambiadas)\n\n');

idx_20 = find(dist == 20);
idx_100 = find(dist == 100);

fprintf('--- CON SELECCIÓN ---\n');
fprintf('Freq     | R_sum(d=20) | R_sum(d=100) | Diferencia | ¿Simétrico?\n');
fprintf('---------|-------------|--------------|------------|------------\n');
for f = 1:length(frequencies)
    r20 = R_sum_sel_mean(idx_20, f);
    r100 = R_sum_sel_mean(idx_100, f);
    diff = abs(r20 - r100);
    sym = diff < 0.05 * max(r20, r100);  % Tolerancia 5%
    fprintf('%6.1f GHz |   %8.4f  |    %8.4f  |   %7.4f  | %s\n', ...
        frequencies(f)/1e9, r20, r100, diff, string(sym));
end

fprintf('\n--- SIN SELECCIÓN ---\n');
fprintf('Freq     | R_sum(d=20) | R_sum(d=100) | Diferencia | ¿Simétrico?\n');
fprintf('---------|-------------|--------------|------------|------------\n');
for f = 1:length(frequencies)
    r20 = R_sum_nosel_mean(idx_20, f);
    r100 = R_sum_nosel_mean(idx_100, f);
    diff = abs(r20 - r100);
    sym = diff < 0.05 * max(r20, r100);
    fprintf('%6.1f GHz |   %8.4f  |    %8.4f  |   %7.4f  | %s\n', ...
        frequencies(f)/1e9, r20, r100, diff, string(sym));
end

fprintf('\n--- TASAS INDIVIDUALES (Con selección, 15 GHz) ---\n');
f = 3;
fprintf('d=20:\n');
fprintf('  U1 (x=20):  %.4f\n', mean(R_k_sel_all(idx_20, :, f, 1)));
fprintf('  U2 (x=100): %.4f\n', mean(R_k_sel_all(idx_20, :, f, 2)));
fprintf('d=100:\n');
fprintf('  U1 (x=100): %.4f\n', mean(R_k_sel_all(idx_100, :, f, 1)));
fprintf('  U2 (x=20):  %.4f\n', mean(R_k_sel_all(idx_100, :, f, 2)));

fprintf('\n¿U1(x=20) ≈ U2(x=20)? ');
u1_20 = mean(R_k_sel_all(idx_100, :, f, 2));  % U2 cuando d=100 está en x=20
u2_20 = mean(R_k_sel_all(idx_20, :, f, 1));   % U1 cuando d=20 está en x=20
fprintf('%.4f vs %.4f (diff=%.4f)\n', u1_20, u2_20, abs(u1_20-u2_20));

fprintf('¿U1(x=100) ≈ U2(x=100)? ');
u1_100 = mean(R_k_sel_all(idx_100, :, f, 1)); % U1 cuando d=100 está en x=100
u2_100 = mean(R_k_sel_all(idx_20, :, f, 2));  % U2 cuando d=20 está en x=100
fprintf('%.4f vs %.4f (diff=%.4f)\n', u1_100, u2_100, abs(u1_100-u2_100));

fprintf('\n--- ANÁLISIS DE VARIANZA ---\n');
fprintf('Iteraciones individuales (15 GHz, Con selección):\n');
fprintf('Iter | R_sum(d=20) | R_sum(d=100) |\n');
for i = 1:Iteration
    fprintf(' %2d  |   %8.4f  |    %8.4f  |\n', i, R_sum_sel_all(idx_20, i, f), R_sum_sel_all(idx_100, i, f));
end

exit;


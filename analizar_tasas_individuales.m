% Análisis de tasas individuales por usuario
clear;
load('resultados_selection_vs_no_selection.mat');

fprintf('=== TASAS INDIVIDUALES POR USUARIO (2 Usuarios) ===\n');
fprintf('Usuario 1 en x=d, Usuario 2 en x=(120-d)\n\n');

idx_60 = find(dist == 60);
idx_100 = find(dist == 100);

fprintf('Posiciones:\n');
fprintf('  d=60:  U1 en x=60,  U2 en x=60  (ambos juntos)\n');
fprintf('  d=100: U1 en x=100, U2 en x=20  (U2 lejos de RIS)\n\n');

for f = 1:length(frequencies)
    fprintf('--- Frecuencia: %.1f GHz ---\n', frequencies(f)/1e9);
    
    % Tasas individuales promedio
    R_k1_60 = mean(R_k_sel_all(idx_60, :, f, 1));
    R_k2_60 = mean(R_k_sel_all(idx_60, :, f, 2));
    R_k1_100 = mean(R_k_sel_all(idx_100, :, f, 1));
    R_k2_100 = mean(R_k_sel_all(idx_100, :, f, 2));
    
    fprintf('d=60:\n');
    fprintf('  U1 (x=60):  %.4f bit/s/Hz\n', R_k1_60);
    fprintf('  U2 (x=60):  %.4f bit/s/Hz\n', R_k2_60);
    fprintf('  SUMA:       %.4f bit/s/Hz\n', R_k1_60 + R_k2_60);
    
    fprintf('d=100:\n');
    fprintf('  U1 (x=100): %.4f bit/s/Hz\n', R_k1_100);
    fprintf('  U2 (x=20):  %.4f bit/s/Hz\n', R_k2_100);
    fprintf('  SUMA:       %.4f bit/s/Hz\n', R_k1_100 + R_k2_100);
    
    fprintf('Diferencia U2: %.4f (U2 en d=100 está en x=20, lejos de RIS)\n\n', R_k2_100 - R_k2_60);
end

fprintf('=== CONCLUSIÓN ===\n');
fprintf('Cuando d=100:\n');
fprintf('  - U1 está en x=100 (cerca de RIS2) -> buena tasa\n');
fprintf('  - U2 está en x=20 (LEJOS de ambos RIS) -> mala tasa\n');
fprintf('  - La tasa suma baja porque U2 contribuye poco\n');
fprintf('\nCuando d=60:\n');
fprintf('  - Ambos usuarios en x=60 (cerca de RIS1) -> buenas tasas\n');
fprintf('  - La tasa suma es mayor\n');

exit;


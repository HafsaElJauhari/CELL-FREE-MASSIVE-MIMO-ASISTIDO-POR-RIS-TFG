% Análisis de varianza para 2 usuarios
clear;
load('resultados_selection_vs_no_selection.mat');

fprintf('=== ANÁLISIS DE VARIANZA (2 Usuarios) ===\n');
fprintf('Usuario 1 en d, Usuario 2 en (120-d)\n\n');

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
    fprintf('  Coef. variación d=60: %.1f%%\n', 100*std(data_60)/mean(data_60));
    fprintf('  Coef. variación d=100: %.1f%%\n', 100*std(data_100)/mean(data_100));
    fprintf('\n');
end

fprintf('=== DATOS CRUDOS (15 GHz, Con selección) ===\n');
f = 3;
fprintf('Iteración |   d=60   |   d=100  |\n');
fprintf('----------|----------|----------|\n');
for i = 1:Iteration
    fprintf('    %2d    | %8.4f | %8.4f |\n', i, R_sum_sel_all(idx_60, i, f), R_sum_sel_all(idx_100, i, f));
end

fprintf('\n=== COMPARACIÓN 1 vs 2 USUARIOS ===\n');
load('resultados_selection_vs_no_selection_1user.mat');
data_1u_60 = R_sum_sel_all(idx_60, :, 3);
data_1u_100 = R_sum_sel_all(idx_100, :, 3);

load('resultados_selection_vs_no_selection.mat');
data_2u_60 = R_sum_sel_all(idx_60, :, 3);
data_2u_100 = R_sum_sel_all(idx_100, :, 3);

fprintf('\n15 GHz - Coeficiente de variación (std/media):\n');
fprintf('1 Usuario: d=60: %.1f%%, d=100: %.1f%%\n', ...
    100*std(data_1u_60)/mean(data_1u_60), 100*std(data_1u_100)/mean(data_1u_100));
fprintf('2 Usuarios: d=60: %.1f%%, d=100: %.1f%%\n', ...
    100*std(data_2u_60)/mean(data_2u_60), 100*std(data_2u_100)/mean(data_2u_100));

fprintf('\n=== ANÁLISIS DE POSICIONES (2 Usuarios) ===\n');
fprintf('Cuando d=60:\n');
fprintf('  Usuario 1 en x=60 (cerca de RIS1)\n');
fprintf('  Usuario 2 en x=60 (cerca de RIS1) -> AMBOS JUNTOS\n');
fprintf('Cuando d=100:\n');
fprintf('  Usuario 1 en x=100 (cerca de RIS2)\n');
fprintf('  Usuario 2 en x=20 (lejos de ambos RIS!)\n');
fprintf('\n¡IMPORTANTE! El escenario NO es simétrico para 2 usuarios:\n');
fprintf('  d=60: ambos usuarios en el centro, cerca de ambos RIS\n');
fprintf('  d=100: U1 cerca de RIS2, U2 LEJOS de ambos RIS (x=20)\n');

exit;


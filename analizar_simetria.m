% Análisis de simetría en los puntos de las RIS
clear;

fprintf('=== ANÁLISIS DE SIMETRÍA EN POSICIONES RIS ===\n');
fprintf('RIS 1 en x=60, RIS 2 en x=100\n\n');

%% Cargar resultados 1 usuario
load('resultados_selection_vs_no_selection_1user.mat');

fprintf('========== 1 USUARIO ==========\n');
fprintf('Posiciones RIS: x=60 y x=100\n\n');

% Índices para d=60 y d=100
idx_60 = find(dist == 60);
idx_100 = find(dist == 100);

fprintf('Frecuencia | d=60 (RIS1) | d=100 (RIS2) | Diferencia | Ratio\n');
fprintf('-----------|-------------|--------------|------------|-------\n');

for f = 1:length(frequencies)
    val_60_sel = R_sum_sel_mean(idx_60, f);
    val_100_sel = R_sum_sel_mean(idx_100, f);
    diff = val_100_sel - val_60_sel;
    ratio = val_100_sel / val_60_sel;
    fprintf('%6.1f GHz |   %8.4f  |    %8.4f  |   %7.4f  | %.3f\n', ...
        frequencies(f)/1e9, val_60_sel, val_100_sel, diff, ratio);
end

fprintf('\n--- Sin selección (para comparar) ---\n');
fprintf('Frecuencia | d=60 (RIS1) | d=100 (RIS2) | Diferencia | Ratio\n');
fprintf('-----------|-------------|--------------|------------|-------\n');

for f = 1:length(frequencies)
    val_60_nosel = R_sum_nosel_mean(idx_60, f);
    val_100_nosel = R_sum_nosel_mean(idx_100, f);
    diff = val_100_nosel - val_60_nosel;
    ratio = val_100_nosel / val_60_nosel;
    fprintf('%6.1f GHz |   %8.4f  |    %8.4f  |   %7.4f  | %.3f\n', ...
        frequencies(f)/1e9, val_60_nosel, val_100_nosel, diff, ratio);
end

%% Analizar posiciones de BS
fprintf('\n--- Análisis de geometría ---\n');
fprintf('Posiciones BS: [60,70,80,90,100] en y=-200\n');
fprintf('RIS 1: (60, -1)\n');
fprintf('RIS 2: (100, -1)\n');
fprintf('\nDistancias BS a RIS:\n');

BS_x = [60, 70, 80, 90, 100];
RIS_x = [60, 100];

for r = 1:2
    fprintf('  RIS %d (x=%d):\n', r, RIS_x(r));
    for b = 1:5
        d_horizontal = abs(BS_x(b) - RIS_x(r));
        d_vertical = 199;  % -200 a -1
        d_total = sqrt(d_horizontal^2 + d_vertical^2);
        fprintf('    BS%d (x=%d): %.1f m\n', b, BS_x(b), d_total);
    end
end

fprintf('\n¡IMPORTANTE! RIS 1 está alineada con BS1 (x=60)\n');
fprintf('             RIS 2 está alineada con BS5 (x=100)\n');
fprintf('Pero hay 5 BS, así que la geometría NO es perfectamente simétrica.\n');

%% Cargar resultados 2 usuarios
fprintf('\n\n========== 2 USUARIOS ==========\n');
load('resultados_selection_vs_no_selection.mat');

fprintf('Usuario 1 en d, Usuario 2 en (120-d)\n');
fprintf('Cuando d=60: U1 en 60, U2 en 60 (ambos juntos)\n\n');

fprintf('--- Con selección ---\n');
fprintf('Frecuencia | d=60       | d=100      | Diferencia\n');
fprintf('-----------|------------|------------|------------\n');

for f = 1:length(frequencies)
    val_60 = R_sum_sel_mean(idx_60, f);
    val_100 = R_sum_sel_mean(idx_100, f);
    diff = val_100 - val_60;
    fprintf('%6.1f GHz |   %8.4f |   %8.4f |   %8.4f\n', ...
        frequencies(f)/1e9, val_60, val_100, diff);
end

fprintf('\n--- Sin selección ---\n');
fprintf('Frecuencia | d=60       | d=100      | Diferencia\n');
fprintf('-----------|------------|------------|------------\n');

for f = 1:length(frequencies)
    val_60 = R_sum_nosel_mean(idx_60, f);
    val_100 = R_sum_nosel_mean(idx_100, f);
    diff = val_100 - val_60;
    fprintf('%6.1f GHz |   %8.4f |   %8.4f |   %8.4f\n', ...
        frequencies(f)/1e9, val_60, val_100, diff);
end

fprintf('\n=== CONCLUSIONES ===\n');
fprintf('La asimetría se debe a:\n');
fprintf('1. BS no simétricas respecto a las RIS (5 BS en x=[60,70,80,90,100])\n');
fprintf('2. El canal BS-RIS es diferente para cada RIS\n');
fprintf('3. A frecuencias altas (15 GHz), pequeñas diferencias de distancia\n');
fprintf('   causan grandes diferencias de pathloss\n');

exit;


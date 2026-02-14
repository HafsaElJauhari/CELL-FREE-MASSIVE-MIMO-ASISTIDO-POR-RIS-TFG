function dibujar(BS_position, RIS_position, UE_position)
%DIBUJAR Representación en 2D de estaciones base, RIS y usuarios.
%   DIBUJAR(BS_position, RIS_position, UE_position) crea una figura con la
%   disposición de los elementos recibidos. Cada fila de las matrices de
%   entrada debe contener las coordenadas [x, y] de la entidad
%   correspondiente.
%
%   Ejemplo de llamada:
%       BS_position = [  0,  0;
%                       10,  0;
%                      -10,  0;
%                        0, 10;
%                        0,-10];
%       RIS_position = [ 0.05, 0;
%                       10.05, 0];
%       UE_position  = [100, 0];  % Puede ser varias filas para varios UEs
%       dibujar(BS_position, RIS_position, UE_position);

arguments
    BS_position (:,2) double
    RIS_position (:,2) double
    UE_position  (:,2) double
end

figure('Name', 'Disposición BS / RIS / UE');
ax = axes('Parent', gcf);
hold(ax, 'on'); grid(ax, 'on'); box(ax, 'on');

% Compresión vertical para reducir visualmente la distancia BS-RIS.
y_break = min(RIS_position(:,2)) - 15; % umbral sobre RIS
compression_factor = 0.2;
transform_y = @(y) aplicar_compresion(y, y_break, compression_factor);

% Estaciones base
plot(ax, BS_position(:,1), transform_y(BS_position(:,2)), 's', ...
    'MarkerSize', 10, 'MarkerEdgeColor', [0 0.2 0.8], ...
    'MarkerFaceColor', [0.3 0.5 1.0], 'DisplayName', 'BS');
for idx = 1:size(BS_position,1)
    text(ax, BS_position(idx,1), transform_y(BS_position(idx,2))+0.8, ...
        sprintf('BS%d', idx), ...
        'HorizontalAlignment', 'center', 'Color', [0 0.2 0.8]);
end

% RIS
plot(ax, RIS_position(:,1), transform_y(RIS_position(:,2)), '^', ...
    'MarkerSize', 9, 'MarkerEdgeColor', [0.8 0.2 0], ...
    'MarkerFaceColor', [1.0 0.5 0.3], 'DisplayName', 'RIS');
for idx = 1:size(RIS_position,1)
    text(ax, RIS_position(idx,1), transform_y(RIS_position(idx,2))-0.8, ...
        sprintf('RIS%d', idx), ...
        'HorizontalAlignment', 'center', 'Color', [0.8 0.2 0]);
end

% Usuarios
plot(ax, UE_position(:,1), transform_y(UE_position(:,2)), 'o', ...
    'MarkerSize', 8, 'MarkerEdgeColor', [0 0.5 0], ...
    'MarkerFaceColor', [0.3 0.9 0.3], 'DisplayName', 'UE');
for idx = 1:size(UE_position,1)
    text(ax, UE_position(idx,1), transform_y(UE_position(idx,2))+0.8, ...
        sprintf('UE%d', idx), ...
        'HorizontalAlignment', 'center', 'Color', [0 0.5 0]);
end

legend(ax, 'Location', 'eastoutside');
xlabel(ax, 'X (m)');
ylabel(ax, 'Y (m)');
title(ax, 'Posiciones de Estaciones Base, RIS y Usuarios (eje Y comprimido)');

all_points = [BS_position; RIS_position; UE_position];
min_x = min(all_points(:,1));
max_x = max(all_points(:,1));
range_x = max(max_x - min_x, eps);
padding_x = max(5, 0.05 * range_x);
xlim(ax, [min_x - padding_x, max_x + padding_x]);

y_visual = transform_y(all_points(:,2));
min_y_vis = min(y_visual);
max_y_vis = max(y_visual);
range_y_vis = max(max_y_vis - min_y_vis, eps);
padding_y = max(2, 0.05 * range_y_vis);
ylim(ax, [min_y_vis - padding_y, max_y_vis + padding_y]);

y_ticks_reales = calcular_ticks_y(min(all_points(:,2)), max(all_points(:,2)), y_break);
set(ax, 'YTick', transform_y(y_ticks_reales), ...
    'YTickLabel', arrayfun(@(v) sprintf('%.0f', v), y_ticks_reales, 'UniformOutput', false));

line(ax, xlim(ax), transform_y([y_break, y_break]), ...
    'LineStyle', '--', 'Color', [0.5 0.5 0.5], 'HandleVisibility', 'off');

hold(ax, 'off');

    function y_out = aplicar_compresion(y_in, punto_corte, factor)
        y_out = y_in;
        mascara = y_in < punto_corte;
        y_out(mascara) = punto_corte + (y_in(mascara) - punto_corte) * factor;
    end

    function ticks = calcular_ticks_y(min_real, max_real, punto_corte)
        parte_baja = linspace(min_real, punto_corte, 3);
        parte_alta = linspace(punto_corte, max_real, 4);
        ticks = unique(round([parte_baja, parte_alta]));
    end

end


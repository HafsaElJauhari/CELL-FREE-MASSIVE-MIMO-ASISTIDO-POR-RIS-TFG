% Script para calibrar la potencia según las diferencias de path loss
% entre el modelo ORIGINAL y el modelo 3GPP UMi

clear; clc;

fprintf('=================================================================\n');
fprintf('CALIBRACIÓN DE POTENCIA: ORIGINAL vs 3GPP UMi\n');
fprintf('=================================================================\n\n');

% Según los resultados de compare_channel_models.m:
diff_H_dB = -5.42;   % Canal H más débil
diff_F_dB = -8.75;   % Canal F más débil
diff_G_dB = -14.41;  % Canal G más débil (CRÍTICO)

fprintf('Diferencias de path loss detectadas:\n');
fprintf('  Canal H (BS→Usuario): %.2f dB\n', diff_H_dB);
fprintf('  Canal F (RIS→Usuario): %.2f dB\n', diff_F_dB);
fprintf('  Canal G (BS→RIS):     %.2f dB\n\n', diff_G_dB);

% Potencia original
P_max_original = 0.001;  % 0 dBm = 1 mW

fprintf('Potencia máxima original: %.4f W = %.2f dBm\n', ...
    P_max_original, 10*log10(P_max_original*1000));

% ======== OPCIÓN 1: Compensar la diferencia promedio ========
diff_avg_dB = mean([abs(diff_H_dB), abs(diff_F_dB), abs(diff_G_dB)]);
P_max_option1 = P_max_original * 10^(diff_avg_dB/10);

fprintf('\n--- OPCIÓN 1: Compensar diferencia promedio ---\n');
fprintf('Diferencia promedio: %.2f dB\n', diff_avg_dB);
fprintf('Potencia sugerida: %.4f W = %.2f dBm\n', ...
    P_max_option1, 10*log10(P_max_option1*1000));
fprintf('Factor de aumento: %.2fx\n', P_max_option1/P_max_original);

% ======== OPCIÓN 2: Compensar el canal más débil (G) ========
P_max_option2 = P_max_original * 10^(abs(diff_G_dB)/10);

fprintf('\n--- OPCIÓN 2: Compensar canal G (el más débil) ---\n');
fprintf('Diferencia canal G: %.2f dB\n', diff_G_dB);
fprintf('Potencia sugerida: %.4f W = %.2f dBm\n', ...
    P_max_option2, 10*log10(P_max_option2*1000));
fprintf('Factor de aumento: %.2fx\n', P_max_option2/P_max_original);

% ======== OPCIÓN 3: Compensar solo el canal H (directo) ========
P_max_option3 = P_max_original * 10^(abs(diff_H_dB)/10);

fprintf('\n--- OPCIÓN 3: Compensar solo canal H (directo) ---\n');
fprintf('Diferencia canal H: %.2f dB\n', diff_H_dB);
fprintf('Potencia sugerida: %.4f W = %.2f dBm\n', ...
    P_max_option3, 10*log10(P_max_option3*1000));
fprintf('Factor de aumento: %.2fx\n', P_max_option3/P_max_original);

% ======== RECOMENDACIÓN ========
fprintf('\n=================================================================\n');
fprintf('RECOMENDACIÓN:\n');
fprintf('=================================================================\n');
fprintf('Para mantener el comportamiento similar al modelo original:\n\n');
fprintf('En main.m, línea 19, cambiar:\n');
fprintf('  ACTUAL:  P_max = 0.001;   %% 0 dBm\n');
fprintf('  OPCIÓN 1: P_max = %.4f;  %% %.2f dBm (compensación promedio)\n', ...
    P_max_option1, 10*log10(P_max_option1*1000));
fprintf('  OPCIÓN 2: P_max = %.4f;  %% %.2f dBm (compensación total)\n', ...
    P_max_option2, 10*log10(P_max_option2*1000));
fprintf('  OPCIÓN 3: P_max = %.4f;  %% %.2f dBm (compensación moderada)\n\n', ...
    P_max_option3, 10*log10(P_max_option3*1000));

fprintf('Nota: La OPCIÓN 1 es un buen compromiso entre realismo y\n');
fprintf('      comportamiento similar al modelo original.\n');
fprintf('=================================================================\n\n');

% ======== VERIFICACIÓN CON VALORES TÍPICOS ========
fprintf('VERIFICACIÓN: Potencias típicas en sistemas reales\n');
fprintf('=================================================================\n');
fprintf('Small cell (femtocell):  10-100 mW   (10-20 dBm)\n');
fprintf('Picocell:               100-250 mW   (20-24 dBm)\n');
fprintf('Microcell:              250 mW-5 W   (24-37 dBm)\n');
fprintf('Macrocell:              5-100 W      (37-50 dBm)\n\n');

if P_max_option1 >= 0.010 && P_max_option1 <= 0.100
    fprintf('✓ OPCIÓN 1 (%.4f W) está en rango típico de small cell\n', P_max_option1);
elseif P_max_option1 > 0.100 && P_max_option1 <= 0.250
    fprintf('✓ OPCIÓN 1 (%.4f W) está en rango típico de picocell\n', P_max_option1);
else
    fprintf('⚠ OPCIÓN 1 (%.4f W) fuera de rangos típicos\n', P_max_option1);
end

if P_max_option2 >= 0.010 && P_max_option2 <= 0.100
    fprintf('✓ OPCIÓN 2 (%.4f W) está en rango típico de small cell\n', P_max_option2);
elseif P_max_option2 > 0.100 && P_max_option2 <= 0.250
    fprintf('✓ OPCIÓN 2 (%.4f W) está en rango típico de picocell\n', P_max_option2);
else
    fprintf('⚠ OPCIÓN 2 (%.4f W) fuera de rangos típicos\n', P_max_option2);
end
fprintf('=================================================================\n');


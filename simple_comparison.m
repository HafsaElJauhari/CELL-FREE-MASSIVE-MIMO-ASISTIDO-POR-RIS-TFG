% Comparación simple y directa: Modelo ORIGINAL vs 3GPP
% Muestra las VERDADERAS diferencias (corrigiendo la convención de signos)

clear; clc;

fprintf('=================================================================\n');
fprintf('COMPARACIÓN SIMPLE: Path Loss Original vs 3GPP\n');
fprintf('=================================================================\n\n');

fprintf('⚠️  IMPORTANTE: Convenciones de Path Loss\n');
fprintf('───────────────────────────────────────────────────────────────\n');
fprintf('Modelo ORIGINAL: PL_dB es NEGATIVO (representa ganancia < 1)\n');
fprintf('Modelo 3GPP:     PL_dB es POSITIVO (representa pérdida, luego\n');
fprintf('                 se convierte con: gain = 10^(-PL_dB/10))\n\n');

%% Parámetros
dist = 80;           % metros (distancia de referencia)
frequency = 3.5e9;   % 3.5 GHz

fprintf('Distancia: %d m\n', dist);
fprintf('Frecuencia: %.1f GHz\n\n', frequency/1e9);

fprintf('=================================================================\n\n');

%% CANAL H (BS → Usuario, NLOS)
fprintf('CANAL H (BS → Usuario, NLOS)\n');
fprintf('─────────────────────────────────────────────────────────────\n');

% Modelo ORIGINAL
PL_linear_orig_H = 10^(-3) * dist^(-3.5);
fprintf('Modelo ORIGINAL: L(d) = 10^-3 × d^-3.5\n');
fprintf('  L(%d) = %.4e (lineal)\n', dist, PL_linear_orig_H);
fprintf('  L(%d) = %.2f dB\n\n', dist, 10*log10(PL_linear_orig_H));

% Modelo 3GPP
PL_loss_dB_H = calculate_pathloss_3GPP_UMi(dist, frequency, 3, 1.5, 0);
PL_linear_3GPP_H = 10^(-PL_loss_dB_H/10);
fprintf('Modelo 3GPP:\n');
fprintf('  Path Loss = %.2f dB (pérdida)\n', PL_loss_dB_H);
fprintf('  L(%d) = 10^(-%.2f/10) = %.4e (ganancia lineal)\n', dist, PL_loss_dB_H, PL_linear_3GPP_H);
fprintf('  L(%d) = %.2f dB\n\n', dist, 10*log10(PL_linear_3GPP_H));

% Diferencia
ratio_H = PL_linear_3GPP_H / PL_linear_orig_H;
diff_dB_H = 10*log10(ratio_H);
fprintf('✓ Diferencia REAL:\n');
fprintf('  Ratio: %.4f (3GPP/Original)\n', ratio_H);
fprintf('  Diferencia: %.2f dB\n', diff_dB_H);
if diff_dB_H < 0
    fprintf('  → El modelo 3GPP es %.2f dB MÁS ATENUANTE\n\n', abs(diff_dB_H));
else
    fprintf('  → El modelo 3GPP es %.2f dB MENOS ATENUANTE\n\n', diff_dB_H);
end

fprintf('=================================================================\n\n');

%% CANAL F (RIS → Usuario, LOS)
fprintf('CANAL F (RIS → Usuario, LOS)\n');
fprintf('─────────────────────────────────────────────────────────────\n');

% Modelo ORIGINAL
PL_linear_orig_F = 2*10^(-3) * dist^(-2.8);
fprintf('Modelo ORIGINAL: L(d) = 2×10^-3 × d^-2.8\n');
fprintf('  L(%d) = %.4e (lineal)\n', dist, PL_linear_orig_F);
fprintf('  L(%d) = %.2f dB\n\n', dist, 10*log10(PL_linear_orig_F));

% Modelo 3GPP
PL_loss_dB_F = calculate_pathloss_3GPP_UMi(dist, frequency, 6, 1.5, 1);
PL_linear_3GPP_F = 10^(-PL_loss_dB_F/10);
fprintf('Modelo 3GPP:\n');
fprintf('  Path Loss = %.2f dB (pérdida)\n', PL_loss_dB_F);
fprintf('  L(%d) = 10^(-%.2f/10) = %.4e (ganancia lineal)\n', dist, PL_loss_dB_F, PL_linear_3GPP_F);
fprintf('  L(%d) = %.2f dB\n\n', dist, 10*log10(PL_linear_3GPP_F));

% Diferencia
ratio_F = PL_linear_3GPP_F / PL_linear_orig_F;
diff_dB_F = 10*log10(ratio_F);
fprintf('✓ Diferencia REAL:\n');
fprintf('  Ratio: %.4f (3GPP/Original)\n', ratio_F);
fprintf('  Diferencia: %.2f dB\n', diff_dB_F);
if diff_dB_F < 0
    fprintf('  → El modelo 3GPP es %.2f dB MÁS ATENUANTE\n\n', abs(diff_dB_F));
else
    fprintf('  → El modelo 3GPP es %.2f dB MENOS ATENUANTE\n\n', diff_dB_F);
end

fprintf('=================================================================\n\n');

%% CANAL G (BS → RIS, LOS)
fprintf('CANAL G (BS → RIS, LOS)\n');
fprintf('─────────────────────────────────────────────────────────────\n');

% Modelo ORIGINAL
PL_linear_orig_G = 2*10^(-3) * dist^(-2.2);
fprintf('Modelo ORIGINAL: L(d) = 2×10^-3 × d^-2.2\n');
fprintf('  L(%d) = %.4e (lineal)\n', dist, PL_linear_orig_G);
fprintf('  L(%d) = %.2f dB\n\n', dist, 10*log10(PL_linear_orig_G));

% Modelo 3GPP
PL_loss_dB_G = calculate_pathloss_3GPP_UMi(dist, frequency, 3, 6, 1);
PL_linear_3GPP_G = 10^(-PL_loss_dB_G/10);
fprintf('Modelo 3GPP:\n');
fprintf('  Path Loss = %.2f dB (pérdida)\n', PL_loss_dB_G);
fprintf('  L(%d) = 10^(-%.2f/10) = %.4e (ganancia lineal)\n', dist, PL_loss_dB_G, PL_linear_3GPP_G);
fprintf('  L(%d) = %.2f dB\n\n', dist, 10*log10(PL_linear_3GPP_G));

% Diferencia
ratio_G = PL_linear_3GPP_G / PL_linear_orig_G;
diff_dB_G = 10*log10(ratio_G);
fprintf('✓ Diferencia REAL:\n');
fprintf('  Ratio: %.4f (3GPP/Original)\n', ratio_G);
fprintf('  Diferencia: %.2f dB\n', diff_dB_G);
if diff_dB_G < 0
    fprintf('  → El modelo 3GPP es %.2f dB MÁS ATENUANTE\n\n', abs(diff_dB_G));
else
    fprintf('  → El modelo 3GPP es %.2f dB MENOS ATENUANTE\n\n', diff_dB_G);
end

fprintf('=================================================================\n\n');

%% RESUMEN
fprintf('RESUMEN DE DIFERENCIAS (d=%dm, f=%.1fGHz)\n', dist, frequency/1e9);
fprintf('=================================================================\n\n');

fprintf('┌────────┬──────────────┬─────────────────┐\n');
fprintf('│ Canal  │ Diferencia   │  Interpretación │\n');
fprintf('├────────┼──────────────┼─────────────────┤\n');
fprintf('│   H    │   %+6.2f dB │  %.0f%% señal     │\n', diff_dB_H, ratio_H*100);
fprintf('│   F    │   %+6.2f dB │  %.0f%% señal     │\n', diff_dB_F, ratio_F*100);
fprintf('│   G    │   %+6.2f dB │  %.0f%% señal     │\n', diff_dB_G, ratio_G*100);
fprintf('└────────┴──────────────┴─────────────────┘\n\n');

diff_promedio_dB = mean([abs(diff_dB_H), abs(diff_dB_F), abs(diff_dB_G)]);
fprintf('Diferencia promedio: %.2f dB\n\n', diff_promedio_dB);

%% RECOMENDACIONES
fprintf('=================================================================\n');
fprintf('RECOMENDACIONES PARA IGUALAR MODELOS\n');
fprintf('=================================================================\n\n');

fprintf('OPCIÓN 1: Ajustar P_max (Recomendado)\n');
fprintf('───────────────────────────────────────────────────────────────\n');
P_max_original = 0.001;  % 0 dBm
factor_potencia = 10^(diff_promedio_dB/10);
P_max_ajustado = P_max_original * factor_potencia;
fprintf('  P_max original: %.3f mW (%.1f dBm)\n', P_max_original*1000, 10*log10(P_max_original*1000));
fprintf('  P_max ajustado: %.3f mW (%.1f dBm)\n', P_max_ajustado*1000, 10*log10(P_max_ajustado*1000));
fprintf('  Factor: %.2fx\n\n', factor_potencia);
fprintf('  En main.m, línea 19:\n');
fprintf('  P_max = %.4f;  %% %.1f dBm\n\n', P_max_ajustado, 10*log10(P_max_ajustado*1000));

fprintf('OPCIÓN 2: Agregar factores de corrección a los canales\n');
fprintf('───────────────────────────────────────────────────────────────\n');
fprintf('  En channel_H.m, después de calcular PL_linear:\n');
fprintf('  PL_linear = PL_linear * %.4f;  %% Corrección %.2f dB\n\n', 10^(abs(diff_dB_H)/10), abs(diff_dB_H));

fprintf('  En channel_F.m, después de calcular PL_linear:\n');
fprintf('  PL_linear = PL_linear * %.4f;  %% Corrección %.2f dB\n\n', 10^(abs(diff_dB_F)/10), abs(diff_dB_F));

fprintf('  En channel_G.m, después de calcular PL_linear:\n');
fprintf('  PL_linear = PL_linear * %.4f;  %% Corrección %.2f dB\n\n', 10^(abs(diff_dB_G)/10), abs(diff_dB_G));

fprintf('=================================================================\n\n');

fprintf('✓ Esto coincide con los resultados de compare_channel_models.m\n');
fprintf('  donde viste diferencias de:\n');
fprintf('  - Canal H: ~%.0f dB\n', diff_dB_H);
fprintf('  - Canal F: ~%.0f dB\n', diff_dB_F);
fprintf('  - Canal G: ~%.0f dB\n\n', diff_dB_G);


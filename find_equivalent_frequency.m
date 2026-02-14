% Script para encontrar qué frecuencia en 3GPP da el mismo path loss que el modelo original
% O alternativamente, qué factor 'a' necesitas agregar para igualar los modelos

clear; clc;

fprintf('=================================================================\n');
fprintf('BÚSQUEDA: Parámetros 3GPP equivalentes al modelo ORIGINAL\n');
fprintf('=================================================================\n\n');

%% ==================== DISTANCIAS DE PRUEBA ====================
dist_test = [30, 50, 80, 100, 150];  % Varias distancias para probar
freq_test = 3.5e9;  % Frecuencia de referencia inicial

fprintf('Vamos a calcular para varias distancias:\n');
fprintf('  Distancias: ');
fprintf('%d ', dist_test);
fprintf('metros\n');
fprintf('  Frecuencia de referencia: %.1f GHz\n\n', freq_test/1e9);

%% ==================== ANÁLISIS POR CANAL ====================

for canal_idx = 1:3
    if canal_idx == 1
        canal_name = 'H (BS → Usuario, NLOS)';
        exp_original = -3.5;
        C0_original = 10^(-3);
        hTX = 3;    % BS
        hRX = 1.5;  % Usuario
        LOS = 0;    % NLOS
    elseif canal_idx == 2
        canal_name = 'F (RIS → Usuario, LOS)';
        exp_original = -2.8;
        C0_original = 2*10^(-3);
        hTX = 6;    % RIS
        hRX = 1.5;  % Usuario
        LOS = 1;    % LOS
    else
        canal_name = 'G (BS → RIS, LOS)';
        exp_original = -2.2;
        C0_original = 2*10^(-3);
        hTX = 3;    % BS
        hRX = 6;    % RIS
        LOS = 1;    % LOS
    end
    
    fprintf('=================================================================\n');
    fprintf('CANAL %s\n', canal_name);
    fprintf('=================================================================\n');
    fprintf('Modelo original: L(d) = %.1e × d^%.1f\n\n', C0_original, exp_original);
    
    %% --- TABLA DE RESULTADOS ---
    fprintf('┌──────────┬──────────────┬──────────────┬──────────────┬──────────────┐\n');
    fprintf('│ Dist (m) │  PL Original │  PL 3GPP     │  Diferencia  │  Freq equiv. │\n');
    fprintf('│          │     (dB)     │  @3.5GHz(dB) │     (dB)     │     (GHz)    │\n');
    fprintf('├──────────┼──────────────┼──────────────┼──────────────┼──────────────┤\n');
    
    freq_equivalente = zeros(size(dist_test));
    
    for i = 1:length(dist_test)
        d = dist_test(i);
        
        % Path loss modelo ORIGINAL (en lineal, representa GANANCIA < 1)
        PL_linear_orig = C0_original * d^(exp_original);
        PL_dB_orig = 10*log10(PL_linear_orig);  % Esto da valor NEGATIVO (e.g. -96 dB)
        
        % Path loss modelo 3GPP (en dB, representa PÉRDIDA > 0)
        PL_dB_3GPP_loss = calculate_pathloss_3GPP_UMi(d, freq_test, hTX, hRX, LOS);  % Valor POSITIVO (e.g. 101 dB)
        PL_linear_3GPP = 10^(-PL_dB_3GPP_loss/10);  % Convertir a ganancia lineal
        PL_dB_3GPP = 10*log10(PL_linear_3GPP);  % Convertir a dB (ahora negativo como el original)
        
        % Diferencia (ahora ambos están en la misma convención)
        diff_dB = PL_dB_3GPP - PL_dB_orig;
        
        % Buscar frecuencia equivalente que dé el mismo PL que el original
        % Usamos fminsearch para encontrar la frecuencia óptima
        % Comparamos en términos de ganancia lineal (más preciso)
        objetivo = @(f) (10^(-calculate_pathloss_3GPP_UMi(d, f, hTX, hRX, LOS)/10) - PL_linear_orig)^2;
        
        % Buscar entre 100 MHz y 100 GHz
        f_equiv = fminsearch(objetivo, freq_test);
        
        % Verificar que está en rango razonable
        if f_equiv < 100e6
            f_equiv = 100e6;
        elseif f_equiv > 100e9
            f_equiv = 100e9;
        end
        
        freq_equivalente(i) = f_equiv;
        
        fprintf('│   %3d    │   %8.2f   │   %8.2f   │   %+7.2f   │    %6.2f    │\n', ...
            d, PL_dB_orig, PL_dB_3GPP, diff_dB, f_equiv/1e9);
    end
    
    fprintf('└──────────┴──────────────┴──────────────┴──────────────┴──────────────┘\n\n');
    
    % Promedio de frecuencia equivalente
    freq_avg = mean(freq_equivalente);
    fprintf('Frecuencia equivalente promedio: %.2f GHz\n', freq_avg/1e9);
    fprintf('Desviación estándar: %.2f GHz\n\n', std(freq_equivalente)/1e9);
    
    %% --- VERIFICACIÓN: ¿Qué factor 'a' necesito multiplicar al modelo 3GPP? ---
    fprintf('ALTERNATIVA: Factor de corrección en path loss\n');
    fprintf('Si quieres ajustar el modelo 3GPP con un factor constante:\n\n');
    
    fprintf('┌──────────┬──────────────┬──────────────────────┐\n');
    fprintf('│ Dist (m) │ Factor a(dB) │ Factor a (lineal)    │\n');
    fprintf('├──────────┼──────────────┼──────────────────────┤\n');
    
    factor_a_dB = zeros(size(dist_test));
    
    for i = 1:length(dist_test)
        d = dist_test(i);
        
        % Path loss original (ganancia lineal)
        PL_linear_orig = C0_original * d^(exp_original);
        PL_dB_orig = 10*log10(PL_linear_orig);
        
        % Path loss 3GPP a 3.5 GHz (convertido a ganancia)
        PL_dB_3GPP_loss = calculate_pathloss_3GPP_UMi(d, freq_test, hTX, hRX, LOS);
        PL_linear_3GPP = 10^(-PL_dB_3GPP_loss/10);
        PL_dB_3GPP = 10*log10(PL_linear_3GPP);
        
        % Factor necesario (en dB)
        factor_a_dB(i) = PL_dB_orig - PL_dB_3GPP;
        factor_a_linear = 10^(factor_a_dB(i)/10);
        
        fprintf('│   %3d    │   %+7.2f   │      %.4f          │\n', ...
            d, factor_a_dB(i), factor_a_linear);
    end
    
    fprintf('└──────────┴──────────────┴──────────────────────┘\n\n');
    
    factor_a_promedio_dB = mean(factor_a_dB);
    factor_a_promedio_linear = 10^(factor_a_promedio_dB/10);
    
    fprintf('Factor "a" promedio: %.2f dB (lineal: %.4f)\n', factor_a_promedio_dB, factor_a_promedio_linear);
    fprintf('Para igualar modelos: PL_ajustado = PL_3GPP × %.4f (en lineal)\n', factor_a_promedio_linear);
    fprintf('                       PL_ajustado_dB = PL_3GPP_dB + %.2f dB\n\n', factor_a_promedio_dB);
    
    %% --- CÓDIGO SUGERIDO ---
    fprintf('─────────────────────────────────────────────────────────────────\n');
    fprintf('CÓDIGO SUGERIDO para channel_%s.m:\n', canal_name(1));
    fprintf('─────────────────────────────────────────────────────────────────\n\n');
    
    if abs(factor_a_promedio_dB) < 1
        fprintf('✓ OPCIÓN 1 (Recomendada): El modelo 3GPP ya es similar al original.\n');
        fprintf('  No necesitas cambios adicionales.\n\n');
    else
        fprintf('OPCIÓN 1: Usar frecuencia equivalente\n');
        fprintf('```matlab\n');
        fprintf('frequency_adjusted = %.2fe9;  %% %.2f GHz (en lugar de la frecuencia real)\n', freq_avg/1e9, freq_avg/1e9);
        fprintf('PL_dB = calculate_pathloss_3GPP_UMi(dis, frequency_adjusted, %.1f, %.1f, %d);\n', hTX, hRX, LOS);
        fprintf('```\n\n');
        
        fprintf('OPCIÓN 2: Agregar factor de corrección\n');
        fprintf('```matlab\n');
        fprintf('PL_dB = calculate_pathloss_3GPP_UMi(dis, frequency, %.1f, %.1f, %d);\n', hTX, hRX, LOS);
        fprintf('PL_dB = PL_dB + %.2f;  %% Factor de corrección para igualar modelo original\n', factor_a_promedio_dB);
        fprintf('PL_linear = 10^(-PL_dB/10);\n');
        fprintf('```\n\n');
        
        fprintf('OPCIÓN 3: Multiplicar por factor después de calcular\n');
        fprintf('```matlab\n');
        fprintf('PL_dB = calculate_pathloss_3GPP_UMi(dis, frequency, %.1f, %.1f, %d);\n', hTX, hRX, LOS);
        fprintf('PL_linear = 10^(-PL_dB/10);\n');
        fprintf('a_correction = %.4f;  %% Factor de corrección\n', factor_a_promedio_linear);
        fprintf('%s = sqrt(PL_linear * a_correction) * %s;\n', canal_name(1), canal_name(1));
        fprintf('```\n\n');
    end
end

%% ==================== RESUMEN GLOBAL ====================
fprintf('=================================================================\n');
fprintf('RESUMEN GLOBAL\n');
fprintf('=================================================================\n\n');

fprintf('HALLAZGOS PRINCIPALES:\n\n');

% Recalcular para un punto específico de referencia
d_ref = 80;
freq_ref = 3.5e9;

fprintf('Para distancia de referencia: %d m @ %.1f GHz\n\n', d_ref, freq_ref/1e9);

% Canal H
PL_orig_H = 10^(-3) * d_ref^(-3.5);
PL_dB_orig_H = 10*log10(PL_orig_H);
PL_dB_3GPP_H_loss = calculate_pathloss_3GPP_UMi(d_ref, freq_ref, 3, 1.5, 0);
PL_linear_3GPP_H = 10^(-PL_dB_3GPP_H_loss/10);
PL_dB_3GPP_H = 10*log10(PL_linear_3GPP_H);
diff_H = PL_dB_3GPP_H - PL_dB_orig_H;

% Canal F
PL_orig_F = 2*10^(-3) * d_ref^(-2.8);
PL_dB_orig_F = 10*log10(PL_orig_F);
PL_dB_3GPP_F_loss = calculate_pathloss_3GPP_UMi(d_ref, freq_ref, 6, 1.5, 1);
PL_linear_3GPP_F = 10^(-PL_dB_3GPP_F_loss/10);
PL_dB_3GPP_F = 10*log10(PL_linear_3GPP_F);
diff_F = PL_dB_3GPP_F - PL_dB_orig_F;

% Canal G
PL_orig_G = 2*10^(-3) * d_ref^(-2.2);
PL_dB_orig_G = 10*log10(PL_orig_G);
PL_dB_3GPP_G_loss = calculate_pathloss_3GPP_UMi(d_ref, freq_ref, 3, 6, 1);
PL_linear_3GPP_G = 10^(-PL_dB_3GPP_G_loss/10);
PL_dB_3GPP_G = 10*log10(PL_linear_3GPP_G);
diff_G = PL_dB_3GPP_G - PL_dB_orig_G;

fprintf('┌────────┬──────────────┬──────────────┬──────────────┐\n');
fprintf('│ Canal  │ PL Orig (dB) │ PL 3GPP (dB) │ Diferencia   │\n');
fprintf('├────────┼──────────────┼──────────────┼──────────────┤\n');
fprintf('│   H    │   %8.2f   │   %8.2f   │   %+6.2f dB │\n', PL_dB_orig_H, PL_dB_3GPP_H, diff_H);
fprintf('│   F    │   %8.2f   │   %8.2f   │   %+6.2f dB │\n', PL_dB_orig_F, PL_dB_3GPP_F, diff_F);
fprintf('│   G    │   %8.2f   │   %8.2f   │   %+6.2f dB │\n', PL_dB_orig_G, PL_dB_3GPP_G, diff_G);
fprintf('└────────┴──────────────┴──────────────┴──────────────┘\n\n');

fprintf('RECOMENDACIÓN FINAL:\n\n');

if abs(diff_H) < 3 && abs(diff_F) < 3 && abs(diff_G) < 3
    fprintf('✓ Las diferencias son pequeñas (<3 dB).\n');
    fprintf('  El modelo 3GPP es razonablemente cercano al original.\n');
    fprintf('  Solo necesitas ajustar la potencia (P_max).\n\n');
else
    fprintf('⚠️ Las diferencias son significativas (>3 dB).\n\n');
    
    fprintf('OPCIÓN A (Recomendada): Ajustar solo la potencia\n');
    diff_promedio = mean(abs([diff_H, diff_F, diff_G]));
    P_max_original = 0.001;
    P_max_ajustada = P_max_original * 10^(diff_promedio/10);
    fprintf('  - Usar P_max = %.4f W (%.1f dBm) en main.m\n', P_max_ajustada, 10*log10(P_max_ajustada*1000));
    fprintf('  - Mantener el modelo 3GPP sin modificar\n');
    fprintf('  - Es la opción más realista\n\n');
    
    fprintf('OPCIÓN B: Ajustar los modelos de canal\n');
    fprintf('  - Agregar factores de corrección en channel_H.m, channel_F.m, channel_G.m\n');
    fprintf('  - Ver el código sugerido arriba para cada canal\n');
    fprintf('  - Esto hace que el modelo 3GPP sea equivalente al original\n\n');
    
    fprintf('OPCIÓN C: Usar frecuencias equivalentes\n');
    fprintf('  - Modificar la frecuencia que pasas a calculate_pathloss_3GPP_UMi\n');
    fprintf('  - Ver las frecuencias equivalentes calculadas arriba\n');
    fprintf('  - Útil para "calibrar" el modelo 3GPP\n\n');
end

fprintf('=================================================================\n');
fprintf('FIN DEL ANÁLISIS\n');
fprintf('=================================================================\n');


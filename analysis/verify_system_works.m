% Script para verificar que el sistema funciona correctamente con modelo 3GPP
% Este script hace una simulación rápida y verifica que todo esté OK

clear; clc;
fprintf('=================================================================\n');
fprintf('VERIFICACIÓN: ¿Funciona el sistema con modelo 3GPP?\n');
fprintf('=================================================================\n\n');

%% ==================== PARÁMETROS (iguales a main.m) ====================
B = 5;              % Número de BS
BS_antennas = 2;    % Antenas por BS
User_antennas = 2;  % Antenas por usuario
P_max = 0.01;       % Potencia ajustada (10 dBm)
K = 4;              % Número de usuarios
P = 4;              % Subportadoras
R = 2;              % Número de RIS
N_ris = 100;        % Elementos por RIS
sigma2 = 1e-11;     % Potencia de ruido

% Probar con las frecuencias de main.m
frequencies = [1.5e9, 3.5e9, 8e9, 15e9];
freq_names = {'1.5 GHz', '3.5 GHz', '8 GHz', '15 GHz'};

% Distancia de prueba
dist_test = 80;  % metros (intermedia)

fprintf('Parámetros de prueba:\n');
fprintf('  B=%d, K=%d, P=%d, R=%d, N_ris=%d\n', B, K, P, R, N_ris);
fprintf('  P_max = %.3f mW (%.1f dBm)\n', P_max*1000, 10*log10(P_max*1000));
fprintf('  sigma2 = %.2e W (%.1f dBm)\n', sigma2, 10*log10(sigma2*1000));
fprintf('  Distancia: %d m\n\n', dist_test);

%% ==================== VERIFICACIÓN POR FRECUENCIA ====================
results = struct();

for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    fprintf('=================================================================\n');
    fprintf('Verificando frecuencia: %s\n', freq_names{freq_idx});
    fprintf('=================================================================\n\n');
    
    % Generar posiciones
    [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate(B, R, K, dist_test);
    
    % Generar canales
    [H_bkp, F_rkp, G_brp] = Channel_generate(B, R, K, P, N_ris, BS_antennas, User_antennas, ...
                                              Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser, frequency);
    
    % Inicializar W y Theta
    [W, Theta] = W_Theta_intialize(P_max, B, K, P, R, N_ris, BS_antennas);
    
    %% --- CHECK 1: Magnitudes de canal ---
    H_mag = abs(H_bkp(:));
    F_mag = abs(F_rkp(:));
    G_mag = abs(G_brp(:));
    
    fprintf('CHECK 1: Magnitudes de canal\n');
    fprintf('  |H|: min=%.2e, mean=%.2e, max=%.2e\n', min(H_mag), mean(H_mag), max(H_mag));
    fprintf('  |F|: min=%.2e, mean=%.2e, max=%.2e\n', min(F_mag), mean(F_mag), max(F_mag));
    fprintf('  |G|: min=%.2e, mean=%.2e, max=%.2e\n', min(G_mag), mean(G_mag), max(G_mag));
    
    % Verificar que no hay NaN o Inf
    if any(isnan(H_mag)) || any(isinf(H_mag))
        fprintf('  ❌ ERROR: Canal H tiene NaN o Inf\n');
        results(freq_idx).H_valid = false;
    else
        fprintf('  ✓ Canal H válido\n');
        results(freq_idx).H_valid = true;
    end
    
    if any(isnan(F_mag)) || any(isinf(F_mag))
        fprintf('  ❌ ERROR: Canal F tiene NaN o Inf\n');
        results(freq_idx).F_valid = false;
    else
        fprintf('  ✓ Canal F válido\n');
        results(freq_idx).F_valid = true;
    end
    
    if any(isnan(G_mag)) || any(isinf(G_mag))
        fprintf('  ❌ ERROR: Canal G tiene NaN o Inf\n');
        results(freq_idx).G_valid = false;
    else
        fprintf('  ✓ Canal G válido\n');
        results(freq_idx).G_valid = true;
    end
    
    %% --- CHECK 2: SNR estimado ---
    fprintf('\nCHECK 2: SNR estimado\n');
    
    % SNR aproximado del canal directo (H)
    P_signal_H = P_max * mean(H_mag.^2);
    SNR_H = P_signal_H / sigma2;
    fprintf('  SNR canal H: %.2f (%.2f dB)\n', SNR_H, 10*log10(SNR_H));
    
    % SNR aproximado vía RIS (F*G)
    P_signal_RIS = P_max * mean(F_mag.^2) * mean(G_mag.^2) * N_ris;  % Ganancia array RIS
    SNR_RIS = P_signal_RIS / sigma2;
    fprintf('  SNR vía RIS: %.2f (%.2f dB)\n', SNR_RIS, 10*log10(SNR_RIS));
    
    % Verificar SNR mínimo
    SNR_min_threshold = 0.1;  % SNR mínimo aceptable (lineal)
    if SNR_H > SNR_min_threshold
        fprintf('  ✓ SNR canal H adecuado\n');
        results(freq_idx).SNR_H_OK = true;
    else
        fprintf('  ⚠️ ADVERTENCIA: SNR canal H muy bajo (%.2f dB)\n', 10*log10(SNR_H));
        results(freq_idx).SNR_H_OK = false;
    end
    
    if SNR_RIS > SNR_min_threshold
        fprintf('  ✓ SNR vía RIS adecuado\n');
        results(freq_idx).SNR_RIS_OK = true;
    else
        fprintf('  ⚠️ ADVERTENCIA: SNR vía RIS muy bajo (%.2f dB)\n', 10*log10(SNR_RIS));
        results(freq_idx).SNR_RIS_OK = false;
    end
    
    %% --- CHECK 3: Probar algoritmos ---
    fprintf('\nCHECK 3: Probando algoritmos de optimización\n');
    
    try
        % Probar MyAlgorithm_noRIS (sin RIS, más simple)
        fprintf('  Ejecutando MyAlgorithm_noRIS... ');
        tic;
        [W_noRIS, R_sum_noRIS] = MyAlgorithm_noRIS(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp, F_rkp, G_brp, W);
        t_noRIS = toc;
        
        if isnan(R_sum_noRIS) || isinf(R_sum_noRIS) || R_sum_noRIS < 0
            fprintf('❌ FALLO (resultado: %.4f)\n', R_sum_noRIS);
            results(freq_idx).noRIS_works = false;
        else
            fprintf('✓ OK (R_sum=%.4f bit/s/Hz, tiempo=%.3f s)\n', R_sum_noRIS, t_noRIS);
            results(freq_idx).noRIS_works = true;
            results(freq_idx).R_sum_noRIS = R_sum_noRIS;
        end
    catch ME
        fprintf('❌ ERROR: %s\n', ME.message);
        results(freq_idx).noRIS_works = false;
    end
    
    try
        % Probar MyAlgorithm (con RIS, más complejo)
        fprintf('  Ejecutando MyAlgorithm... ');
        tic;
        [W_RIS, Theta_RIS, R_sum_RIS] = MyAlgorithm(B, BS_antennas, User_antennas, P_max, K, P, R, N_ris, sigma2, H_bkp, F_rkp, G_brp, W, Theta);
        t_RIS = toc;
        
        if isnan(R_sum_RIS) || isinf(R_sum_RIS) || R_sum_RIS < 0
            fprintf('❌ FALLO (resultado: %.4f)\n', R_sum_RIS);
            results(freq_idx).RIS_works = false;
        else
            fprintf('✓ OK (R_sum=%.4f bit/s/Hz, tiempo=%.3f s)\n', R_sum_RIS, t_RIS);
            results(freq_idx).RIS_works = true;
            results(freq_idx).R_sum_RIS = R_sum_RIS;
            
            % Verificar ganancia RIS
            if results(freq_idx).noRIS_works
                gain_RIS = R_sum_RIS / R_sum_noRIS;
                fprintf('  → Ganancia con RIS: %.2fx (%.2f%%)\n', gain_RIS, (gain_RIS-1)*100);
                results(freq_idx).RIS_gain = gain_RIS;
                
                if gain_RIS > 1.0
                    fprintf('  ✓ RIS mejora el rendimiento\n');
                elseif gain_RIS >= 0.9
                    fprintf('  ⚠️ RIS tiene poca ganancia (puede ser normal en algunas condiciones)\n');
                else
                    fprintf('  ⚠️ ADVERTENCIA: RIS empeora el rendimiento\n');
                end
            end
        end
    catch ME
        fprintf('❌ ERROR: %s\n', ME.message);
        results(freq_idx).RIS_works = false;
    end
    
    %% --- Guardar resultados ---
    results(freq_idx).frequency = frequency;
    results(freq_idx).freq_name = freq_names{freq_idx};
    
    fprintf('\n');
end

%% ==================== RESUMEN FINAL ====================
fprintf('=================================================================\n');
fprintf('RESUMEN DE VERIFICACIÓN\n');
fprintf('=================================================================\n\n');

fprintf('┌──────────┬────────┬────────┬────────┬──────────┬──────────┬──────────┐\n');
fprintf('│ Frec.    │ H OK   │ F OK   │ G OK   │ SNR_H OK │ SNR_R OK │ Alg. OK  │\n');
fprintf('├──────────┼────────┼────────┼────────┼──────────┼──────────┼──────────┤\n');

all_OK = true;
for freq_idx = 1:length(frequencies)
    fprintf('│ %-8s │', results(freq_idx).freq_name);
    
    % Canales válidos
    fprintf(' %s │', results(freq_idx).H_valid ? '  ✓   ' : '  ✗   ');
    fprintf(' %s │', results(freq_idx).F_valid ? '  ✓   ' : '  ✗   ');
    fprintf(' %s │', results(freq_idx).G_valid ? '  ✓   ' : '  ✗   ');
    
    % SNR OK
    fprintf(' %s  │', results(freq_idx).SNR_H_OK ? '   ✓    ' : '   ✗    ');
    fprintf(' %s  │', results(freq_idx).SNR_RIS_OK ? '   ✓    ' : '   ✗    ');
    
    % Algoritmos OK
    alg_OK = results(freq_idx).noRIS_works && results(freq_idx).RIS_works;
    fprintf(' %s  │\n', alg_OK ? '   ✓    ' : '   ✗    ');
    
    if ~alg_OK
        all_OK = false;
    end
end

fprintf('└──────────┴────────┴────────┴────────┴──────────┴──────────┴──────────┘\n\n');

%% ==================== DIAGNÓSTICO Y RECOMENDACIONES ====================
fprintf('=================================================================\n');
fprintf('DIAGNÓSTICO Y RECOMENDACIONES\n');
fprintf('=================================================================\n\n');

if all_OK
    fprintf('✅ SISTEMA FUNCIONA CORRECTAMENTE\n\n');
    fprintf('El sistema funciona con el modelo 3GPP y la potencia ajustada.\n');
    fprintf('Puedes ejecutar main.m con confianza.\n\n');
    
    % Mostrar rendimiento esperado
    fprintf('Rendimiento esperado (dist=%dm):\n', dist_test);
    for freq_idx = 1:length(frequencies)
        if results(freq_idx).RIS_works
            fprintf('  %s: R_sum ≈ %.3f bit/s/Hz (ganancia RIS: %.1fx)\n', ...
                results(freq_idx).freq_name, results(freq_idx).R_sum_RIS, ...
                results(freq_idx).RIS_gain);
        end
    end
else
    fprintf('⚠️ SISTEMA TIENE PROBLEMAS\n\n');
    
    % Identificar problemas
    problems_found = false;
    
    for freq_idx = 1:length(frequencies)
        if ~results(freq_idx).H_valid || ~results(freq_idx).F_valid || ~results(freq_idx).G_valid
            fprintf('❌ Problema en frecuencia %s: Canales inválidos (NaN/Inf)\n', results(freq_idx).freq_name);
            fprintf('   → Revisar channel_H.m, channel_F.m, channel_G.m\n\n');
            problems_found = true;
        end
        
        if ~results(freq_idx).SNR_H_OK || ~results(freq_idx).SNR_RIS_OK
            fprintf('⚠️ Problema en frecuencia %s: SNR muy bajo\n', results(freq_idx).freq_name);
            fprintf('   → Opciones:\n');
            fprintf('      1. Aumentar P_max (actualmente %.3f mW)\n', P_max*1000);
            fprintf('      2. Revisar sigma2 (actualmente %.2e W)\n', sigma2);
            fprintf('      3. Usar distancias menores\n\n');
            problems_found = true;
        end
        
        if ~results(freq_idx).noRIS_works || ~results(freq_idx).RIS_works
            fprintf('❌ Problema en frecuencia %s: Algoritmos no convergen\n', results(freq_idx).freq_name);
            fprintf('   → Opciones:\n');
            fprintf('      1. Revisar MyAlgorithm.m y MyAlgorithm_noRIS.m\n');
            fprintf('      2. Aumentar P_max para mejorar SNR\n');
            fprintf('      3. Ajustar tolerancias de convergencia\n\n');
            problems_found = true;
        end
    end
    
    if ~problems_found
        fprintf('Los checks básicos pasan pero hay advertencias menores.\n');
        fprintf('El sistema debería funcionar, pero con rendimiento subóptimo.\n\n');
    end
end

fprintf('=================================================================\n');
fprintf('VALORES RECOMENDADOS SEGÚN FRECUENCIA:\n');
fprintf('=================================================================\n\n');

% Calcular potencias recomendadas según frecuencia
fprintf('Si alguna frecuencia falla, prueba ajustar P_max:\n\n');
for freq_idx = 1:length(frequencies)
    if results(freq_idx).SNR_H_OK
        fprintf('  %s: P_max actual (%.3f mW) es OK ✓\n', results(freq_idx).freq_name, P_max*1000);
    else
        % Calcular potencia recomendada
        P_recommended = P_max * 2;  % Duplicar potencia
        fprintf('  %s: Prueba P_max = %.3f mW (%.1f dBm) ⚠️\n', ...
            results(freq_idx).freq_name, P_recommended*1000, 10*log10(P_recommended*1000));
    end
end

fprintf('\n');
fprintf('Script de verificación completado.\n');
fprintf('=================================================================\n');


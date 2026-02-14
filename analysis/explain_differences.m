% Script para explicar las diferencias entre modelos y el ajuste de potencia
clear; clc;

fprintf('=================================================================\n');
fprintf('EXPLICACIÓN: ¿Por qué los modelos dan resultados diferentes?\n');
fprintf('=================================================================\n\n');

%% EJEMPLO NUMÉRICO CONCRETO
dist = 80;           % metros
frequency = 3.5e9;   % 3.5 GHz
P_tx_original = 0.001;  % 1 mW (0 dBm) - Potencia original
P_tx_new = 0.01;        % 10 mW (10 dBm) - Potencia ajustada

fprintf('ESCENARIO DE EJEMPLO:\n');
fprintf('  Distancia: %d metros\n', dist);
fprintf('  Frecuencia: %.1f GHz\n', frequency/1e9);
fprintf('  Potencia TX (original): %.3f mW = %.1f dBm\n', P_tx_original*1000, 10*log10(P_tx_original*1000));
fprintf('  Potencia TX (ajustada): %.3f mW = %.1f dBm\n\n', P_tx_new*1000, 10*log10(P_tx_new*1000));

%% ==================== CANAL G (BS → RIS) ====================
fprintf('=================================================================\n');
fprintf('CANAL G (BS → RIS) - El más crítico\n');
fprintf('=================================================================\n\n');

% MODELO ORIGINAL
PL_original_G = 2*10^(-3) * dist^(-2.2);
P_rx_original_G = P_tx_original * PL_original_G;

fprintf('--- MODELO ORIGINAL ---\n');
fprintf('Path Loss: L(d) = 2×10^-3 × %d^-2.2 = %.4e\n', dist, PL_original_G);
fprintf('Path Loss (dB): %.2f dB\n', 10*log10(PL_original_G));
fprintf('Potencia RX: %.3f mW × %.4e = %.4e W\n', P_tx_original*1000, PL_original_G, P_rx_original_G);
fprintf('Potencia RX (dBm): %.2f dBm\n\n', 10*log10(P_rx_original_G*1000));

% MODELO 3GPP con potencia ORIGINAL
PL_dB_3GPP_G = calculate_pathloss_3GPP_UMi(dist, frequency, 3, 6, 1);
PL_linear_3GPP_G = 10^(-PL_dB_3GPP_G/10);
P_rx_3GPP_original_G = P_tx_original * PL_linear_3GPP_G;

fprintf('--- MODELO 3GPP (potencia original) ---\n');
fprintf('Path Loss: %.2f dB → L(d) = %.4e\n', PL_dB_3GPP_G, PL_linear_3GPP_G);
fprintf('Potencia RX: %.3f mW × %.4e = %.4e W\n', P_tx_original*1000, PL_linear_3GPP_G, P_rx_3GPP_original_G);
fprintf('Potencia RX (dBm): %.2f dBm\n', 10*log10(P_rx_3GPP_original_G*1000));
fprintf('❌ Diferencia: %.2f dB MÁS DÉBIL\n\n', 10*log10(P_rx_3GPP_original_G/P_rx_original_G));

% MODELO 3GPP con potencia AJUSTADA
P_rx_3GPP_adjusted_G = P_tx_new * PL_linear_3GPP_G;

fprintf('--- MODELO 3GPP (potencia ajustada +10 dB) ---\n');
fprintf('Path Loss: %.2f dB → L(d) = %.4e\n', PL_dB_3GPP_G, PL_linear_3GPP_G);
fprintf('Potencia RX: %.3f mW × %.4e = %.4e W\n', P_tx_new*1000, PL_linear_3GPP_G, P_rx_3GPP_adjusted_G);
fprintf('Potencia RX (dBm): %.2f dBm\n', 10*log10(P_rx_3GPP_adjusted_G*1000));
fprintf('✓ Diferencia con original: %.2f dB\n\n', 10*log10(P_rx_3GPP_adjusted_G/P_rx_original_G));

%% ==================== RESUMEN VISUAL ====================
fprintf('=================================================================\n');
fprintf('COMPARACIÓN DE POTENCIA RECIBIDA EN RIS (Canal G)\n');
fprintf('=================================================================\n\n');

fprintf('┌─────────────────────────────┬──────────────┬──────────────┐\n');
fprintf('│ Modelo                      │  P_RX (W)    │  P_RX (dBm)  │\n');
fprintf('├─────────────────────────────┼──────────────┼──────────────┤\n');
fprintf('│ Original (P_TX = 0 dBm)     │  %.2e  │   %.2f dBm  │\n', P_rx_original_G, 10*log10(P_rx_original_G*1000));
fprintf('│ 3GPP (P_TX = 0 dBm)         │  %.2e  │   %.2f dBm  │ ❌\n', P_rx_3GPP_original_G, 10*log10(P_rx_3GPP_original_G*1000));
fprintf('│ 3GPP (P_TX = 10 dBm)        │  %.2e  │   %.2f dBm  │ ✓\n', P_rx_3GPP_adjusted_G, 10*log10(P_rx_3GPP_adjusted_G*1000));
fprintf('└─────────────────────────────┴──────────────┴──────────────┘\n\n');

%% ==================== IMPACTO EN SNR ====================
fprintf('=================================================================\n');
fprintf('IMPACTO EN LA RELACIÓN SEÑAL-RUIDO (SNR)\n');
fprintf('=================================================================\n\n');

sigma2 = 1e-11;  % Potencia de ruido (de main.m)

SNR_original = P_rx_original_G / sigma2;
SNR_3GPP_original = P_rx_3GPP_original_G / sigma2;
SNR_3GPP_adjusted = P_rx_3GPP_adjusted_G / sigma2;

fprintf('Potencia de ruido: %.2e W = %.2f dBm\n\n', sigma2, 10*log10(sigma2*1000));

fprintf('┌─────────────────────────────┬───────────┬────────────┐\n');
fprintf('│ Modelo                      │    SNR    │  SNR (dB)  │\n');
fprintf('├─────────────────────────────┼───────────┼────────────┤\n');
fprintf('│ Original (P_TX = 0 dBm)     │   %.2f   │   %.2f dB │\n', SNR_original, 10*log10(SNR_original));
fprintf('│ 3GPP (P_TX = 0 dBm)         │   %.2f    │   %.2f dB │ ❌ MUY BAJO\n', SNR_3GPP_original, 10*log10(SNR_3GPP_original));
fprintf('│ 3GPP (P_TX = 10 dBm)        │   %.2f   │   %.2f dB │ ✓ VIABLE\n', SNR_3GPP_adjusted, 10*log10(SNR_3GPP_adjusted));
fprintf('└─────────────────────────────┴───────────┴────────────┘\n\n');

%% ==================== ¿QUÉ SIGNIFICA ESTO? ====================
fprintf('=================================================================\n');
fprintf('¿QUÉ SIGNIFICA TODO ESTO?\n');
fprintf('=================================================================\n\n');

fprintf('1. MODELO ORIGINAL vs 3GPP:\n');
fprintf('   • El modelo original era OPTIMISTA (path loss menor)\n');
fprintf('   • El modelo 3GPP es REALISTA (path loss mayor según estándar)\n');
fprintf('   • Con 3GPP, las señales se atenúan %.2f dB más\n\n', abs(10*log10(PL_linear_3GPP_G/PL_original_G)));

fprintf('2. ¿POR QUÉ SUBIR LA POTENCIA?\n');
fprintf('   • Con P_TX = 0 dBm (original), el SNR con 3GPP es %.2f dB\n', 10*log10(SNR_3GPP_original));
fprintf('   • Esto es MUY BAJO para que el sistema funcione bien\n');
fprintf('   • Con P_TX = 10 dBm, el SNR sube a %.2f dB ✓\n', 10*log10(SNR_3GPP_adjusted));
fprintf('   • Esto permite que los algoritmos de optimización converjan\n\n');

fprintf('3. ¿ES REALISTA 10 dBm?\n');
fprintf('   • Sí, 10 dBm (10 mW) es típico para:\n');
fprintf('     - Small cells / Femtocells: 10-20 dBm\n');
fprintf('     - WiFi Access Points: 15-20 dBm\n');
fprintf('     - Indoor base stations: 10-25 dBm\n');
fprintf('   • El modelo original con 0 dBm era demasiado bajo incluso\n');
fprintf('     para el modelo optimista\n\n');

fprintf('4. CONCLUSIÓN:\n');
fprintf('   • Los modelos NO dan los mismos resultados\n');
fprintf('   • El modelo 3GPP es más realista pero más atenuante\n');
fprintf('   • Subir la potencia a 10 dBm compensa la mayor atenuación\n');
fprintf('   • Esto mantiene el sistema viable y más realista\n');

fprintf('=================================================================\n\n');

%% ==================== GRÁFICA COMPARATIVA ====================
figure('Position', [100, 100, 1200, 500]);

dist_range = linspace(20, 150, 100);

% Canal G con diferentes configuraciones
P_rx_orig = zeros(size(dist_range));
P_rx_3GPP_0dBm = zeros(size(dist_range));
P_rx_3GPP_10dBm = zeros(size(dist_range));

for i = 1:length(dist_range)
    % Original
    PL_orig = 2*10^(-3) * dist_range(i)^(-2.2);
    P_rx_orig(i) = P_tx_original * PL_orig;
    
    % 3GPP con 0 dBm
    PL_dB = calculate_pathloss_3GPP_UMi(dist_range(i), frequency, 3, 6, 1);
    PL_linear = 10^(-PL_dB/10);
    P_rx_3GPP_0dBm(i) = P_tx_original * PL_linear;
    
    % 3GPP con 10 dBm
    P_rx_3GPP_10dBm(i) = P_tx_new * PL_linear;
end

% Subplot 1: Potencia recibida
subplot(1,2,1);
semilogy(dist_range, P_rx_orig*1000, 'b-', 'LineWidth', 2.5);
hold on;
semilogy(dist_range, P_rx_3GPP_0dBm*1000, 'r--', 'LineWidth', 2);
semilogy(dist_range, P_rx_3GPP_10dBm*1000, 'g-.', 'LineWidth', 2.5);
yline(sigma2*1000, 'k:', 'LineWidth', 1.5, 'Label', 'Ruido');
xlabel('Distancia BS-RIS (m)');
ylabel('Potencia Recibida en RIS (mW)');
title('Canal G: Potencia Recibida vs Distancia');
legend('Original (P_{TX}=0dBm)', '3GPP (P_{TX}=0dBm)', '3GPP (P_{TX}=10dBm)', 'Ruido', 'Location', 'best');
grid on;

% Subplot 2: SNR
subplot(1,2,2);
SNR_orig = P_rx_orig / sigma2;
SNR_3GPP_0dBm = P_rx_3GPP_0dBm / sigma2;
SNR_3GPP_10dBm = P_rx_3GPP_10dBm / sigma2;

semilogy(dist_range, SNR_orig, 'b-', 'LineWidth', 2.5);
hold on;
semilogy(dist_range, SNR_3GPP_0dBm, 'r--', 'LineWidth', 2);
semilogy(dist_range, SNR_3GPP_10dBm, 'g-.', 'LineWidth', 2.5);
yline(10, 'k:', 'LineWidth', 1.5, 'Label', 'SNR mínimo (10)');
xlabel('Distancia BS-RIS (m)');
ylabel('SNR (lineal)');
title('Canal G: SNR vs Distancia');
legend('Original (P_{TX}=0dBm)', '3GPP (P_{TX}=0dBm)', '3GPP (P_{TX}=10dBm)', 'Location', 'best');
grid on;

sgtitle(sprintf('Comparación de Modelos de Canal G (f=%.1f GHz)', frequency/1e9), ...
    'FontSize', 14, 'FontWeight', 'bold');

fprintf('Gráficas generadas. Puedes ver:\n');
fprintf('  • Izquierda: Cómo varía la potencia recibida con la distancia\n');
fprintf('  • Derecha: Cómo varía el SNR con la distancia\n');
fprintf('  • La línea verde (3GPP con 10 dBm) es similar a la azul (original)\n\n');




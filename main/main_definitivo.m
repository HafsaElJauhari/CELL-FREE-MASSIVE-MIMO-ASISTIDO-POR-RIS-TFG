clear;
tic
Iteration=10;    % 40 - Numero de repeticiones
dist_sweep = 40:10:120; % Valores de L que se representarán en las curvas
user_fixed_dist = 80;   % Posición real del usuario en el eje x (m)

% MODO 2: Barrido de frecuencias (ACTIVO)
frequencies = [3.5e9, 8e9, 15e9]; % 3.5, 8, 15 GHz
freq_names = {'3.5 GHz', '8 GHz', '15 GHz'};

% Matrices para almacenar resultados de cada frecuencia
R_sum_all         = zeros(length(dist_sweep), Iteration, length(frequencies)); 
R_sum_noRIS_all   = zeros(length(dist_sweep), Iteration, length(frequencies));

B=5;          % Numero de BS
BS_antennas = 2; % Antenas por BS (M)
User_antennas = 2;% Antenas por usuario (U) --> 64*2, 900*2 = 1800 canales entre cada usuario y cada ris, y por tanto necesitas mas pilotos, salvo que se usen tecnicas
P_max = 0.005;   % Potencia mx. por BS (W) (= 7 dBm) - Ajustado para compensar path loss 3GPP UMi
K=1;           % Unico usuario fijo
P=4;           % Subportadoras optimizan para todo el escenario y no para una ris en concreto, configurar la ris Y LA PRECODIFICACI07N (optimizacin paper vs sandra)
R=2;           % Nmero de RIS
N_ris_values = [64, 256, 900]; % Elementos por RIS por frecuencia (N)
sigma2 = 1e-11;  % Potencia de ruido

%% ==================== BUCLE PARA MÚLTIPLES FRECUENCIAS (ACTIVO) ====================
for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    N_ris = N_ris_values(freq_idx); % Elementos de la RIS en esta frecuencia
    fprintf('\n=== Frecuencia: %.2f GHz ===\n', frequency/1e9);
    fprintf('Simulacion (curvas: Ideal RIS / Without RIS)\n');

    for a=1:length(dist_sweep)
        dist_eval = dist_sweep(a);  % Valor solo para referencia en gráficos
        [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate(B,R,K,user_fixed_dist);
        fprintf('Punto L=%dm (usuario fijo en %dm) (%d/%d)\n', dist_sweep(a), user_fixed_dist, a, length(dist_sweep));

        for b=1:Iteration             
% ----- 1) Generación de canales (BS-user, RIS-user, BS-RIS) -----
            [ H_bkp,F_rkp,G_brp ] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS, Dis_BStoUser,Dis_RIStoUser, frequency);     
% ----- 2) Inicialización de W (BS) y Theta (RIS) -----
            [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);   
% (A) Without RIS: solo canal directo H y precodificación multiusuario
            [W,R_sum_noRIS_all(a,b,freq_idx)] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W);
% (B) Without direct link: fuerza H=0 y usa solo trayectorias vía RIS (opcional)
            %[~,~,R_sum_Bench(a,b)] = MyAlgorithm_Bench(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,0*H_bkp,F_rkp,G_brp,W,Theta); 
% (D) Ideal RIS case (marco propuesto, caso ideal del paper)
            [W,Theta,R_sum_all(a,b,freq_idx)] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
        end
    end
end

% ===== PROMEDIO PARA MÚLTIPLES FRECUENCIAS (ACTIVO) =====
R_sum_mean_all        = zeros(length(dist_sweep), length(frequencies));
R_sum_noRIS_mean_all  = zeros(length(dist_sweep), length(frequencies));

for freq_idx = 1:length(frequencies)
    R_sum_mean_all(:,freq_idx)        = mean(R_sum_all(:,:,freq_idx), 2);
    R_sum_noRIS_mean_all(:,freq_idx)  = mean(R_sum_noRIS_all(:,:,freq_idx), 2);
end

%% ==================== GRÁFICA PARA MÚLTIPLES FRECUENCIAS (ACTIVO) ====================
fprintf('Generando gráficas...\n');
figure('Position', [100, 100, 1400, 500]);
tiledlayout(1, length(frequencies), 'TileSpacing', 'compact', 'Padding', 'compact');

% Colores para las curvas
colors = {'b', 'r', 'g'};

for freq_idx = 1:length(frequencies)
    nexttile(freq_idx);
    hold on; box on; grid on;

    % Graficar curvas para esta frecuencia
    plot(dist_sweep, R_sum_mean_all(:,freq_idx),        '-p', 'LineWidth', 1.5, 'Color', colors{freq_idx});
    plot(dist_sweep, R_sum_noRIS_mean_all(:,freq_idx),  '--^','LineWidth', 1.5, 'Color', colors{freq_idx});

    % Configurar subplot
    legend('Ideal RIS case', 'Without RIS', 'Location', 'best');
    xlabel('Distance ${\it L}$ (m)','Interpreter','latex');
    ylabel('Weighted sum-rate (bit/s/Hz)','Interpreter','latex');
    title(sprintf('Frecuencia: %s', freq_names{freq_idx}));
    set(gca,'FontName','Times','FontSize',10);
end

% Ajustar espaciado entre subplots
sgtitle('Rendimiento RIS vs. sin RIS para distintas frecuencias', 'FontSize', 14, 'FontWeight', 'bold');

fprintf('\n¡Simulación completada!\n');
toc

% la cantidad de recursos es proporcional a la complejidad de la estimacion
% del canal --> aqui se considera que el canal se conoce, conusme muchos
% recursos  --> LINEAS FUTURAS DEL TFG, importancia de la buena estimacion
% del canal sin que el consumo de rcursos sea exagerado sin subir el numero
% de elemtnos

% porbar este escenario 1 con una unica RIS --> resultado deberia estar por
% debajo de la otra aprox en la mitad

% si solo tuviera una BS, el resultado parecido podria ser --> holografic
% mimo, es conseguir que una BS con 4 antes al ponerle un panel ris muy
% cerca, lo estas convirtienod en multicanal mimo y por tanto ganancia
% colocar la ris pegada a la estacion base, estaciones base celulares no
% cell-free. UE 1 --> 40-80m, UE2 -- 80-120m. RIS en 60 y 100

% Prueba: tener más usuarios dos, uno en 40 y otro en 80, podemos decidir
% que solo la RIs 1 la configuramos para el usario 1, y la ris 2 para el 2,
% y esto seria beneficioso para la estimacion canal. Sabiendo que la Ris
% que sta en 40 atienda al usuario 1tr, perderiamos ese poquito porcentaje
% pero es una ventaja porque me ahorro cierta complejidad de la estimacion
% del canal. Hasta 60 atiende RIS 1, apartir de la de 60 la RIS 2 (2 parte
% del paper) --> mirar el codigo --> el de 80, mirar en 60 y 100, y en 70 y 90

% tener la grafica los tres con 64 elementos, y si lo comparamos con el
% tamaño fisico.... tengo esta grafica que he sacado, para 80 y una de las
% otros dos pruebas

% al subir la frecuencia la propgacion es peor, no compensas con la
% ganancia

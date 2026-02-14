clear;
tic
Iteration=10;    % 40 - Numero de repeticiones
%dist=[0:10:160]; % Distancia L (m) del centro del grupo de usuarios
dist = [0:20:160];
% dist=120;      % (Ejemplo para un solo punto)

% Definir las frecuencias para el barrido
frequencies = [1.5e9, 3.5e9, 8e9, 15e9]; % 1.5, 3.5, 8, 15 GHz
freq_names = {'1.5 GHz', '3.5 GHz', '8 GHz', '15 GHz'};

% Matrices para almacenar resultados de cada frecuencia
R_sum_all         = zeros(length(dist), Iteration, length(frequencies)); % Ideal RIS case
R_sum_noRIS_all   = zeros(length(dist), Iteration, length(frequencies)); % Without RIS

B=5;          % Numero de BS
BS_antennas = 2; % Antenas por BS (M) - MANTENER
User_antennas = 1;% Antenas por usuario (U) - CAMBIADO A 1
P_max = 0.001;   % Potencia mx. por BS (W) (= 0 dBm)
K=4;           % Nmero de usuarios
P=1;           % Subportadoras - SIMPLIFICADO A 1 (sin subportadoras)
R=2;           % Nmero de RIS
N_ris = 100;     % Elementos por RIS (N)
sigma2 = 1e-11;  % Potencia de ruido

% Parametros temporales para el modelo simplificado
T_samples = 500;  % 500 muestras temporales (canal no cambia durante este tiempo)
T_blocks = 10;    % Numero de bloques temporales para optimizacion

fprintf('=== MODELO SIMPLIFICADO ===\n');
fprintf('Sin subportadoras (P=1)\n');
fprintf('Usuarios con una sola antena\n');
fprintf('Optimizacion por bloques temporales\n\n');

% Bucle principal para cada frecuencia
for freq_idx = 1:length(frequencies)
    frequency = frequencies(freq_idx);
    fprintf('\n=== Frecuencia: %.2f GHz ===\n', frequency/1e9);
    fprintf('Simulacion (curvas: Ideal RIS / Without RIS)\n');
    
    for a=1:length(dist) 
       [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate(B,R,K,dist(a)); % Genera posiciones geomtricas (BS, RIS, usuarios) para este L
    %    [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate_2(B,R,K);
        fprintf('Punto L=%dm (%d/%d)\n', dist(a), a, length(dist));
        
        for b=1:Iteration             
    % ----- 1) Generacin de canales (BS-user, RIS-user, BS-RIS) -----
            [ H_bkp,F_rkp,G_brp ] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS, Dis_BStoUser,Dis_RIStoUser, frequency);     
    % ----- 2) Inicializacin de W (BS) y (RIS) -----
            [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);   
            
    % ----- 3) Optimizacion por bloques temporales -----
            % El canal se mantiene constante durante T_samples
            % Optimizamos para cada bloque temporal
            
            % (A) Without RIS: solo canal directo H y precodificacin multiusuario
            [W,R_sum_noRIS_all(a,b,freq_idx)] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W);
            
    % (B) Without direct link: fuerza H=0 y usa solo trayectorias va RIS
            %[~,~,R_sum_Bench(a,b)] = MyAlgorithm_Bench(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,0*H_bkp,F_rkp,G_brp,W,Theta); 
    % (D) Ideal RIS case (marco propuesto, casoideal del paper)
            [W,Theta,R_sum_all(a,b,freq_idx)] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
        end
    end
end

%% ==================== Promedio sobre repeticiones ====================
% Calcular promedios para cada frecuencia
R_sum_mean_all        = zeros(length(dist), length(frequencies)); % Ideal RIS
R_sum_noRIS_mean_all  = zeros(length(dist), length(frequencies)); % Without RIS

for freq_idx = 1:length(frequencies)
    R_sum_mean_all(:,freq_idx)        = mean(R_sum_all(:,:,freq_idx), 2); % Ideal RIS
    R_sum_noRIS_mean_all(:,freq_idx)  = mean(R_sum_noRIS_all(:,:,freq_idx), 2); % Without RIS
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save('main_clean.mat','dist','R_sum_mean_all','R_sum_noRIS_mean_all','frequencies','freq_names');

%% ==================== Grfica final ====================
% Crear figura con 4 subplots (2x2)
figure;

% Colores para las curvas
colors = {'b', 'r', 'g', 'm'};

for freq_idx = 1:length(frequencies)
    subplot(2, 2, freq_idx);
    hold on; box on; grid on;
    
    % Graficar curvas para esta frecuencia
    plot(dist, R_sum_mean_all(:,freq_idx),        '-p', 'LineWidth', 1.5, 'Color', colors{freq_idx});
    plot(dist, R_sum_noRIS_mean_all(:,freq_idx),  '--^','LineWidth', 1.5, 'Color', colors{freq_idx});
    
    % Configurar subplot
    legend('Ideal RIS case', 'Without RIS', 'Location', 'best');
    xlabel('Distance ${\it L}$ (m)','Interpreter','latex');
    ylabel('Weighted sum-rate (bit/s/Hz)','Interpreter','latex');
    title(sprintf('Frecuencia: %s', freq_names{freq_idx}));
    set(gca,'FontName','Times','FontSize',10);
end

% Ajustar espaciado entre subplots
sgtitle('Modelo Simplificado: Comparacin de Rendimiento por Frecuencia', 'FontSize', 14, 'FontWeight', 'bold');

% Mostrar informacion del modelo
fprintf('\n=== RESUMEN DEL MODELO SIMPLIFICADO ===\n');
fprintf('Subportadoras: P = %d (sin subportadoras)\n', P);
fprintf('Antenas por usuario: %d\n', User_antennas);
fprintf('Antenas por BS: %d\n', BS_antennas);
fprintf('Muestras temporales por bloque: %d\n', T_samples);
fprintf('Bloques temporales: %d\n', T_blocks);
fprintf('Optimizacion: Por bloques temporales (no por frecuencia)\n');

toc

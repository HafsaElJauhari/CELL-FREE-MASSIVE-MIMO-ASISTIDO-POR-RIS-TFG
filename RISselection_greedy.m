function [S_k_r,F_rkp_sel,Theta_sel]=RISselection_greedy(B,BS_antennas,User_antennas,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta)
% RISselection_greedy - Selección GREEDY de RIS para cada usuario
% Cada usuario elige secuencialmente su mejor RIS dado lo que eligieron los anteriores
% NOTA: Este algoritmo NO garantiza simetría (depende del orden de usuarios)

[w_pk,~] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);

% Inicializar matrices de selección
S_k_r = zeros(K, R);
F_rkp_sel = zeros(R,K,P,N_ris,User_antennas);
R_sum = zeros(K, R);

% Algoritmo GREEDY: cada usuario elige secuencialmente
for k = 1:K
    % Probar cada RIS para el usuario k
    for r = 1:R
        % Crear F_rkp_sel temporal con:
        % - Las selecciones REALES de usuarios anteriores (ya fijadas en S_k_r)
        % - La prueba del RIS r para el usuario k actual
        F_rkp_sel_test = F_rkp_sel;  % Copiar estado actual (usuarios anteriores)
        
        % Limpiar cualquier selección previa del usuario k
        for r_clean = 1:R
            F_rkp_sel_test(r_clean,k,:,:,:) = 0;
        end
        
        % Probar asignar RIS r al usuario k
        F_rkp_sel_test(r,k,:,:,:) = F_rkp(r,k,:,:,:);
        
        % Calcular tasa suma con esta configuración
        [F_kp_test,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp_sel_test,G_brp);
        h_kp = h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp_test);
        [~,R_sum(k,r)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
    end
    
    % Elegir el mejor RIS para usuario k (el que maximiza R_sum)
    [~, mejor_ris] = max(R_sum(k,:));
    S_k_r(k, mejor_ris) = 1;
    
    % IMPORTANTE: Actualizar F_rkp_sel con la selección REAL del usuario k
    % antes de pasar al siguiente usuario
    for r = 1:R
        F_rkp_sel(r,k,:,:,:) = S_k_r(k,r) * F_rkp(r,k,:,:,:);
    end
end

% Configurar Theta_sel
Theta_r = zeros(R,N_ris,N_ris);
for r = 1:R
    temp = exp(1j*2*pi*rand(N_ris,1));
    Theta_r(r,:,:) = diag(temp);  % Fases aleatorias por defecto
end

% Para los RIS seleccionados, mantener las fases originales
for r = 1:R
    for k = 1:K
        if S_k_r(k,r) == 1
            Theta_r(r,:,:) = Theta((r-1)*N_ris+1:r*N_ris, (r-1)*N_ris+1:r*N_ris);
        end
    end
end

Theta_sel = Theta_generate(R,N_ris,Theta_r);

end


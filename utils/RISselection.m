function [S_k_r,F_rkp_sel,Theta_sel]=RISselection(B,BS_antennas,User_antennas,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta)
% RISselection - Selección ÓPTIMA de RIS para cada usuario
% Evalúa TODAS las combinaciones posibles y elige la que maximiza R_sum
% Esto garantiza simetría (no depende del orden de usuarios)

[w_pk,~] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);

% Generar todas las combinaciones posibles de asignación RIS-Usuario
% Cada usuario puede elegir cualquiera de los R RIS
% Total combinaciones: R^K
num_combinaciones = R^K;

% Matriz para almacenar todas las combinaciones
% Cada fila es una combinación, cada columna es el RIS asignado al usuario k
combinaciones = zeros(num_combinaciones, K);
for i = 1:num_combinaciones
    temp = i - 1;
    for k = K:-1:1
        combinaciones(i, k) = mod(temp, R) + 1;  % RIS del 1 al R
        temp = floor(temp / R);
    end
end

% Evaluar cada combinación
R_sum_combinaciones = zeros(num_combinaciones, 1);
F_rkp_sel_temp = zeros(R,K,P,N_ris,User_antennas);

for c = 1:num_combinaciones
    % Configurar F_rkp_sel para esta combinación
    for k = 1:K
        ris_asignado = combinaciones(c, k);
        for r = 1:R
            if r == ris_asignado
                F_rkp_sel_temp(r,k,:,:,:) = F_rkp(r,k,:,:,:);
            else
                F_rkp_sel_temp(r,k,:,:,:) = 0;
            end
        end
    end
    
    % Calcular tasa suma para esta combinación
    [F_kp_sel,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp_sel_temp,G_brp);
    h_kp = h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp_sel);
    [~,R_sum_combinaciones(c)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
end

% Seleccionar la mejor combinación
[~, mejor_combinacion] = max(R_sum_combinaciones);

% Construir S_k_r con la mejor combinación
S_k_r = zeros(K, R);
for k = 1:K
    ris_asignado = combinaciones(mejor_combinacion, k);
    S_k_r(k, ris_asignado) = 1;
end

% Construir F_rkp_sel final
F_rkp_sel = zeros(R,K,P,N_ris,User_antennas);
for k = 1:K
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

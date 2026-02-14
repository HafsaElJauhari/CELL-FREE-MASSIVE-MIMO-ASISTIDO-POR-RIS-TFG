% Análisis detallado del algoritmo RISselection
clear;

fprintf('=== ANÁLISIS DEL ALGORITMO RISselection ===\n\n');

% Parámetros
B=5; BS_antennas=2; User_antennas=2; P_max=0.005;
K=2; P=4; R=2; N_ris=64; sigma2=1e-11;
frequency=3.5e9;

% Posiciones para d=100 (U1 en x=100, U2 en x=20)
fprintf('Escenario: U1 en x=100, U2 en x=20\n');
fprintf('RIS1 en x=60, RIS2 en x=100\n\n');

hBS=15; hRIS=6; hUE=1.5;
BS_position = [60 -200; 70 -200; 80 -200; 90 -200; 100 -200];
RIS_position = [60 -1; 100 -1];
user_position = [100 0; 20 0];  % d=100: U1 en 100, U2 en 20

Dis_BStoRIS = zeros(B,R); Dis_BStoUser = zeros(B,K); Dis_RIStoUser = zeros(R,K);
for b=1:B
    for r=1:R, Dis_BStoRIS(b,r) = sqrt(sum((BS_position(b,:)-RIS_position(r,:)).^2)+(hRIS-hBS)^2); end
    for k=1:K, Dis_BStoUser(b,k) = sqrt(sum((BS_position(b,:)-user_position(k,:)).^2)+(hBS-hUE)^2); end
end
for r=1:R
    for k=1:K, Dis_RIStoUser(r,k) = sqrt(sum((RIS_position(r,:)-user_position(k,:)).^2)+(hRIS-hUE)^2); end
end

fprintf('Distancias RIS-Usuario:\n');
fprintf('  RIS1(x=60) a U1(x=100): %.1f m\n', Dis_RIStoUser(1,1));
fprintf('  RIS1(x=60) a U2(x=20):  %.1f m\n', Dis_RIStoUser(1,2));
fprintf('  RIS2(x=100) a U1(x=100): %.1f m\n', Dis_RIStoUser(2,1));
fprintf('  RIS2(x=100) a U2(x=20):  %.1f m\n', Dis_RIStoUser(2,2));

% Generar canales
[H_bkp,F_rkp,G_brp] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS,Dis_BStoUser,Dis_RIStoUser,frequency);
[W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);

% Ejecutar RISselection paso a paso
fprintf('\n=== EJECUCIÓN PASO A PASO DE RISselection ===\n');

S_k_r=zeros(K,R);
R_sum_test=zeros(K,R);
F_rkp_sel=zeros(R,K,P,N_ris,User_antennas);

[w_pk,~] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);

for k=1:K
    fprintf('\n--- Evaluando usuario k=%d ---\n', k);
    for r=1:R
        % Configurar F_rkp_sel: solo RIS r activo para usuario k
        for rr=1:R
            if rr~=r
                F_rkp_sel(rr,k,:,:,:)=0*F_rkp(rr,k,:,:,:);
            else
                F_rkp_sel(rr,k,:,:,:)=F_rkp(rr,k,:,:,:);
            end
        end
        
        % PROBLEMA: F_rkp_sel para otros usuarios (j≠k) tiene valores de iteración anterior!
        fprintf('  Probando RIS %d para usuario %d:\n', r, k);
        fprintf('    F_rkp_sel(:,%d,:,:,:) modificado\n', k);
        if k > 1
            fprintf('    PERO F_rkp_sel(:,1,:,:,:) tiene valores de selección anterior de U1!\n');
        end
        
        [F_kp_sel,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp_sel,G_brp);
        h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp_sel);
        [~,R_sum_test(k,r)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
        
        fprintf('    R_sum (TODOS los usuarios) = %.4f\n', R_sum_test(k,r));
    end
    [~,s_temp]=max(R_sum_test(k,:));
    S_k_r(k,s_temp)=1;
    fprintf('  -> Usuario %d selecciona RIS %d\n', k, s_temp);
end

fprintf('\n=== MATRIZ DE SELECCIÓN S_k_r ===\n');
fprintf('        RIS1  RIS2\n');
for k=1:K
    fprintf('User%d:   %d     %d\n', k, S_k_r(k,1), S_k_r(k,2));
end

fprintf('\n=== PROBLEMAS IDENTIFICADOS ===\n');
fprintf('1. SINR_generate calcula tasa de TODOS los usuarios, no solo del usuario k\n');
fprintf('2. Cuando evalúa k=2, F_rkp_sel(:,1,:,:,:) ya tiene la selección de k=1\n');
fprintf('3. La selección de k=2 depende de la selección previa de k=1 (NO independiente)\n');
fprintf('4. Esto causa ASIMETRÍA: el orden de los usuarios afecta el resultado\n');

fprintf('\n=== VERIFICACIÓN: Intercambiar orden de usuarios ===\n');
% Repetir con usuarios intercambiados
user_position_swap = [20 0; 100 0];  % Intercambiados
for r=1:R
    for k=1:K, Dis_RIStoUser(r,k) = sqrt(sum((RIS_position(r,:)-user_position_swap(k,:)).^2)+(hRIS-hUE)^2); end
end
for b=1:B
    for k=1:K, Dis_BStoUser(b,k) = sqrt(sum((BS_position(b,:)-user_position_swap(k,:)).^2)+(hBS-hUE)^2); end
end

[H_bkp2,F_rkp2,G_brp2] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS,Dis_BStoUser,Dis_RIStoUser,frequency);

% Esto debería dar resultados diferentes porque el orden importa!
fprintf('Si el algoritmo fuera simétrico, intercambiar U1<->U2 daría el mismo R_sum total.\n');
fprintf('Pero como el orden importa, los resultados serán diferentes.\n');

exit;


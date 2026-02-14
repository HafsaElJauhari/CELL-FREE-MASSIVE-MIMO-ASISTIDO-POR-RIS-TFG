% Test RÁPIDO para verificar diferencia F_rkp vs F_rkp_sel (sin CVX)
clear;

% Parámetros
B=5; BS_antennas=2; User_antennas=2; P_max=0.005;
K=1; P=4; R=2; N_ris=64; sigma2=1e-11;
frequency=3.5e9;

% Generar posiciones
hBS=15; hRIS=6; hUE=1.5;
BS_position = [60 -200; 70 -200; 80 -200; 90 -200; 100 -200];
RIS_position = [60 -1; 100 -1];
user_position = [80 0];

Dis_BStoRIS = zeros(B,R); Dis_BStoUser = zeros(B,K); Dis_RIStoUser = zeros(R,K);
for b=1:B
    for r=1:R, Dis_BStoRIS(b,r) = sqrt(sum((BS_position(b,:)-RIS_position(r,:)).^2)+(hRIS-hBS)^2); end
    Dis_BStoUser(b,1) = sqrt(sum((BS_position(b,:)-user_position).^2)+(hBS-hUE)^2);
end
for r=1:R, Dis_RIStoUser(r,1) = sqrt(sum((RIS_position(r,:)-user_position).^2)+(hRIS-hUE)^2); end

% Generar canales
[H_bkp,F_rkp,G_brp] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS,Dis_BStoUser,Dis_RIStoUser,frequency);

% Inicializar W y Theta con valores aleatorios (sin optimizar)
[W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);
[w_pk,~] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);

% Crear F_rkp_sel: poner RIS 2 a cero (simular selección del RIS 1)
F_rkp_sel = F_rkp;
F_rkp_sel(2,:,:,:,:) = 0;  % RIS 2 desactivado

% Calcular canal efectivo con F_rkp COMPLETO (2 RIS)
[F_kp_full,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp,G_brp);
h_kp_full = h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp_full);
[~,R_full,~] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp_full,w_pk,sigma2);

% Calcular canal efectivo con F_rkp_sel (1 RIS)
[F_kp_sel,~] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp_sel,G_brp);
h_kp_sel = h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp_sel);
[~,R_sel,~] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp_sel,w_pk,sigma2);

% Calcular solo canal directo (sin RIS)
Theta_zero = zeros(size(Theta));
h_kp_direct = h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta_zero,G_bp,F_kp_full);
[~,R_direct,~] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp_direct,w_pk,sigma2);

fprintf('\n=== TEST RÁPIDO (sin optimización CVX) ===\n');
fprintf('Canal directo (sin RIS):     %.4f bit/s/Hz\n', R_direct);
fprintf('Con 1 RIS (F_rkp_sel):       %.4f bit/s/Hz\n', R_sel);
fprintf('Con 2 RIS (F_rkp completo):  %.4f bit/s/Hz\n', R_full);
fprintf('\nDiferencia 2 RIS vs 1 RIS:   %.4f bit/s/Hz\n', R_full - R_sel);

fprintf('\n=== CONCLUSIÓN ===\n');
if R_full > R_sel
    fprintf('2 RIS da MEJOR resultado que 1 RIS (esperado)\n');
    fprintf('La selección reduce recursos -> menos tasa\n');
else
    fprintf('1 RIS da mejor o igual que 2 RIS (fases no optimizadas)\n');
end

fprintf('\n=== VERIFICACIÓN DEL BUG ===\n');
fprintf('Si en MyAlgorithm_sel.m usamos F_rkp en vez de F_rkp_sel:\n');
fprintf('- Optimizamos Theta para 1 RIS\n');
fprintf('- Pero calculamos tasa con 2 RIS\n');
fprintf('- El 2do RIS tiene fases aleatorias (no optimizadas)\n');
fprintf('- Puede dar resultados inconsistentes\n');


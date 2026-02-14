% Test para verificar si hay bug en MyAlgorithm_sel
clear;

% Parámetros
B=5; BS_antennas=2; User_antennas=2; P_max=0.005;
K=1; P=4; R=2; N_ris=64; sigma2=1e-11;
frequency=3.5e9;

% Generar posiciones (usuario en d=80)
[Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_test(B,R,K,80);

% Generar canales
[H_bkp,F_rkp,G_brp] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS,Dis_BStoUser,Dis_RIStoUser,frequency);

% Inicializar W y Theta
[W_init,Theta_init] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);

% 1) Sin RIS
[~,R_noRIS] = MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init);

% 2) Sin selección (usa ambos RIS)
[~,~,R_nosel,~] = MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init,Theta_init);

% 3) Con selección - código ACTUAL (con mi corrección: usa F_rkp_sel)
[~,~,R_sel_corregido,~] = MyAlgorithm_sel(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init,Theta_init);

% 4) Probar manualmente con F_rkp original para ver la diferencia
% Esto simula el código ANTES de mi corrección
[~,F_rkp_sel,Theta_sel]=RISselection(B,BS_antennas,User_antennas,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_init,Theta_init);
[W_sel,Theta_sel2,~,~]=MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp_sel,G_brp,W_init,Theta_sel); 
[w_pk,~] = W2wbpk_and_wpk(P,K,B,BS_antennas,W_sel);
[F_kp_original,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp,G_brp);  % <-- F_rkp original
h_kp_original= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta_sel2,G_bp,F_kp_original);
[~,R_sel_bug,~] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp_original,w_pk,sigma2);

fprintf('\n=== RESULTADOS TEST ===\n');
fprintf('Sin RIS:                    %.4f bit/s/Hz\n', R_noRIS);
fprintf('Sin seleccion (2 RIS):      %.4f bit/s/Hz\n', R_nosel);
fprintf('Con seleccion CORREGIDO:    %.4f bit/s/Hz\n', R_sel_corregido);
fprintf('Con seleccion BUG (F_rkp):  %.4f bit/s/Hz\n', R_sel_bug);

fprintf('\nAnalisis:\n');
fprintf('- Si BUG < CORREGIDO: el codigo original tenia interferencia destructiva\n');
fprintf('- Si BUG > CORREGIDO: el codigo original usaba ambos RIS (no era seleccion real)\n');
fprintf('- Diferencia BUG vs CORREGIDO: %.4f\n', R_sel_bug - R_sel_corregido);

exit;

function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser] = Position_generate_test(B,R,K,current_dist)
    Dis_BStoRIS = zeros(B, R);
    Dis_BStoUser = zeros(B, K);
    Dis_RIStoUser = zeros(R, K);
    hBS = 15; hRIS = 6; hUE = 1.5;
    BS_position = [60 -200; 70 -200; 80 -200; 90 -200; 100 -200];
    RIS_position = [60 -1; 100 -1];
    user_position = [current_dist 0];
    for b = 1:B
        for r = 1:R
            Dis_BStoRIS(b, r) = sqrt(sum((BS_position(b,:)-RIS_position(r,:)).^2) + (hRIS-hBS)^2);
        end
        Dis_BStoUser(b, 1) = sqrt(sum((BS_position(b,:)-user_position).^2) + (hBS-hUE)^2);
    end
    for r = 1:R
        Dis_RIStoUser(r, 1) = sqrt(sum((RIS_position(r,:)-user_position).^2) + (hRIS-hUE)^2);
    end
end


function [W_sel,Theta_sel,R_sum_sel,R_k]=MyAlgorithm_sel_greedy(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta)
% MyAlgorithm_sel_greedy - Algoritmo con selección de RIS usando método GREEDY
% Usa RISselection_greedy (secuencial) en lugar de RISselection (óptimo global)

    [~,F_rkp_sel,Theta_sel]=RISselection_greedy(B,BS_antennas,User_antennas,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta);
    [W_sel,Theta_sel,~,~]=MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp_sel,G_brp,W,Theta_sel); 
    
    [w_pk,~] = W2wbpk_and_wpk(P,K,B,BS_antennas,W_sel);
    [F_kp,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp_sel,G_brp);
    h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta_sel,G_bp,F_kp);
    [~,R_sum_sel,R_k] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
end


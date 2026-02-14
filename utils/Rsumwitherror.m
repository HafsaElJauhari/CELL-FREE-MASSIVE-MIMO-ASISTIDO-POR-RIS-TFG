function [W,Theta,R_sum]=Rsumwitherror(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta)

[w_pk,w_bpk] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);
w_pk = wbpk2wpk(P,K,B,BS_antennas,w_bpk);

[F_kp,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp,G_brp);

%%  等效信道生成与合并
h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp);
%%  求解信噪比和和速率
[~,R_sum] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);

end
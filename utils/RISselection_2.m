function [S_k_r]=RISselection_2(B,BS_antennas,User_antennas,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta)

S_k_r=zeros(K,R); %RIS 选择与否
R_sum=zeros(K,R);
F_rkp_sel=zeros(R,K,P,N_ris,User_antennas); %选择后的信道

[w_pk,~] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);

for k=1:K
    for r=1:R
        for rr=1:R
            if rr~=r
                F_rkp_sel(rr,k,:,:,:)=0*F_rkp(rr,k,:,:,:);
            else
                F_rkp_sel(rr,k,:,:,:)=F_rkp(rr,k,:,:,:);
            end
        end                                             
        [F_kp_sel,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp_sel,G_brp);
        h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp_sel);
        [~,R_sum(k,r)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
    end
    [~,s_temp]=max(R_sum(k,:));
    S_k_r(k,s_temp)=1;
end

for k=1:K
    for r=1:R
        for rr=1:R
            if rr~=r
                F_rkp_sel(rr,k,:,:,:)=S_k_r(k,rr)*F_rkp(rr,k,:,:,:);
            else
                F_rkp_sel(rr,k,:,:,:)=F_rkp(rr,k,:,:,:);
            end
        end                                             
        [F_kp_sel,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp_sel,G_brp);
        h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp_sel);
        [~,R_sum(k,r)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
    end
    [~,s_temp]=max(R_sum(k,:));
    S_k_r(k,s_temp)=1;
end

end


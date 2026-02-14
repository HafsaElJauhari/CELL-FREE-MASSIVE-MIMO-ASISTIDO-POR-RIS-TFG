function [ H_bkp,F_rkp,G_brp ] = Channel_generate_2( B,R,K,P,N_ris,BS_antennas,User_antennas,large_fading_AI,large_fading_DI,Dis_BStoRIS, Dis_BStoUser,Dis_RIStoUser,Gain)
for b=1:B
    for k=1:K
        for p=1:P
            H_bkp(b,k,p,:,:)=channel_H(BS_antennas,User_antennas,Dis_BStoUser(b,k),large_fading_AI);          
        end
    end
end
for r=1:R
    for k=1:K
        for p=1:P
            F_rkp(r,k,p,:,:)=Gain*channel_F(N_ris,User_antennas,Dis_RIStoUser(r,k),large_fading_DI);
        end
    end
end
for b=1:B
    for r=1:R
        for p=1:P
            G_brp(b,r,p,:,:)=Gain*channel_G(N_ris,BS_antennas,Dis_BStoRIS(b,r),large_fading_DI);
        end
    end
end

end


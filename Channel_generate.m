function [ H_bkp,F_rkp,G_brp ] = Channel_generate( B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS, Dis_BStoUser,Dis_RIStoUser,frequency)
H_bkp=zeros(B,K,P,BS_antennas,User_antennas);
F_rkp=zeros(R,K,P,N_ris,User_antennas);
G_brp=zeros(B,R,P,N_ris,BS_antennas);

% Generar canales H: BS -> Usuario (NLOS)
for b=1:B
    for k=1:K
        for p=1:P
            H_bkp(b,k,p,:,:)=channel_H(BS_antennas,User_antennas,Dis_BStoUser(b,k),frequency);             
        end
    end
end

% Generar canales F: RIS -> Usuario (LOS/NLOS automático)
for r=1:R
    for k=1:K
        for p=1:P
            F_rkp(r,k,p,:,:)=channel_F(N_ris,User_antennas,Dis_RIStoUser(r,k),frequency);
        end
    end
end

% Generar canales G: BS -> RIS (LOS)
for b=1:B
    for r=1:R
        for p=1:P
            G_brp(b,r,p,:,:)=channel_G(N_ris,BS_antennas,Dis_BStoRIS(b,r),frequency);
        end
    end
end

end


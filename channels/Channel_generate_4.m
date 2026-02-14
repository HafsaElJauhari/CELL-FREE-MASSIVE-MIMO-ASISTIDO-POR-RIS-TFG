function [ H_bkp,F_rkp,G_brp ] = Channel_generate_4( B,R,K,P,N_ris,BS_antennas,User_antennas)
H_bkp=zeros(B,K,P,BS_antennas,User_antennas);
F_rkp=zeros(R,K,P,N_ris,User_antennas);
G_brp=zeros(B,R,P,N_ris,BS_antennas);

BS_posi=[0,-50,3];
RIS_posi=[100,10,6];
user_posi=[100,0,1.5];

dis_BS_user=(BS_posi(1)-RIS_posi(1))^2+(BS_posi(2)-RIS_posi(2))^2+(BS_posi(3)-RIS_posi(3))^2;
dis_BS_user=sqrt(dis_BS_user);

dis_RIS_user=(user_posi(1)-RIS_posi(1))^2+(user_posi(2)-RIS_posi(2))^2+(user_posi(3)-RIS_posi(3))^2;
dis_RIS_user=sqrt(dis_RIS_user);

dis_BS_RIS=(BS_posi(1)-RIS_posi(1))^2+(BS_posi(2)-RIS_posi(2))^2+(BS_posi(3)-RIS_posi(3))^2;
dis_BS_RIS=sqrt(dis_BS_RIS);

for b=1:B
    for k=1:K
        for p=1:P
            H=raylrnd(1,BS_antennas,User_antennas);
            for aa=1:BS_antennas
                for bb=1:User_antennas
                    H(aa,bb) = H(aa,bb)*exp(1j*2*pi*rand());
                end
            end
            a = 10^(-3)*dis_BS_user^(-3.5);
            H = sqrt(a)*H;
            H_bkp(b,k,p,:,:)=H;             
        end
    end
end
for r=1:R
    for k=1:K
        for p=1:P
            F=raylrnd(1,N_ris,User_antennas);
            for aa=1:N_ris
                for bb=1:User_antennas
                    F(aa,bb) = F(aa,bb)*exp(1j*2*pi*rand());
                end
            end
            a = 2*10^(-3)*dis_RIS_user^(-2.8);%3dBi antenna gain
            F = sqrt(a)*F;
            F_rkp(r,k,p,:,:)=F;
        end
    end
end
for b=1:B
    for r=1:R
        for p=1:P
            G = ones(N_ris,BS_antennas);
            a = 2*10^(-3)*dis_BS_RIS^(-2.2);
            G = sqrt(a)*G;
            G_brp(b,r,p,:,:)=G;
        end
    end
end

end


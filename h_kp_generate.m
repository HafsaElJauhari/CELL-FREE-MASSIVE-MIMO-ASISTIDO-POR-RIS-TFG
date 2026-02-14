function h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp)
%%  ��Ч�ŵ�����
h_bkp=zeros(B,K,P,BS_antennas,User_antennas);
for b=1:B
    for k=1:K
        for p=1:P
            temp0=reshape(H_bkp(b,k,p,:,:),BS_antennas,User_antennas);        %H_bpk canal directo
            temp1=reshape(G_bp(b,p,:,:),R*N_ris,BS_antennas);   %G_bp 
            temp2=reshape(F_kp(k,p,:,:),R*N_ris,User_antennas);
            h_bkp(b,k,p,:,:)=temp0+temp1'*Theta*temp2; % H_bkp + G_bp * Theta * F_kp --  conseguir que H, G*F -> H, RIS ventaja, modulo de H --> ganancia del canal
        end
    end
end

% reorganiza
h_kp=zeros(K,P,B*BS_antennas,User_antennas);
for k=1:K
    for p=1:P
        for b=1:B
            h_kp(k,p,(b-1)*BS_antennas+1:b*BS_antennas,:)=h_bkp(b,k,p,:,:);
        end
    end
end
end

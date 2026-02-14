function [OMG, Zeta] = BETA_kpj_update(B,R,K,P,User_antennas,N_ris,BS_antennas,Theta_r,alpha_hat_kp,H_bkp,F_rkp,G_brp,w_bpk,eps_kp)

BETA_kpj=zeros(K,P,K,R);
OMG=zeros(K*R,K*R);
OMG_k=zeros(K,R,R);
Zeta=zeros(K*R,1);
Zeta_k=zeros(K,R);

c_kpj=zeros(K,P,K);

for r=1:R
    for k=1:K
        for p=1:P
            for j=1:K         
                
                BETA_kpj(k,p,j,r)=0;
                for b=1:B
                    temp1=reshape(eps_kp(k,p,:),User_antennas,1);   %varpi
                    temp2=reshape(F_rkp(r,k,p,:,:),N_ris,User_antennas);   %Frkp
                    temp3=reshape(Theta_r(r,:,:),N_ris,N_ris);   %Theta_r
                    temp4=reshape(G_brp(b,r,p,:,:),N_ris,BS_antennas);   %Gbrp
                    temp5=reshape(w_bpk(b,p,j,:),BS_antennas,1);   %wbpj                    
                    BETA_kpj(k,p,j,r)=BETA_kpj(k,p,j,r)+temp1'*temp2'*temp3'*temp4*temp5;
                end    
                
            end
        end          
    end
end

for k=1:K
    temp0=zeros(R,R);
    for p=1:P
        for j=1:K
            temp1=reshape(BETA_kpj(k,p,j,:),R,1);
            temp0=temp0+temp1*temp1';
        end
    end
    OMG_k(k,:,:)=temp0;
end

for k=1:K
    OMG((k-1)*R+1:k*R,(k-1)*R+1:k*R)=reshape(OMG_k(k,:,:),R,R);
end
OMG=real(OMG);

for k=1:K
    for p=1:P
        for j=1:K
            c_kpj(k,p,j)=0;
            for b=1:B
                temp1=reshape(eps_kp(k,p,:),User_antennas,1);   %varpi
                temp2=reshape(H_bkp(b,k,p,:,:),BS_antennas,User_antennas);   %H_bkp
                temp3=reshape(w_bpk(b,p,j,:),BS_antennas,1);   %wbpj     
                c_kpj(k,p,j)=c_kpj(k,p,j)+temp1'*temp2'*temp3;
            end
        end
    end
end
    
for k=1:K
    temp1=zeros(R,1);
    for p=1:P
        temp1=temp1+sqrt(alpha_hat_kp(k,p))*reshape(BETA_kpj(k,p,k,:),R,1);
    end
    temp2=zeros(R,1);
    for p=1:P
        for j=1:K
            temp2=temp2+(c_kpj(k,p,j))'*reshape(BETA_kpj(k,p,j,:),R,1);
        end
    end
    Zeta_k(k,:)=real(temp1-temp2);
end

for k=1:K
    Zeta((k-1)*R+1:k*R)=reshape(Zeta_k(k,:),R,1);
end


end


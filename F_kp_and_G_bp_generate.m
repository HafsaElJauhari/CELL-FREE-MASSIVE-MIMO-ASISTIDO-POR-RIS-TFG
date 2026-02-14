function [F_kp,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp,G_brp)
F_kp=zeros(K,P,R*N_ris,User_antennas);
for k=1:K
    for p=1:P
        for r=1:R
            F_kp(k,p,(r-1)*N_ris+1:1:r*N_ris,:)=F_rkp(r,k,p,:,:);
        end
    end
end
G_bp=zeros(B,P,R*N_ris,BS_antennas); 
for b=1:B
   for p=1:P
       for r=1:R
           G_bp(b,p,(r-1)*N_ris+1:1:r*N_ris,:)=G_brp(b,r,p,:,:); 
       end
   end
end
end


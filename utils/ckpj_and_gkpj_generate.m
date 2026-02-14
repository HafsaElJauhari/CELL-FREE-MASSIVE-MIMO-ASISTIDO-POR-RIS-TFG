function [c_kpj,g_kpj] = ckpj_and_gkpj_generate(K,P,R,N_ris,User_antennas,F_kp,b_kpj,a_pj,eps_kp)
c_kpj=zeros(K,P,K);
g_kpj=zeros(K,P,K,R*N_ris);
for k=1:K
    for p=1:P
        for j=1:K   
            temp1=reshape(eps_kp(k,p,:),User_antennas,1);
            temp2=reshape(b_kpj(k,p,j,:),User_antennas,1);
            c_kpj(k,p,j)=temp1'*temp2;
            
            temp3=reshape(F_kp(k,p,:,:),R*N_ris,User_antennas);
            temp4=reshape(eps_kp(k,p,:),User_antennas,1);
            g_kpj(k,p,j,:)=diag(temp4'*temp3')*reshape(a_pj(p,j,:),R*N_ris,1);
            
        end
    end
end

end
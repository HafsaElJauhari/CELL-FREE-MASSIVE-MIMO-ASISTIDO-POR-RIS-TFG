function [U,v] = U_v_generate(K,P,R,N_ris,alpha_hat_kp,c_kpj,g_kpj)
v=zeros(R*N_ris,1);
U=zeros(R*N_ris,R*N_ris);
for k=1:K
    for p=1:P
        for j=1:K
            temp=reshape(g_kpj(k,p,j,:),R*N_ris,1);
            U=U+temp*temp';
        end
    end
end
for k=1:K
    for p=1:P
        temp=0;
        for j=1:K
            temp=temp+c_kpj(k,p,j)'*reshape(g_kpj(k,p,j,:),R*N_ris,1);
        end
        temp2=reshape(g_kpj(k,p,k,:),R*N_ris,1);
        v=v+sqrt(alpha_hat_kp(k,p))*temp2-temp;
    end
end
end


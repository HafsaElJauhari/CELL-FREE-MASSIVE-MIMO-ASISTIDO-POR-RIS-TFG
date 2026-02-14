function V= V_generate(P,K,B,BS_antennas,User_antennas,alpha_hat_kp,beta_kp,h_kp)
v_pk=zeros(P,K,B*BS_antennas);
for k=1:K
    for p=1:P
        temp=reshape(beta_kp(k,p,:),User_antennas,1);
        temp2=reshape(h_kp(k,p,:,:),B*BS_antennas,User_antennas);
        v_pk(p,k,:)=sqrt(alpha_hat_kp(k,p))*temp2*temp;
    end
end
V=zeros(P*K*B*BS_antennas,1)+1j*zeros(P*K*B*BS_antennas,1);
for p=1:P
    for k=1:K
        V(B*BS_antennas*(K*(p-1)+k-1)+1:1:B*BS_antennas*(K*(p-1)+k),1)= ...
            v_pk(p,k,:);        
    end
end
end


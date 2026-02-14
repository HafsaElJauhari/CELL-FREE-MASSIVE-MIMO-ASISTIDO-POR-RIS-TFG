function beta_kp = beta_kp_update(K,P,B,BS_antennas,User_antennas,alpha_hat_kp,h_kp,w_pk,sigma2)
beta_kp=ones(K,P,User_antennas);      %¸¨Öú±äÁ¿beta
for k=1:K
    for p=1:P
        temp0=0;
        temp1=reshape(h_kp(k,p,:,:),B*BS_antennas,User_antennas);
        for j=1:K
            temp2=reshape(w_pk(p,j,:),B*BS_antennas,1);
            temp2=temp1'*temp2;
            temp0=temp0+temp2*temp2';
        end
        temp0=temp0+sigma2*eye(User_antennas);  
        temp0=temp0^(-1);
        temp3=reshape(w_pk(p,k,:),B*BS_antennas,1);
        temp3=temp1'*temp3;     
        beta_kp(k,p,:)=sqrt(alpha_hat_kp(k,p))*temp0*temp3;
    end
end
end


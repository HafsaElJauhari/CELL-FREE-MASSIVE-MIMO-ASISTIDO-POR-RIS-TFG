function w_pk= Zero_Forcing(B,K,P,BS_antennas,h_kp,lambda)
w_pk=zeros(P,K,B*BS_antennas);
for p=1:P
    h_temp=zeros(K,B*BS_antennas);
    for k=1:K
        temp=reshape(h_kp(k,p,:),B*BS_antennas,1);
        h_temp(k,:)=temp';       
    end
    temp_w=(h_temp'*h_temp)^(-1)*h_temp';
    for k=1:K
        temp=reshape(temp_w(:,k),B*BS_antennas,1);
        w_pk(p,k,:)=temp;
    end
end
w_pk=w_pk*lambda;
end


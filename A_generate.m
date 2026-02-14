function A = A_generate(P,K,B,BS_antennas,User_antennas,beta_kp,h_kp)
A_p=zeros(P,B*BS_antennas,B*BS_antennas);
for p=1:P
    for k=1:K       
        temp=reshape(h_kp(k,p,:,:),B*BS_antennas,User_antennas);   
        temp3=reshape(beta_kp(k,p,:),User_antennas,1);        
        temp2=reshape(A_p(p,:,:),B*BS_antennas,B*BS_antennas);
        temp=temp*temp3;
        A_p(p,:,:)=temp2+temp*temp';
    end
end
A_p_2=zeros(P,K*B*BS_antennas,K*B*BS_antennas);
for p=1:P
    for k=1:K
        A_p_2(p,(k-1)*B*BS_antennas+1:1:(k)*B*BS_antennas,(k-1)*B*BS_antennas+1:1:(k)*B*BS_antennas)= ...
            A_p(p,:,:);
    end
end
A=zeros(P*K*B*BS_antennas,K*P*B*BS_antennas);
for p=1:P
    A((p-1)*K*B*BS_antennas+1:1:(p)*K*B*BS_antennas,(p-1)*K*B*BS_antennas+1:1:(p)*K*B*BS_antennas) ...
    =A_p_2(p,:,:);
end

end


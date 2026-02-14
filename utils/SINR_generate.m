function [SINR_kp,R_sum,R_k] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2)
R_sum=0;
SINR_kp=zeros(K,P);
R_k=zeros(K,1);  % Tasa por usuario (suma de todas las subportadoras)
for k=1:K
    for p=1:P
        temp0=reshape(h_kp(k,p,:,:),B*BS_antennas,User_antennas);
        temp1=reshape(w_pk(p,k,:),B*BS_antennas,1);
        temp2=temp0'*temp1;
        
        temp=0;
        for j=1:K
            temp3=reshape(w_pk(p,j,:),B*BS_antennas,1);
            temp3=temp0'*temp3;
            temp=temp+(temp3)*(temp3)';
        end
        temp=temp+sigma2*eye(User_antennas)-temp2*temp2';      
        temp=temp^(-1);
        SINR_kp(k,p)=temp2'*temp*temp2;
        R_sum=R_sum+log2(1+SINR_kp(k,p));
        R_k(k)=R_k(k)+log2(1+SINR_kp(k,p));  % Suma todas las subportadoras para el usuario k
    end
end
end


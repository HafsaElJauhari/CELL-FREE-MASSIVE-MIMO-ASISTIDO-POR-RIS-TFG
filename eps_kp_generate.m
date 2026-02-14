function eps_kp = eps_kp_generate(R,N_ris,K,P,a_kpj,b_kpj,theta,alpha_hat_kp,sigma2)
eps_kp=zeros(K,P);
for k=1:K
   for p=1:P
       temp=0;
       for j=1:K
           temp1=reshape(a_kpj(k,p,j,:),R*N_ris,1);
           temp1=b_kpj(k,p,j)+theta'*temp1;
           temp=temp+norm(temp1,2)^2;
       end
       temp1=reshape(a_kpj(k,p,k,:),R*N_ris,1);
       eps_kp(k,p)=sqrt(alpha_hat_kp(k,p))*(b_kpj(k,p,k)+theta'*temp1)/(temp+sigma2);
   end
end
end


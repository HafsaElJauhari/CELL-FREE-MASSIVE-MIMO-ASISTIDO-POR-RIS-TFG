function [b_kpj,a_pj] = apj_and_bkp_generate(K,P,R,B,N_ris,BS_antennas,User_antennas,w_bpk,H_bkp,G_bp)
b_kpj=zeros(K,P,K,User_antennas);
a_pj=zeros(P,K,R*N_ris);
for k=1:K
    for p=1:P
        for j=1:K
            
            for b=1:B
                temp1=reshape(H_bkp(b,k,p,:,:),BS_antennas,User_antennas);
                temp2=reshape(w_bpk(b,p,j,:),BS_antennas,1);
                temp3=reshape(b_kpj(k,p,j,:),User_antennas,1);
                b_kpj(k,p,j,:)=temp3+temp1'*temp2;
            end
            
        end
    end
end
for p=1:P
    for j=1:K           
        for b=1:B
            temp1=reshape(G_bp(b,p,:,:),R*N_ris,BS_antennas);
            temp2=reshape(w_bpk(b,p,j,:),BS_antennas,1);
            temp3=reshape(a_pj(p,j,:),R*N_ris,1);
            a_pj(p,j,:)=temp3+temp1*temp2;
        end            
    end
end
end
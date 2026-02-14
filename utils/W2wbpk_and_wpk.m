function [w_pk,w_bpk] = W2wbpk_and_wpk(P,K,B,BS_antennas,W)
w_bpk=zeros(B,P,K,BS_antennas); 
w_pk=zeros(P,K,B*BS_antennas);
for p=1:P
    for k=1:K
        w_pk(p,k,:)=W(B*BS_antennas*(K*(p-1)+k-1)+1:1:B*BS_antennas*(K*(p-1)+k),1);
    end
end
for k=1:K
    for p=1:P
        for b=1:B
            w_bpk(b,p,k,:)=w_pk(p,k,(b-1)*BS_antennas+1:b*BS_antennas);
        end
    end
end
end


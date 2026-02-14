function W = wpk2W(P,K,B,BS_antennas,w_pk)
W=zeros(P*K*B*BS_antennas,1)+1j*zeros(P*K*B*BS_antennas,1);
for p=1:P
    for k=1:K
        W(B*BS_antennas*(K*(p-1)+k-1)+1:1:B*BS_antennas*(K*(p-1)+k),1)= ...
            w_pk(p,k,:);
    end
end
end


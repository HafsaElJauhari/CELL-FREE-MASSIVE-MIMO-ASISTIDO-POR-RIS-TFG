function w_pk = wbpk2wpk(P,K,B,BS_antennas,w_bpk)

w_pk=zeros(P,K,B*BS_antennas);
for k=1:K
    for p=1:P
        for b=1:B
            w_pk(p,k,(b-1)*BS_antennas+1:b*BS_antennas)=w_bpk(b,p,k,:);
        end
    end
end
end


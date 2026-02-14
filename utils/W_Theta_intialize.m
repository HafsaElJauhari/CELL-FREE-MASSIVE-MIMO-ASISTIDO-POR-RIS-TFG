function [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas)

w_bpk=sqrt(P_max/K/P/BS_antennas/2)*(ones(B,P,K,BS_antennas)+1j*ones(B,P,K,BS_antennas));
w_pk = wbpk2wpk(P,K,B,BS_antennas,w_bpk);
W = wpk2W(P,K,B,BS_antennas,w_pk);

Theta_r=zeros(R,N_ris,N_ris);                     %��ͬRIS�ϵ���λ
for r=1:1:R
    temp=exp(1j*2*pi*rand(N_ris,1));
    Theta_r(r,:,:)=diag(temp);                    %��λ��ֵȫ��Ϊ0
end
Theta= Theta_generate(R,N_ris,Theta_r);

end


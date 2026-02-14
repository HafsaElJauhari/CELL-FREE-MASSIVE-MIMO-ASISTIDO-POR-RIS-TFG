function [R_sum,R_sum_noRIS] = Channel_generate_5(P_max,sigma2,N_ris,H_bkp,F_rkp,G_brp)
H=0;
F=zeros(N_ris,1);
G=zeros(N_ris,1);

H=H_bkp(1,1,1,1,1);
F=reshape(F_rkp(1,1,1,:,:),N_ris,1);
G=reshape(G_brp(1,1,1,:,:),N_ris,1);

H=abs(H);
F=abs(F');
G=abs(G);

h=H+F*G;

SNR=P_max*h^2/sigma2;


R_sum=log2(1+SNR);
R_sum_noRIS=log2(1+P_max*H^2/sigma2);
end


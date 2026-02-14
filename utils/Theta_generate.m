function Theta= Theta_generate(R,N_ris,Theta_r)
%%  等效信道合并
Theta=zeros(R*N_ris,R*N_ris)+1j*zeros(R*N_ris,R*N_ris);
for r=1:R
    Theta((r-1)*N_ris+1:r*N_ris,(r-1)*N_ris+1:r*N_ris)=Theta_r(r,:,:);
end
end


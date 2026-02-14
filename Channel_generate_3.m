function [H_bkp_hat,F_rkp_hat,G_brp_hat ] = Channel_generate_3( B,R,K,P,N_ris,BS_antennas,User_antennas,H_bkp,F_rkp,G_brp,delta)
for b=1:B
    for k=1:K
        for p=1:P
			for m=1:BS_antennas
				for u=1:User_antennas
					sigma_n= delta*abs(H_bkp(b,k,p,m,u))^2;
%					H_bkp_hat(b,k,p,m,u)=H_bkp(b,k,p,m,u)-delta*abs(H_bkp(b,k,p,m,u))*exp(1j*2*pi*rand());
                    H_bkp_hat(b,k,p,m,u)=H_bkp(b,k,p,m,u)+sqrt(sigma_n/2)*randn()+1j*sqrt(sigma_n/2)*randn();
                    H_bkp_hat(b,k,p,m,u)=abs(H_bkp(b,k,p,m,u))/sqrt(1+delta^2)/abs(H_bkp_hat(b,k,p,m,u))*H_bkp_hat(b,k,p,m,u);
				end
			end            
        end
    end
end

for r=1:R
    for k=1:K
        for p=1:P
			for n=1:N_ris
				for u=1:User_antennas
					sigma_n= delta*abs(F_rkp(r,k,p,n,u))^2;
%					F_rkp_hat(r,k,p,n,u)=F_rkp(r,k,p,n,u)-delta*abs(F_rkp(r,k,p,n,u))*exp(1j*2*pi*rand());
                    F_rkp_hat(r,k,p,n,u)=F_rkp(r,k,p,n,u)+sqrt(sigma_n/2)*randn()+1j*sqrt(sigma_n/2)*randn();
                    F_rkp_hat(r,k,p,n,u)=abs(F_rkp(r,k,p,n,u))/sqrt(1+delta^2)/abs(F_rkp_hat(r,k,p,n,u))*F_rkp_hat(r,k,p,n,u);
				end
			end
        end
    end
end
for b=1:B
    for r=1:R
        for p=1:P
			for n=1:N_ris
				for m=1:BS_antennas
					sigma_n= delta*abs(G_brp(b,r,p,n,m))^2;
%					G_brp_hat(b,r,p,n,m)=G_brp(b,r,p,n,m)-delta*abs(G_brp(b,r,p,n,m))*exp(1j*2*pi*rand());
                    G_brp_hat(b,r,p,n,m)=G_brp(b,r,p,n,m)+sqrt(sigma_n/2)*randn()+1j*sqrt(sigma_n/2)*randn();
                    G_brp_hat(b,r,p,n,m)=abs(G_brp(b,r,p,n,m))/sqrt(1+delta^2)/abs(G_brp_hat(b,r,p,n,m))*G_brp_hat(b,r,p,n,m);
				end
			end		
        end
    end
end

end


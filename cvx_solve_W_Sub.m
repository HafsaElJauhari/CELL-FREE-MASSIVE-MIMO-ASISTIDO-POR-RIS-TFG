function [W,P_b] = cvx_solve_W_Sub(A,V,W,D_b,P_max)
N=size(A,1);

% CCC=eig(A);
% CCC=CCC(1);
% if CCC<=0
% A=A+CCC*eye(N,N);
% % end
A=A+10^(-100);

A=1/2*(A+A');
for aa=1:N
    for bb=1:N
        if (aa==bb)
            A(aa,aa)=real(A(aa,aa));
        elseif aa>bb
            A(aa,bb)=conj(A(bb,aa));
        end
    end
end

B=size(D_b,1);
P_b=zeros(B,1);
% AAA=(-(W')*A*W+2*real((V')*W));

W=A^(-1)*V;

for b=1: B
    P_b(b)=(W')*reshape(D_b(b,:,:),N,N)*W;
    P_b(b)=sqrt(P_max/(P_b(b)));
end

W=min(P_b(b))*W;
end


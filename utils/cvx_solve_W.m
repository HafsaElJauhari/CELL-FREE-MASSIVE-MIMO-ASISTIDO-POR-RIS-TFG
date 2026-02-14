function [W,P_b] = cvx_solve_W(A,V,W,D_b,P_max)
N=size(A,1);
A=A+10^(-50);
CCC=eig(A);
CCC=1.001*CCC(1);
if CCC<=0
    A=A-CCC*eye(N,N);
end
%A=A+10^(-50);

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
cvx_begin quiet
    cvx_precision low
    variable W(N,1) complex;
    minimize((W')*A*W-2*real((V')*W))
    subject to
    for b = 1:B
        temp=reshape(D_b(b,:,:),N,N);
        real((W')*temp*W)<=P_max;
    end
cvx_end
% BBB=(-(W')*A*W+2*real((V')*W));
% if BBB<AAA
%     printf('1\n');
% end
for b=1: B
    P_b(b)=(W')*reshape(D_b(b,:,:),N,N)*W;
end
end


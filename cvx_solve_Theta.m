function theta= cvx_solve_Theta(N,U,v,theta)
U=U+10^(-50);

CCC=eig(U);
CCC=1.001*CCC(1);
if CCC<=0
    U=U-CCC*eye(N,N);
end
U=0.5*(U+U');
%((theta')*U*theta-2*real((theta')*v))
cvx_begin quiet
    cvx_precision low
    variable theta(N,1) complex;
    minimize ((theta')*U*theta-2*real((theta')*v))
    subject to
    for n = 1:N
        abs(theta(n))<=1;
    end
cvx_end

% sqrt(sum((abs(theta)-1).^2))
end


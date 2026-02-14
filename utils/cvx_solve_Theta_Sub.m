function theta= cvx_solve_Theta_Sub(N,U,v,theta)
U=U+10^(-50);
U=0.5*(U+U');
%((theta')*U*theta-2*real((theta')*v))
cvx_begin quiet
    variable theta(N,1) complex;
    minimize (-2*real((theta')*v))
    subject to
    for n = 1:N
        abs(theta(n))<=1;
    end
cvx_end

end


function [ue] = ue_optimize(K,R,ue,OMG,Zeta,Rmatch)

cvx_begin quiet
    variable X(K*R,K*R) symmetric;
    variable x(K*R);
    minimize trace(OMG*X)-2*(Zeta.')*x
    subject to
    for i = 1:K*R
        X(i,i) == x(i);
    end
    kron(eye(K),ones(1,R))*X<=Rmatch*ones(K,1)*x.';
    kron(eye(K),ones(1,R))*x<=Rmatch*ones(K,1);
    [1,x';x,X]>= 0;
cvx_end

ue=x;

end


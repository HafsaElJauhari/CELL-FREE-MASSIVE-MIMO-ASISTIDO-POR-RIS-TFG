clear all; close all; clc;

Q=[-9,-24,2,18,-12;
   -24,-3,-7,36,-84;
   2,-7,0,20,4;
   18,0,20,0,-44;
   -12,0,0,-44,6];
c=[0,-4,2,23,6]';
a=[1,1,1,1,1]';
b=2;

N=5;

cvx_begin 
    variable X(N,N) symmetric;
    variable x(N);
    minimize trace(Q*X)+(c')*x
    subject to
    for i = 1:N
        X(i,i) == x(i);
    end
    a'*X==b*x';
    a'*x==b;
    [1,x';x,X]>= 0;
cvx_end


% N=5;
% cvx_begin 
%     variable X(N,N) symmetric;
%     variable x(N);
%     minimize -9*x(1)-7*x(2)+2*x(3)+23*x(4)+12*x(5)-48*X(1,2)+4*X(1,3)+36*X(1,4)-24*X(1,5)-7*X(2,3)+36*X(2,4)-84*X(2,5)+40*X(3,4)+4*X(3,5)-88*X(4,5)
%     subject to
%     for i = 1:N
%         X(i,i) == x(i);
%     end
%     for i = 1:N
%         X(1,i)+X(2,i)+X(3,i)+X(4,i)+X(5,i) == 2*x(i);
%     end   
%     x(1)+x(2)+x(4)+x(5) == 2;
%     [1,x';x,X]>= 0;
% cvx_end




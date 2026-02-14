function [H] = channel(N,M,dis,large_fading)
% N number of receiver
% M number of transmitter
H = zeros(N,M);
for aa=1:N
    for bb=1:M
       H(aa,bb) = normrnd(0,1)+1j*normrnd(0,1);
    end
end
a = 10^(-3)*dis^(-large_fading)/sqrt(2);

H = a*H;
end


function A= ReturnNear( theta,Theta_Num )
[~,C]=min(abs(Theta_Num-theta));
A=Theta_Num(C);
end


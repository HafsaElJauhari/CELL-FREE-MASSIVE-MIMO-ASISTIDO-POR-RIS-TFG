close all; clear; clc;
tic
Iteration=40;

B=[1:1:24];       %基站数量
R=[0:5:110];             %RIS数量

P_max=0.001;

R_sum=zeros(length(R),Iteration,length(B));
E_sum=0*R_sum;

BS_antennas=1;      %基站天线数
User_antennas=1;    %用户天线数
K=1;                %用户数量
P=1;                %子载波数量
N_ris=4;            %每个RIS上的单元数

sigma2=10^(-11);    %噪声

P_BS=10^(9/20);
Eps=1.2;
P_UE=10^(-20/20);
P_ris=10^(-20/20);

fprintf('Trade off\n');

R_number=length(R);
B_number=length(B);
for b=1:Iteration    
	 for a=1:R_number
        fprintf('第%d循环第%d轮\n',b,a);
        for c=1:B_number          
            if R(a)==0
                [ H_bkp,F_rkp,G_brp ] =Channel_generate_4(B(c),1,K,P,N_ris,BS_antennas,User_antennas);           
                [W,Theta] = W_Theta_intialize(P_max,B(c),K,P,1,N_ris,BS_antennas);				
                [W,Theta,R_sum(a,b,c)]=MyAlgorithm(B(c),BS_antennas,User_antennas,P_max,K,P,1,N_ris,sigma2,H_bkp,0*F_rkp,0*G_brp,W,Theta);
                E_sum(a,b,c)=R_sum(a,b,c)/(Eps*abs(W'*W)+B(c)*P_BS+K*P_UE+N_ris*R(a)*P_ris);      
            else
                [ H_bkp,F_rkp,G_brp ] =Channel_generate_4(B(c),R(a),K,P,N_ris,BS_antennas,User_antennas);           
                [W,Theta] = W_Theta_intialize(P_max,B(c),K,P,R(a),N_ris,BS_antennas);				
                [W,Theta,R_sum(a,b,c)]=MyAlgorithm(B(c),BS_antennas,User_antennas,P_max,K,P,R(a),N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta);
                E_sum(a,b,c)=R_sum(a,b,c)/(Eps*abs(W'*W)+B(c)*P_BS+K*P_UE+N_ris*R(a)*P_ris);       
            end
        end
    end
end

for a=1:R_number
	for c=1:B_number
        E_sum_mean(a,c)=abs(mean(E_sum(a,:,c)));
    end
end

%save('main_7.mat','R','B','R_sum','E_sum_mean');

figure;
surf(B,R,E_sum_mean);

figure;
hold on;
box on;
grid on;
plot(R,E_sum_mean(:,1),'-p','LineWidth',1.5);
plot(R,E_sum_mean(:,2),'--o','LineWidth',1.5);
plot(R,E_sum_mean(:,3),':*','LineWidth',1.5);
plot(R,E_sum_mean(:,4),'-s','LineWidth',1.5);
plot(R,E_sum_mean(:,5),'--^','LineWidth',1.5);
plot(R,E_sum_mean(:,6),'--^','LineWidth',1.5);
set(gca,'FontName','Times','FontSize',12);
legend('1','2','3','4','5','6');


toc
clear; clc;
tic
Iteration=40;

P_max=0.001;
N_ris=[20:20:200];       %每个RIS上的单元数
%N_ris=[1,N_ris];
dist=65;

R_sum=zeros(length(N_ris),Iteration);
R_sum_InFbit=zeros(length(N_ris),Iteration);
R_sum_sel=zeros(length(N_ris),Iteration);

R_sum_2bit=zeros(length(N_ris),Iteration);
R_sum_1bit=zeros(length(N_ris),Iteration);
R_sum_Bench=zeros(length(N_ris),Iteration);
% R_sum_sub=zeros(length(N_ris),Iteration);
R_sum_bas=zeros(length(N_ris),Iteration);
R_sum_noRIS=zeros(length(N_ris),Iteration);
B=5;            %基站数量
BS_antennas=2;  %基站天线数
User_antennas=2;    %用户天线数
K=4;            %用户数量
P=4;            %子载波数量
R=2;            %RIS数量

Rmatch=1;

sigma2=10^(-11);%噪声
fprintf('RIS\n');
for a=1:length(N_ris)
    fprintf('第%d轮\n',a);
    [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate_2(B,R,K);
    for b=1:Iteration       

        [ H_bkp,F_rkp,G_brp ] = Channel_generate(B,R,K,P,N_ris(a),BS_antennas,User_antennas,Dis_BStoRIS, Dis_BStoUser,Dis_RIStoUser);     
        [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris(a),BS_antennas);
        
        [W,R_sum_noRIS(a,b)]=MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp,W);             
        [W,Theta,R_sum_bas(a,b)]=MyAlgorithm_Bas(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp,W,Theta);
        
        [W,Theta,R_sum_1bit(a,b)]=MyAlgorithm_1bit(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
        [W,Theta,R_sum_2bit(a,b)]=MyAlgorithm_2bit(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
        [W,Theta,R_sum_InFbit(a,b)]=MyAlgorithm_InFbit(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
        [W,Theta,R_sum(a,b)]=MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp,W,Theta); 
        [~,~,R_sum_sel(a,b)]=MyAlgorithm_LCR(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp,W,Theta,Rmatch);
        
        [~,~,R_sum_Bench(a,b)]=MyAlgorithm_Bench(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,0*H_bkp,F_rkp,G_brp,W,Theta); 
%       [W,Theta,R_sum_1bit(a,b)]=MyAlgorithm_1bit(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp);
%       [W,Theta,R_sum_2bit(a,b)]=MyAlgorithm_2bit(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp,W,Theta);             
%        [W,Theta,R_sum_InFbit(a,b)]=MyAlgorithm_InFbit(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris(a),sigma2,H_bkp,F_rkp,G_brp,W,Theta);
  
    end
end
R_sum_mean=mean(R_sum,2);
R_sum_InFbit_mean=mean(R_sum_InFbit,2);
R_sum_sel_mean=mean(R_sum_sel,2);
R_sum_2bit_mean=mean(R_sum_2bit,2);
R_sum_1bit_mean=mean(R_sum_1bit,2);
% R_sum_sub_mean=mean(R_sum_sub,2);
R_sum_bas_mean=mean(R_sum_bas,2);
R_sum_noRIS_mean=mean(R_sum_noRIS,2);
R_sum_Bench_mean=mean(R_sum_Bench,2);

%save('main_3.mat','N_ris','R_sum_mean','R_sum_InFbit_mean','R_sum_2bit_mean','R_sum_1bit_mean','R_sum_sel_mean','R_sum_Bench_mean','R_sum_bas_mean','R_sum_noRIS_mean');


figure;
hold on;
plot(N_ris,R_sum_mean,'-p','LineWidth',1.5);
plot(N_ris,R_sum_sel_mean,'-.d','LineWidth',1.5);
plot(N_ris,R_sum_InFbit_mean,'--o','LineWidth',1.5);
plot(N_ris,R_sum_2bit_mean,'-*','LineWidth',1.5);
plot(N_ris,R_sum_1bit_mean,'--s','LineWidth',1.5);
% % plot(N_ris,R_sum_sub_mean,'-^','LineWidth',1.5);
plot(N_ris,R_sum_Bench_mean,':*','LineWidth',1.5);
plot(N_ris,R_sum_bas_mean,'-s','LineWidth',1.5);
plot(N_ris,R_sum_noRIS_mean,'--^','LineWidth',1.5);

legend('Ideal RIS case','Two-timescale scheme','Continuous phase shift','2-bit phase shift','1-bit phase shift','Without direct link','Random phase shift','Without RIS','Interpreter','latex')
box on;
grid on
ylabel('Weighted sum-rate (bit/s/Hz)','Interpreter','latex')
xlabel('Number of elements at RIS ${\it N}$','Interpreter','latex')
set(gca,'FontName','Times','FontSize',12);
toc
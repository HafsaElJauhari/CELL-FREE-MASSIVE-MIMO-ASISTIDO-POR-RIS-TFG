clear; clc;
tic
Iteration=40;

delta=[0:0.05:0.4];

User_antennas=2;    %用户天线数
P_max=0.001;

R_sum=zeros(Iteration,length(delta));
R_sum_InFbit=zeros(Iteration,length(delta));
R_sum_sel=zeros(Iteration,length(delta));
R_sum_2bit=zeros(Iteration,length(delta));
R_sum_1bit=zeros(Iteration,length(delta));
R_sum_Bench=zeros(Iteration,length(delta));
% R_sum_sub=zeros(length(delta),Iteration);
R_sum_noRIS=zeros(Iteration,length(delta));
R_sum_bas=zeros(Iteration,length(delta));

B=5;                %基站数量
BS_antennas=2;      %基站天线数

K=4;                %用户数量
P=4;                %子载波数量
R=2;                %RIS数量
N_ris=100;          %每个RIS上的单元数
sigma2=10^(-11);    %噪声
fprintf('误差\n');
[Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate(B,R,K,65);   
    
Ll=length(delta);
for b=1:Iteration   
    fprintf('第%d轮\n',b);
    [ H_bkp,F_rkp,G_brp] = Channel_generate(B,R,K,P,N_ris,BS_antennas,User_antennas,Dis_BStoRIS, Dis_BStoUser,Dis_RIStoUser);     
    [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);
        
    [W_noRIS,~]=MyAlgorithm_noRIS(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W);        
    [W_Bas,Theta_Bas,~]=MyAlgorithm_Bas(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_noRIS,Theta);
    [W_InF,Theta_InF,~]=MyAlgorithm_InFbit(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_Bas,Theta_Bas); 
    [W_my,Theta_my,~]=MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_InF,Theta_InF);
    [W_sel,Theta_sel,~] = MyAlgorithm_sel(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W_my,Theta_my);  
    [W_Bench,Theta_Bench,~]=MyAlgorithm_Bench(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,0*H_bkp,F_rkp,G_brp,W_my,Theta_my); 		
    for a=1:Ll      
        [H_bkp_hat,F_rkp_hat,G_brp_hat ] = Channel_generate_3(B,R,K,P,N_ris,BS_antennas,User_antennas,H_bkp,F_rkp,G_brp,delta(a));
        [~,~,R_sum(b,a)]=Rsumwitherror(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp_hat,F_rkp_hat,G_brp_hat,W_my,Theta_my);
        [~,~,R_sum_InFbit(b,a)]=Rsumwitherror(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp_hat,F_rkp_hat,G_brp_hat,W_InF,Theta_InF);
        [~,~,R_sum_sel(b,a)]=Rsumwitherror(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp_hat,F_rkp_hat,G_brp_hat,W_sel,Theta_sel);
        [~,~,R_sum_Bench(b,a)]=Rsumwitherror(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp_hat,F_rkp_hat,G_brp_hat,W_Bench,Theta_Bench);
        [~,~,R_sum_bas(b,a)]=Rsumwitherror(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp_hat,F_rkp_hat,G_brp_hat,W_Bas,Theta_Bas);
        [~,~,R_sum_noRIS(b,a)]=Rsumwitherror(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp_hat,F_rkp_hat,G_brp_hat,W_noRIS,0*Theta_Bas);		
    end
end
R_sum_mean=mean(R_sum,1);
R_sum_InFbit_mean=mean(R_sum_InFbit,1);
R_sum_sel_mean=mean(R_sum_sel,1);
R_sum_2bit_mean=mean(R_sum_2bit,1);
R_sum_1bit_mean=mean(R_sum_1bit,1);
% R_sum_sub_mean=mean(R_sum_sub,1);
R_sum_bas_mean=mean(R_sum_bas,1);
R_sum_noRIS_mean=mean(R_sum_noRIS,1);
R_sum_Bench_mean=mean(R_sum_Bench,1);
%save('CSIerror.mat','delta','R_sum_mean','R_sum_InFbit_mean','R_sum_noRIS_mean','R_sum_bas_mean','R_sum_Bench_mean');

%save('main_7.mat','delta','R_sum_mean','R_sum_InFbit_mean','R_sum_sel_mean','R_sum_Bench_mean','R_sum_bas_mean','R_sum_noRIS_mean');


figure;
hold on;
plot(delta,R_sum_mean,'-p','LineWidth',1.5);
plot(delta,R_sum_InFbit_mean,'--o','LineWidth',1.5);
plot(delta,R_sum_sel_mean,'-.d','LineWidth',1.5);
% plot(delta,R_sum_2bit_mean,'-*','LineWidth',1.5);
% plot(delta,R_sum_1bit_mean,'--s','LineWidth',1.5);
% % plot(delta,R_sum_sub_mean,'-^','LineWidth',1.5);
plot(delta,R_sum_Bench_mean,':*','LineWidth',1.5);
plot(delta,R_sum_bas_mean,'-s','LineWidth',1.5);
plot(delta,R_sum_noRIS_mean,'--^','LineWidth',1.5);

legend('Ideal RIS case','Continuous phase shift','Two-timescale scheme','Without direct link','Random phase shift','Without RIS')
box on;
grid on
ylabel('Weighted sum-rate (bit/s/Hz)','Interpreter','latex')
xlabel('CSI error parameter $\delta$','Interpreter','latex')
set(gca,'FontName','Times','FontSize',12);



toc
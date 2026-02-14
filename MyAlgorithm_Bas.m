function [W,Theta,R_sum]=MyAlgorithm_Bas(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta)
iteration=30;  %迭代次数
R_sum=zeros(2*iteration,1);
gamma_k=ones(K,1);      %用户优先级
alpha_kp=ones(K,P);     %辅助变量alpha 
beta_kp=ones(K,P);      %辅助变量beta
% Theta_r=zeros(R,N_ris,N_ris);                     %不同RIS上的相位
% for r=1:1:R
%     temp=exp(1j*pi*(rand(N_ris,1)>0.5));
%     Theta_r(r,:,:)=diag(temp);                    %相位初值全设为0
% end
% w_bpk=sqrt(P_max/K/P/BS_antennas/2)*(ones(B,P,K,BS_antennas)+1j*ones(B,P,K,BS_antennas));     %数字预编码矩阵
theta=Theta*ones(R*N_ris,1);
Theta_all=[0,pi,2*pi];
for aa=1:length(theta)
    temp=angle(theta(aa));
    while (temp<0)
        temp=temp+2*pi;
    end
    while (temp>2*pi)
        temp=temp-2*pi;
    end
    temp=ReturnNear(temp,Theta_all);
   theta(aa)=rand()*exp(1j*temp);
%   theta(aa)=rand()*theta(aa);
end
Theta=diag(theta);
%%  约束条件合并
D_b=zeros(B,B*P*K*BS_antennas,B*P*K*BS_antennas);
for b=1:B
    temp=zeros(B,B);
    temp(b,b)=1;
    temp=kron(temp,eye(BS_antennas,BS_antennas));
    temp=kron(eye(P*K,P*K),temp);
    D_b(b,:,:)=temp;
end
%%  多RIS信道向量合并
[F_kp,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp,G_brp);
%%  多RIS合并
% Theta= Theta_generate(R,N_ris,Theta_r);
%% 功率分配向量合并
% w_pk = wbpk2wpk(P,K,B,BS_antennas,w_bpk);
[w_pk,w_bpk] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);
for Q=1:iteration
%%  等效信道生成与合并
h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp);
%%  求解信噪比和和速率
[SINR_kp,R_sum(2*Q-1)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
if Q>1
    if (R_sum(2*Q-1)-R_sum(2*Q-3))/R_sum(2*Q-2)<0.01   %增长率小于0.5%则弹出
       break; 
    end
end
% AAA=R_sum(Q)
%%  alpha更新
alpha_kp=SINR_kp;
alpha_hat_kp=diag(gamma_k)*(1+alpha_kp);          %辅助变量alpha_hat
%%  beta更新
beta_kp = beta_kp_update(K,P,B,BS_antennas,User_antennas,alpha_hat_kp,h_kp,w_pk,sigma2);
%%  V生成
V= V_generate(P,K,B,BS_antennas,User_antennas,alpha_hat_kp,beta_kp,h_kp);
%%  W 生成
W = wpk2W(P,K,B,BS_antennas,w_pk);
% BBB=W'*W
%% A 矩阵生成
A = A_generate(P,K,B,BS_antennas,User_antennas,beta_kp,h_kp);
%%  优化W
[W,P_b]= cvx_solve_W(A,V,W,D_b,P_max);
%%  同步所有w
[w_pk,w_bpk] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);
[SINR_kp,R_sum(2*Q)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
end
% plot(abs(R_sum));
R_sum=max(R_sum);
end
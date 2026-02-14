function [W,Theta,R_sum]=MyAlgorithm_LCR(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta,Rmatch)
iteration=30;  %迭代次数
R_sum=zeros(2*iteration,1);
gamma_k=ones(K,1);      %用户优先级
alpha_kp=ones(K,P);     %辅助变量alpha 
beta_kp=ones(K,P);      %辅助变量beta
Theta_r=zeros(R,N_ris,N_ris);                     %不同RIS上的相位

ue=ones(K*R,1);

[w_pk,w_bpk] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);

flag=1;
%%  约束条件合并
D_b=zeros(B,B*P*K*BS_antennas,B*P*K*BS_antennas);
for b=1:B
    temp=zeros(B,B);
    temp(b,b)=1;
    temp=kron(temp,eye(BS_antennas,BS_antennas));
    temp=kron(eye(P*K,P*K),temp);
    D_b(b,:,:)=temp;
end
%%  多RIS合并
% Theta= Theta_generate(R,N_ris,Theta_r);
%% 功率分配向量合并
w_pk = wbpk2wpk(P,K,B,BS_antennas,w_bpk);
F_rkp_hat=F_rkp;
%%  多RIS信道向量合并
[F_kp,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp_hat,G_brp);
for Q=1:iteration
%%  等效信道生成与合并
for r=1:R
    for k=1:K
         F_rkp_hat(r,k,:,:,:)=F_rkp(r,k,:,:,:)*ue((k-1)*R+r);
    end
end
[F_kp_hat,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp_hat,G_brp);

h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp_hat);
%%  求解信噪比和和速率
[SINR_kp,R_sum(2*Q-1)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
if Q>2
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
%%  对角阵转向量
theta=Theta*ones(R*N_ris,1);
%%  计算 b 和 a
[b_kpj,a_pj] = apj_and_bkp_generate(K,P,R,B,N_ris,BS_antennas,User_antennas,w_bpk,H_bkp,G_bp);
%%  eps更新
eps_kp = beta_kp_update(K,P,B,BS_antennas,User_antennas,alpha_hat_kp,h_kp,w_pk,sigma2);
[c_kpj,g_kpj] = ckpj_and_gkpj_generate(K,P,R,N_ris,User_antennas,F_kp_hat,b_kpj,a_pj,eps_kp);
%%  计算U V
[U,v] = U_v_generate(K,P,R,N_ris,alpha_hat_kp,c_kpj,g_kpj);
%% 优化theta
theta=cvx_solve_Theta(R*N_ris,U,v,theta);
Theta=diag(theta);  %与对角阵保持一致
%% 分解各个Theta
for r=1:R
    Theta_r(r,:,:)=Theta((r-1)*N_ris+1:r*N_ris,(r-1)*N_ris+1:r*N_ris);
end

if flag==1  %once is enough
    [OMG, Zeta] = BETA_kpj_update(B,R,K,P,User_antennas,N_ris,BS_antennas,Theta_r,alpha_hat_kp,H_bkp,F_rkp,G_brp,w_bpk,eps_kp);
    [ue] = ue_optimize(K,R,ue,OMG,Zeta,Rmatch);
    flag=0;   
    [W,Theta] = W_Theta_intialize(P_max,B,K,P,R,N_ris,BS_antennas);   
end

end
%plot(abs(R_sum));
h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp);
[~,R_sum] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);

end
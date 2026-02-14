function R_sum=MyAlgorithm_ZF(B,BS_antennas,P_max,K,P,sigma2,H_bkp)
% digits(64);
%%  基本参数设置
iteration=1;  %迭代次数
R_sum=zeros(iteration,1);

lambda_upper=0.0001;
lambda_lower=0;

gamma_k=ones(K,1);      %用户优先级

alpha_kp=ones(K,P);     %辅助变量alpha 
beta_kp=ones(K,P);      %辅助变量beta
w_bpk=sqrt(P_max/K/P/BS_antennas/2)*(ones(B,P,K,BS_antennas)+1j*ones(B,P,K,BS_antennas));     %数字预编码矩阵
%%  约束条件合并
D_b=zeros(B,B*P*K*BS_antennas,B*P*K*BS_antennas);
for b=1:B
    temp=zeros(B,B);
    temp(b,b)=1;
    temp=kron(temp,eye(BS_antennas,BS_antennas));
    temp=kron(eye(P*K,P*K),temp);
    D_b(b,:,:)=temp;
end
%% 功率分配向量合并
w_pk = wbpk2wpk(P,K,B,BS_antennas,w_bpk);
% [w_pk,w_bpk] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);
%%  等效信道生成与合并
h_bkp=zeros(B,K,P,BS_antennas);
for b=1:B
    for k=1:K
        for p=1:P
            temp0=reshape(H_bkp(b,k,p,:),BS_antennas,1);        %H_bpk
            h_bkp(b,k,p,:)=temp0;
        end
    end
end
%%  等效信道合并
h_kp=zeros(K,P,B*BS_antennas);
for k=1:K
    for p=1:P
        for b=1:B
            h_kp(k,p,(b-1)*BS_antennas+1:b*BS_antennas)=h_bkp(b,k,p,:);
        end
    end
end
%%  zf
temp1=reshape(D_b(1,:,:),B*P*K*BS_antennas,B*P*K*BS_antennas);
temp2=reshape(D_b(2,:,:),B*P*K*BS_antennas,B*P*K*BS_antennas);

w_pk_1=Zero_Forcing(B,K,P,BS_antennas,h_kp,lambda_upper);
W_1 = wpk2W(P,K,B,BS_antennas,w_pk_1);  

w_pk_2=Zero_Forcing(B,K,P,BS_antennas,h_kp,lambda_lower);
W_2 = wpk2W(P,K,B,BS_antennas,w_pk_2);  
Q=1;
    while ~(real(W_1'*temp1*W_1)<=P_max && real(W_1'*temp2*W_1)<=P_max && real(W_2'*temp2*W_2)<=P_max && real(W_2'*temp1*W_2)<=P_max )
        Q=Q+1;
        w_pk_1=Zero_Forcing(B,K,P,BS_antennas,h_kp,lambda_upper);
        W_1 = wpk2W(P,K,B,BS_antennas,w_pk_1);  
        w_pk_2=Zero_Forcing(B,K,P,BS_antennas,h_kp,lambda_lower);
        W_2 = wpk2W(P,K,B,BS_antennas,w_pk_2);         
        lambda=(lambda_upper+lambda_lower)/2;
        w_pk=Zero_Forcing(B,K,P,BS_antennas,h_kp,lambda);
        W = wpk2W(P,K,B,BS_antennas,w_pk); 
        if real(W'*temp1*W)<=P_max && real(W'*temp2*W)<=P_max
            lambda_lower=lambda;
        else
            lambda_upper=lambda;
        end
        lambda
        if Q>1000
            break;
        end
        [SINR_kp,R_sum] = SINR_generate(K,P,B,BS_antennas,h_kp,w_pk,sigma2);
        R_sum
    end
[SINR_kp,R_sum] = SINR_generate(K,P,B,BS_antennas,h_kp,w_pk,sigma2);
end
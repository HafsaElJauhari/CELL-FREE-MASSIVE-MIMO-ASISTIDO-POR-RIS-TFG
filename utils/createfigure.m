function createfigure1(X1, YMatrix1)
%CREATEFIGURE1(X1, YMatrix1)
%  X1:  x 数据的向量
%  YMATRIX1:  y 数据的矩阵

%  由 MATLAB 于 27-Dec-2019 17:24:41 自动生成

% 创建 figure
figure('OuterPosition',[395.8 287.4 572.8 501.2]);

% 创建 axes
axes1 = axes;
hold(axes1,'on');

% 使用 plot 的矩阵输入创建多行
plot1 = plot(X1,YMatrix1,'LineWidth',1.5);
set(plot1(1),'DisplayName','Upper bound','LineStyle','--');
set(plot1(2),'DisplayName','InF-bit','Marker','square');
set(plot1(3),'DisplayName','2-bit','Marker','*');
set(plot1(4),'DisplayName','1-bit','Marker','^');
set(plot1(5),'DisplayName','No RIS','Marker','o');

% 创建 ylabel
ylabel('Weighted sum-rate /bit/s/Hz');

% 创建 xlabel
xlabel('Distance L/m');

% 取消以下行的注释以保留坐标区的 Y 范围
% ylim(axes1,[0 200]);
box(axes1,'on');
grid(axes1,'on');
% 创建 legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.148452377989179 0.706031741717505 0.215357145820345 0.195238099552336]);


function plotRatios(dataMat, binCenters)

h = figure(110); clf;
% boxplot(dataMat(:, 2:end), 'labels', binCenters(2:end));
boxprct(dataMat(:, 2:end), 0, h);

set(gca, 'YLim', [1 5]);
set(gca, 'XTick', 4:4:24, 'XTickLabel', binCenters(2:end));
xlabel('Time interval duration (\tau)');
ylabel('Noise gain ratio r_{\lambda}');
% ylabel('Condition number ratio r_{t}')
grid on; box on;

set(gca, 'FontSize', 18);
set(gcf, 'Position', [1000 900 560 350]);

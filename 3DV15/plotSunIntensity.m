function [] = plotSunIntensity(varargin)
% Plot a figure to show the sun intensity throughout the day.
%
% Inputs:
% matA : Matrix A containing the Mean Light Vectors dans time information
%

matA = [];
exportPlots = false;

parseVarargin(varargin{:});

%% Get the relevant information from matA
sunIntensity = matA.sunInts;
dateNums = matA.info.datetimes;
rel_dateNums = dateNums - floor(max(dateNums));

%% Generate the figure

figure(101); clf;
y_sunInts_log = logsun(sunIntensity);
plot(rel_dateNums, y_sunInts_log, 'LineWidth', 3);
datetick('x','HH:MM');
grid on;

% squish vertically a bit
set(gcf, 'Position', [560 528 560 160]);
set(gca, 'XLim', [min(rel_dateNums) max(rel_dateNums)]);

set(gca, 'YLim', [0 12]);

t = get(gca, 'XTickLabel');
set(gca, 'XTickLabel', {});

%     ylabel('Log sun intensity');
%     xlabel('Time of day');

set(gca, 'XTickLabel', t);
title('Sun intensity in logsun');

if exportPlots
    export_fig(fullfile(outputPath, sprintf('%s-intensity', day)), ...
        '-transparent', '-png', '-pdf');
end

end


function X = logsun(X)
% Values below 1 are treated as linear, while values over 1 are log.
    % 
    %   f(x) = x;           x <= 1; linear part
    %   f(x) = log(x)+1;    x > 1;  log part
    %
    linearInd = X <= 1;
    X = X .* linearInd + log(X .* ~linearInd + linearInd) + ~linearInd;
    %   linear part,       log(0)=-Inf,   log(1)=0, plus 1 in log part 
end
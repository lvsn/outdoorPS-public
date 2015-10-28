function plotAllRelativePerformance(varargin)

outputPath = getPathName('results', '3dvplots', 'events');
metricName = 'cn';

intervalDataPath = getPathName('data', 'intervalData');

parseVarargin(varargin{:});

% let's keep only the days which are not either completely overcast or
% completely sunny
sunIntsData = load(fullfile(intervalDataPath, 'sunIntsFull.mat'));
sunVis = cellfun(@(i) mean(i>5000), sunIntsData.sunIntsFull.sunInts);

validInd = sunVis > .15 & sunVis < .85;
validDays = sunIntsData.sunIntsFull.days(validInd);

dataMat = {};
for i_f = 1:length(validDays)
    f = fullfile(outputPath, ...
        sprintf('%s-%s-global-relativePerfData.mat', validDays{i_f}, metricName));
    if exist(f, 'file')
        d = load(f);
        dataMat = cat(1, dataMat, d.dataMat);
    end
end

allDataMat = cell(1, size(dataMat, 2));
for i_c = 1:size(dataMat, 2)
    allDataMat{i_c} = cat(1, dataMat{:,i_c});
end

plotRatios(allDataMat, d.binCenters);

export_fig(fullfile(outputPath, sprintf('all-%s-relativePerf.pdf', metricName)), '-transparent');
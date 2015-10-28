function [] = plotCorrelationBetweenRcondAndSunInts(varargin)
% Plot a figure to show the correlation between rcond and the sky
% appearance
%
%   1. rcond of the MLV matrix
%   2. sun intensity in linear / log space
%   3. mean / variance in a hour
%
% Inputs:
% matA : Matrix A containing the Mean Light Vectors dans time information
% plotGraphics : Whether to plot graphics or not
% doLoadData : If false (or 0), generate the data in the file tmp_{day}.mat
%

matA = [];

exportPlots = false;
outputPath = getPathName('results', '3dvplots', 'events');

metricName = 'maxGain'; % YAN TODO: TO REMOVE
normalization = 'local'; % local or global

rho = 1;
pctNoise = .01;

doPlotSunIntensities = false; %YAN TODO: Split in another file.
doPlotGains = true;

parseVarargin(varargin{:});

dateNums = matA.info.datetimes;

% normalsx3xdatenums
[allMetrics, lengths] = cacheFunction(@computeMetrics, ...
    permute(matA.MLVs, [3 2 1]), matA.normal, dateNums, ...
    'normalization', normalization, ...
    'rho', rho, 'pctNoise', pctNoise);

medMetric = median(allMetrics, 3);

%%

% Relative performance bar plot
% bestMetric = squeeze(nanmin(nanmin(allMetrics, [], 1), [], 2));
% bestMetric = prctile(allMetrics(:), 1);
bestMetric = reshape(allMetrics, [], size(allMetrics, 3));
bestMetric = prctile(bestMetric, 1, 1);
bestMetric = repmat(permute(bestMetric, [3 1 2]), size(allMetrics, 1), size(allMetrics, 2));

relativePerf = allMetrics ./ bestMetric;
% relativePerf = allMaxGain;
lengthsVec = repmat(lengths, [1 1 size(allMetrics, 3)]);
    
% plot this per length of time interval
relativePerfVec = relativePerf(:);
lengthsVec = lengthsVec(:);

% look at when is it a good time to start?
startTimes = repmat(dateNums(end:-1:1), 1, length(dateNums), size(allMetrics, 3));
startTimes = startTimes(:);

validInd = ~isnan(lengthsVec);
relativePerfVec = relativePerfVec(validInd);
lengthsVec = lengthsVec(validInd);
startTimes = startTimes(validInd);

assert(nnz(isnan(relativePerfVec)) == 0);

% histogram the lengths
lengthsVec = lengthsVec*24; % in hours
binEdges = -.5:1:6.5;
binCenters = binEdges(1:end-1) + (binEdges(2:end)-binEdges(1:end-1))/2;
[~,binInd] = histc(lengthsVec, binEdges);

% dataMat = NaN.*ones(length(relativePerfVec), length(binCenters));
dataMat = cell(1, length(binCenters));
for i_c = 1:length(binCenters)
    curInd = binInd == i_c;
%     dataMat(1:nnz(curInd), i_c) = relativePerfVec(curInd);
    dataMat{i_c} = relativePerfVec(curInd);
end

% let's save this
%save(fullfile(outputPath, sprintf('%s-relativePerfData.mat', baseFilename)), ...
%    'dataMat', 'binCenters');

% make sure we have enough data
dataMatLength = cellfun(@length, dataMat);
dataMat = dataMat(dataMatLength>0);
binCenters = binCenters(dataMatLength>0);

plotRatios(dataMat, binCenters);

if exportPlots
%    export_fig(fullfile(outputPath, sprintf('%s-relativePerf', baseFilename)), ...
%            '-transparent', '-pdf');
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute the data
% ------------------
% Plot the figures
% close all; % close the figures

% 2. Sun intensity
if doPlotSunIntensities
    
end

%% 3. Image version of the residual maximum uncertainty (median across all normals)
figure(203); clf;

rel_dateNums = dateNums - floor(max(dateNums));

% 5 = normal pointing towards the camera
%     tmp_residual_cs = cellfun(@(x) x(:,3), residual_cs,'UniformOutput',false);

pcolor(rel_dateNums, rel_dateNums, medMetric);
switch normalization
    case 'global'
        caxis([0 40]);
    case 'local'
        caxis([0 100]);
end

axis xy; grid on;
shading flat;
datetick(gca,'x','HH:MM'); datetick(gca, 'y','HH:MM');
colormap(jet);

axis equal;
set(gca, 'XLim', [min(rel_dateNums) max(rel_dateNums)], ...
    'YLim', [min(rel_dateNums) max(rel_dateNums)]);

if exportPlots
    if i_p==1
        export_fig(fullfile(outputPath, sprintf('%s-events.png', baseFilename)), ...
            '-transparent', '-m2');
    else
        export_fig(fullfile(outputPath, sprintf('%s-events-norm.png', baseFilename)), ...
            '-transparent', '-m2');
    end
end

colorbar;


% 3D version looks not good
% z_RCN = cell2mat(residual_rcns);
% figure; surf(datetimeTimeInterval,intervals,z_RCN);
% xlabel('Begining of the Interval'); ylabel('Length of the Interval'); zlabel('Reciprocal Condition Number');
% title(sprintf('RCN and Capture time in %s',dayi));
% datetick('x','HH:MM');
% axis tight vis3d

end

function [metric, lengths] = computeMetrics(mlvInterval, normals, dateNums, varargin)
    normalization = 'local';

    rho = 1;
    pctNoise = .01;

    parseVarargin(varargin{:});

    [nbNormals, ~, nbTimeInstances] = size(mlvInterval);

    metric = NaN.*ones(nbTimeInstances, nbTimeInstances, nbNormals);
    lengths = NaN.*ones(nbTimeInstances, nbTimeInstances);

    for t0 = 1:nbTimeInstances
        for t1 = (t0+2):nbTimeInstances
            mlvCur = mlvInterval(:, :, t0:t1);
            % compute max gain on all rows of mlvCur
            [~, metric(t1, t0, :)] = ...
                arrayfun(@(i) computeGains(squeeze(mlvCur(i, :, :)), ...
                'normalization', normalization), ...
                1:size(mlvCur, 1));

            % also save the length
            lengths(t1, t0) = dateNums(t1)-dateNums(t0);
        end
    end
end


function [meanGain, maxGain, condNb] = computeGains(L, varargin)

    normalization = 'local';

    parseVarargin(varargin{:});

    % L = normalizeL(L, 'normalization', normalization);
    % L = double(int32(L*1000));

    s = svd(L,'econ');

    condNb = s(1) / s(3);        % cond
    %         cn2(t1,t0) = s(3) / (s(1)+eps);  % rcond

    meanGain = mean( 1./s(:) );
    maxGain = 1/s(3);           % lambda_max
end


%% ---------------------------close all---------------------------
% Statistic of Sun intensity
function meanInts = statSunIntensities(sunInts,timenums,curtimenum,interval_minutes,charMethod)
    assert(numel(sunInts)==numel(timenums),'image number seems wrong');
    desired_interval = datenum(0, 0, 0, 0, interval_minutes, 0);

    mintime = curtimenum - desired_interval;
    maxtime = curtimenum + desired_interval;
    msk = timenums>= mintime & timenums <= maxtime;

    if strcmpi(charMethod,'mean')
        meanInts = mean(sunInts(msk));
    elseif strcmpi(charMethod,'std')
        meanInts = std(sunInts(msk));
    end
end



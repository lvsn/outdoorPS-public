function [matrixA, validDay] = findMatrixA(matA,lightDb,lightInd,d)
% Constructs the matrixA based on time interval
%
% input:
%   'matA' is pre-computed mean light vectors
%   'lightDb' contains our full database
%   'lightInd' and 'd' are light index and day which were loaded from 'date_x.mat'
%
% output:
%   'matrixA' is the constructed matrixA
%
% This code is used in ICCP15-outdoorPS.
% ----------
%

meanLightStructAllday = matA;

% find that day
day_of_precomputed = num2str(meanLightStructAllday.info.dateValue);
nbImg_of_precomputed = size(meanLightStructAllday.fullSphere,1);

% do we have data in this time interval
if ~any(ismember(d,day_of_precomputed))
    fprintf('no data in this time interval, day: %s',day_of_precomputed);
    matrixA=[];
    return 
end

% find the index to reconstruct the matrix A, find index from all lightDb
allDays = arrayfun(@(l) fileparts(l.stack.file.folder), lightDb.light, 'UniformOutput', false);
validDay = ismember(allDays,day_of_precomputed);
allDay = allDays(validDay);

% assert the index of images in right in pre-computed mean light and db
assert(nbImg_of_precomputed == length(allDay),'seems wrong in the image number');

% find the valid index for this day
ind = lightInd;
validDayInd = validDay(ind);
indDayInterval = ind(validDayInd);
indDayAll = find(validDay>0);
ind_interval = find(ismember(indDayAll, indDayInterval));

% construct the matrixA
matrixA.fullSphere = meanLightStructAllday.fullSphere(ind_interval,:,:);
matrixA.b_ground = meanLightStructAllday.b_ground(ind_interval,:);
matrixA.normal = meanLightStructAllday.normal;

matrixA.condNums = condNum;
matrixA.info = meanLightStructAllday.info;
matrixA.info.index = ind_interval;
matrixA.text = 'by interval';


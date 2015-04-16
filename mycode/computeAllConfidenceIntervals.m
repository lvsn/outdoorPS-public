function confidenceIntervals = computeAllConfidenceIntervals(allMats, allNormals, noise)
% Computes confidence intervals for a lot of normals
%
%   'allMats' must be Tx3xN, where T = #timestamps
%   'allNormals' must be 3xN
%
% This code is used in ICCP15-outdoorPS.
% ----------
% Jean-Francois Lalonde

% Set default noise level
if nargin < 3
    % Default noise level set to 1%
    noise = .01;
end

% check inputs
[~,d,N] = size(allMats);
assert(d==3 && size(allNormals, 1) == 3);
assert(N == size(allNormals, 2));

confidenceIntervals = zeros(1, N);
for i_n = 1:N
    confidenceIntervals(i_n) = analyzeMeanLightVectorMatrix(...
        allMats(:,:,i_n), allNormals(:,i_n), noise);
end

% just set NaN's to very high values
confidenceIntervals(isnan(confidenceIntervals)) = 1000;
confidenceIntervals = real(confidenceIntervals);

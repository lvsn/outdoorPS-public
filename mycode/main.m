% main function to compute and display the sphere for ICCP15-outdoorPS
%
% TODO: Build the illumination from the pre-computed matA.
%       More jobs? (fig. 3 will be shown in this script)
% -----------
%

% locate the sky images
databasePath = '/home-local/yahog.extra.nobkp/www/pictures/master/skycam';
% databasePath = '/home/jacen/laval/lvsn'

% which day will be analysed
dateValue = '20141108'; % '20141108'

% list the raw data
X = getfilenames(fullfile(databasePath,dateValue),'envmap.exr',1,1);

% resize the raw image 
MAPSIZE = 256;

% preparing for computing
nIms = size(X,2);
matA = zeros(nIms,3);

% sample the directions
sphereSize = 3; % 642 vertices
tri = SubdivideSphericalMesh(IcosahedronMesh, sphereSize);
tmp_x = tri.X(:,1)';tmp_y = tri.X(:,2)';tmp_z = tri.X(:,3)';
normal_fullSphere = cat(1,row(tmp_y),row(tmp_z),row(tmp_x));
clear tmp_*

assert(nIms > 0, 'No environment map in the specified folder');
disp('Computing the mean light vectors for a day');

for i_x = 1:nIms
    if mod(i_x,10)==1 && nIms > 30
        fprintf('  computing mean light vector for EnvMap: %d in %d\n', i_x,nIms);
    end
    
	e = EnvironmentMap(X{i_x});
	e = imresize(e, [MAPSIZE, MAPSIZE]);

    % compute the mean light vector
    [matA_fullSphere,b_ground] = findAi(e, normal_fullSphere);
    
    % save the result to a structure
    matA.fullSphere(i_x,:,:) = matA_fullSphere;
    matA.b_ground(i_x,:,:) = b_ground(1,1,:);    
end

% orginaze the result
matA.normal.spheresize = sphereSize;
matA.normal.normal_fullSphere = normal_fullSphere;
matA.info.dateValue = dateValue;
matA.info.imageSize = MAPSIZE;

% save the structure
% resultFilename = fullfile(resultbasePath, sprintf('%s_matA.mat',dateValue));
% save(resultFilename,'matA');

% TODO: We do not have the interval data, try to replace the function
% findMatrixA.m by a simpler method.
% load time interval data
interval = 6;
load(sprintf('data/intervalData/data_%d.mat',interval));
load('data/intervalData/db.mat');

% constructs the illumination matrix
matA = findMatrixA(matA, lightDb, lightInd, d);
if isempty(matA)
    disp('no valid data in this day'); return;
end

% compute the confidence interval
noise =  0.01;
c = computeAllConfidenceIntervals(matA.fullSphere, ...
    matA.normal.normal_fullSphere, noise);

displayConfidenceIntervals(c);






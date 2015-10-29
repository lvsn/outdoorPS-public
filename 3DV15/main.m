% Computes the figures 3-6 in holdgeoffroy_3dv_15
%
% To use this code, please specify the 'databasePath' and 'dateValue'
%
% For example, invoke with:
% main('databasePath', '/home/user/envmaps/', 'dateValue', '20141031');
%
% -----------
%

function [] = main(varargin)

setpath;
% locate the sky images
databasePath = '/home/username/path/to/database';

% which day will be analysed
dateValue = '20131106';

% which plots to generate
doPlotHemisphereMLVs = true;
doPlotMaxUncertaintySphere = false;
doPlotGainIntervals = true;
doPlotSunIntensity = true;


parseVarargin(varargin{:});

%%
% list the raw data
X = getfilenames(fullfile(databasePath, dateValue), 'envmap.exr', 1, 1);

% sample the directions
sphereSize = 3; % 642 vertices
ico = SubdivideSphericalMesh(IcosahedronMesh, sphereSize);
tmp_x = ico.X(:,1)';tmp_y = ico.X(:,2)';tmp_z = ico.X(:,3)';
normal_fullSphere = cat(1,row(tmp_y),row(tmp_z),row(tmp_x));
clear tmp_*

% resize the raw image
MAPSIZE = 256;

matA = cacheFunction(@computeMatA, X, normal_fullSphere, MAPSIZE, dateValue, sphereSize);

%% plot the hemisphere mean light vectors
if doPlotHemisphereMLVs
    
    MLVs = matA.MLVs;
    N = matA.normal;

    % normals bo be drawn in the sphere
    %a = (90:-1:-90)'; N0 = [ 0*a sind(a) -cosd(a) ]; % from Zenith to Nadir
    DEG90 = 90  / 180 * pi; DEG45 = 45  / 180 * pi;
    [a1x, a1y, a1z] = sph2cart(DEG90, -DEG45, 1);
    [a2x, a2y, a2z] = sph2cart(0, -DEG45, 1);
    [a3x, a3y, a3z] = sph2cart(-DEG90, -DEG45, 1);
    N0 = [a1x a1y a1z; a2x a2y a2z; a3x a3y a3z]; % values of fig.3 in 3DV15

    mm = 0.1375; % scale the intensity

    for i = 1:size(N0,1)
        n0 = N0(i,:);
        [~,id] = max( N' * n0(:) );
        Ln = MLVs(:,:,id);
        figure(400+i);
        plotHemisphereMLVs(Ln./mm, n0, 'DISP_ANGLES', 0); drawnow;
    end
end


if doPlotMaxUncertaintySphere
    
end

if doPlotGainIntervals
    plotCorrelationBetweenRcondAndSunInts('matA', matA);
end


if doPlotSunIntensity
    plotSunIntensity('matA', matA);
end

end


function [matA] = computeMatA(X, normal_fullSphere, MAPSIZE, dateValue, sphereSize)

    r = 1; nIms = size(X,2); datetimes = []; sunXYZs = [];
    
    assert(nIms > 0, 'No environment map in the specified folder');
    disp('Computing the mean light vectors for a day');

    for i_x = 1:nIms
        envmap_filename = X{i_x};
        
        % load the environment map
        e = EnvironmentMap(envmap_filename, 'Angular');
        e = imresize(e, [MAPSIZE, MAPSIZE]);

        % select image in the time interval
        xmlInfo = load_xml(strrep(envmap_filename, 'envmap.exr', 'envmap.meta.xml'));
        if isfield(xmlInfo, 'date')
            date = xmlInfo.date;
            envmap_time = datenum(date.year, date.month, date.day, date.hour, date.minute, date.second);
        else
            path_split = strsplit(envmap_filename, filesep);
            date = strcat(path_split(end-2), path_split(end-1));
            envmap_time = datenum(date, 'yyyymmddHHMMSS');
        end

        fprintf('  computing mean light vector for EnvMap: %s\n', datestr(envmap_time,'HH:MM:SS'));
        datetimes = cat(1, datetimes, envmap_time);

        % compute the mean light vector
        MLVs = calcMeanLightVector(e, normal_fullSphere);

        % compute the sun positions
        % fsunXYZs = cat(1,sunXYZs,sunRealPositionFromDateNum(envmap_time));
        
        % compute sun intensity
        [~,sunColor] = brightestSpot(e);
        matA.sunInts(r) = hdr_rgb2gray(sunColor');

        % put the result into a structure    
        matA.MLVs(r,:,:) = MLVs; r = r + 1;
    end

    % structure the result
    matA.normal = normal_fullSphere;
    matA.info.spheresize = sphereSize;
    matA.info.dateValue = dateValue;
    matA.info.datetimes = datetimes;
    matA.info.imageSize = MAPSIZE;
    matA.info.sunXYZ = sunXYZs;

    % save the structure
    %resultFilename = sprintf('%s_matA.mat', dateValue);
    %save(resultFilename,'matA');
end
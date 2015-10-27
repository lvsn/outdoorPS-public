% main function to compute and display the figures in holdgeoffroy_3dv_15
%
% To use this code, please specify the 'databasePath' and 'dateValue'
%
% -----------
%
function  main3DV15(dateValue)
setpath;
% locate the sky images
databasePath = '/home/username/path/to/database';

% which day will be analysed
%dateValue = '20131106'; % '20141108','20141011'

% list the raw data
X = getfilenames(fullfile(databasePath,dateValue),'envmap.exr',1,1);

% sample the directions
sphereSize = 3; % 642 vertices
ico = SubdivideSphericalMesh(IcosahedronMesh, sphereSize);
tmp_x = ico.X(:,1)';tmp_y = ico.X(:,2)';tmp_z = ico.X(:,3)';
normal_fullSphere = cat(1,row(tmp_y),row(tmp_z),row(tmp_x));
clear tmp_*

% resize the raw image 
MAPSIZE = 256;

% preparing for computing 
time_interval_a = '10:30:00';
time_interval_b = '16:30:00';
nIms = size(X,2); r = 1; datetimes = []; sunXYZs = [];

assert(nIms > 0, 'No environment map in the specified folder');
disp('Computing the mean light vectors for a day');

for i_x = 1:nIms
    envmap_filename = X{i_x};
    
    % select image in the time interval
    xmlInfo = load_xml(strrep(envmap_filename,'envmap.exr','envmap.meta.xml'));
    if isfield(xmlInfo, 'date')
        date = xmlInfo.date;
        envmap_time = datenum(date.year, date.month, date.day, date.hour, date.minute, date.second);
    end
    
	if envmap_time - datenum(strcat(dateValue,time_interval_a),'yyyymmddHH:MM:SS') <=0 || ...
        envmap_time - datenum(strcat(dateValue,time_interval_b),'yyyymmddHH:MM:SS') >=0 
        continue;
	end

	fprintf('  computing mean light vector for EnvMap: %s\n', datestr(envmap_time,'HH:MM:SS'));
    datetimes = cat(1,datetimes,envmap_time);
    
    % load the environment map
	e = EnvironmentMap(envmap_filename);
	e = imresize(e, [MAPSIZE, MAPSIZE]);

    % compute the mean light vector
	MLVs = calcMeanLightVector(e, normal_fullSphere);
    
    % compute the sun positions
    % fsunXYZs = cat(1,sunXYZs,sunRealPositionFromDateNum(envmap_time));
    
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
resultFilename = sprintf('%s_matA.mat',dateValue);
save(resultFilename,'matA');

% plot the result
if 0
MLVs = matA.MLVs;
N = matA.normal; 
% Ls = matA.info.sunXYZ;

% normals bo be drawn in the sphere
a = (90:-1:-90)'; N0 = [ 0*a sind(a) -cosd(a) ]; % from Zenith to Nadir
% N0 = [0 .7 -.7; .7 0 -.7; 0 -.8 -.6]; % approximate value of fig.3 in 3DV15

mm = 0.1375; % scale the intensity

for i = 1:size(N0,1)
    n0 = N0(i,:);
    [~,id] = max( N' * n0(:) );
    Ln = MLVs(:,:,id);
    plotHemisphereMLVs(Ln./mm,n0,'DISP_ANGLES',0);  pause(0.1)  
end
end

% main function to compute and display the sphere for ICCP15-outdoorPS
%
% TODO: Build the illumination from the pre-computed matA.
%       More jobs? (fig. 3 will be shown in this script)
% -----------
%

% locate the sky images
databasePath = '/home-local/yahog.extra.nobkp/www/pictures/master/skycam';
% databasePath = '/home/jacen/laval'

% which day will be analysed
dateValue = '20141108'; % '20141108','20141011'

% list the raw data
X = getfilenames(fullfile(databasePath,dateValue),'envmap.exr',1,1);

% sample the directions
sphereSize = 3; % 642 vertices
tri = SubdivideSphericalMesh(IcosahedronMesh, sphereSize);
tmp_x = tri.X(:,1)';tmp_y = tri.X(:,2)';tmp_z = tri.X(:,3)';
normal_fullSphere = cat(1,row(tmp_y),row(tmp_z),row(tmp_x));
clear tmp_*

% resize the raw image 
MAPSIZE = 256;

% preparing for computing
nIms = size(X,2); 
time_interval_a = '10:48:00';
time_interval_b = '16:51:00';
r = 0;

assert(nIms > 0, 'No environment map in the specified folder');
disp('Computing the mean light vectors for a day');

for i_x = 1:nIms
    envmap_filename = X{i_x};
    
    % choose the image base on time interval
    xmlInfo = load_xml(strrep(envmap_filename,'envmap.exr','envmap.meta.xml'));
    if isfield(xmlInfo, 'date')
        date = xmlInfo.date;
        envmap_time = datenum(date.year, date.month, date.day, date.hour, date.minute, date.second);
    end
    
    if envmap_time - datenum(strcat(dateValue,time_interval_a),'yyyymmddHH:MM:SS') <=0 || ...
       envmap_time - datenum(strcat(dateValue,time_interval_b),'yyyymmddHH:MM:SS') >=0 
       continue;
    end
    
    r = r + 1;
    fprintf('  computing mean light vector for EnvMap: %s\n', datestr(envmap_time,'HH:MM:SS'));
    
    % load the environment map
	e = EnvironmentMap(envmap_filename);
	e = imresize(e, [MAPSIZE, MAPSIZE]);

    % compute the mean light vector
    [matA_fullSphere,b_ground] = findAi(e, normal_fullSphere);
    
    % save the result to a structure    
    matA.fullSphere(r,:,:) = matA_fullSphere;
    matA.b_ground(r,:,:) = b_ground(1,1,:);
end

% orginaze the result
matA.normal.spheresize = sphereSize;
matA.normal.normal_fullSphere = normal_fullSphere;
matA.info.dateValue = dateValue;
matA.info.imageSize = MAPSIZE;

% save the structure
% resultFilename = sprintf('%s_matA.mat',dateValue);
% save(resultFilename,'matA');

% compute the confidence interval
noise =  0.01;
c = computeAllConfidenceIntervals(matA.fullSphere, ...
    matA.normal.normal_fullSphere, noise);

displayConfidenceIntervals(c);






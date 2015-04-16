function findCondNum(dateValue, doLoadData, databasePath)
% find the big matrixA and the condition number for specialy day
% input:
%   dateValue (date in numerical)
% output:
%   write back the matA and condition number in a structure
% 
if nargin < 1
    dateValue = 20131113;
end
if nargin < 2
    doLoadData = true; % load And save the envmap in disk
end
if nargin < 3
    databasePath = '/home-local/yahog.extra.nobkp/www/pictures/master/skycam';
end

% setup the path
basePath = fileparts(fileparts(which('compsky.m'))); % barely use the codes in this repo, song
databasePathRaw = fullfile(databasePath);
databasePathMat = fullfile(basePath,'data');
resultbasePath = fullfile(basePath, 'results');

% get the original images/mask data
MAPSIZE = 256;
if doLoadData ==true
    allDataFilename = fullfile(databasePathMat, sprintf('%08d_data_fulldata_sz%d.mat', dateValue,MAPSIZE));
    if(exist(allDataFilename,'file'))
        load(allDataFilename,'X','Xm','mdata');
    else
        [X,Xm,mdata] = loadSkyFullData(fullfile(databasePathRaw, sprintf('%08d', dateValue)),MAPSIZE);
        %[X,Xm,mdata] = loadSkyFullData(databasePath);
        save(allDataFilename,'X','Xm','mdata','-v7.3');
    end
else
    % load the raw data from Victoria-> .../master/skycam
    X = getfilenames(fullfile(databasePathRaw,num2str(dateValue)),'envmap.exr',1,1);
    Xm=[];
end



% generate the normals
% sphereSize = 50 ;
% a full sphere normal, corresponding different orentation walls
% [tmp_x,tmp_y,tmp_z] = sphere(sphereSize);
% validSphere = ones(size(tmp_x));

% uniformly sample sphere
sphereSize = 3; % 3 = 642; 4 = 2562 vertices
tri = SubdivideSphericalMesh(IcosahedronMesh, sphereSize);
tmp_x = tri.X(:,1)';tmp_y = tri.X(:,2)';tmp_z = tri.X(:,3)';
normal_fullSphere = cat(1,row(tmp_y),row(tmp_z),row(tmp_x));% 3-by-n

% pre-compute the TransportImg which is needed in findAi.m -> rendering ground
e = ones(MAPSIZE,MAPSIZE,3);
normal_ground = reshape([0,1,0],1,1,3);
preComputedTransportImg = precomputeTransportImg(e,normal_ground,'envmapFormat','Angular');


% preparing for computing
nIms = size(X,2);
matA = zeros(nIms,3);

assert(nIms > 0, 'Could not find any environment map in the specified folder');
disp('finding matA');

for i_x = 1:nIms
    if mod(i_x,10)==1
        fprintf('computing matrixA for envmaps: %d in %d\n', i_x,nIms);
    end
    if iscell(X)
        e = EnvironmentMap(X{i_x});
    else        
        e = reshape(X(:,i_x),[MAPSIZE,MAPSIZE,3]);
    end
    if ~isempty(Xm)
        validSky = reshape(Xm(:,i_x),[size(e,1),size(e,2)]);
    else
        validSky = ones(size(e,1),size(e,2));
    end
    
    % save the rendered(with ground) full envmap
    envmapFilename = fullfile(resultbasePath,sprintf('envmap_jpg/envmap_%d_%03d.jpg',dateValue,i_x));
    
    % compute the matA for sphere
    [matA_fullSphere,b_ground] = findAi(e,validSky,normal_fullSphere,...
                                            'envmapFilename',envmapFilename,...
                                            'envmapFormat','Angular',...
                                            'preComputedTransportImg',preComputedTransportImg);
    % save the result to the structure
    matA.fullSphere(i_x,:,:) = matA_fullSphere;
    matA.b_ground(i_x,:,:) = b_ground(1,1,:);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	% compute for some vectors, south-zenith-north; round45
%   if computeNormalPoints
%         % 1. south/ front
%         az = pi;         
%         els = linspace(0,pi/2,91);% horizon -> up
%         normal = mysph2cart(az,els);
%         matA_south = findAi(e,validSky,normal);
%       
%         % 2. zenith
%         az = 0; els = pi/2; % up
%         normal = mysph2cart(az,els);
%         matA_zenith = findAi(e,validSky,normal);
%  
%         % 3. north/behind
%         az = 0;         
%         els = linspace(pi/2,0,91);% up -> horizon
%         normal = mysph2cart(az,els);
%         matA_north = findAi(e,validSky,normal);
%         
%         % 4. connection
%         matA_south2north = cat(3,matA_south,matA_zenith,matA_north);
%         matA.south2north(i_x,:,:) = matA_south2north;
%         
%         azs = linspace(0,2*pi,361);
%         el = pi/4; normal=[];
%         for i_az = 1:numel(azs)
%         normal_tmp = mysph2cart(azs(i_az),el);
%         normal = cat(2,normal,normal_tmp);
%         end
%         matA_round = findAi(e,validSky,normal);
%         matA.round45(i_x,:,:) = matA_round;
%   end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

% compute the condition number
nNormalDirections = size(matA.fullSphere,3);
condNum_fullSphere = zeros(1,nNormalDirections);
for i_d = 1:nNormalDirections
    condNum_fullSphere(i_d) = cond(matA.fullSphere(:,:,i_d));
end
% condNum_fullSphere(~validSphere)=NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	if computeNormalPoints
%         nDirections = size(matA.south2north,3);
%         condNum_south2north = zeros(1,nDirections);
%         for i_d = 1:nDirections
%             condNum_south2north(i_d) = cond(matA.south2north(:,:,i_d));
%         end
% 
%         nDirections = size(matA.round45,3);
%         condNum_round45 = zeros(1,nDirections);
%         for i_d = 1:nDirections
%             condNum_round45(i_d) = cond(matA.round45(:,:,i_d));
%         end
%         orginaze the result
%         matA.angle.south2north = [linspace(0,90,91),90,linspace(90,180,91)];
%         matA.angle.round45 = linspace(0,2*pi,361)*180/pi;
%         matA.condNums.south2north = condNum_south2north;
%         matA.condNums.round45 = condNum_round45;
%	end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% orginaze the result
matA.normal.spheresize = sphereSize;
matA.normal.normal_fullSphere = normal_fullSphere;
matA.condNums.fullSphere = condNum_fullSphere;
matA.info.dateValue = dateValue;
matA.info.imageSize = MAPSIZE;

% save the structure
resultFilename = fullfile(resultbasePath, sprintf('%08d_matA.mat',dateValue));
save(resultFilename,'matA');

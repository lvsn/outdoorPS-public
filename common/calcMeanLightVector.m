function IntensVecs = calcMeanLightVector(envmap,normal)
% Computes the mean light vector for normal(s)
%
%   'normal' must be 3xN
%   'IntensVec' reutrns the mean light VECTOR in worldcoordinate
%   'b_ground' returns the color of the rendered ground
%
% This code is used in ICCP15-outdoorPS.
% ----------
%

groundAlbedo = [ 0.148077 0.150000 0.151923 ]'; % used in our paper
envmapWithGround = fillGroundAlbedo(envmap, groundAlbedo);

[xw,yw,zw,validInd] = envmap.worldCoordinates;

%% compute the valid envmap region

% from now on, the full environment map will be in intensity
envmap = envmapWithGround.intensity();

solidAngles = envmap.solidAngles();
validInd = validInd & ~isnan(solidAngles);

solidAngles = solidAngles./sum(solidAngles(validInd)); % normalize so it sums to 1
solidAngles = solidAngles(validInd);

%% compute the visibility 

% not all the sky could be seen by the normal,o nly keep the valid data
normal = normc(normal); 
N = size(normal,2);
xyzw = cat(2, xw(validInd>0), yw(validInd>0), zw(validInd>0)); 
envmapIntensity = envmap.data(validInd);

try
    visibilityN = xyzw * normal > 0;
catch
    visibilityN = [];
end

%% compute the mean vector for the normals
showInfo = N > 2000;
IntensVecs = zeros(1,3,N);

for i_v = 1:N
    if ~isempty(visibilityN)
        visibility = visibilityN(:,i_v);
    else
        visibility = xyzw * normal(:,i_v) > 0;
    end
    xyz_vis = xyzw(visibility, :); 
    intensity_vis = envmapIntensity(visibility);
    solidAngles_vis = solidAngles(visibility);

    % find the light vector and intensity
    meanlight = sum(xyz_vis.*intensity_vis(:, ones(1, 3)).*solidAngles_vis(:, ones(1,3)), 1);
   
    % the mean light vectors should not be normalized, since we want to
    % keep their magnitude. 
    IntensVecs(:,:,i_v) = column(meanlight);
        
    if showInfo
        if mod(i_v,100) == 1
            if i_v == 1
               fprintf('  computing the mean light for %d normals ',N);
            end
            fprintf('.'); 
            if N-i_v < 100
                fprintf('\n');
            end
        end
    end
end

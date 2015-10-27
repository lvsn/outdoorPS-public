function B = renderGround(envmap,ground_normal,varargin)
% Renders the Ground use an environment map
%
% input:
%       'envmap' is the environment map
%       'normal' is a [3-channel matrix]
% output:
%       'B' is the color of the rendered ground 
%
% TODO: 1. simple the ground normal to a vector 2. just keep the
% color-scale
%
% This code is used in ICCP15-outdoorPS.
% ----------
%

[normal_w, normal_h,~] = size(ground_normal);
n = reshape(ground_normal,[] ,3);  

envmapFormat = 'Angular';  % default to our resized envmap

parseVarargin(varargin{:});

if ~isa(envmap,'EnvironmentMap')
    envmap = EnvironmentMap(envmap,envmapFormat);
end

% Light intensity
depth = envmap.nbands;
l = reshape(envmap.data, [], depth); % l is a envmap

% Enviroment properties
envmapDims = size(envmap);
foreshorteningImg = EnvironmentMap(zeros(envmapDims), envmapFormat);

% light direction
[xl, yl, zl, validInd] = foreshorteningImg.worldCoordinates();
solidAngles = foreshorteningImg.solidAngles();

% consider the solid angle
normFactor = solidAngles ./ sum(solidAngles(~isnan(solidAngles)));

% render the ground
nVertices = size(n,1);
rInt = zeros(nVertices,depth);   

for i = 1: nVertices    
    transportImg = max(xl.*n(i,1) + yl.*n(i,2) + zl.*n(i,3), 0);
    transportImg = transportImg.* normFactor;
    % render
    rInt(i,:) = row(transportImg(validInd))*l(validInd, :);    
end

% return the rendered ground 
B = reshape(rInt,normal_w,normal_h,depth);






















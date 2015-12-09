function envmapGround = fillGroundAlbedo(envmap, albedo, varargin)
% Fills the ground with an infinite ground plane of constant albedo
%
% ----------
% Jean-Francois Lalonde

% render the ground
vecGround = [0 1 0]';

[x,y,z,valid] = envmap.worldCoordinates();
solidAngles = envmap.solidAngles();
solidAngles = row(solidAngles(valid));

lightInt = reshape(envmap.data, [], envmap.nbands)';
lightInt = max(lightInt(:, valid), 0);

vecWorld = cat(1, row(x(valid)), row(y(valid)), row(z(valid)));

dotProd = sum(bsxfun(@times, vecGround, vecWorld), 1);
dotProd = bsxfun(@times, dotProd .* solidAngles, lightInt);

b = sum(dotProd(dotProd>=0)) .* (albedo / pi);
b = repmat(permute(b, [3 2 1]), [envmap.nrows, envmap.ncols 1]);

% ground is where the y direction is pointing down
indGround = (y <= 0) & valid;
indGround = indGround(:,:,ones(1, envmap.nbands));

newData = envmap.data;
newData(indGround) = b(indGround);
% let's keep the exposure value around
envmapGround = EnvironmentMap(newData, envmap.format, ...
    'ev', envmap.exposureValue);

function [ output_args ] = plotSphereMaxGain( varargin )
% Plot the maximum gain over the hemisphere for a day
%   Detailed explanation goes here
% N is 3 x nC
% L is nC x 3 x nF
% ts is nF x 1 cell (hour of the day)

matA = [];

Lp0 = [];            % default
fs = [ 0 0 ];       % frames to skip at (beginning, end)

Tm = 0.2; % threshold to discard MLVs that are too dim (%)

parseVarargin(varargin{:});

%%
assert(~isempty(matA), 'this function requires a values for `matA`.');

L = permute(matA.MLVs, [3, 2, 1]);
N = matA.normal;

L0 = L;

% single normal above, or generate sequence of normals for video
if 0
    n0 = normr( n0{2} ); N0 = n0;
else
    %a = (90:-1:-90)'; N0 = [ 0*a sind(a) -cosd(a) ];
    
    %[Zs,N0,mask] = psGenerateSphere([1 1]*64, 80 );
    %N0 = -N0;
    
    t = SubdivideSphericalMesh(IcosahedronMesh, 3);
    N0 = [ t.X(:,3) -t.X(:,1) t.X(:,2) ];
    
    msk = (N0 * [ 0 0 -1 ]') > cosd(87);  % select subset of normals face camera
    N0 = N0(msk,:);
end
nn = size(N0,1);
M = cell(nn,2);    % computed metrics

% ----------------------------------------------------------------------------
tic
for i = 1:nn, n0 = N0(i,:);

    %% initialize MLVs for particular normal
    [~,nh] = max( n0 * N );

    if isempty(Lp0)
        Lp = squeeze( L0(nh,:,:) )';
    else
        Lp = squeeze( L0(nh,:,Lp0) )';          % MLV interval for plane estimation
    end
    % nF x 3 (for single hemisphere/normal)
    L  = squeeze( L0(nh,:,(1+fs(1)):(end-fs(2))) )';
    sz = size(L);

    mag = sqrt(sum(L.^2, 2));
    mm = 0.1375;

    L = L / mm;
    mag = mag / mm;

    % set very dim MLVS to zero or NaN (won't appear in plots)
    L(mag < Tm, :) = NaN;
    
    % If all values are too dim, skip this normal.
    if all(isnan(L))
        M{i,1} = inf;
        continue;
    end

    % ----------------------------------------------------------------------------
    %% Plot MLVs, magnitudes, 3rd components

    % projection on 3rd dimension (out of main plane)
    assert( ~isempty(Lp), 'Need frames to compute solar MLV plane' )

    [~,S,~] = svd( L(all(isfinite(L),2),:), 'econ'); el = S(end);
    el2 = asind( el );        % map to "elevation" in simulation w/ v{1,2,3}

    M{i,1} = el;

end
toc

%% Plot computed metrics on sphere
M0 = nan(nn,1);

for i = 1:nn
    n0 = N0(i,:);
    nae = [ acosd( n0(1) ) acosd( -n0(2) )-90 ]; % (az,el) angles with (X,-Y)-axis
    
    if nae(2) < -80
        M0(i) = 0;
        continue
    end
    
    M0(i) = 1 / (eps + max( abs(M{i,1}) ));
end

%% increase resolution (interpolate KNN)
%K = 20;
K = 6;

t2 = SubdivideSphericalMesh(IcosahedronMesh, 4);
N2 = [ t2.X(:,3) -t2.X(:,1) t2.X(:,2) ];
    
msk2 = (N2 * [ 0 0 -1 ]') > cosd(87);  % select subset of normals face camera
N2 = N2(msk2,:);
nn2 = size(N2,1);
M2 = nan(nn2,1);

for i = 1:nn2, n2 = N2(i,:);
    [~, knn] = sort( N0 * n2', 'descend');
    
    M2(i) = mean( M0( knn(1:K) ) );  % uniform weights
    
    M2(i) = min( M2(i), 12 );
end
t = t2; msk = msk2;


%% final plot
N0 = [ t.X(:,3) -t.X(:,1) t.X(:,2) ];
N0(~msk,:) = NaN;

figure(32), set(gcf,'color',[1 1 1]), subplot('position',[.05 .05 .9 .9]), fcmap = @() jet(128);

rg = [ nanmin(M2) nanmax(M2) ];

mag = (M2 - rg(1)); mag = mag / nanmax(mag);
C = fcmap();
C = C( max(1,round(mag * size(C,1))), : );
C2 = zeros(size(N0)); C2(msk,:) = C;

OPTS = {'EdgeColor','none','FaceColor','interp','FaceVertexCData',C2,'FaceLighting','phong'};

hplot = trimesh( t.Triangulation, N0(:,1), N0(:,2), N0(:,3), OPTS{:} );
view(2), axis equal off; colormap( fcmap() )
 
% circle in complex plane (boundary)
hold on
pt = 0.99 * exp(-1i * (0:(pi/100):(2*pi))); pt(end+1) = pt(1);
plot3( real(pt), imag(pt), zeros(size(pt)), '-k', 'linewidth', 3 )
hold off
FOPTS = {'FontName','Helveltica','FontSize',16,'FontWeight','bold'};

text(-.05,1.1,0, 'Zenith', FOPTS{:})
text(-.05,-1.1,0, 'Nadir', FOPTS{:})
text(-1.15,0,0, 'W', FOPTS{:})
text( 1.03,0,0, 'E', FOPTS{:})
text(-.02,0,10.01, 'S', FOPTS{:}, 'Color','k','FontSize',20)

ax = colorbar('Location','WestOutside'); caxis(rg)

end


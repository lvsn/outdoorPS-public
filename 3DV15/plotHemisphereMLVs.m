function [] = plotHemisphereMLVs( L, n0, varargin )
%function [] = plotHemisphereMLVs( L, n0, varargin )
%
% L is mx3 MLVs matrix

% TODO: add more default parameters here
Ls = [];           % actual sun directions (mx3)
CBAR = 'on';
DISP_ANGLES = 1;
parseVarargin( varargin{:} )

% surf plot options
OPTS_SKY = {'FaceLighting','phong','FaceColor',[20 200 250]/255,'EdgeColor',[0 140 255]/255};
OPTS_HMS = {'FaceLighting','phong','FaceColor',[1 1 1]*.1,'EdgeColor','none'};
OPTS_GND = {'FaceLighting','phong','FaceColor',[1 1 1]*.6,'EdgeColor',[1 1 1]*.4};

FOPTS = {'FontName','Helvetica','FontSize',20,'FontWeight','bold'};

%% (1) plot sky and ground hemispheres
[X,Y,Z] = sphere(24); Z(Z<0) = NaN;
hs = surf(X,-Z,Y, OPTS_GND{:});         % ground hemisphere
hold on
hs = surf(X, Z,Y, OPTS_SKY{:});         % sky hemisphere
axis equal off; 
axis([ -1 1 -1 1 -1 1 ]*1.2)
%xlabel('X'), ylabel('Y'), zlabel('Z')
text(-.05,1.1,0, 'Zenith', FOPTS{:})
text(-.05,-1.1,0, 'Nadir (ground)', FOPTS{:})
text( 1.15,0,0, 'W', FOPTS{:})
text(-1.05,0,0, 'E', FOPTS{:})
text(-.02,0,-1.01, 'S', FOPTS{:})
view(180,-77), zoom(1.25)

%% (2) plot normal and its SHADOW hemisphere (opposite to normal hemisphere)
%scatter3( n0(1)*1.01, n0(2)*1.01, n0(3)*1.01, 100, 'd','filled' )
%arrow3d( n0, 1.25*n0, 20, 'cylinder', [ 0.5 0.3 ])
[hline,hhead] = arrow3d( n0, 1.25*n0, 20, 'cylinder', [ 0.5 0.3 ]);
set(hline(1),'FaceColor','b')
set(hhead(1),'FaceColor','b')
%set(hline(2),'FaceColor','b')
%set(hhead(2),'FaceColor','b')

% use more faces for this hemisphere
[X,Y,Z] = sphere(72); Z(Z > 0) = NaN;
ss = size(X);

% set orientation of normal hemisphere
X = getRotation( n0 ) * (1.01*[ X(:) Z(:) Y(:) ]');
Y = reshape( X(3,:), ss );
Z = reshape( X(2,:), ss );
X = reshape( X(1,:), ss );

% plot normal hemisphere
hs = surf(X,Z,Y, OPTS_HMS{:}); alpha(hs, 0.7)

%% (3) project MLVs onto sphere (unit-length), color-code their intensities
Lt = normr(L) * 1.02;
mag = sqrt(sum(L.^2,2));

C = hot(128); colormap(C)
C = C( max(1,round(min(1,mag) * size(C,1))), : );

scatter3( Lt(:,1), Lt(:,2), Lt(:,3), 16, C, 'o', 'filled' )

% plot actual sun arc if available
if ~isempty(Ls)
    scatter3( Ls([1 end],1), Ls([1 end],2), Ls([1 end],3), 16, 'w', 'o', 'filled' )
    plot3( Ls(:,1), Ls(:,2), Ls(:,3), 'w--', 'linewidth', 2 )
end
hold off
ax = colorbar('Location','WestOutside'); set(gca,'clim',[ 0 1 ]), %set(ax,'Ylabel','test')
set(ax,'visible',CBAR)

% display elevation of normal
if DISP_ANGLES
    % get 2 normal angles
    ae = [ 180-acosd(n0(1)) acosd(-n0(2))-90 ];   % (az,el) angles with (X,-Y)-axis
    
    text(1.4,-.35,-3, texlabel(sprintf('(a,e)=(%2.0f^o,%2.0f^o)',ae)), FOPTS{:})
end

%% -----------------------------------------------------------------------------

function R = getRotation( n0 )

% get 2 normal angles
az = acosd( n0(1) );        % angle with X-axis
%el = acosd(-n0(3) );       % angle with Z-axis
el = acosd( -n0(2) ) - 90;  % angle with Y-axis

Ry = [ cosd(az) 0 -sind(az) ; ...
          0     1      0    ; ...
       sind(az) 0  cosd(az) ];
   
%Rx = [ 1     0        0     ; ...
%       0  cosd(el) sind(el) ; ...
%       0 -sind(el) cosd(el) ];

el = -el;

Rz = [ cosd(el) sind(el) 0 ; ...
      -sind(el) cosd(el) 0 ; ...
          0        0     1 ];

% first rotation aligns the "zenith" of hemispher to the x-axis (West)
Rz90 = [  0  1  0 ; ...
         -1  0  0 ; ...
          0  0  1 ];

%R = Rx*Ry*Rz90;
R = Ry'*Rz*Rz90;

%% -----------------------------------------------------------------------------

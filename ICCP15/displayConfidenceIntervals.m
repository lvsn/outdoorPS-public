function displayConfidenceIntervals(c, varargin)
% This code is used in ICCP15-outdoorPS.
%
% ----------
% Jean-Francois Lalonde

nSubdivs = 3;

parseVarargin(varargin{:});

% compute normals
t = SubdivideSphericalMesh(IcosahedronMesh, nSubdivs);

caxisVal = [0 20];
ax = [];
for i_s = 1:2
    ax(i_s) = subplot(1,2,i_s);
    trimesh(t.Triangulation, t.X(:,1), t.X(:,2), t.X(:,3), c, ...
        'EdgeColor', 'none', 'FaceColor', 'interp');
    axis equal off; caxis(caxisVal);
    colormap(hot(1024));
    
    % add labels
    delta = .1;
    if i_s == 1
        text(-1 - delta, 0, 0, 'S', 'Color', 'w');
    else
        text(1 + delta,  0, 0, 'N', 'Color', 'w');
    end
    text(0, 1 + delta, 0,  'W');
    text(0, -1 - delta, 0, 'E');
    text(0, 0, 1 + delta,  'Zenith');
    text(0, 0, -1 - delta, 'Nadir');

    % shared properties
    set(findall(gca, 'type', 'text'), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 14);

    set(gca, 'CameraViewAngle', 6);
    
    % set view
    if i_s == 1
        view([-90 0]);
    else
        view([90 0]); 
    end
end

set(gcf, 'Position', [560 560 760 380]);

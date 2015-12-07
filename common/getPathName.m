function path = getPathName(varargin)
% Returns path name for the current project
%
%   path = getPathName(str, varargin)
%
% Here, 'varargin' works as in the matlab built-in 'fullfile', i.e. it
% concatenates other strings into paths.
%
%   path = getPathName(local, str, varargin)
%
% 'local' is a boolean variable indicating whether the path should be local
% or networked. Default is local.
%
% See also:
%   fullfile
%
% ----------
% Jean-Francois Lalonde

global projectRootPath
if isempty(projectRootPath)
    error('getPathName:noroot', 'Run ''setPath'' first!');
end

if islogical(varargin{1})
    local = varargin{1};
    % remove from varargin, proceed as normal
    varargin = varargin(2:end);
else
    local = true;
end

str = varargin{1};
varargin = varargin(2:end);

% use path to 'getPathName' to retrieve the base path
basePath = fileparts(fileparts(fileparts(projectRootPath)));

if ~local
    % here we replace the local path to the networked path.
    basePath = strrep(basePath, '/Users', '/Volumes');
end

resultsBasePath = fullfile(basePath, 'results');
dataBasePath = fullfile(basePath, 'data');
codeBasePath = fullfile(basePath, 'code');

% automatically retrieve the project name
[~, projectName] = fileparts(fileparts(projectRootPath));

switch(str)
    case 'codeBase'
        path = codeBasePath;
    
    case 'code'
        path = fullfile(codeBasePath, projectName);
        
    case 'results'
        path = fullfile(resultsBasePath, projectName);
        
    case 'data'
        path = fullfile(dataBasePath, projectName);
        
    case 'logs'
        path = fullfile(basePath, 'logs');
        
    case 'slaves'
        path = getPathName(local, 'results', 'slaves');
        
    otherwise
        error('Invalid option');
end

if ~isempty(varargin)
    path = fullfile(path, varargin{:});
end

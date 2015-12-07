% add the 3rd_party
sdir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(sdir, '3rd_party')));
addpath(genpath(fullfile(sdir, 'common')));

a = strfind(path, '/utils/mycode');
if isempty(strfind(path, '/utils/mycode'))
    rdir = fullfile(fileparts(sdir), 'utils');
    assert(exist(rdir, 'dir') > 0, 'The package `utils` is required.');
    addpath(genpath(fullfile(fileparts(sdir), 'utils')));
end
if isempty(strfind(path, '/hdrutils/mycode'))
    rdir = fullfile(fileparts(sdir), 'hdrutils');
    assert(exist(rdir, 'dir') > 0, 'The package `hdrutils` is required.');
    addpath(genpath(fullfile(fileparts(sdir), 'hdrutils')));
end
if isempty(strfind(path, '/envMapConversions/mycode'))
    rdir = fullfile(fileparts(sdir), 'envMapConversions');
    assert(exist(rdir, 'dir') > 0, 'The package `envMapConversions` is required.');
    addpath(genpath(rdir));
end

clear sdir rdir;
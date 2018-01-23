% write face movie to binary file and then load to do SVDs, projections,
% pupil computations
function h = LumpProc(h)
%
pmovie = 0;
tic;
h.binfile = fullfile(h.binfolder, 'mov.bin');

% make binary file------------------------------- %
fprintf('writing ROIs to binary file\n');
[nframes, avgframe, avgmotion, npix] = WriteBinFile(h);

h.fileframes = nframes;
h.avgframe = avgframe;
h.avgmotion = avgmotion;
h.npix      = npix;

%%
% compute svd ----------------------------- %
h = computeSVDmasks(h);

%%
% get timetraces for U ------------------------------- %
h = projectMasks(h);

%%

saveROI(h);

fprintf('done processing!\n');



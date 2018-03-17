% write face movie to binary file and then load to do SVDs, projections,
% pupil computations
function h = LumpProc(h)
%
pmovie = 0;
tic;
h.binfile = fullfile(h.binfolder, 'mov.bin');

% for compressed files only
% make binary file------------------------------- %
% fprintf('writing ROIs to binary file\n');
% [nframes, avgframe, avgmotion, npix] = WriteBinFile(h);
% h.nframes = nframes;
% h.avgframe = avgframe;
% h.avgmotion = avgmotion;
% h.npix = npix;
% h.wpix = wpix;

% for uncompressed files
h = subsampledMean(h);


keyboard;

%%
% compute svd ----------------------------- %
%h = computeSVDmasks(h);
h = computeSVDmotion(h);

%%
% get timetraces for U ------------------------------- %
h = projectMasks(h);

%%

saveROI(h);

fprintf('done processing!\n');



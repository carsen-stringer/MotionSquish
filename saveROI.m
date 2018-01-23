% if there are multiple blocks, save the processed data for each block
% separately in its own folder

function saveROI(h)

proc.files = h.files;
proc.folders = h.folders;
    
if isfield(h,'motSVD')
    % save processed data
    proc.motSVD   = h.motSVD;
    proc.uMotMask = h.uMotMask;
    if isfield(h,'movSVD')
        proc.movSVD   = h.movSVD;
        proc.uMovMask = h.uMovMask;
    end
    proc.avgframe = h.avgframe;
    proc.avgmotion = h.avgmotion;
end
    
proc.binfolder = h.binfolder;
proc.binfile   = h.binfile;
proc.nX = h.nX;
proc.nY = h.nY;
proc.ROI = h.ROI;
proc.eROI = h.eROI;

proc.saturation = h.saturation;
proc.sc = h.sc;
proc.tsc = h.tsc;
    
[~,fname,~] = fileparts(h.files{1});
%savefile   = fname(6:end);

fname = [fname '.mat'];

%%
savefile = fname;
savepath   = fullfile(h.binfolder, savefile);
h.settings = savepath;
save(savepath,'-v7.3','proc');

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
nt = 5000;
% compute svd ---------------------------------- %
k = 0;
ncomps = 1000;
fprintf('computing SVDs across all movies\n');
nsegs = floor(10000 / (ncomps/2));
if pmovie
    uMov = zeros(sum(npix), nsegs * floor(ncomps/2));
end
uMot = zeros(sum(npix), nsegs * floor(ncomps/2), 'single');
fid = fopen(h.binfile, 'r');
while 1
    fdata = fread(fid,[sum(npix) nt]);
    if isempty(fdata)
        break;
    end
    
    if mod(k, round(nframes/nt/20)) == 0
        if pmovie
            fdata   = single(fdata);
            fdata0  = bsxfun(@minus, fdata, avgframe(:));
            [u s v] = svd(fdata0' * fdata0);
            umov0   = fdata0 * u(:,1:min(floor(ncomps/2),size(u,2)));
            uMov    = cat(2, uMov, umov0);
        end
        
        fdata0  = bsxfun(@minus, abs(diff(fdata,1,2)), avgmotion(:));
        [u s v] = svd(fdata0' * fdata0);
        umot0   = fdata0 * u(:,1:min(floor(ncomps/2),size(u,2)));
        uMot    = cat(2, uMot, umot0);
    end
    k = k+1;
    fprintf('%d / %d done\n',k, round(nframes/nt));
end
fclose(fid);
if pmovie
    [u s v] = svd(uMov'*uMov);
    uMovMask = uMov * u(:,1:min(ncomps,size(u,2)));
    uMovMask = normc(uMovMask);
end

[u s v] = svd(uMot'*uMot);
uMotMask = uMot * u(:,1:min(ncomps,size(u,2)));
uMotMask = normc(uMotMask);
%%
% get timetraces for U ------------------------------- %
ncomps = 1000;
k = 0;
fid = fopen(h.binfile,'r');

frend = zeros(sum(npix),1,'single');
motSVD = zeros(nframes,ncomps,'single');
movSVD = zeros(nframes,ncomps,'single');
ifr = 0;
fprintf('computing time traces\n');
while 1
    fr = fread(fid,[sum(npix) nt]);
    fr = single(fr);
    if isempty(fr)
        break;
    end
    
    frd = abs(diff(cat(2,frend,fr),1,2));
    
    nt = size(fr, 2);
    fr2     = bsxfun(@minus, frd, avgmotion(:));
    motSVD(ifr+[1:nt],:)  = fr2'*uMotMask;
       
    if pmovie
        fr2     = bsxfun(@minus, fr, avgframe(:));
        movSVD(ifr+[1:nt],:) = fr2'*uMovMask;
    end
    
    k=k+1;
    ifr = ifr + nt;
    frend = fr(:,end);
    
    fprintf('%d / %d done\n',k, round(nframes/nt));
    
end

fclose(fid);
%%

save('/media/carsen/SSD/M1_SVDs.mat','-v7.3',...
    'motSVD','uMotMask','h');

fprintf('done processing!\n');

% load face file and compute SVD of motion and/or movie
function h = computeSVDmasks(h)

pmovie = 0;
nt = 2000;
k = 0;

npix = h.npix;
nframes = h.nframes;

ncomps = 500;
fprintf('computing SVDs across all movies\n');
nsegs = floor(10000 / (ncomps/2));
if pmovie
    uMov = zeros(sum(npix), nsegs * floor(ncomps/2));
end
%%
uMot = zeros(sum(npix), nsegs * floor(ncomps/2), 'single');
fid = fopen(h.binfile, 'r');
while 1
    fdata = fread(fid,[sum(npix) nt]);
    if isempty(fdata)
        break;
    end
    
    if rem(round(nframes/nt), nsegs) == 0
        if pmovie
            fdata   = single(fdata);
            fdata0  = bsxfun(@minus, fdata, h.avgframe(:));
            [u s v] = svd(fdata0' * fdata0);
            umov0   = fdata0 * u(:,1:min(floor(ncomps/2),size(u,2)));
            uMov    = cat(2, uMov, umov0);
        end
        
        fdata0  = bsxfun(@minus, abs(diff(fdata,1,2)), h.avgmotion(:));
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
    h.uMovMask = uMovMask
end

[u s v] = svd(uMot'*uMot);
uMotMask = uMot * u(:,1:min(ncomps,size(u,2)));
uMotMask = normc(uMotMask);

h.uMotMask = uMotMask;

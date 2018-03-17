% load face file and compute SVD of motion and/or movie
function h = computeSVDmotion(h)

np = [0 h.npix];
np = cumsum(np);
npix = h.npix;
nframes = h.nframes;
nvids = numel(h.vr);

ncomps = 500;
fprintf('computing SVDs across all movies\n');
nsegs = floor(10000 / (ncomps/2));

nt = 2000;

tf = round(linspace(1,nframes-ncomps,nsegs));

uMot = zeros(sum(npix), nsegs * floor(ncomps/2), 'single');

for j = 1:nsegs
    im0 = zeros(sum(npix),ncomps,'single');
    for k = 1:nvids
        h.vr{k}.CurrentTime = tf(j)-1;
        for t = 1:ncomps
            im = h.vr{k}.readFrame;
            im = im(:,:,1);
            [nx,ny] = size(im);
            ns = h.sc;
            im = squeeze(mean(mean(reshape(single(im(1:floor(nx/ns)*ns,1:floor(ny/ns)*ns)),...
                ns, floor(nx/ns), ns, floor(ny/ns)), 1),3));
            im0(np(k) + [1:npix(k)], t) = im(h.wpix{k}(:));
        end
    end
    
    imot  = bsxfun(@minus, abs(diff(im0,1,2)), h.avgmotion(:));
    [u s v] = svd(gpuArray(imot' * imot));
    u       = gather(u);
    umot0   = imot * u(:,1:min(floor(ncomps/2),size(u,2)));
    uMot    = cat(2, uMot, umot0);    
    
    if mod(j-1,5) == 0
        fprintf('%d / %d done in %2.2f sec\n',j, nsegs, toc);
    end
end


[u s v]  = svd(gpuArray(uMot'*uMot));
u        = gather(u);
uMotMask = uMot * u(:,1:min(ncomps,size(u,2)));
uMotMask = normc(uMotMask);

h.uMotMask = uMotMask;

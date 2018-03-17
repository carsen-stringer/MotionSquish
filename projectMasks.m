function h = projectMasks(h)
%%
ncomps = size(h.uMotMask,2);
%
npix = h.npix;
nframes = h.nframes;
nt0 = 5000;
np = [0 h.npix];
np = cumsum(np);

imend = zeros(sum(npix),1,'single');
motSVD = zeros(nframes,ncomps,'single');
ifr = 0;
fprintf('computing time traces\n');

nvids = numel(h.vr);
for k = 1:nvids
    h.vr{k}.CurrentTime = 0;
end

nsegs = ceil(nframes/nt0);

%uMotMask = gpuArray(h.uMotMask);

for j = 1:nsegs
    for k = 1:nvids
        imb = zeros(npix(k),nt0,'single');
        nt = 0;
        for t = 1:nt0
            if h.vr{k}.hasFrame
                im = h.vr{k}.readFrame;
                im = im(:,:,1);
                [nx,ny] = size(im);
                ns = h.sc;
                im = squeeze(mean(mean(reshape(single(im(1:floor(nx/ns)*ns,1:floor(ny/ns)*ns)),...
                    ns, floor(nx/ns), ns, floor(ny/ns)), 1),3));
                imb(:, t) = im(h.wpix{k}(:));
                nt = nt + 1;
            end
        end
        imb = imb(:,1:nt);
        %disp(k)
        imdiff = abs(diff(cat(2,imend(np(k) + [1:npix(k)]),imb),1,2));
        if j==1
            imdiff(:,1) = imdiff(:,2);
        end
        
        imdiff = bsxfun(@minus, imdiff, h.avgmotion(h.wpix{k}(:)));
        %imdiff = gpuArray(imdiff);
        
        motSVD(ifr+[1:nt],:)  = motSVD(ifr+[1:nt],:) + ...
            gather(imdiff' * h.uMotMask(np(k) + [1:npix(k)],:));
        
        imend(np(k) + [1:npix(k)]) = imb(:,end);
    end
   
    ifr = ifr + nt;
    
    fprintf('%d / %d done in %2.2f\n',j, nsegs,toc);
    
end

h.motSVD = motSVD;

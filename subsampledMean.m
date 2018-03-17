% write face and pupil to binary file
function h = subsampledMean(h)

nframes = h.vr{1}.Duration * h.vr{1}.FrameRate;
nvids = numel(h.nX);
npix = [];
for k = 1:nvids
    h.vr{k}.currentTime = 0;
    nx = floor(h.nX{k}/h.sc);
    ny = floor(h.nY{k}/h.sc);
    h.wpix{k} = false(ny, nx);
    if ~isempty(h.ROI{k}{1})
        for j = 1:numel(h.ROI{k})
            pos = round(h.ROI{k}{j});
            h.wpix{k}(pos(2)-1 + [1:pos(4)], pos(1)-1 + [1:pos(3)]) = 1;
        end
        if ~isempty(h.eROI{k}{1})
            for j = 1:numel(h.eROI{k})
                pos = round(h.eROI{k}{j});
                h.wpix{k}(pos(2)-1 + [1:pos(4)], pos(1)-1 + [1:pos(3)]) = 0;
            end
        end
    else
        h.wpix{k} = true(nx,ny);
    end
    npix(k) = sum(h.wpix{k}(:));
end
    
nf = 2000;
tf = round(linspace(1,nframes-1,nf));
np = [0 npix];
np = cumsum(np);

for j = 1:nf
    im0 = zeros(sum(npix),2,'single');
    
    for k = 1:nvids
        h.vr{k}.CurrentTime = tf(j)-1;
        for t = 1:2
            im = h.vr{k}.readFrame;
            im = im(:,:,1);
            [nx,ny] = size(im);
            ns = h.sc;
            im = squeeze(mean(mean(reshape(single(im(1:floor(nx/ns)*ns,1:floor(ny/ns)*ns)),...
                ns, floor(nx/ns), ns, floor(ny/ns)), 1),3));
            im0(np(k) + [1:npix(k)], t) = im(h.wpix{k}(:));
        end
    end
    im0 = double(im0);
    
    if j==1
        avgframe = zeros(sum(npix),1,'double');
        avgmotion = zeros(sum(npix),1,'double');
    end
    avgframe  = avgframe + sum(im0,2)/2;
    avgmotion = avgmotion + abs(im0(:,2)-im0(:,1));
    
    if mod(j-1, 500) == 0
        fprintf('%d / %d done in %2.2f sec\n',j, nf,toc);
    end
    
end
avgframe = avgframe/nf;
avgmotion = avgmotion/nf;

h.nframes = nframes;
h.avgframe = single(avgframe);
h.avgmotion = single(avgmotion);
h.npix = npix;


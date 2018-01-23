% write face and pupil to binary file
function [tf, avgframe, avgmotion, npix] = WriteBinFile(h)

fid = fopen(h.binfile, 'w');

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
    
tf = 0;
while hasFrame(h.vr{1}) 
    im0 = [];
    for k = 1:nvids
        im = h.vr{k}.readFrame;
        im = mean(im,3);
        [nx,ny] = size(im);
        ns = h.sc;
        im = squeeze(mean(mean(reshape(single(im(1:floor(nx/ns)*ns,1:floor(ny/ns)*ns)),...
            ns, floor(nx/ns), ns, floor(ny/ns)), 1),3));       
        im0 = cat(1,im0, uint8(im(h.wpix{k}(:))));
    end
    fwrite(fid, im0);

    ima = double(im0);
    if tf==0
        avgframe = zeros(size(ima),'double');
        avgmotion = zeros(size(ima),'double');
        ima0 = ima;
    end
    avgframe  = avgframe + ima;
    avgmotion = avgmotion + abs(ima-ima0);
    
    ima0 = ima;
    tf = tf+1;
    if mod(tf,5000)==0
        fprintf('written %d frames\n',tf);
        toc;
    end
end
avgframe = avgframe/tf;
avgmotion = avgmotion/tf;

fclose(fid);

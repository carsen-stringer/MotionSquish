bin = 5;
bm = squeeze(sum(reshape(motSVD(1:floor(size(motSVD,1)/bin)*bin,:), bin, [], 1000),1));

%%
cc = corr(abs(bm));
cc = cc - diag(NaN*diag(cc));

imagesc(cc(1:100, 1:100));

%%

nvids = numel(h.npix);

t0 = 20000;

clf;

%nvids = 1;
NT = 500;
for j = 1:NT
    clf;
    for k = 2
        if j == 1
            h.vr{k}.currentTime = t0;
        end
        im = readFrame(h.vr{k});
        subplot(2, 1, 1),
        imagesc(mean(im,3),[0 100]);
        axis image;
        colormap('gray');
    end

    subplot(2,1,2),
    plot(motSVD(t0*h.vr{1}.FrameRate + [1:NT], 1));
    hold on;
    plot([j j], [-300 -200],'k','linewidth',2);
    hold off;
    
    %hold all;
    axis tight;
    %ylim([-300 -200]);
    drawnow;
    pause(.1);
end

%%
load('/media/carsen/SSD/M1_SVDs.mat');

%%
%h=proc;
nvids = 5;
for k = 1:nvids
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
    
end

%%
np = [0 size(uMotMask,1)];
np = cumsum(np)
ic = ic+1;
clf;
for k = 1:nvids
    i1 = uMotMask(np(k)+[1:size(uMotMask,1)], ic);
    
    ib = zeros(floor(h.nY{k}/h.sc), floor(h.nX{k}/h.sc));
    ib(h.wpix{k}) = i1;
    
    imagesc(ib);
    axis image;
end


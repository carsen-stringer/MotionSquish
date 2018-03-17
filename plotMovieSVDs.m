load('/media/carsen/SSD/cam0_GP6_2018_03_02_1_nf.mat');


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
    h.npix(k) = sum(h.wpix{k}(:));
end

%%
np = [0 h.npix];
np = cumsum(np);
mall=[];
for ic = 1:100
for k = 1:nvids-1
    i1 = uMotMask(np(k)+[1:h.npix(k)], ic);
    
    ib = zeros(floor(h.nY{k}/h.sc), floor(h.nX{k}/h.sc));
    ib(h.wpix{k}) = i1;
    %subplot(1,4,k),
    %imagesc(ib);
    %axis image;
    
    mc{k} = ib;
end
    mall([1:159]+5,1:140,ic) = mc{2}(:,1:140);
    %mall(159+[1:111],1:140,ic) = mc{1}([1:111],20+[1:140]);
    mall([1:85],[1:160]+140,ic) = mc{3}(35+[1:85],20+[1:160]);
    mall([1:85]+85,[1:147]+148,ic) = mc{4}(30+[1:85],:);
    
    mall(:,:,ic) = (mall(:,:,ic) - mean(reshape(mall(:,:,ic),[],1),1))/std(reshape(mall(:,:,ic),[],1));
    
end

%%
clf
vr = VideoWriter('/media/carsen/DATA2/svds.avi');
vr.FrameRate = 1;
open(vr);
set(gcf,'color','w');

clf;
for j = [1:size(mall,3)]
    mc = mall(:,:,j);
    mc = mc - min(mc(:));
    mc = mc/max(mc(:));
    mc0 = max(mean(mc(:))-.5*std(mc(:)), mc);
    mc0 = min(mean(mc(:))+.5*std(mc(:)), mc0);
    mc0 = mc0 - min(mc0(:));
    mc0 = mc0 / max(mc0(:));
    imagesc(mc0);
    writeVideo(vr, mc0);
end

close(vr);
axis image;

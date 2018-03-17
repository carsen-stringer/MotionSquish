% plot full face frame and selected ROI
function PlotFrame(h)

k = h.whichfile;

wROI = h.wROI;

% smoothing constants
sc = h.sc;
tsc = h.tsc;

axes(h.axes1);
%cla;
colormap('gray');

h.vr{k}.currentTime = h.vr{k}.FrameRate * h.cframe;
frame = readFrame(h.vr{k});
       
if size(frame,3) == 3
    isRGB = 1;
else
    isRGB = 0;
end
if isRGB
    frame = rgb2gray(frame);
end

%sat    = min(254,max(1,(h.sat)*255));
   

% all ROIs besides pupil are down-sampled
if sc > 1
    [nY nX nt]  = size(frame);
    nYc = floor(nY/sc)*sc;
    nXc = floor(nX/sc)*sc;
    fr = squeeze(mean(reshape(single(frame(1:nYc,:,:)),sc,nYc/sc,nX,nt),1));
    fr = squeeze(mean(reshape(fr(:,1:nXc,:),nYc/sc,sc,nXc/sc,nt),2));
    
else
    fr = single(frame);
end
   
if h.saturation(k) > 0 
    minsat = max(0, mean(fr(:)) - (1-h.saturation(k) + .05)*2.5*std(fr(:)));
    maxsat = min(255, mean(fr(:)) + (1-h.saturation(k) + .05)*2.5*std(fr(:)));
else
    minsat = min(fr(:));
    maxsat = max(fr(:));
end

fr = uint8(round(fr));

imagesc(fr, [minsat maxsat]);
hold on;
if wROI
    % plot ROIs
    if ~isempty(h.ROI{k}{1})
        for j = 1:numel(h.ROI{k})
            rectangle('position',h.ROI{k}{j},'edgecolor','c','linewidth',2);
        end
    end
    if ~isempty(h.eROI{k}{1})
        for j = 1:numel(h.eROI{k})
            rectangle('position',h.eROI{k}{j},'edgecolor','r','linewidth',2);
        end
    end
else
    cla;
    % apply inclusion / exclusion criterion
    wpix = false(size(fr,1), size(fr,2));
    if ~isempty(h.ROI{k}{1})
        for j = 1:numel(h.ROI{k})
            pos = round(h.ROI{k}{j});
            wpix(pos(2)-1 + [1:pos(4)], pos(1)-1 + [1:pos(3)]) = 1;
        end
        if ~isempty(h.eROI{k}{1})
            for j = 1:numel(h.eROI{k})
                pos = round(h.eROI{k}{j});
                wpix(pos(2)-1 + [1:pos(4)], pos(1)-1 + [1:pos(3)]) = 0;
            end
        end    
        
        fr = max(minsat, single(fr));
        fr = min(maxsat, single(fr));
        fr = (fr - minsat) * (255 / (maxsat-minsat));
        fr = uint8(round(fr));
        
        fr = repmat(fr, 1, 1, 3);
        fr = reshape(fr, [], 3);
        fr(~wpix(:),1) = 255;
        fr(~wpix(:),2) = 1;
        fr(~wpix(:),3) = 1;
        fr = reshape(fr, size(wpix,1), size(wpix,2), 3);
                
        imagesc(fr);
    else
        imagesc(fr, [minsat maxsat]);
    end
    
end
hold off;


indROI = find(h.plotROIs);
hold all;
if ~isempty(indROI)
    for j = indROI'
        rectangle('position',h.locROI{j},'edgecolor',h.colors(j,:),'linewidth',2);
    end
end
axis off;
axis image;
drawnow;

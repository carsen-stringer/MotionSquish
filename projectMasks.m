function h = projectMasks(h)
%%
pmovie = 0;

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
    fr2     = bsxfun(@minus, frd, h.avgmotion(:));
    motSVD(ifr+[1:nt],:)  = fr2' * h.uMotMask;
       
    if pmovie
        fr2     = bsxfun(@minus, fr, h.avgframe(:));
        movSVD(ifr+[1:nt],:) = fr2' * h.uMovMask;
    end
    
    k=k+1;
    ifr = ifr + nt;
    frend = fr(:,end);
    
    fprintf('%d / %d done\n',k, round(nframes/nt));
    
end

fclose(fid);

h.motSVD = motSVD;

if pmovie
    h.movSVD = movSVD;
end
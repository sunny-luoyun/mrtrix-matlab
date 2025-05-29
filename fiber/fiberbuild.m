function [newpath,fodfolder] = fiberbuild(workPath,subFolder,currentPath,startfloder,optiontest,goin,angle,min,max,fod,trytime,fibernum,modetest,roi,mask)
    
    newfolder = sprintf('fiber_%s', ...
        startfloder);
    fodfilepath = fullfile(workPath,startfloder,subFolder);
    outputpath = fullfile(workPath,newfolder,subFolder);
    mkdir(outputpath)

    if strcmp(modetest, '全脑追踪')
    
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack -seed_gmwmi %s/T1_corg/%s/gmwmSeed_coreg.mif -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/wmfod_norm_MNI.mif %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,workPath,subFolder,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,outputpath);
        system(cmd);
    
    elseif strcmp(modetest,'基于种子点')
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack -seed_sphere %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/wmfod_norm_MNI.mif %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,roi,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,outputpath);
        system(cmd);

    elseif strcmp(modetest,'基于mask')
        cmd = sprintf('tckgen -algorithm %s -act %s/T1_corg/%s/5tt_coreg.mif -backtrack -seed_image %s -step %f -angle %d -minlength %d -maxlength %d -cutoff %f -trials %d -select %s %s/wmfod_norm_MNI.mif %s/tracks.tck -force', ... 
            optiontest,workPath,subFolder,mask,goin,angle,min,max,fod,trytime,fibernum,fodfilepath,outputpath);
        system(cmd);

    end
    newpath = outputpath;
    fodfolder = startfloder;
end
function [newpath,newstart] = gibbs(path, name, work, startname)
    newstart = [startname 'G'];
    gibbs = fullfile(work, newstart, name); 
    mkdir(gibbs); % 创建目录
    
    dwigibbs = sprintf('mrdegibbs %s/dwi.mif %s/dwi.mif -force', ... 
        path, gibbs);
    system(dwigibbs);
    
    newpath = gibbs;
    
end
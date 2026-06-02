function step16_log_fdc(workPath, subList)
    templateDir = fullfile(workPath, 'fba', 'template');
    fcDir = fullfile(templateDir, 'fc');
    logFcDir = fullfile(templateDir, 'log_fc');
    fdcDir = fullfile(templateDir, 'fdc');
    mkdir(logFcDir);
    mkdir(fdcDir);
    copyfile(fullfile(fcDir, 'index.mif'), fullfile(logFcDir, 'index.mif'));
    copyfile(fullfile(fcDir, 'directions.mif'), fullfile(logFcDir, 'directions.mif'));
    copyfile(fullfile(fcDir, 'index.mif'), fullfile(fdcDir, 'index.mif'));
    copyfile(fullfile(fcDir, 'directions.mif'), fullfile(fdcDir, 'directions.mif'));
    for i = 1:length(subList)
        sub = subList{i};
        fcFile = fullfile(fcDir, sprintf('%s.mif', sub));
        fdFile = fullfile(templateDir, 'fd', sprintf('%s.mif', sub));
        if exist(fcFile, 'file')
            cmd1 = sprintf('mrcalc %s -log %s/%s.mif -force', fcFile, logFcDir, sub);
            system(cmd1);
        end
        if exist(fcFile, 'file') && exist(fdFile, 'file')
            cmd2 = sprintf('mrcalc %s %s -mult %s/%s.mif -force', fdFile, fcFile, fdcDir, sub);
            system(cmd2);
        end
    end
end

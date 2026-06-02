function step18_connect(workPath, tckParams)
    templateDir = fullfile(workPath, 'fba', 'template');
    cmd = sprintf('fixelconnectivity %s/fixel_mask %s/tracks_%d_sift.tck %s/matrix -force', ...
        templateDir, templateDir, tckParams.select, templateDir);
    system(cmd);
end

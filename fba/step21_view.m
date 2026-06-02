function step21_view(workPath)
    templateDir = fullfile(workPath, 'fba', 'template');
    cmd = sprintf('mrview %s/wmfod_template.mif', templateDir);
    system(cmd);
end

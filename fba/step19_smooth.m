function step19_smooth(workPath, metrics)
    templateDir = fullfile(workPath, 'fba', 'template');
    if ismember('fd', metrics)
        cmd1 = sprintf('fixelfilter %s/fd smooth %s/fd_smooth -matrix %s/matrix -force', ...
            templateDir, templateDir, templateDir);
        system(cmd1);
    end
    if ismember('log_fc', metrics)
        cmd2 = sprintf('fixelfilter %s/log_fc smooth %s/log_fc_smooth -matrix %s/matrix -force', ...
            templateDir, templateDir, templateDir);
        system(cmd2);
    end
    if ismember('fdc', metrics)
        cmd3 = sprintf('fixelfilter %s/fdc smooth %s/fdc_smooth -matrix %s/matrix -force', ...
            templateDir, templateDir, templateDir);
        system(cmd3);
    end
end

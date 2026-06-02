function step20_stats(workPath, designTxt, contrastTxt, nshuffles, cfe_h, cfe_e, cfe_c, metrics)
    templateDir = fullfile(workPath, 'fba', 'template');
    filesTxt = fullfile(templateDir, 'files.txt');
    subDirs = dir(fullfile(workPath, 'fba', 'subjects', 'Sub*'));
    if isempty(subDirs)
        subDirs = dir(fullfile(workPath, 'fba', 'subjects', 'sub*'));
    end
    fid = fopen(filesTxt, 'w');
    for i = 1:length(subDirs)
        fprintf(fid, '%s.mif\n', subDirs(i).name);
    end
    fclose(fid);
    designFile = fullfile(templateDir, 'design_matrix.txt');
    fid = fopen(designFile, 'w');
    fprintf(fid, '%s', designTxt);
    fclose(fid);
    contrastFile = fullfile(templateDir, 'contrast_matrix.txt');
    fid = fopen(contrastFile, 'w');
    fprintf(fid, '%s', contrastTxt);
    fclose(fid);
    if ismember('fd', metrics)
        cmd = sprintf('fixelcfestats %s/fd_smooth %s %s %s %s/matrix %s/stats_fd -nshuffles %d -cfe_h %f -cfe_e %f -cfe_c %f -force', ...
            templateDir, filesTxt, designFile, contrastFile, templateDir, templateDir, nshuffles, cfe_h, cfe_e, cfe_c);
        system(cmd);
    end
    if ismember('log_fc', metrics)
        cmd = sprintf('fixelcfestats %s/log_fc_smooth %s %s %s %s/matrix %s/stats_log_fc -nshuffles %d -cfe_h %f -cfe_e %f -cfe_c %f -force', ...
            templateDir, filesTxt, designFile, contrastFile, templateDir, templateDir, nshuffles, cfe_h, cfe_e, cfe_c);
        system(cmd);
    end
    if ismember('fdc', metrics)
        cmd = sprintf('fixelcfestats %s/fdc_smooth %s %s %s %s/matrix %s/stats_fdc -nshuffles %d -cfe_h %f -cfe_e %f -cfe_c %f -force', ...
            templateDir, filesTxt, designFile, contrastFile, templateDir, templateDir, nshuffles, cfe_h, cfe_e, cfe_c);
        system(cmd);
    end
end

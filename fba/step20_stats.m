function step20_stats(workPath, designTxt, contrastTxt, nshuffles, cfe_h, cfe_e, cfe_c, metrics, subList, exchangeFile, outSuffix)
    templateDir = fullfile(workPath, 'fba', 'template');
    filesTxt = fullfile(templateDir, 'files.txt');

    if nargin < 9, subList = {}; end
    if nargin < 10, exchangeFile = ''; end
    if nargin < 11, outSuffix = ''; end

    if isempty(subList)
        subDirs = dir(fullfile(workPath, 'fba', 'subjects', 'Sub*'));
        if isempty(subDirs)
            subDirs = dir(fullfile(workPath, 'fba', 'subjects', 'sub*'));
        end
        subList = {subDirs.name};
    end
    fid = fopen(filesTxt, 'w');
    for i = 1:length(subList)
        fprintf(fid, '%s.mif\n', subList{i});
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

    excOpt = '';
    if ~isempty(exchangeFile) && exist(exchangeFile, 'file')
        excOpt = sprintf(' -exchangeability %s', exchangeFile);
    end

    outNames = containers.Map();
    outNames('fd') = sprintf('stats_fd%s', outSuffix);
    outNames('log_fc') = sprintf('stats_log_fc%s', outSuffix);
    outNames('fdc') = sprintf('stats_fdc%s', outSuffix);

    metricsList = {'fd', 'log_fc', 'fdc'};
    for k = 1:length(metricsList)
        m = metricsList{k};
        if ~ismember(m, metrics), continue; end
        smoothDir = sprintf('%s_smooth', m);
        cmd = sprintf('fixelcfestats %s/%s %s %s %s %s/matrix %s/%s -nshuffles %d -cfe_h %f -cfe_e %f -cfe_c %f%s -force', ...
            templateDir, smoothDir, filesTxt, designFile, contrastFile, templateDir, templateDir, outNames(m), nshuffles, cfe_h, cfe_e, cfe_c, excOpt);
        system(cmd);
    end
end

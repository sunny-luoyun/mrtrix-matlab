function step2_respmean(workPath, algorithm)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    subDirs = dir(fullfile(fbaSubDir, 'Sub*'));
    if isempty(subDirs)
        subDirs = dir(fullfile(fbaSubDir, 'sub*'));
    end
    fbaDir = fullfile(workPath, 'fba');
    if strcmp(algorithm, 'dhollander')
        cmd1 = sprintf('responsemean');
        for i = 1:length(subDirs)
            cmd1 = sprintf('%s %s/response_wm.txt', cmd1, fullfile(fbaSubDir, subDirs(i).name));
        end
        cmd1 = sprintf('%s %s/group_average_response_wm.txt -force', cmd1, fbaDir);
        system(cmd1);
        cmd2 = sprintf('responsemean');
        for i = 1:length(subDirs)
            cmd2 = sprintf('%s %s/response_gm.txt', cmd2, fullfile(fbaSubDir, subDirs(i).name));
        end
        cmd2 = sprintf('%s %s/group_average_response_gm.txt -force', cmd2, fbaDir);
        system(cmd2);
        cmd3 = sprintf('responsemean');
        for i = 1:length(subDirs)
            cmd3 = sprintf('%s %s/response_csf.txt', cmd3, fullfile(fbaSubDir, subDirs(i).name));
        end
        cmd3 = sprintf('%s %s/group_average_response_csf.txt -force', cmd3, fbaDir);
        system(cmd3);
    else
        cmd = sprintf('responsemean');
        for i = 1:length(subDirs)
            cmd = sprintf('%s %s/response_wm.txt', cmd, fullfile(fbaSubDir, subDirs(i).name));
        end
        cmd = sprintf('%s %s/group_average_response_wm.txt -force', cmd, fbaDir);
        system(cmd);
    end
end

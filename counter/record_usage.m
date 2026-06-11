function record_usage(class, detail)
    counterDir = fileparts(mfilename('fullpath'));
    logFile = fullfile(counterDir, 'usage.mat');

    if exist(logFile, 'file')
        S = load(logFile);
        data = S.data;
    else
        data.total = 0;
        data.modules = struct();
        data.log = struct('time', {}, 'class', {}, 'detail', {});
    end

    data.total = data.total + 1;
    if isfield(data.modules, class)
        data.modules.(class) = data.modules.(class) + 1;
    else
        data.modules.(class) = 1;
    end

    entry.time = datetime('now');
    entry.class = class;
    entry.detail = detail;
    data.log(end+1) = entry;

    save(logFile, 'data');
end

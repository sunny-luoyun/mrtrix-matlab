function Cfg = ROIListDialog()
    fig = uifigure('Name', 'ROI List', ...
        'Position', [400, 300, 520, 380], ...
        'Resize', 'off', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none');

    ROIDef = {};
    ROISelectedIndex = {};

    mainGrid = uigridlayout(fig, [6, 2], ...
        'RowHeight', {'1x', 30, 30, 30, 30, 30}, ...
        'ColumnWidth', {'1x', '1x'}, ...
        'Padding', [10, 10, 10, 10], ...
        'RowSpacing', 6, ...
        'ColumnSpacing', 8);

    listbox = uilistbox(mainGrid, ...
        'Items', {});
    listbox.Layout.Row = 1;
    listbox.Layout.Column = [1, 2];

    btnAddSphere = uibutton(mainGrid, 'push', ...
        'Text', 'Add Sphere', ...
        'ButtonPushedFcn', @(btn, event) addSphere());
    btnAddSphere.Layout.Row = 2;
    btnAddSphere.Layout.Column = 1;

    btnAddMask = uibutton(mainGrid, 'push', ...
        'Text', 'Add Mask', ...
        'ButtonPushedFcn', @(btn, event) addMask());
    btnAddMask.Layout.Row = 2;
    btnAddMask.Layout.Column = 2;

    btnAddSeed = uibutton(mainGrid, 'push', ...
        'Text', 'Add Seed', ...
        'ButtonPushedFcn', @(btn, event) addSeed());
    btnAddSeed.Layout.Row = 3;
    btnAddSeed.Layout.Column = 1;

    btnRemove = uibutton(mainGrid, 'push', ...
        'Text', 'Remove', ...
        'ButtonPushedFcn', @(btn, event) removeROI());
    btnRemove.Layout.Row = 3;
    btnRemove.Layout.Column = 2;

    btnSave = uibutton(mainGrid, 'push', ...
        'Text', 'Save', ...
        'ButtonPushedFcn', @(btn, event) saveROI());
    btnSave.Layout.Row = 4;
    btnSave.Layout.Column = 1;

    btnLoad = uibutton(mainGrid, 'push', ...
        'Text', 'Load', ...
        'ButtonPushedFcn', @(btn, event) loadROI());
    btnLoad.Layout.Row = 4;
    btnLoad.Layout.Column = 2;

    btnClear = uibutton(mainGrid, 'push', ...
        'Text', 'Clear All', ...
        'ButtonPushedFcn', @(btn, event) clearAll());
    btnClear.Layout.Row = 5;
    btnClear.Layout.Column = 1;

    btnOK = uibutton(mainGrid, 'push', ...
        'Text', 'OK', ...
        'ButtonPushedFcn', @(btn, event) okCallback());
    btnOK.Layout.Row = 5;
    btnOK.Layout.Column = 2;

    dummy = uilabel(mainGrid, 'Text', '');
    dummy.Layout.Row = 6;
    dummy.Layout.Column = [1, 2];

    uiwait(fig);

    if isvalid(fig)
        Cfg = guidata(fig);
        delete(fig);
    else
        Cfg = [];
    end

    function updateListbox()
        StringCell = cell(size(ROIDef));
        for i = 1:numel(ROIDef)
            if isnumeric(ROIDef{i})
                s = ROIDef{i};
                StringCell{i} = sprintf('Sphere ( X: %g -- Y: %g -- Z: %g >> Radius: %g )', ...
                    s(1), s(2), s(3), s(4));
            else
                if ~isempty(ROISelectedIndex{i})
                    StringCell{i} = ['[Selected ROI Indices] ', ROIDef{i}];
                else
                    StringCell{i} = ['[All ROI Indices] ', ROIDef{i}];
                end
            end
        end
        listbox.Items = StringCell;
        if ~isempty(StringCell)
            listbox.Value = StringCell{end};
        end
    end

    function addSphere()
        SphereCell = w_AddSphere_gui_local();
        if isempty(SphereCell)
            return
        end
        [ROIDef, RepeatFlags] = GetROICell(SphereCell, ROIDef);
        SphereCell(RepeatFlags) = [];
        if ~isempty(SphereCell)
            ROISelectedIndex = [ROISelectedIndex; cell(length(SphereCell), 1)];
            updateListbox();
        end
    end

    function addMask()
        [Name, Path] = uigetfile(...
            {'*.img;*.nii;*.nii.gz;*.gii', 'Brain Image Files (*.img;*.nii;*.nii.gz;*.gii)'; '*.*', 'All Files (*.*)'}, ...
            'Pick the Mask file', 'MultiSelect', 'on');
        if isnumeric(Name)
            return
        end
        if ischar(Name)
            Name = {Name};
        end
        Name = Name';
        PathCell = cellfun(@(name) fullfile(Path, name), Name, 'UniformOutput', false);
        [ROIDef, RepeatFlags] = GetROICell(PathCell, ROIDef);
        PathCell(RepeatFlags) = [];
        ROISelectedIndex = [ROISelectedIndex; cell(length(PathCell), 1)];
        if ~isempty(PathCell)
            updateListbox();
        end
    end

    function addSeed()
        [Name, Path] = uigetfile(...
            {'*.txt;*.csv;*.tsv', 'Seed Series File (*.txt;*.csv;*.tsv)'; '*.*', 'All Files (*.*)'}, ...
            'Pick the Seed Series for ROI', 'MultiSelect', 'on');
        if isnumeric(Name)
            return
        end
        if ischar(Name)
            Name = {Name};
        end
        Name = Name';
        PathCell = cellfun(@(name) fullfile(Path, name), Name, 'UniformOutput', false);
        [ROIDef, RepeatFlags] = GetROICell(PathCell, ROIDef);
        PathCell(RepeatFlags) = [];
        ROISelectedIndex = [ROISelectedIndex; cell(length(PathCell), 1)];
        if ~isempty(PathCell)
            updateListbox();
        end
    end

    function removeROI()
        if isempty(listbox.Items)
            return
        end
        idx = find(strcmp(listbox.Value, listbox.Items));
        if isempty(idx)
            return
        end
        ROIDef(idx) = [];
        ROISelectedIndex(idx) = [];
        updateListbox();
    end

    function saveROI()
        [Name, Path] = uiputfile('ROI_List.mat', 'Save ROI List as');
        if isnumeric(Name)
            return
        end
        FilePath = fullfile(Path, Name);
        CfgSave.ROIDef = ROIDef;
        CfgSave.ROISelectedIndex = ROISelectedIndex;
        save(FilePath, '-struct', 'CfgSave');
    end

    function loadROI()
        [Name, Path] = uigetfile(...
            {'*.mat', 'ROI List (*.mat)'; '*.*', 'All Files (*.*)'}, ...
            'Pick ROI List');
        if isnumeric(Name)
            return
        end
        FilePath = fullfile(Path, Name);
        CfgLoad = load(FilePath);
        if isfield(CfgLoad, 'Cfg')
            CfgLoad = CfgLoad.Cfg;
        end
        if ~isfield(CfgLoad, 'ROIDef')
            ROIDef = {};
        else
            ROIDef = CfgLoad.ROIDef;
        end
        if ~isfield(CfgLoad, 'ROISelectedIndex')
            ROISelectedIndex = {};
        else
            ROISelectedIndex = CfgLoad.ROISelectedIndex;
        end
        if ~iscell(ROIDef)
            ROIDef = {ROIDef};
        end
        if ~iscell(ROISelectedIndex)
            ROISelectedIndex = {ROISelectedIndex};
        end
        updateListbox();
    end

    function clearAll()
        ROIDef = {};
        ROISelectedIndex = {};
        updateListbox();
    end

    function okCallback()
        CfgOut.ROIDef = ROIDef;
        CfgOut.ROISelectedIndex = ROISelectedIndex;
        guidata(fig, CfgOut);
        uiresume(fig);
    end
end

function [ROICellOut, RepeatFlags] = GetROICell(PathCell, ROICell)
    RepeatFlags = false(size(PathCell));
    for i = 1:numel(PathCell)
        if isnumeric(PathCell{i})
            continue
        end
        flag = find(strcmpi(PathCell{i}, ROICell) > 0, 1);
        if ~isempty(flag)
            RepeatFlags(i) = true;
        end
    end
    PathCell(RepeatFlags) = [];
    ROICellOut = [ROICell; PathCell];
end

function SphereCell = w_AddSphere_gui_local()
    dlg = uifigure('Name', 'Add Sphere', ...
        'Position', [500, 400, 380, 200], ...
        'Resize', 'off', ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none', ...
        'Toolbar', 'none');

    grid = uigridlayout(dlg, [5, 3], ...
        'RowHeight', {30, 30, 30, 10, 35}, ...
        'ColumnWidth', {80, '1x', 80}, ...
        'Padding', [10, 10, 10, 10], ...
        'RowSpacing', 6, ...
        'ColumnSpacing', 8);

    labelXYZ = uilabel(grid, 'Text', 'X Y Z Radius:', ...
        'HorizontalAlignment', 'right');
    labelXYZ.Layout.Row = 1;
    labelXYZ.Layout.Column = 1;

    editCoord = uieditfield(grid, 'text', ...
        'Value', '', ...
        'Placeholder', 'e.g. 10 20 30 5');
    editCoord.Layout.Row = 1;
    editCoord.Layout.Column = [2, 3];

    labelFormat = uilabel(grid, 'Text', 'Format:', ...
        'HorizontalAlignment', 'right');
    labelFormat.Layout.Row = 2;
    labelFormat.Layout.Column = 1;

    btnGroup = uibuttongroup(grid);
    btnGroup.Layout.Row = 2;
    btnGroup.Layout.Column = [2, 3];
    radioTal = uiradiobutton(btnGroup, ...
        'Text', 'Talairach', ...
        'Position', [10, 5, 80, 20]);
    radioMNI = uiradiobutton(btnGroup, ...
        'Text', 'MNI', ...
        'Position', [100, 5, 60, 20], ...
        'Value', true);

    labelHint = uilabel(grid, 'Text', '(Each row: X Y Z Radius)', ...
        'FontSize', 11, ...
        'FontColor', [0.5, 0.5, 0.5]);
    labelHint.Layout.Row = 3;
    labelHint.Layout.Column = [1, 3];

    btnAccept = uibutton(grid, 'push', ...
        'Text', 'Accept');
    btnAccept.Layout.Row = 5;
    btnAccept.Layout.Column = 2;

    btnCancel = uibutton(grid, 'push', ...
        'Text', 'Cancel');
    btnCancel.Layout.Row = 5;
    btnCancel.Layout.Column = 3;

    SphereCell = {};

    btnAccept.ButtonPushedFcn = @(btn, event) acceptCallback();
    btnCancel.ButtonPushedFcn = @(btn, event) cancelCallback();

    uiwait(dlg);

    if isvalid(dlg)
        delete(dlg);
    end

    function acceptCallback()
        CoordMat = str2num(editCoord.Value);
        if isempty(CoordMat)
            uialert(dlg, 'Please input valid coordinates (X Y Z Radius per row).', 'Invalid Input');
            return
        end
        if size(CoordMat, 2) < 4
            uialert(dlg, 'Each row must have at least 4 values: X Y Z Radius.', 'Invalid Input');
            return
        end
        CoordMat = CoordMat(:, 1:4);
        if radioTal.Value
            for row = 1:size(CoordMat, 1)
                coord = CoordMat(row, :);
                mniCoord = utils_tal2icbm_spm(coord(1:3)');
                CoordMat(row, 1:3) = mniCoord(1:3)';
            end
        end
        CoordCell = num2cell(CoordMat, 2);
        SphereCell = CoordCell;
        uiresume(dlg);
    end

    function cancelCallback()
        uiresume(dlg);
    end
end

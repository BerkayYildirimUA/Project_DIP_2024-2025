function closeAllWaitbars()
allFigures = findall(0, 'Type', 'figure');

for i = 1:length(allFigures)
    if isfield(get(allFigures(i)), 'Tag') && strcmp(get(allFigures(i), 'Tag'), 'TMWWaitbar')
        delete(allFigures(i));
    end
end

disp('All waitbars closed (if any were open).');
end
function dispDateBreakdown(source,event)
    disp(event.Source.Tag)
%     keyboard
    pos = get(gcf, 'Position');
    h = findobj(gcf, 'type', 'uicontrol');
        delete(h)
    DateInfo = uicontrol('style','text',...
            'String', event.Source.Tag,...
            'Position', [pos(3)/2 pos(4)/8 110 45]);
end

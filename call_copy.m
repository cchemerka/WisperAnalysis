function call_copy()

cm=get(gcf,'colormap'); 
cf=get(gcf,'color')

copyobj(gca,figure)
set(gca,'Position',[0.13 0.11 0.775 0.815]);
set(gca,'ButtonDownFcn','');
h_child=get(gca,'Children');
set(h_child,'ButtonDownFcn','');
set(gcf,'colormap',cm)
set(gcf,'color',cf)

if strcmp(get(h_child(1),'Type'),'surface');
    colorbar;
end;

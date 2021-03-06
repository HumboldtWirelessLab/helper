function grapheditaboutdialog(varargin)
%DIALOG ABOUT for Graphedit. 
%   This file is part of Scheduling Toolbox.
%

%   Author: V. Navratil
%   Created in terms of Bachelor project 2006
%   Department of Control Engineering, FEE, CTU Prague, Czech Republic
%


    h = dialog('ButtonDownFcn','','Visible','off','Tag','about','Name','About');

    im = imread('private/grapheditclock.jpg');
    [height,width,x] = size(im);
    
    positionDialog = tocenter(width,height);
    positionAxes = [15 44 width height];  
    
    image(im);
    set(gca,'Visible','off','Units','pixels','Position',positionAxes);      
 
    uicontrol('Parent',h,'Style','text','FontSize',7,...
        'String','For opening web page click to some text in picture.',...
        'Position',[15 10 340 18],'HorizontalAlignment','left');
    uicontrol('Parent',h,'Style','pushbutton','String','Close',...
        'Position',[positionDialog(3)-100 10 80 24],'Callback',{@delete,h});
    set(h,'WindowStyle','modal','Position',positionDialog,'Visible','on');
        
    settext(gca);
    
    
function settext(hAxes)
    blue = [63 120 255]/255;
    
    t = text(10,15,'Department of Control Engineering');
    set(t,...
        'Color',blue,...  
        'ButtonDownFcn','web http://dce.felk.cvut.cz -browser',...
        'FontUnits','Pixels',...
        'FontAngle','italic',...
        'FontSize',13,...
        'FontWeight','bold',...
        'FontName','Arial');
    t = text(10,33,'Faculty of Electrical Engineering, CTU Prague, Czech Republic');
    set(t,...
        'Color',blue,...
        'ButtonDownFcn','web http://www.fel.cvut.cz -browser',...
        'FontUnits','Pixels',...
        'FontAngle','italic',...
        'FontSize',13,...
        'FontName','Arial');

    t = text(78,88,'Graphedit');
    set(t,...
        'Color',blue,... %       'FontAngle','italic',...
        'FontUnits','Pixels',...
        'FontSize',50,...
        'FontWeight','bold',...
        'FontName','Arial');

    t = text(390,160,sprintf('TORSCHE Scheduling Toolbox\nfor Matlab'));
    set(t,...
        'Color',blue,...
        'ButtonDownFcn','web http://rtime.felk.cvut.cz/scheduling-toolbox/ -browser',...
        'FontUnits','Pixels',...
        'HorizontalAlignment','right',...
        'FontSize',24,...
        'FontWeight','bold',...
        'FontName','Arial');
    
    t = text(390,226,sprintf('Vojtech Navratil,'));
    set(t,...
        'Color',blue,...
        'HorizontalAlignment','right',...
        'FontUnits','Pixels',...
        'FontAngle','italic',...
        'FontSize',13,...
        'FontWeight','bold',...
        'FontName','Arial');
%     t = text(390,227,sprintf('Bachelor Project,'));
%     set(t,...
%         'Color',blue,...
%         'HorizontalAlignment','right',...
%         'FontUnits','Pixels',...
%         'FontAngle','italic',...
%         'FontSize',13,...
%         'FontWeight','bold',...
%         'FontName','Arial');
    t = text(390,244,sprintf('mailto: navrav1@fel.cvut.cz'));
    set(t,...
        'Color',blue,...
        'ButtonDownFcn','web mailto:navrav1@fel.cvut.cz',...
        'FontUnits','Pixels',...
        'HorizontalAlignment','right',...
        'FontAngle','italic',...
        'FontSize',13,...
        'FontName','Arial');
   
%    web http://www.mathworks.com -browser
%    web mailto:email_address

    
function position = tocenter(width,height)
    monitor = get(0,'ScreenSize');
    position(3) = width + 30;
    position(4) = height + 54;
    position(1) = monitor(1) + (monitor(3)-position(3)) / 2;
    position(2) = monitor(2) + (monitor(4)-position(4)) / 2;

    
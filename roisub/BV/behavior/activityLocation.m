function [] = activityLocation(mleft,totalDistIncm,VelocityIncms,percPause,percOutside)
global v
global d

%plots location of mouse while specified cells are active
printyn=1; %for printing figures
x=zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),size(d.ROImeans,2));
xts=[];
for j=1:size(d.ROImeans,2)
    n=0;
    c=0;
    a=0;
    threshold=5*median(abs(d.ROImeans(:,j))/0.6745);
    ArrowCoord=[];
    for k=1:floor(length(v.traceA)/round(length(v.traceA)/size(d.ROImeans,1),2))
        if v.Pspot==0
            if d.ROImeans(k,j)>threshold  && v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)>0 %quiroga spike detection
                c=c+1;
                a=a+1;
                x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)=x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)+1;
                xts(c,j)=k/d.framerate; %#ok<*AGROW>
            elseif d.ROImeans(k,j)>threshold  && v.traceA(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)==0 %>=0.6
                n=n+1;
                xts(c,j)=k/d.framerate;
            end
        else
            if d.ROImeans(k,j)>threshold  && v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)>0 && v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)>0 %quiroga spike detection
                c=c+1;
                a=a+1;
                ArrowCoord{a,j}=[v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1);v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2) v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)];
                x(round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2)),round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)),j)=x(round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2)),round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)),j)+1;
                x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)=x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)+1;
                xts(c,j)=k/d.framerate;
            elseif d.ROImeans(k,j)>threshold  && v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)>0 && v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)==0 %>=0.6
                x(round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2)),round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)),j)=x(round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),2)),round(v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)),j)+1;
                c=c+1;
                xts(c,j)=k/d.framerate;
            elseif d.ROImeans(k,j)>threshold  && v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)==0 && v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)>0 %>=0.6
                x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)=x(round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),2)),round(v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)),j)+1;
                c=c+1;
                xts(c,j)=k/d.framerate;
            end
            if d.ROImeans(k,j)>threshold && (v.traceA(round(k*round(length(v.traceA)/size(d.ROImeans,1),2)),1)==0 && v.traceP(round(k*round(length(v.traceP)/size(d.ROImeans,1),2)),1)==0) %>=0.6
                n=n+1;
            end
        end
    end
    %plot cell activity
    h=figure(4+j); image(v.imd(1).cdata); hold on;
    string=sprintf('ROI No.%d',j);
    title(string);
    cellactive=imresize(imresize(x,0.25),4);
    colormap(jet);grid=imagesc(cellactive(:,:,j));cb=colorbar;cb.Label.String = 'Relative position distribution';
    set(gcf,'renderer','OpenGL');
    alpha(grid,0.75);
    %display how many percent mouse was registered out of bounds
    OoB=round(100*(n/(n+c)));
    str=sprintf('Cell fires when mouse is out of bounds in %d percent of cases',OoB);
    if mleft==0
        text(20,20,str,'Color','r');
    end
    % plot direction
    if v.Pspot==1
        drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:});
        for  k=1:size(ArrowCoord,1)
            drawArrow([ArrowCoord{k,j}(1,1) ArrowCoord{k,j}(1,2)],[ArrowCoord{k,j}(2,1) ArrowCoord{k,j}(2,2)],'MaxHeadSize',5,'LineWidth',1,'Color',[1 0 0]);
        end
        hold off;
    end
    %saving plots
    if printyn==1
        name=sprintf('ROI%d_trace',j);
        path=[d.pn '/location/',name,'.png'];
        path=regexprep(path,'\','/');
        print(h,'-dpng','-r100',path); %-depsc for vector graphic

        %saving table
        T=table(totalDistIncm,VelocityIncms,percPause,percOutside);
        filename=[d.pn '\location\' d.fn(1:end-4) 'behavior.xls'];
        writetable(T,filename);

        %saving positions at ROIs
        filename=[d.pn '\location\ROIposition'];
        field1='ROIposition';
        field2='ts';
        value1{j,1}=x;
        value2{j,1}=xts;
        Positions=struct(field1,value1,field2,value2);
        OutofBounds=OoB;
        save(filename, 'Positions','OutofBounds');
    end
end
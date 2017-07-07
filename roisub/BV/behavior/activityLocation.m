function [] = activityLocation(mleft,totalDistIncm,VelocityIncms,percPause,percOutside)

% FUNCTION  for plotting the location of the mouse during neuronal activity.
%           It takes the spikes detected with the deconvolution of the
%           calcium signal and plots the location to the time that the
%           spike occured. If two color spots on the mouse were tracked, an
%           arrow pointing from butt to head will be plotted along as well.
%           Additionally, a table will be saved with the statistics of
%           total travelled distance, mean velocity, resting, and out of
%           view.
% 
% INPUT     mleft: value of 0 (mouse did leave the testing area) or 1
%           (mouse did not leave the testing area)
%           totalDistincm: total distance travelled by the mouse in cm.
%           VelocityIncms: mean velocity of the mouse in cm/s
%           percPause: percentage of the time the mouse rested.
%           percOutside: percentage of the time the mouse was out of view.


global v
global d

%getting timestamps from spikes from calcium traces
ts=cell(1,size(d.ROImeans,2));
for k=1:size(d.ROImeans,2)
    ts{:,k}=find(d.spikes(:,k));
end

%plots location of mouse while specified cells are active
printyn=1; %for printing figures
x=zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),size(d.ROImeans,2));
for j=1:size(d.ROImeans,2)
    ArrowCoord=[];
    if v.Pspot==0
        position=round(v.traceA(ts{1,j},:));
        n=numel(find(position==0))/2;
        c=length(ts{1,j})-n;
        for k=1:length(ts{1,j})
            x(position(k,2),position(k,1),j)=x(position(k,2),position(k,1),j)+1;
        end
    else
        %anterior
        positionA=round(v.traceA(ts{1,j},:));
        for k=1:length(ts{1,j})
            x(positionA(k,2),positionA(k,1),j)=x(positionA(k,2),positionA(k,1),j)+1;
        end
        %posterior
        positionP=round(v.traceP(ts{1,j},:));
        n=(numel(find(positionA==0))+numel(find(positionP==0)))/2; %none >0
        c=length(ts{1,j})-n; %one of the spots or both >0
        a=0;
        for k=1:length(ts{1,j})
            x(positionP(k,2),positionP(k,1),j)=x(positionP(k,2),positionP(k,1),j)+1;
            if positionA(k,1)>0 && positionP(k,1)>0
                a=a+1;
                ArrowCoord{a,j}=[positionP(k,2) positionA(k,2);positionP(k,1) positionA(k,1)];
            end
        end
    end
    %plot cell activity
    h=figure(4+j); image(v.imd(1).cdata); hold on;
    string=sprintf('ROI No.%d',j);
    title(string);
    cellactive=imresize(imresize(x(:,:,j),0.25),4);
    colormap(jet);grid=imagesc(cellactive);cb=colorbar;cb.Label.String = 'Relative position distribution';
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
            drawArrow([ArrowCoord{k,j}(2,1) ArrowCoord{k,j}(2,2)],[ArrowCoord{k,j}(1,1) ArrowCoord{k,j}(1,2)],'MaxHeadSize',5,'LineWidth',1,'Color',[1 0 0]);
        end
        hold off;
    end
    %saving plots
    if printyn==1
        fname=sprintf('ROI%d_trace',j);
        ffname=[d.name '_' fname];
        path=[d.pn '/location/',ffname,'.png'];
        path=regexprep(path,'\','/');
        print(h,'-dpng','-r100',path); %-depsc for vector graphic

        %saving table
        T=table(totalDistIncm,VelocityIncms,percPause,percOutside);
        filename=[d.pn '\location\' d.name '_behavior.xls'];
        writetable(T,filename);

        %saving positions at ROIs
        filename=[d.pn '\location\ROIposition_' d.name];
        field1='ROIposition';
        field2='ts';
        value1{j,1}=x;
        value2{j,1}=ts';
        Positions=struct(field1,value1,field2,value2);
        OutofBounds=OoB;
        save(filename, 'Positions','OutofBounds');
    end
    close(h);
end
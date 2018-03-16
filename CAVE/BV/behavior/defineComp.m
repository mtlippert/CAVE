function [cood] = defineComp

% FUNCTION for defining copmartments/ROIs in the testing arena.
% 
% OUTPUT    cood: coordinates of the ROIs

global d
global v
global p

%defining compartments
%check whether compartments have been imported
if p.import==1
    %loop of selecting compartments, giving names and calculations
        perccomp=zeros(1,p.amount);
        for k=1:p.amount
            %calculating amount of time the mouse (the head) was in a compartment in percent
            [y,x]=find(p.ROImask(:,:,k)>0);
            cood=[x,y];
                traceAround=round(v.traceAplot); %coordinates of head of the mouse over time
                combi=[];
                for j=1:length(cood)
                    cood1=find(traceAround(:,1)==cood(j,1));
                    cood2=find(traceAround(:,2)==cood(j,2));
                    coodf=ismember(cood1,cood2).*cood1;
                    coodf=coodf(coodf>0);
                    combi=[combi;coodf];
                end
                numpixel=length(combi);
                perccomp(1,k)=round(numpixel/length(v.traceA)*100,2); %percent in regards to the whole time
                %calculating calcium activity within compartment
                totalspk=sum(d.spikes,2);
                evrate(1,k)=sum(totalspk(combi))/(length(combi)/d.framerate);
                Compartments.(char(name{1,k})) = evrate(1,k);
        end
        %saving image
        if v.Pspot==1
            a=figure; image(v.imd(1).cdata); hold on;
            plot(v.tracePplot(:,1),v.tracePplot(:,2),v.colorP);
            %plotting anterior trace
            plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA);
        else
            a=figure; image(v.imd(1).cdata); hold on;
            %plotting anterior trace
            plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA);
        end
        for j=1:amount
            boundary = bwboundaries(ROImask(:,:,j));
            plot(boundary{1,1}(:,2),boundary{1,1}(:,1),'w','LineWidth',2);
            stats=regionprops(ROImask(:,:,j), {'Centroid'});
            c=round(stats.Centroid);
            text(c(1),c(2),num2str(perccomp(1,j),2),'Color','white','FontSize',14);
            text(c(1),c(2)-10,num2str(evrate(1,j),2),'Color','green','FontSize',14);
        end
        fname=sprintf('arena_ROIs');
        ffname=[cell2mat(d.name) '_' fname];
        path=[d.pn '/location/',ffname,'.png'];
        path=regexprep(path,'\','/');
        print(a,'-dpng','-r100',path); %-depsc for vector graphic
        %saving table
        T=struct2table(Compartments);
        filename=[d.pn '\location\' cell2mat(d.name) '_compartments.xls'];
        writetable(T,filename);
        %saving tracing ROIs
        filename=[d.pn '\tracingROIs_' cell2mat(d.name)];
        save(filename, 'amount','name','ROImask');
else
    %question if
    % Construct a questdlg with two options
    choice = questdlg('Would you like to define regions of interest?', ...
        'Attention', ...
        'Yes','No','No');
    % Handle response
    if isempty(choice)==1
        cood=[];
        return;
    end
    switch choice
        case 'Yes'
            %question how many
            prompt = {'How many?'};
            dlg_title = 'Amount';
            num_lines = 1;
            answer = inputdlg(prompt,dlg_title,num_lines);
            if isempty(answer)==1
                cood=[];
                return;
            end
            amount=str2num(cell2mat(answer));
            %loop of selecting compartments, giving names and calculations
            perccomp=zeros(1,amount);
            name=cell(1,amount);
            ROImask=zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),amount);
            for k=1:amount
                %selecting ROI
                figure,image(v.imd(1).cdata);
                str=sprintf('Define ROI No. %d',k);
                title(str);
                if p.help==1
                    str=sprintf('Please define compartment No. %d by clicking around the area!',k);
                    uiwait(msgbox(str,'Attention'));
                end
                ROI=roipoly;
                ROImask(:,:,k)=ROI;
                %name of ROI
                prompt = {'What do you want to call it? (Without using spaces!)'};
                dlg_title = 'Names';
                num_lines = 1;
                answer = inputdlg(prompt,dlg_title,num_lines);
                if isempty(answer)==1
                    cood=[];
                    return;
                end
                name{1,k}=answer;
                close(gcf);
                %calculating amount of time the mouse (the head) was in a compartment in percent
                [y,x]=find(ROI>0);
                cood=[x,y];
                traceAround=round(v.traceAplot); %coordinates of head of the mouse over time
                combi=[];
                for j=1:length(cood)
                    cood1=find(traceAround(:,1)==cood(j,1));
                    cood2=find(traceAround(:,2)==cood(j,2));
                    coodf=ismember(cood1,cood2).*cood1;
                    coodf=coodf(coodf>0);
                    combi=[combi;coodf];
                end
                numpixel=length(combi);
                perccomp(1,k)=round(numpixel/length(v.traceA)*100,2); %percent in regards to the whole time
                %calculating calcium activity within compartment
                totalspk=sum(d.spikes,2);
                evrate(1,k)=sum(totalspk(combi))/(length(combi)/d.framerate);
                Compartments.(char(name{1,k})) = evrate(1,k);
            end
            %saving image
            if v.Pspot==1
                a=figure; image(v.imd(1).cdata); hold on;
                plot(v.tracePplot(:,1),v.tracePplot(:,2),v.colorP);
                %plotting anterior trace
                plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA);
            else
                a=figure; image(v.imd(1).cdata); hold on;
                %plotting anterior trace
                plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA);
            end
            for j=1:amount
                boundary = bwboundaries(ROImask(:,:,j));
                plot(boundary{1,1}(:,2),boundary{1,1}(:,1),'w','LineWidth',2);
                stats=regionprops(ROImask(:,:,j), {'Centroid'});
                c=round(stats.Centroid);
                text(c(1),c(2),num2str(perccomp(1,j),2),'Color','white','FontSize',14);
                text(c(1),c(2)-10,num2str(evrate(1,j),2),'Color','green','FontSize',14);
            end
            fname=sprintf('arena_ROIs');
            ffname=[cell2mat(d.name) '_' fname];
            path=[d.pn '/location/',ffname,'.png'];
            path=regexprep(path,'\','/');
            print(a,'-dpng','-r100',path); %-depsc for vector graphic
            %saving table
            T=struct2table(Compartments);
            filename=[d.pn '\location\' cell2mat(d.name) '_compartments.xls'];
            writetable(T,filename);
            %saving tracing ROIs
            filename=[d.pn '\tracingROIs_' cell2mat(d.name)];
            save(filename, 'amount','name','ROImask');
        case 'No'
            cood=[];
    end
end
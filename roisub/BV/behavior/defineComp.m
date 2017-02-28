function [cood] = defineComp
global d
global v
global p

%defining compartments
%check whether compartments have been imported
if p.import==1
    %loop of selecting compartments, giving names and calculations
        perccomp=zeros(1,p.amount);
        for k=1:p.amount;
            %calculating amount of time the mouse (the head) was in a compartment in percent
            [y,x]=find(p.ROImask(:,:,k)>0);
            cood=[x,y];
            v.traceAround=round(v.traceAplot);
            mhead=accumarray(v.traceAround,1);
            Mhead=imresize(mhead, [size(p.ROImask(:,:,k),1) size(p.ROImask(:,:,k),2)]);
            Mhead(Mhead<0.1)=0;
            Mhead(Mhead>0.1)=1;
            combi=p.ROImask(:,:,k)+Mhead;
            numpixel=numel(find(combi>1));
            numpixel=numpixel*((size(mhead,1)/size(p.ROImask(:,:,k),1)+size(mhead,2)/size(p.ROImask(:,:,k),2))/2);
            perccomp(1,k)=round(numpixel/length(v.traceA)*100,2); %percent in regards to the whole time
            Compartments.(char(p.name{1,k})) = perccomp(1,k);
        end
        %saving table
        T=struct2table(Compartments);
        filename=[d.pn '\location\' d.fn(1:end-4) 'compartments.xls'];
        writetable(T,filename);
        %saving tracing ROIs
        filename=[d.pn '\tracingROIs'];
        save(filename, 'amount','name','ROImask');
else
    %question if
    % Construct a questdlg with two options
    choice = questdlg('Would you like to define regions of interest?', ...
        'Attention', ...
        'Yes','No','No');
    % Handle response
    switch choice
        case 'Yes'
            %question how many
            prompt = {'How many?'};
            dlg_title = 'Amount';
            num_lines = 1;
            answer = inputdlg(prompt,dlg_title,num_lines);
            amount=str2num(cell2mat(answer));
            %loop of selecting compartments, giving names and calculations
            perccomp=zeros(1,amount);
            name=cell(1,amount);
            ROImask=zeros(size(v.imd(1).cdata,1),size(v.imd(1).cdata,2),amount);
            for k=1:amount;
                %selecting ROI
                figure,image(v.imd(1).cdata);
                str=sprintf('Please define compartment No. %d by clicking around the area!',k);
                uiwait(msgbox(str,'Attention'));
                ROI=roipoly;
                ROImask(:,:,k)=ROI;
                %name of ROI
                prompt = {'What do you want to call it? (Without using spaces!)'};
                dlg_title = 'Names';
                num_lines = 1;
                answer = inputdlg(prompt,dlg_title,num_lines);
                name{1,k}=answer;
                close(gcf);
                %calculating amount of time the mouse (the head) was in a compartment in percent
                [y,x]=find(ROI>0);
                cood=[x,y];
                v.traceAround=round(v.traceAplot);
                mhead=accumarray(v.traceAround,1);
                Mhead=imresize(mhead, [size(ROI,1) size(ROI,2)]);
                Mhead(Mhead<0.1)=0;
                Mhead(Mhead>0.1)=1;
                combi=ROI+Mhead;
                numpixel=numel(find(combi>1));
                numpixel=numpixel*((size(mhead,1)/size(ROI,1)+size(mhead,2)/size(ROI,2))/2);
                perccomp(1,k)=round(numpixel/length(v.traceA)*100,2); %percent in regards to the whole time
                Compartments.(char(name{1,k})) = perccomp(1,k);
            end
            %saving table
            T=struct2table(Compartments);
            filename=[d.pn '\location\' d.fn(1:end-4) 'compartments.xls'];
            writetable(T,filename);
            %saving tracing ROIs
            filename=[d.pn '\tracingROIs'];
            save(filename, 'amount','name','ROImask');
        case 'No'
            cood=[];
    end
end
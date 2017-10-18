function [skeys,tfb] = loadlastBV

%FUNCTION for loading last processed version of behavioral video.

%OUTPUT     skeys: shortkeys used for defining behaviors.
%
%           tfb: names of behaviors.

global v
global d

%loading cropped and converted video
h=msgbox('Loading... please wait!');
load([v.pn '\' v.fn{1}(1:end-4) '_converted']);
v.imd=convVimd;
v.pushed=1; %signals video is loaded
v.crop=1; %signals that video was cropped
%loading traces of color spot/s if available
files=dir(v.pn);
tfA=zeros(1,length(dir(v.pn)));
tfP=zeros(1,length(dir(v.pn)));
for k=1:length(dir(v.pn))
    tfA(k)=strcmp('traceA.mat',files(k).name);
    tfP(k)=strcmp('traceP.mat',files(k).name);
end
if sum(tfA)>0
    load([v.pn '\traceA']);
    v.traceA=traceA;
    v.traceAplot=traceAplot;
    v.colorA=colorA;
    v.Aspot=1;
end
if sum(tfP)>0
    load([v.pn '\traceP']);
    v.traceP=traceP;
    v.tracePplot=tracePplot;
    v.colorP=colorP;
    v.Pspot=1;
end
if sum(tfA)>0&&sum(tfP)>0
    %plotting traces
    figure, image(v.imd(1).cdata); hold on;
    plot(v.tracePplot(:,1),v.tracePplot(:,2),v.colorP);
    plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA); hold off;
else
    %plotting trace
    figure, image(v.imd(1).cdata); hold on;
    plot(v.traceAplot(:,1),v.traceAplot(:,2),v.colorA); hold off;
end
%loading behavior
files=dir(v.pn);
tfb=zeros(1,length(dir(v.pn)));
for k=1:length(dir(v.pn))
    tfb(k)=strcmp(['Behavior_' d.name '.mat'],files(k).name);
end
if sum(tfb)>0
    %saving positions at ROIs
    load([v.pn '\Behavior_' d.name]);
    v.amount=Amount;
    v.events=Events;
    v.shortkey=Shortkeys;
    v.name=BehavNames;
    v.barstart=barstart;
    v.barwidth=barwidth;
    v.skdefined=1;
    v.behav=1;
    %showing plot
    figure;
    str={};
    skeys={};
    for j=1:v.amount
        v.events.(char(v.name{1,j}))(v.events.(char(v.name{1,j}))>1)=1; %in case event was registered multiple times at the same frame
        area(1:size(v.imd,2),v.events.(char(v.name{1,j})),'edgecolor',d.colors{1,j},'facecolor',d.colors{1,j},'facealpha',0.5),hold on;
        str(end+1)={char(v.name{1,j})}; %#ok<*AGROW>
        skeys(end+1)={char(v.shortkey{1,j})};
    end
    %relabeling X-ticks in time in seconds
    xlabel('Time in seconds');
    tlabel=get(gca,'XTickLabel');
    for k=1:length(tlabel)
        tlabel{k,1}=str2num(tlabel{k,1});
    end
    tlabel=cell2mat(tlabel);
    tlabel=tlabel./d.framerate;
    set(gca,'XTickLabel',tlabel);
    legend(str);
    hold off;
else
    skeys={};
end
close(h);
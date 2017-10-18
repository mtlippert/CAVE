function [] = loadlastCI

%FUNCTION for loading the last processed version of the calcium imaging
%video. The first progress that is saved is the deltaF/F video, within that
%the information whether alignment was performed. The next progress is
%masked ROIs and the last progress saved includes also ROI values.

%no INPUT or OUTPUT since everything is calculated with global variables

global d

%loading delta F/F video
h=msgbox('Loading... please wait!');
load([d.pn '\name']); %load name
d.name=name;
load([d.pn '\' d.fn(1:end-4) 'dFvid']);
d.imd=deltaFimd;
close(h);
d.pushed=1; %signals that CI video was loaded
d.pre=1; %signals that the video was preprocessed
d.dF=1; %signals that delta F/F calculation was performed
%loading MIP
MaxIntensProj = max(d.imd, [], 3);
stdIm = std(d.imd,0,3);
d.mip=MaxIntensProj./stdIm;
figure,imagesc(d.mip),title('Maximum Intensity Projection');
%loading ROI mask
%check whether ROI mask had been saved before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn))
    tf(k)=strcmp([d.name 'ROIs.mat'],files(k).name);
end
if sum(tf)>0 %if a file is found
    load([d.pn '\' d.name 'ROIs.mat']);
    d.mask=ROImask; %mask with all the ROIs
    d.ROIsbw=ROIsingles; %logical mask of every single ROI
    d.pushed=4; %signals that ROIs were selected
    d.roisdefined=1; %signals that ROIs were defined
    d.load=1; %signals that a ROI mask was loaded
else
    %variable initialization for ROI calculations
    d.mask=zeros(size(d.imd,1),size(d.imd,2));
    d.ROIsbw=zeros(size(d.imd,1),size(d.imd,2));
    d.ROIs=[];
end
%loading ROI values
%check whether ROI values had been saved before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn))
    tf(k)=strcmp([d.name '_ROIvalues.mat'],files(k).name);
end
if sum(tf)>0
    load([d.pn '\' d.name '_ROIvalues.mat']);
    d.ROImeans=ROImeans; %ROI values trhoughout the video
    d.ROIv=1; %signals that ROI values have been loaded, so that you don't have to re-calculate them
else
    d.ROIv=0; %signals that ROI values have not been loaded
end
%loading scale for neuropil subtraction
%check whether scale had been saved before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn))
    tf(k)=strcmp('nscale.mat',files(k).name);
end
if sum(tf)>0
    load([d.pn '\nscale.mat']);
    d.nscale=nscale;
else
    d.nscale=[];
end
%loading calcium signal
%check whether calcium signal had been saved before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn))
    tf(k)=strcmp('traces',files(k).name);
end
if sum(tf)>0
    load([d.pn '\traces\traces_' d.name '.mat']);
    d.cCaSignal=traces.wave;
    d.spikes=zeros(size(d.cCaSignal));
    for j=1:size(d.cCaSignal,2);
        d.spikes(traces.spikes(1,j).ts,j)=traces.spikes(1,j).amp;
    end
    d.decon=1;
else
    d.decon=0; %signal was not deconvoluted;
end
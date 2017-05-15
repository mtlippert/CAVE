function [] = loadlastCI

%FUNCTION for loading the last processed version of the calcium imaging
%video. The first progress that is saved is the deltaF/F video, within that
%the information whether alignment was performed. The next progress is
%masked ROIs and the last progress saved includes also ROI values.

%no INPUT or OUTPUT since everything is calculated with global variables

global d

%loading delta F/F video
h=msgbox('Loading... please wait!');
load([d.pn '\' d.fn(1:end-4) 'dFvid']);
d.imd=deltaFimd;
close(h);
d.pushed=1; %signals that CI video was loaded
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
    tf(k)=strcmp([d.fn(1:end-4) 'ROIs.mat'],files(k).name);
end
if sum(tf)>0 %if a file is found
    load([d.pn '\' d.fn(1:end-4) 'ROIs.mat']);
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
    tf(k)=strcmp([d.fn(1:end-4) 'ROIvalues.mat'],files(k).name);
end
if sum(tf)>0
    load([d.pn '\' d.fn(1:end-4) 'ROIvalues.mat']);
    d.ROIs=ROIvalues; %ROI values trhoughout the video
    d.ROIv=1; %signals that ROI values have been loaded, so that you don't have to re-calculate them
else
    d.ROIv=0; %signals that ROI values have not been loaded
end
%loading calcium signal
%check whether calcium signal had been saved before
files=dir(d.pn);
tf=zeros(1,length(dir(d.pn)));
for k=1:length(dir(d.pn))
    tf(k)=strcmp([d.fn(1:end-4) 'CaSignal.mat'],files(k).name);
end
if sum(tf)>0
    load([d.pn '\' d.fn(1:end-4) 'CaSignal.mat']);
    d.ROImeans=ROImeans;
    d.cCaSignal=cCaSignal;
    d.spikes=spikes;
    d.decon=decon;
else
    d.decon=0; %signal was not deconvoluted;
end
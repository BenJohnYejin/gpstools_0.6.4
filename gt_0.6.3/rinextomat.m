function stat=rinextomat(matfile,ofile,nfile,gfile,code1)
%-------------------------------------------------------------------------------
% RINEXTOMAT(...)
% [Function] : RINEX�t�@�C����ǂݍ��݃f�[�^��matlab�t�@�C���ɏo�͂���
% [InArgs]   : matfile = matlab�t�@�C��
%              ofile   = RINEX �ϑ��f�[�^�t�@�C��
%              nfile   = RINEX GPS�L���t�@�C��
%              gfile   = RINEX GLONASS�L���t�@�C��
%              RINEX�t�@�C���ɂ̓��C���h�J�[�h'*'�܂��͕����t�@�C�����w��ł���
% [OutArgs]  : stat    = �X�e�[�^�X(0:����,-1:�G���[)
% [Note]     : matlab�t�@�C���ɏo�͂����ϐ��͈ȉ��̒ʂ�
%              epocn                   = �ϑ��f�[�^�G�|�b�N��
%              satn                    = �ϑ��f�[�^�q����
%              usern                   = �ϑ��ǐ�
%              Satlist                 = �q���ԍ����X�g
%                                        (GPS:PRN�ԍ�,GLONASS:�o�^�ԍ�+50)
%              Userlist                = �ϑ��ǖ����X�g
%              Weekno                  = �G�|�b�N�T�ԍ�
%              Epocidx(epocn,1)        = �G�|�b�N���X�g(sec of week)
%              Epocidxerr(epocn,usern) = �G�|�b�N�G���[���X�g(sec)
%              Prng1(epocn,satn,usern) = �ϑ��f�[�^(C1)
%              Prng2(epocn,satn,usern) = �ϑ��f�[�^(P2)
%              Phas1(epocn,satn,usern) = �ϑ��f�[�^(L1)
%              Phas2(epocn,satn,usern) = �ϑ��f�[�^(L2)
%              EpheD(datan,38,satn)    = GPS�L���
%              EpheG(datan,22,satn)    = GLONASS�L���
%              Pos                     = �ϑ��ǈʒu(x,y,z)(WGS84)
%              (Matfile)               = matlab�t�@�C��
%              (Ofile)                 = RINEX �ϑ��f�[�^�t�@�C��
%              (Nfile)                 = RINEX GPS�L���t�@�C��
%              (Gfile)                 = RINEX GLONASS�L���t�@�C��
%              (code1)                 = L1�R�[�h�w��('C1':C/A�R�[�h,'P1':P�R�[�h)
%                                        �ȗ���'C1'
%              �ϑ��f�[�^�̓G�|�b�N��,GPS�L����IODE��,GLONASS�L����TOC����
%              �\�[�g
%              �L���v�f��RINEX�t�@�C���i�[��(GPS:37����,GLONASS:22����)
%              �ϑ��ǈʒu�͍ŏ��ɓǂݍ��񂾊ϑ��f�[�^�̒l���g�p
%              �����f�[�^,�f�[�^�Ȃ���nan
%              [�g�p��]
%              rinextomat('out','abcd131.01O','abcd131.01N','abcd131.01G');
%              rinextomat('out','\rinex\obs\*.*','\rinex\nav\*.*');
%              rinextomat('out',{'*20.00o';'*30.00o'});
% [Version]  : $Id$
% [History]  : 01/09/27  1.1  �V�K
%              01/09/28  1.2  Weekno��1024��modulo���o�͂���l�ɏC��
%                             GPS�L����TOE�Ń\�[�g����悤�C��
%              03/10/14  1.3  �G�|�b�N�G���[���X�g�o�͒ǉ�
%              03/12/13  1.4  �G�|�b�N���X�g��т̏ꍇ��nan�f�[�^�}���ǉ�
%              04/05/24  1.5  readrinexobs,readrinenav�g�p�ɑΉ�
%                             �����ǑΉ�,Userlist�o�͒ǉ�
%                             Epocidx��x�N�g����
%              04/06/02  1.6  3�ǈȏ�̃f�[�^�ǂݍ��ݎ��G���[�C��
%              04/06/08  1.7  ���Ȃ炸���擪����f�[�^���n�܂�悤�ɂ���B
%              04/09/06  1.8  ���͈���code1(L1�R�[�h�w��)�ǉ�
%              04/11/02  1.9  matlab7�Ή�
%-------------------------------------------------------------------------------
global epocn satn usern Satlist Userlist Weekno Epocidx Epocidxerr
global Prng1 Prng2 Phas1 Phas2 EpheD EpheG Pos Matfile Ofile Nfile Gfile
epocn=0; satn=0; usern=0; Satlist=[]; Weekno=0; Epocidx=[]; Epocidxerr=[];
Prng1=[]; Prng2=[]; Phas1=[]; Phas2=[]; EpheD=[]; EpheG=[]; Pos=[];
Matfile=''; Ofile=''; Nfile=''; Gfile=''; Code1='C1'; stat=-1;
if nargin>=1 Matfile=matfile; end
if nargin>=2 Ofile=ofile; if ischar(Ofile), Ofile={Ofile}; end, end
if nargin>=3 Nfile=nfile; if ischar(Nfile), Nfile={Nfile}; end, end
if nargin>=4 Gfile=gfile; if ischar(Gfile), Ofile={Gfile}; end, end
if nargin>=5 Code1=code1; end
if isempty(Matfile) disp('matfile missing error!!'), return, end

if ~isempty(Ofile)
    [Weekno,Satlist,Userlist,z,iz,Pos]=...
        ReadRinexObss(Ofile,{Code1;'P2';'L1';'L2'});
    
    if ~isempty(Weekno)
        Weekno=mod(Weekno,1024);
        satn=length(Satlist);
        usern=length(Userlist);
        
        timef=round(iz(:,1)); timee=iz(:,1)-timef;
        t=unique(timef); tint=t(2)-t(1);
        timef0=floor(timef(1)/86400)*86400; % ���擪�n�܂�
        Epocidx=(timef0:tint:timef(end))';
        epocn=length(Epocidx);
        Epocidxerr=repmat(nan,epocn,1);
        
        Prng1=repmat(nan,[epocn,satn,usern]);
        Prng2=Prng1; Phas1=Prng1; Phas2=Prng2;
        for n=1:satn
            for m=1:usern
                i=find(mod(timef,tint)==0&iz(:,2)==n&iz(:,3)==m);
                if ~isempty(i)
                    j=(timef(i)-timef0)/tint+1;
                    Epocidxerr(j,m)=timee(i);
                    Prng1(j,n,m)=z(i,1);
                    Prng2(j,n,m)=z(i,2);
                    Phas1(j,n,m)=z(i,3);
                    Phas2(j,n,m)=z(i,4);
                end
            end
        end
        stat=0;
    end
end
if ~isempty(Nfile)
    [EpheD,Satlist]=ReadRinexNavs(Nfile,'G',Satlist);
    if ~isempty(EpheD), stat=0; end
end
if ~isempty(Gfile)
    [EpheG,Satlist]=ReadRinexNavs(Gfile,'N',Satlist);
    if ~isempty(EpheG), stat=0; end
end
if stat==0
    disp(sprintf('writing matlab file (%s.mat) ...',Matfile))
    save(Matfile,'epocn','satn','usern','Satlist','Userlist','Weekno','Epocidx',...
         'Epocidxerr','Prng1','Prng2','Phas1','Phas2','EpheD','EpheG','Pos',...
         'Matfile','Ofile','Nfile','Gfile')
else disp('no rinex file can be read !!'), end

% read rinex obs files ---------------------------------------------------------
function [weekno,sats,rcvs,z,iz,poss]=ReadRinexObss(files,type)
weekno=[]; sats=[]; rcvs={}; z=[]; iz=[]; poss=[]; td=[]; ts=[];

for n=1:length(files)
    [dirs,file,ext]=fileparts(files{n});
    if ~isempty(dirs), wd=cd; cd(dirs); end
    if ~isempty([file,ext])
        for f=dir([file,ext])'
            disp(['reading rinex obs : ',fullfile(dirs,f.name)])
            
            [epoch,time,types,u,s,rcv,data,isat,pos]=readrinexobs(f.name);
            
            if ~isempty(epoch)
                if isempty(td), [td,ts]=caltomjd(epoch); time=time+ts;
                else [tdd,tss]=caltomjd(epoch); time=time+(tdd-td)*86400+tss; end
                
                rcv=upper(rcv); ircv=find(strcmp(rcv,rcvs));
                if isempty(ircv)
                    rcvs={rcvs{:},rcv}; poss=[poss,pos]; ircv=length(rcvs);
                end
                zz=repmat(nan,length(time),length(type));
                for m=1:length(type)
                    k=find(strcmp(type{m},types));
                    if ~isempty(k), zz(:,m)=data(:,k); end
                end
                z=[z;zz];
                iz=[iz;time,isat,repmat(ircv,length(time),1)];
            else
                disp(['rinex obs file read error : ',f.name])
            end
        end
    end
    if ~isempty(dirs), cd(wd); end
end
if ~isempty(td)&~isempty(iz)
    weekno=floor((td-44244)/7);
    iz(:,1)=iz(:,1)+(td-44244-weekno*7)*86400;
    sats=unique(iz(:,2));
    i=zeros(size(iz,1),1);
    for n=1:length(sats), i(find(iz(:,2)==sats(n)))=n; end
    iz(:,2)=i;
    [iz,i]=sortrows(iz,1:3); z=z(i,:);
end
rcvs=rcvs';

% read rinex nav files ---------------------------------------------------------
function [ephs,sats]=ReadRinexNavs(files,type,sats)
ephs=[]; navs=[]; inav=[];

for n=1:length(files)
    [dirs,file,ext]=fileparts(files{n});
    if ~isempty(dirs), wd=cd; cd(dirs); end
    if ~isempty([file,ext])
        for f=dir([file,ext])'
            disp(['reading rinex nav : ',fullfile(dirs,f.name)])
            [s,rcv,nav,index]=readrinexnav(f.name);
            if ~isempty(nav)
                navs=[navs;index,nav];
            else
                disp(['rinex nav file read error : ',f.name])
            end
        end
    end
    if ~isempty(dirs), cd(wd); end
end
if isempty(navs), return, end

if type=='G', navs=sortrows(navs,[29,19]); else, [navs,i]=sortrows(navs,10); end

if isempty(sats), sats=unique(navs(:,1)); end
ephs=repmat(nan,[100,38,length(sats)]); ne=0;
for n=1:length(sats)
    eph=navs(find(navs(:,1)==sats(n)),:); ne=max(ne,size(eph,1));
    ephs(1:size(eph,1),:,n)=eph;
end
ephs=ephs(1:ne,:,:);

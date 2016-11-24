function gensdisp(td,time,rcvs,dirs,tide,wave,omodel)
%-------------------------------------------------------------------------------
% [system] : ���ʃV�X�e���݌v��̓c�[��
% [module] : �����ʒu�ψʗʐ���
% [func]   : �����ɂ��ʒu�ψʗ\���l���v�Z����B
% [argin]  : td,time = ���t(MJD),�����x�N�g��(sec)(UTC)
%            rcvs = �ϑ��ǃx�N�g��
%            (dirs)   = �o�̓f�B���N�g��
%            (tide)   = 1:�ő̒���+�C�m,2:�ő̒���,3:�C�m����
%            (wave)   = ���� {wv1,wv2,...}
%            (omodel) = �������f��('nao'=NAO.99b,'got'=GOTO,'csr'=CSR4.0)
% [argout] : �Ȃ�
% [note]   : gotic2�t�����g�G���h
%            gotic2��<command path>\..\..\gotic2�ɃC���X�g�[������Ă��邱�ƁB
%            GOTIC2 version 2001.05.16
%            reference:
%            Matsumoto, K., T. Sato, T. Takanezawa, and M. Ooe,
%            GOTIC2: A Program for Computation of Oceanic Tidal Loading Effect, 
%            J. Geod. Soc. Japan, 47, 243-248, 2001
% [version]: $Revision: 1 $ $Date: 04/09/21 22:13 $
% [history]: 04/10/08  0.1  �V�K�쐬
%-------------------------------------------------------------------------------
if nargin<4, dirs=''; end
if nargin<5, tide=1; end
if nargin<6, wave={'M2','S2','N2','K2','K1','O1','P1','Q1','Mf','Mm','Ssa'}; end
if nargin<7, omodel='nao'; end
if ischar(rcvs), rcvs={rcvs}; end
fctr='tmp.ctr';
fin ='tmp.in';
fout='tmp.out';
[path,name]=fileparts(which(mfilename));
gdir=[path,filesep,'..',filesep,'..',filesep,'gotic2']; % GOTIC2�p�X
if ~exist(gdir,'dir')|~exist(fullfile(gdir,'gotic2.exe'),'file')
    error(['gotic2 not installed : ',gdir])
end
for n=1:length(rcvs)
    rcv=rcvs{n};
    posr=readpos(td,time(1),rcv,dirs)';
    gpos=eceftogeod(posr);
    [epos,E]=geodtoecef(gpos);
    wd=pwd;
    cd(gdir);
    disp(['generating site disp... : ',rcv])
    if GenCtr(fctr,gpos,td,time,tide,'RD,HD','','',wave,omodel)
        dos(['gotic2.exe <',fctr,'>',fin]);
    end
    if GenCtr(fctr,gpos,td,time,tide,'RD',fin,fout,wave,omodel)
        [s,w]=dos(['gotic2.exe <',fctr]);
        dposr=dlmread(fout);
    end
    if GenCtr(fctr,gpos,td,time,tide,'HD',fin,fout,wave,omodel)
        [s,w]=dos(['gotic2.exe <',fctr]);
        dposh=dlmread(fout);
    end
    %delete(fout);
    %delete(fin);
    %delete(fctr);
    cd(wd);
    dposf=[dposh(:,[3,2]),dposr(:,2)];
    for m=1:length(time), dpos(m,:)=dposf(m,:)*E; end
    
    epoch=mjdtocal(td,time(1));
    file=fullfile(dirs,sprintf('sdsp_%s_%04d%02d%02d%02d%02d.mat',rcv,epoch(1:5)));
    save(file,'epoch','time','rcv','posr','dpos','dposf');
end

% GOTIC2����t�@�C���o�� --------------------------------------------------------
function stat=GenCtr(file,gpos,td,time,tide,type,fin,fout,wave,omodel)
ts=mjdtocal(td,time(1));
te=mjdtocal(td,time(end));
ti=(time(2)-time(1))/60;
fo=fopen(file,'wt');
if fo==-1, disp(['control file open error : ',file]), stat=0; return, end
fprintf(fo,'STAPOSD 0000, %.5f, %.5f, %.3f, 0.0\n',gpos([2,1,3]));
wv=wave{1}; for n=2:length(wave), wv=[wv,',',wave{n}]; end
fprintf(fo,'WAVE %s\n',wv);
fprintf(fo,'KIND %s\n',type);
fprintf(fo,'OMODEL %s\n',omodel);
if ~isempty(fin)
    fprintf(fo,'PREDICT %d,%04d%02d%02d%02d%02d,%04d%02d%02d%02d%02d,%.0f\n',...
            tide,ts(1:5),te(1:5),ti);
    fprintf(fo,'PREXFL %s\n',fin);
    fprintf(fo,'PREFMT 4,1\n');
    fprintf(fo,'PREOUT %s\n',fout);
end
fprintf(fo,'END\n');
fclose(fo);
stat=1;

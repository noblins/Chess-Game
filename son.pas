//------------------------------------------------------------------------------
//                EREDIA V.1.0     www.eredia.fr      17/06/08
//
//      Epita [FR] Promo 2012   (www.epita.fr)
//
//      Developped by : Belkahia Emir : belkah_e@epita.fr
//                      Marquegnies Julien : chaosoldier@hotmail.com
//                      Daguenet Raphaël : metalikange@hotmail.fr (Manager)
//
//------------------------------------------------------------------------------

unit son;

interface

uses
  Classes,
  fmod,
  sysutils,
  fmodtypes;

var
  music, music2,music3: Tstream;
  chemin, chemin2: string;

function loadmusic(music : tstream ; st: PChar):TStream;
procedure playmusic(i : integer; musicfond: TStream);
procedure stopmusic(musicfond: TStream);
procedure mute(i: integer);
procedure setvolume(i : integer; setvolume : integer);
function sfxload(canal: integer; nom: PChar):PFSoundSample;
procedure sfxplay(canal:integer; sample:PFSoundSample);
procedure getMp3List;
procedure sfxstop(canal:integer);
procedure switchmusic(var bool : array of boolean; track : integer; var IntegerArray : array of Integer);

implementation

procedure getMp3List;
Var
  F : textfile;
  Info   : TSearchRec;
begin
  Assignfile(F,'musiqueperso.list');
  rewrite(F);
  If FindFirst(Chemin+'Sons\Musique perso\*.mp3',faAnyFile,Info)=0 Then
  Begin
    Repeat
      If ((Info.Attr And faDirectory)=0) then
        Writeln(F,Info.FindData.cFileName)
      Until FindNext(Info)<>0;
      FindClose(Info);
      CloseFile(F);
  End;
end;

function readMp3List(track : integer) : string;
var
  F : textfile;
  line : string;
  size, i : integer;
begin
  Assignfile(F,'musiqueperso.list');
  size := 1;
  reset(F);
  readln(F,line);
  for i := 1 to track - 1 do
    begin
      readln(F,line);
      size := size + 1;
      if size > track then
        size := size mod track;
    end;
  closefile(F);
  result := line;
end;

function loadmusic(music : tstream ; st: PChar):TStream;
  begin
   music := FSOUND_Stream_Open(st,FSOUND_2D,0,0);
   result := music;
  end;

procedure playmusic(i : integer; musicfond: TStream);
  begin
    FSOUND_Stream_Play(i,musicfond);
  end;

procedure stopmusic(musicfond: TStream);
  begin
    FSOUND_Stream_Stop(musicfond);
  end;

procedure pause(i: integer);
  begin
    FSOUND_SetPaused(i, not FSOUND_GetPaused(i));
  end;

procedure mute(i: integer);
  begin
    FSOUND_SetMute(i, not FSOUND_GetMute(i));
  end;

procedure setvolume(i : integer; setvolume : integer);
  begin
    FSOUND_SetVolume(i,setvolume);
  end;

function sfxload(canal: integer; nom: PChar):PFSoundSample;
  begin
    result:=FSOUND_Sample_Load(canal, nom, 0, 0, 0);
  end;

procedure sfxplay(canal:integer; sample:PFSoundSample);
  begin
    FSOUND_PlaySound(canal, sample);
  end;

procedure sfxstop(canal:integer);
  begin
    FSOUND_StopSound(canal);
  end;

procedure switchmusic(var bool : array of boolean; track : integer; var IntegerArray : array of Integer);
begin
  if not bool[24]{switch musique} then
    begin
        case IntegerArray[5] of
         1 : music := Loadmusic(music, 'Sons/Musique/orion.wma');
         2 : music := Loadmusic(music, 'Sons/Musique/smallhours.mp3');
         3 : music := Loadmusic(music, 'Sons/Musique/guns.mp3');
         4 : music := Loadmusic(music, 'Sons/Musique/blow.mp3');
         else
            music := Loadmusic(music, 'Sons/Musique/orion.wma');
         end;
    end
  else
    music := LoadMusic(music,Pchar('Sons/Musique perso/' + readMp3List(track)));
end;
end.

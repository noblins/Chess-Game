unit quitter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, fmod, fmodtypes;

type
  TExit = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Exit: TExit;
  clic: PFSoundSample;


implementation

{$R *.dfm}

procedure TExit.Button1Click(Sender: TObject);
begin
FSOUND_PlaySound(FSOUND_FREE, clic);
Application.Terminate ;
end;

procedure TExit.Button2Click(Sender: TObject);
begin
FSOUND_SetPaused(FSOUND_ALL, false); // On enlève la pause de la musique
FSOUND_PlaySound(FSOUND_FREE, clic);
Exit.Visible:=false;
end;

INITIALIZATION

FSOUND_Init(44100, 32, 0);
clic := FSOUND_Sample_Load(3, 'clic.mp3', 0, 0, 0);

end.

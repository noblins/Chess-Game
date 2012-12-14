unit menu;


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, fmodtypes, fmod, quitter, ToolWin, ComCtrls, aide
  , UtilAffiche ;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Button2: TButton;
    Label3: TLabel;
    Button3: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Button4: TButton;
    Label6: TLabel;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);

   // procedure FormOnPaint(Sender: TObject);
   // procedure FormCreate(Sender: TObject);
   // procedure FormDestroy(Sender: TObject);

  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  Form2 : TForm2;
  Mode : integer ;
  Bitmap : TBitMap;
  music : PFSoundStream;
  clic : PFSoundSample;

procedure init_music_boucle (nom: PAnsiChar);

implementation

uses two_play;

{$R *.dfm}

procedure init_music_boucle (nom: PAnsiChar);


begin

  // initialisation de fmod
  FSOUND_Init(44100,4,0); // fr�quence de 44 100 Hz (qualit� CD), 32 canaux et pas d'options particuli�res (flag = 0).

  // Chargement du son et v�rification du chargement
  music:=NIL;
  music := FSOUND_Stream_Open(nom, FSOUND_LOOP_NORMAL, 0, 0);
  // FSOUND_SetVolume(3, 120);
  if music = NIL then  // si on ne trouve pas le fichier son

       Showmessage('Impossible de lire les fichiers sons') // message d'erreur

     else

     FSOUND_Stream_SetLoopCount(music, -1); // On active la r�p�tition de la musique � l'infini
     FSOUND_Stream_Play(3, music); // on joue la musique


end;



{procedure TForm2.FormOnPaint(Sender: TObject);
begin
  Form2.Canvas.Draw(0,0,BitMap);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile('logo.bmp');
  Form2.Canvas.Draw(0,0,BitMap);
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  Bitmap.Free;
end;}



procedure TForm2.Button1Click(Sender: TObject);
begin
FSOUND_PlaySound(FSOUND_FREE, clic);
Form3.show ;
mode := 2 ;     // mode jeu
contre_ordi := true ;
Aide_dep := false ;
couleur_ordi := noir ;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
FSOUND_SetPaused(FSOUND_ALL, true);
FSOUND_PlaySound(FSOUND_FREE, clic);
Exit.Visible:=true;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
FSOUND_PlaySound(FSOUND_FREE, clic);
Form3.Show;
mode := 2 ;   // mode jeu
contre_ordi := false ;
Aide_dep := false ;
end;

procedure TForm2.Button4Click(Sender: TObject);
begin
FSOUND_PlaySound(FSOUND_FREE, clic);
Button1.Visible:=false;
Button3.Visible:=false;
Label4.Visible:=false;
Label5.Visible:=false;
Form1.Visible:=true;
Form1.Memo1.Clear;
Form1.Memo1.Lines.Add('    Bienvenue � tous dans le tutoriel de Battle in ChessLand !');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('I. Les deux modes de jeu.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Tout au long du jeu, vous aurez la possibilit� de jouer selon deux types de mode diff�rents :');
Form1.Memo1.Lines.Add(' * Le mode UN JOUEUR');
Form1.Memo1.Lines.Add('Dans ce mode de jeu, vous pourrez jouer contre le programme du jeu Battle in ChessLand. Vous jouez donc seul contre l''ordinateur.');
Form1.Memo1.Lines.Add(' * Le mode DEUX JOUEURS');
Form1.Memo1.Lines.Add('Dans cet autre mode, vous jouez sur le m�me ordi avec quelqu''un (ami...)');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Enfin, vous avez aussi la possibilit�, dans les deux modes de jeu, d''etre aid� dans les d�placements.');
Form1.Memo1.Lines.Add('Pour cela, cliquez dans l''un des deux modes (un ou deux joueurs) puis dans le menu "deplacements" cliquez sur "Aide"');
Form1.Memo1.Lines.Add('Voila. Vous verrez des sortes de boules vertes transparentes vous indiquer pour chaque piece les diff�rents coups possibles.');
Form1.Memo1.Lines.Add('Si vous n''en voyez pas, pas d''inqui�tude, cela signifie simplement qu''il n''y en a pas (que la piece ne peut pas bouger)');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Et � pr�sent, pour tous les d�butants aux �checs, voici un tuto qui vous apprendra � y jouer.');
Form1.Memo1.Lines.Add('Bonne lecture!');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('II. LE TUTORIEL : APPRENDRE A JOUER AUX ECHECS (ce cours est tir� du site : http://normandlamoureux.com/echecs/index.html)');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('La description des pi�ces.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Il y a 6 sortes de pi�ces aux �checs :');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('les rois, les dames, les tours, les fous, les cavaliers et les pions. D�crivons-les bri�vement :');
Form1.Memo1.Lines.Add('* Les pions sont tous pareils et sont habituellement les plus petites pi�ces du jeu. Ce sont les soldats.');
Form1.Memo1.Lines.Add('* Le roi et la dame sont de plus haute taille que les autres pi�ces. Le roi porte une couronne masculine, et la dame une couronne f�minine.');
Form1.Memo1.Lines.Add('* On reconna�t aussi les fous � leur coiffe, qui est la mitre. Se sont les conseillers du roi et de la dame.');
Form1.Memo1.Lines.Add('* Les cavaliers sont habituellement repr�sent�s par une t�te de cheval. Se sont les chefs d''arm�e.');
Form1.Memo1.Lines.Add('* Les tours, finalement, ont la forme d''une tour de ch�teau. Ils repr�sentent les murs de la forteresse.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Les r�gles g�n�rales.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Le mouvement d''une pi�ce se d�finit par l''abandon de sa case de d�part et par l''occupation de sa case d''arriv�e.');
Form1.Memo1.Lines.Add('Deux pi�ces ne peuvent jamais occuper une m�me case en m�me temps.');
Form1.Memo1.Lines.Add('Si une pi�ce arrive sur une case occup�e par une pi�ce adverse, cette derni�re est � captur�e � et doit �tre retir�e pour le reste de la partie.');
Form1.Memo1.Lines.Add('On ne peut jamais capturer ses propres pi�ces, on n''est pas oblig� de capturer une pi�ce adverse et on ne peut capturer qu''une seule pi�ce � la fois.');
Form1.Memo1.Lines.Add('Toutes les pi�ces ont le droit de reculer, sauf les pions.');
Form1.Memo1.Lines.Add('Le roi se d�place dans n''importe quelle direction d''une seule case � la fois, mais sans jamais avoir le droit se mettre lui-m�me en prise.');
Form1.Memo1.Lines.Add('La dame se d�place d''autant de cases cons�cutives que voulu suivant un alignement horizontal, vertical ou diagonal, mais sans jamais pouvoir franchir une case occup�e.');
Form1.Memo1.Lines.Add('La tour se d�place d''autant de cases cons�cutives que voulu suivant un alignement horizontal ou vertical, mais sans jamais pouvoir franchir une case occup�e.');
Form1.Memo1.Lines.Add('Le fou se d�place d''autant de cases cons�cutives que voulu suivant un alignement diagonal, mais sans jamais pouvoir franchir une case occup�e.');
Form1.Memo1.Lines.Add('Le cavalier se d�place d''une case comme une tour, puis d''une case comme un fou en s''�loignant de sa case de d�part. Il est la seule pi�ce capable de franchir une case occup�e.');
Form1.Memo1.Lines.Add('Le pion avance d''une seule case � la fois, sauf lorsqu''il se trouve sur sa case de d�part. Il peut alors avancer d''une case ou deux.');
Form1.Memo1.Lines.Add('Le pion est la seule pi�ce qui ne capture pas comme elle se d�place. Un pion ne peut capturer que ce qui se trouve sur une case situ�e devant lui et de m�me couleur que la sienne');
Form1.Memo1.Lines.Add('Un pion arriv� au bout de sa course doit se transformer. Il peut devenir une dame, une tour, un fou ou un cavalier, mais jamais un roi.');
Form1.Memo1.Lines.Add('La pi�ce qu''il devient n''a pas besoin d''avoir d�j� �t� captur�e.');
Form1.Memo1.Lines.Add('Cette transformation ne concerne que les pions et se nomme � promotion �.');
Form1.Memo1.Lines.Add('Lorsqu''un pion adverse avance de deux cases et vient se loger � c�t� d''un pion,');
Form1.Memo1.Lines.Add('ce dernier peut, au coup suivant, capturer l''autre comme s''il n''avait avanc� que d''une seule case.');
Form1.Memo1.Lines.Add('Cette capture ne concerne que les pions et se nomme prise � en passant �.');
Form1.Memo1.Lines.Add('Elle suppose que le pion adverse vient d''avancer de deux cases et non d''une seule.');
Form1.Memo1.Lines.Add('Et elle doit se faire tout de suite, sans pouvoir �tre report�e au tour suivant.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('La valeur des pi�ces:');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Si la valeur d''un pion est fix�e � 1 point, alors une dame vaut 9 pions, une tour 5, un fou 3 et un cavalier 3. La valeur du roi ne peut �tre chiffr�e, puisque sa perte met fin � la partie.');
Form1.Memo1.Lines.Add('Le joueur qui a les blancs joue le premier coup. On dit que celui a qui c''est le tour de jouer a � le trait �.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('La nature et le but du roque.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Le roque implique le mouvement du roi et d''une tour. C''est le seul coup r�glementaire qui suppose le d�placement de deux pi�ces. Il vise � mettre le roi en s�curit� et � centraliser une tour.');
Form1.Memo1.Lines.Add('Le � petit roque � et le � grand roque � sont nomm�s ainsi en raison du nombre de cases vides entre le roi et la tour avant l''ex�cution du coup.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Les conditions du roque.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Un m�me joueur ne peut roquer qu''une seule fois au cours d''une m�me partie. Il peut le faire lorsque les 6 conditions suivantes sont r�unies :');
Form1.Memo1.Lines.Add('* toutes les cases entre le roi et la tour sont libres ;');
Form1.Memo1.Lines.Add('* la tour ne doit jamais avoir boug� (mais elle peut �tre en prise) ;');
Form1.Memo1.Lines.Add('* le roi ne doit jamais avoir boug� ;');
Form1.Memo1.Lines.Add('* le roi ne doit pas �tre en �chec (mais il peut l''avoir �t�)');
Form1.Memo1.Lines.Add('* le roi ne doit pas arriver sur une case o� il serait en �chec');
Form1.Memo1.Lines.Add('* le roi ne doit pas passer par une case o� il serait en �chec.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('La mani�re d''effectuer le roque.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Les d�placements du roi et de la tour doivent �tre effectu�s avec la m�me main et de la mani�re suivante :');
Form1.Memo1.Lines.Add('* on range d''abord son roi de 2 cases vers la tour (ce qui est vrai aussi bien pour le petit roque que pour le grand)');
Form1.Memo1.Lines.Add('* puis on vient mettre cette tour de l''autre c�t� du roi, sur la case que ce dernier vient de franchir.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('La fin de la partie.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Une partie d''�checs se termine soit par la victoire d''un joueur sur l''autre, soit par la nulle. D''o� les deux parties de cette le�on.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Le mat.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Aucun r�glement n''y oblige, mais l''usage veut qu''un joueur qui met le roi adverse en prise l''annonce en disant � �chec �.');
Form1.Memo1.Lines.Add('Le joueur dont le roi est en �chec est oblig� de l''y soustraire avant de faire quoi que ce soit d''autre.');
Form1.Memo1.Lines.Add('Il n''existe que trois mani�res de soustraire un roi � un �chec :');
Form1.Memo1.Lines.Add(' * capturer la pi�ce qui attaque le roi ;');
Form1.Memo1.Lines.Add(' * d�placer le roi sur une case o� il n''est plus en prise ;');
Form1.Memo1.Lines.Add(' * interposer une pi�ce entre l''attaquant et le roi.');
Form1.Memo1.Lines.Add('Lorsqu''un roi est en �chec et qu''aucun coup r�glementaire ne permet de l''y soustraire, il est � mat � et la partie est termin�e.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('La partie nulle.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Il y a 6 cas de nullit� aux �checs :');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('1) le consentement mutuel des joueurs ;');
Form1.Memo1.Lines.Add('2) l''insuffisance de mat�riel');
Form1.Memo1.Lines.Add('3) le pat');
Form1.Memo1.Lines.Add('4) l''�chec perp�tuel');
Form1.Memo1.Lines.Add('5) la triple r�p�tition de la position');
Form1.Memo1.Lines.Add('6) la r�gle des 50 coups.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Il y a nulle par consentement mutuel lorsque les joueurs s''entendent � l''amiable pour se partager le point. Le score est alors de 1/2 � 1/2.');
Form1.Memo1.Lines.Add('Il y a nulle par insuffisance de mat�riel lorsqu''aucun des joueurs n''est en mesure de forcer le mat avec les pi�ces qui lui restent.');
Form1.Memo1.Lines.Add('Ce qui est toujours le cas lorsqu''il ne reste plus que les rois seuls ou un roi et un fou ou un cavalier contre un roi.');
Form1.Memo1.Lines.Add('Un joueur se trouve dans une position telle que son roi n''est pas en �chec, mais qu''il ne dispose plus d''aucun coup l�gal,');
Form1.Memo1.Lines.Add('son roi est � pat � et la partie est nulle (voir l''exemple ci-dessous).');
Form1.Memo1.Lines.Add('Il y a �chec perp�tuel lorsqu''un joueur, sans parvenir � mater le roi adverse, peut le mettre en �chec sans rel�che, sans que celui-ci ne dispose d''aucun moyen d''y mettre fin.');
Form1.Memo1.Lines.Add('Il y a nulle par triple r�p�tition de la position lorsque le joueur, au trait, est en mesure de reproduire la m�me position une troisi�me fois au cours de la m�me partie,');
Form1.Memo1.Lines.Add('avec les m�mes possibilit�s de roque et de prise en passant, et qu''il r�clame la nulle en indiquant ce coup, mais sans le jouer (s''il le joue, il passe le trait � son adversaire qui, ce faisant,');
Form1.Memo1.Lines.Add('peut accepter ou refuser la nulle).');
Form1.Memo1.Lines.Add('Lorsque 50 coups cons�cutifs des blancs et des noirs ne comportent ni coup de pion ni capture, le joueur au trait peut r�clamer la nulle.');
Form1.Memo1.Lines.Add('');
Form1.Memo1.Lines.Add('Pour ceux qui d�sirent en savoir plus, je les invite � se rendre sur ce site tr�s complet :');
Form1.Memo1.Lines.Add('http://normandlamoureux.com/echecs/index.html');
end;

procedure TForm2.Button5Click(Sender: TObject);
begin
FSOUND_PlaySound(FSOUND_FREE, clic);
Button1.Visible:=true;
Button3.Visible:=true;
Label5.Visible:=true;
Label4.Visible:=true;
end;

INITIALIZATION

FSOUND_Init(44100, 4, 0);
init_music_boucle ('matrix.mp3');
clic := FSOUND_Sample_Load(3, 'clic.mp3', 0, 0, 0);

end.

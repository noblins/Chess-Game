unit two_play;

interface

uses
    Windows
    , Messages
    , SysUtils
    , Variants
    , Classes
    , Graphics
    , Controls
    , Forms
    , Dialogs
    , Opengl         // comme son nom l'indique
    , StdCtrls
    , ExtCtrls
    , shellapi
    , BMP            // unité gérant le chargement des texture Bitmap
    , ComCtrls       // gestion des controles ( VCL Delphi ) API Windows
    , Buttons        // gestion des boutons ( VCL Delphi ) API Windows
    , Unit3ds        // unité gérant le chargement des Mesh
    , UnitBtbInit    // unité d' définition des BitBoards de base
    , UtilAffiche
    , Menus
    , Cible_piece
    , fmod
    , fmodtypes
    , menu, ImgList ;   // unité définissant l'affichage

type

  TForm3 = class(TForm)
    TimerSpheres: TTimer;
    TimerIntro: TTimer;
    MainMenu1: TMainMenu;
    files1: TMenuItem;
    Newgame1: TMenuItem;
    Quit1: TMenuItem;
    camera1: TMenuItem;
    Libre1: TMenuItem;
    Devantjoueurautrait1: TMenuItem;
    Devantjoueurauxblancs1: TMenuItem;
    Devantjoueurauxnoirs1: TMenuItem;
    decors1: TMenuItem;
    Orion1: TMenuItem;
    Horizon: TMenuItem;
    Echiquier1: TMenuItem;
    Bois1: TMenuItem;
    Marbre: TMenuItem;
    Promotion_panel: TPanel;
    Tour_prom: TButton;
    Cavalier_prom: TButton;
    Fou_prom: TButton;
    Dame_prom: TButton;
    Label1: TLabel;
    pnl_score: TPanel;
    ImageList1: TImageList;
    pnl_list_essais: TPanel;
    Memo_essais: TMemo;
    Dplacements1: TMenuItem;
    Aide1: TMenuItem;
    Couleur1: TMenuItem;
    Noir1: TMenuItem;
    Blancs1: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
    procedure  FormMouseDown(Sender: TObject; Button: TMouseButton;
                             Shift: TShiftState; X, Y: Integer);
    procedure Btn_ResetClick(Sender: TObject);
    procedure BtnSplitClick(Sender: TObject);
    procedure SBt_NordClick(Sender: TObject);
    procedure SBt_SudClick(Sender: TObject);
    procedure SBt_EstClick(Sender: TObject);
    procedure SBt_OuestClick(Sender: TObject);
    procedure SBt_NordMouseDown(Sender: TObject; Button: TMouseButton;
                                Shift: TShiftState; X, Y: Integer);
    procedure SBt_SudMouseDown(Sender: TObject; Button: TMouseButton;
                               Shift: TShiftState; X, Y: Integer);
    procedure SBt_SEClick(Sender: TObject);
    procedure SBt_NOClick(Sender: TObject);
    procedure RB_TextureBoisClick(Sender: TObject);
    procedure RB_TextureMarbreClick(Sender: TObject);
    procedure SBt_SOClick(Sender: TObject);
    procedure BNtn_HorizonClick(Sender: TObject);
    procedure TimerSpheresTimer(Sender: TObject);
    procedure Btn_OrionClick(Sender: TObject);
    procedure Btn_Split_2Click(Sender: TObject);
//    procedure parcoursCavalierEuler(Sender: TObject;ligne, colonne: integer);
    procedure TimerIntroTimer(Sender: TObject);
    procedure RB_CavalierClick(Sender: TObject);
    procedure testpClick(Sender: TObject);
    procedure PartieClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Quit1Click(Sender: TObject);
    procedure Newgame1Click(Sender: TObject);
    procedure Libre1Click(Sender: TObject);
    procedure Devantjoueurautrait1Click(Sender: TObject);
    procedure Devantjoueurauxblancs1Click(Sender: TObject);
    procedure Devantjoueurauxnoirs1Click(Sender: TObject);
    procedure Orion1Click(Sender: TObject);
    procedure HorizonClick(Sender: TObject);
    procedure Bois1Click(Sender: TObject);
    procedure MarbreClick(Sender: TObject);
    procedure Tour_promClick(Sender: TObject);
    procedure Cavalier_promClick(Sender: TObject);
    procedure Fou_promClick(Sender: TObject);
    procedure Dame_promClick(Sender: TObject);
    procedure Ajuste_panel_promotion();
    procedure Aide1Click(Sender: TObject);
    procedure Blancs1Click(Sender: TObject);
    procedure Noir1Click(Sender: TObject);
   private
   GLContext: HGLRC;
   glDC: HDC;
   piece_Cav:GLUquadricObj;

 (*....................  le regard sur la scène   .......................¨.*)
  // variables pour le changement de point de vue de la scène avec:
  // gluLookAt(ex,ey, ez,cx,cy,cz,upx,upy,upz : GLdouble );
    Oeil_ex,Oeil_ey,Oeil_ez    : GLdouble;  // Coordonnées de l'oeil observateur
    Cible_cx,Cible_cy,Cible_cz : GLdouble;  // Coordonnées du point de mire
    Rep_upx,Rep_upy,Rep_upz    : GLdouble;  // Coordonnées du repère courant
    fi, teta, rotxOy, coefzoom, coefzoom_rot : real ;
    vitesse_rot, bloczoom : integer ;
    wx,wy,tz,winZ: gldouble;
    realy:gldouble;
    mvmatrix,projmatrix:array[0..15]of Gldouble;
    viewport:array[0..3]of Gldouble;

  public
    { Public declarations }
  end;

  var
   Form3: TForm3;
   split,split2 :Boolean;
   index_x,index_y : integer;
   tic_Intro:integer;
   tac_Intro:integer;

 implementation

{$R *.dfm}

//  La fonction qui nous permet de définir la texture active est la suivante
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


procedure TForm3.PartieClick(Sender: TObject);
begin
piece_en_main := A_Partie ;
end;

procedure TForm3.Quit1Click(Sender: TObject);
begin
piece_en_main := A_zero ;
Close ;
end;

procedure TForm3.RB_CavalierClick(Sender: TObject);
begin
 piece_en_main := A_cavalier;


end;

procedure TForm3.RB_TextureBoisClick(Sender: TObject);
begin
   texture[14]:= texture[7];
   texture[15]:= texture[8];
   texture[16]:= texture[9];
   formpaint(self);
end;

procedure TForm3.RB_TextureMarbreClick(Sender: TObject);
begin
   texture[14]:= texture[10];
   texture[15]:= texture[11];
   texture[16]:= texture[12];
   formpaint(self);
end;

procedure TForm3.SBt_SEClick(Sender: TObject);
begin
 Oeil_ez := Oeil_ez  + 1 ;
 FormResize(Sender);
end;

procedure TForm3.SBt_SOClick(Sender: TObject);
begin
Oeil_ez := Oeil_ez  - 1 ;
FormResize(Sender);
end;

procedure TForm3.SBt_SudClick(Sender: TObject);
begin
Oeil_ex := Oeil_ex  - 1 ;
//glRotate(1, cos(rotxOy*6.28/360), sin(rotxOy*6.28/360), 0);
teta := teta+1;

FormResize(Sender);
end;


procedure TForm3.SBt_SudMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Oeil_ex := Oeil_ex  - 1 ;  if Oeil_ex<1 then Oeil_ex  := 1 ;
 FormResize(Sender);
end;

procedure TForm3.testpClick(Sender: TObject);
begin
piece_en_main := A_partie ;
init_plateau ;
end;

procedure TForm3.SBt_EstClick(Sender: TObject);
begin
 Oeil_ey := Oeil_ey  + 1 ;
 FormResize(Sender);
end;

procedure TForm3.SBt_OuestClick(Sender: TObject);
begin
Oeil_ey := Oeil_ey  - 1 ;
FormResize(Sender);
end;

procedure TForm3.SBt_NOClick(Sender: TObject);
begin
 Oeil_ez := Oeil_ez  + 1 ;
 FormResize(Sender);
end;

procedure TForm3.SBt_NordClick(Sender: TObject);
begin
 Oeil_ez := Oeil_ez  + 1 ;
 FormResize(Sender);
end;

procedure TForm3.SBt_NordMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Oeil_ex := Oeil_ex  + 1 ;
 FormResize(Sender);
end;


procedure TForm3.FormCreate(Sender: TObject);
var
pfd: TPixelFormatDescriptor;
FormatIndex: integer;
i,j: integer;

begin
initbitboards;            // indispensable pour leur utilisation !
fillchar(pfd,SizeOf(pfd),0);

with pfd do
    begin
      nSize := SizeOf(pfd);
      nVersion := 1;     //La version courrante du desccripteur est 1
      dwFlags := PFD_DRAW_TO_WINDOW or PFD_SUPPORT_OPENGL or PFD_DOUBLEBUFFER;
      iPixelType := PFD_TYPE_RGBA;
      cColorBits := 24;
      cDepthBits := 32;
      iLayerType := PFD_MAIN_PLANE;
    end;

// glfwInit ();

  glDC := getDC(handle);
  FormatIndex := ChoosePixelFormat(glDC,@pfd);
  SetPixelFormat(glDC,FormatIndex,@pfd);
  GLContext := wglCreateContext(glDC);
  wglMakeCurrent(glDC,GLContext);
  glEnable(GL_COLOR_MATERIAL);
  glEnable(GL_DEPTH_TEST);

  glDepthFunc(GL_LEQUAL);
  glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);

 // ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
 //  nous initialisons les textures utilisées par l'application
 //¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
   glEnable(GL_TEXTURE_2D); //  valide l'utilisation des textures2D

  init_textures ;       // initialisation des textures
  init_piece_mesh ;      // initialisation des six mesh ( une par pièce )

 //////////////////////////////////////////////////////////////////////////////
 // chargement des objets meshs ( type File3ds , fichiers 3ds )
 //  model.load3ds('mesh/le_cavalier_blanc.3DS');
 //  model.load3ds('mesh/StauntonKnight.3DS');
 //  model.load3ds('mesh/StauntonKing.3DS');
 //model.load3ds('mesh/le_cavalier_blanc.3DS');
 // M2.load3ds('mesh/boss.3DS');
 /////////////////////////////////////////////////////////////////////////////

  // ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
 //  nous créons les cubes représentant l'échiquier
 //¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

   for I := 0 to 7 do //  création des cubes du plateau
   for j := 0 to 7 do //  création des cubes du plateau
     begin
       cube[i,j].ligne   := i ;         // abcisse de la case
       cube[i,j].colonne := j;          // ordonnée  de la case
       cube[i,j].num     := i*8+j;      // numéro de la case [0..63)]
       cube[i,j].select  := false;      // case sélectionnée
       cube[i,j].index   := false;      // case sélectionnée
       cube[i,j].piece   := A_zero;     // type de pièce occupant la case
       cube[i,j].couleur := aucune;     // couleur de la pioece occupant la case
    end;

 // ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
 //   dernière variables à initialiser
 //¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

  g_Count  :=10;                // nombre de cube par arète: 8 cases 2 bords
  g_Medio  := g_Count div 2;    // on repère le centre de l'échiquier
  g_Arete  :=2;                // distance entre les cubes
  split := false;              // pas d'éclatement de l'échiquier par défaut
  Oeil_ex :=25;       // oeil camera   : x
  Oeil_ey :=0;        // oeil camera   : y
  Oeil_ez :=25;       // oeil camera   : z
  Cible_cx :=0;       // centre scene  : x
  Cible_cy :=0;       // centre scene  : y
  Cible_cz :=0;       // centre scene  : z
  Rep_upx  :=0;
  Rep_upy  :=0;
  Rep_upz  :=1;
  vitesse_rot := 1;
  coefzoom := 1.05 ;
  coefzoom_rot := 1 ; // influence du zoom sur la rotation

  mode_camera := 0 ;


  bloczoom := 10 ;

  rotxOy         := 90  ;
  fi             := 0  ;
  teta           := 45 ;
  rotxOy         := 90  ;

  horizon_b := false;
  spin_x:=0;          // un réel pour  angles x de rotation : sphères int/ext
  spin_y:=0;          // un réel pour  angles y de rotation : sphères int/ext
  spin_z:=180;        // un réel pour  angles z de rotation : sphères int/ext
  spin_bat:=0;        // un réel pour  angles x,y,z de rotation : sphère:trait
  spin_index:=0;      // un réel pour  angles x,y,z de rotation : sphère:index
  spin_ext :=0;
  spin_piece := 0;
  blanc_au_trait := true;
  angle:=1;
  segment:= 1;
  taille:=1;
//  case_depart := -1 ;
  coup_depart := true ;
  selection := false ;
  actif_selection := false ;

//  case_depart := -1
//  case_arrive : TCase;
//
//   num_en_cours : integer;
  num_depart := -1 ;
//   num_arrive : integer;

  modif_taille  := false ;
  modif_pos_rot :=false ;
  modif_pos_tran :=false ;
  num_en_cours := 0;
  piece_en_main := A_zero ;

 // horizon sphere : création de deux sphere pleines co-inscrites
  sphere_Int:= gluNewQuadric();
  gluQuadricDrawStyle(sphere_Int, GLU_FILL);
  gluQuadricNormals(sphere_Int, GLU_SMOOTH);
  gluQuadricTexture(sphere_Int, GL_TRUE);

  sphere_Ext:= gluNewQuadric();
  gluQuadricDrawStyle(sphere_Ext, GLU_FILL);
  gluQuadricNormals(sphere_Ext, GLU_SMOOTH);
  gluQuadricTexture(sphere_Ext, GL_TRUE);

  // sphère signalant la couleur au trait
  sphere_trait := gluNewQuadric();
  gluQuadricDrawStyle(sphere_trait, GLU_FILL);
  gluQuadricNormals(sphere_trait, GLU_SMOOTH);
  gluQuadricTexture(sphere_trait, GL_TRUE);

   //  sphère indexant une case
  sphere_index := gluNewQuadric();
  gluQuadricDrawStyle(sphere_index, GLU_FILL);
  gluQuadricNormals(sphere_index, GLU_SMOOTH);
  gluQuadricTexture(sphere_index, GL_TRUE);

  piece_Cav := gluNewQuadric();		       // sphère pour simuler un cavalier
  gluQuadricDrawStyle(piece_Cav, GLU_FILL);    // en attendant la maitrise
  gluQuadricNormals(piece_Cav, GLU_SMOOTH);    // des fichiers mesh
  gluQuadricTexture(piece_Cav, GL_TRUE);       // qui ne saurait tarder

  glEnable(GL_COLOR_MATERIAL);
  glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);

  // on selection la texture bois par defaut!
  RB_TextureBoisClick(Sender); // en simulant un clic sur le radio_bouton
 //¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
  end;

procedure TForm3.FormDestroy(Sender: TObject);
begin
wglMakeCurrent(Canvas.Handle,0);
wglDeleteContext(GLContext);
end;

procedure TForm3.FormResize(Sender: TObject);
begin
if (Height = 0) then                // prevent divide by zero exception
    Height := 1;
   glViewport(0, 0, Width, Height);    // Set the viewport for the OpenGL window
   glMatrixMode(GL_PROJECTION);        // Change Matrix Mode to Projection
   glLoadIdentity();                   // Reset View
   gluperspective(45,width/height,1,256);
   glulookat(Oeil_ex ,Oeil_ey ,Oeil_ez
            ,Cible_cx,Cible_cy,Cible_cz
            ,Rep_upx,Rep_upy,Rep_upz);
   glMatrixMode(GL_MODELVIEW);         // Return to the modelview matrix
   glLoadIdentity();

end;



procedure TForm3.Fou_promClick(Sender: TObject);
var  Str_score: string;
begin
  plateau_actuel[num_arrive,0] := A_fou ;
  Promotion_panel.Visible := False ;
  promotion_faite := A_fou ;

   if plateau_actuel[num_arrive,1]>0
      then begin
               Arbre_jeu^.pos.plateau[noir][num_arrive] :=
                          plateau_actuel[num_arrive,blanc];
               inc(Arbre_jeu^.pos.pieces[blanc][bishop]);
      end
      else begin
               Arbre_jeu^.pos.plateau[noir][num_arrive] :=
                          plateau_actuel[num_arrive,blanc];
               inc(Arbre_jeu^.pos.pieces[noir][bishop]);
      end;

  if num_arrive > 40 then
    BtB_fou_dame[0] := BtB_fou_dame[0] or Btb[num_arrive]
  else
    BtB_fou_dame[1] := BtB_fou_dame[1] or Btb[num_arrive];


         Arbre_jeu^.score:=score_matériel(Arbre_jeu );
         Str_score :=inttostr(Arbre_jeu^.score);
    pnl_score.Caption:= ' score = ' +Str_score;
   promue:= true ;
  end;

procedure TForm3.Libre1Click(Sender: TObject);
begin
mode_camera := 0 ;
Oeil_ex := 25 ;
Oeil_ey := 0  ;
Oeil_ez := 25 ;

coefzoom_rot := 1 ;
rotxOy   := 90  ;
fi     := 0  ;
teta   := 45 ;
rotxOy := 90  ;

bloczoom := 2 ;
coefzoom := 1.05 ;

FormResize(Sender);

end;

procedure TForm3.MarbreClick(Sender: TObject);
begin
texture[14]:= texture[10];
texture[15]:= texture[11];
texture[16]:= texture[12];
formpaint(self);
end;

procedure TForm3.Newgame1Click(Sender: TObject);
begin
Initarbre(Arbre_calcul);
piece_en_main := A_partie ;
init_plateau ;
Lister_Essais(Arbre_calcul,0,Alliees[0],Alliees[1]);
if Arbre_calcul = NIL then
  ShowMessage('d''api');
arbre_pos_actuelle := Arbre_calcul ;
mode_camera := 1 ;
Oeil_ex := 0 ;
Oeil_ey := -25  ;
Oeil_ez := 25 ;
FormResize(Sender);
end;

procedure TForm3.Noir1Click(Sender: TObject);
begin
if contre_ordi and (couleur_ordi = 0) and (arbre_pos_actuelle <> NIL) then
begin
  couleur_ordi := 1 ;
  ordi_joue ;
  mode_camera := 3 ;
  Oeil_ex := 0 ;
  Oeil_ey := 25  ;
  Oeil_ez := 25 ;

FormResize(Sender);
end;
end;

procedure TForm3.FormPaint(Sender: TObject);

begin
  glClearColor(0.7, 0.7, 0.7, 1.0);
  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);        // Clear the colour buffer
  AfficheCases();
  swapbuffers(gldc);
end;


procedure TForm3.Blancs1Click(Sender: TObject);
begin
if contre_ordi and (couleur_ordi = 1) and (arbre_pos_actuelle <> NIL) then
begin
  couleur_ordi := 0 ;
  ordi_joue ;

  mode_camera := 2 ;
  Oeil_ex := 0 ;
  Oeil_ey := -25  ;
  Oeil_ez := 25 ;

FormResize(Sender);
end;

end;

procedure TForm3.BNtn_HorizonClick(Sender: TObject);
begin
horizon_b := not horizon_b ;
end;

procedure TForm3.Bois1Click(Sender: TObject);
begin
texture[14]:= texture[7];
texture[15]:= texture[8];
texture[16]:= texture[9];
formpaint(self);
end;

procedure TForm3.BtnSplitClick(Sender: TObject);
begin
  split := Not Split;            // eclatement ou non?
  if split
      then g_Arete  :=3
      else g_Arete  :=2;        // distance entre les cubes
  formpaint(self);
end;


procedure TForm3.Button1Click(Sender: TObject);
begin
Close;
end;


procedure TForm3.Button2Click(Sender: TObject);

begin
piece_en_main := A_partie ;
init_plateau ;

end;

procedure TForm3.Cavalier_promClick(Sender: TObject);
var  Str_score: string;
begin
  plateau_actuel[num_arrive,0] := A_cavalier ;
  Promotion_panel.Visible := False ;
  promotion_faite := A_cavalier ;

   if plateau_actuel[num_arrive,1]>0
      then begin
               Arbre_jeu^.pos.plateau[noir][num_arrive] :=
                          plateau_actuel[num_arrive,blanc];
               inc(Arbre_jeu^.pos.pieces[blanc][knight]);
      end
      else begin
               Arbre_jeu^.pos.plateau[noir][num_arrive] :=
                          plateau_actuel[num_arrive,blanc];
               inc(Arbre_jeu^.pos.pieces[noir][knight]);
      end;


  if num_arrive > 40 then
    BtB_cavalier[0] := BtB_cavalier[0] or Btb[num_arrive]
  else
    BtB_cavalier[1] := BtB_cavalier[1] or Btb[num_arrive] ;

         Arbre_jeu^.score:=score_matériel(Arbre_jeu );
         Str_score :=inttostr(Arbre_jeu^.score);
    pnl_score.Caption:= ' score = ' +Str_score;
  promue:= true ;
end;

procedure TForm3.HorizonClick(Sender: TObject);
begin
horizon_b := not horizon_b;
end;

procedure TForm3.Dame_promClick(Sender: TObject);
var  Str_score: string;
begin
  plateau_actuel[num_arrive,0] := A_dame ;
  Promotion_panel.Visible := False ;
  promotion_faite := A_dame ;

   if plateau_actuel[num_arrive,1]>0
      then begin
               Arbre_jeu^.pos.plateau[noir][num_arrive] :=
                          plateau_actuel[num_arrive,blanc];
               inc(Arbre_jeu^.pos.pieces[blanc][queen]);
      end
      else begin
               Arbre_jeu^.pos.plateau[noir][num_arrive] :=
                          plateau_actuel[num_arrive,blanc];
               inc(Arbre_jeu^.pos.pieces[noir][queen]);
      end;

  if num_arrive > 40 then
  begin
    BtB_tour_dame[0] := BtB_tour_dame[0] or Btb[num_arrive] ;
    BtB_fou_dame[0] := BtB_fou_dame[0] or Btb[num_arrive]
  end
  else
  begin
    BtB_tour_dame[1] := BtB_tour_dame[1] or Btb[num_arrive]  ;
    BtB_fou_dame[1] := BtB_fou_dame[1] or Btb[num_arrive] ;
  end;

         Arbre_jeu^.score:=score_matériel(Arbre_jeu );
         Str_score :=inttostr(Arbre_jeu^.score);
    pnl_score.Caption:= ' score = ' +Str_score;
  promue:= true ;
end;

procedure TForm3.Devantjoueurautrait1Click(Sender: TObject);
begin
mode_camera := 1 ;
end;

procedure TForm3.Devantjoueurauxblancs1Click(Sender: TObject);
begin
mode_camera := 2 ;
Oeil_ex := 0 ;
Oeil_ey := -25  ;
Oeil_ez := 25 ;

FormResize(Sender);
end;

procedure TForm3.Devantjoueurauxnoirs1Click(Sender: TObject);
begin
mode_camera := 3 ;
Oeil_ex := 0 ;
Oeil_ey := 25  ;
Oeil_ez := 25 ;

FormResize(Sender);
end;

procedure TForm3.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var   rang,col : integer;             // ligne & colonne en chiffre
      str_rang,str_col: string ;      // ligne & colonne en lettres      souris:TMouseButton ;
  begin

//------------------------------------------------
  viewport[0] := 0;
  viewport[1] := 0;
  viewport[2] := ClientWidth;
  viewport[3] := ClientHeight;

  glGetIntegerv (GL_VIEWPORT, @viewport);
  glGetDoublev (GL_MODELVIEW_MATRIX, @mvmatrix);
  glGetDoublev (GL_PROJECTION_MATRIX, @projmatrix);

//viewport[3] est la hauteur de la fenêtre en pixels

  realy := viewport[3] - y-1 ;

  if( Y = 0 )then Y := 1;
  glReadPixels(	X, -Y, width, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @winZ );

  gluUnProject (x,  realy,0,
  @mvmatrix, @projmatrix, @viewport, wx, wy, winz);
  tz:=winz/(Oeil_ez-winz);


//______ repère la case visée par la souris _____________________

 col := round((tz*(wx-Oeil_ex )+wx +(g_Medio* g_Arete))/2)-1;
 rang :=round(((wy-Oeil_ey)*tz+wy +(g_Medio* g_Arete))/2) -1;
 str_rang :='';
 str_col:='';

   if ((rang in [1..8]) and (col in [1..8]))
      then
        begin     // souris sur une case
             str_col:= string(char(64+col));
        end;
                  //  on affiche la case en alpha numérique [A1..H8]


end;

//______________________________________________________________________________

procedure TForm3.FormMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);

var   rang,col,trait : integer;             // ligne & colonne en chiffre      str_col: string ;      // ligne & colonne en lettres
//      BtB_cible : TBitboard ;
      capture : byte;         // variable temporaire pour ajustement du score
      promotion: byte;        // variable temporaire pour ajustement du score
      depart   : byte;
      arrivee   : byte;
      piece   : byte;
      Str_score: string;
      coup_joue : integer ;
      parcourt_liste : Parbre_coups ;
      eval_max : integer ;
      test : integer ;
 begin

if (Button = mbleft) then begin
//------------------------------------------------
  viewport[0] := 0;
  viewport[1] := 0;
  viewport[2] := ClientWidth;
  viewport[3] := ClientHeight;

  glGetIntegerv (GL_VIEWPORT, @viewport);
  glGetDoublev (GL_MODELVIEW_MATRIX, @mvmatrix);
  glGetDoublev (GL_PROJECTION_MATRIX, @projmatrix);

  realy := viewport[3] - y-1 ;
  if( Y = 0 )then Y := 1;
  glReadPixels(	X, -Y, width, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @winZ );
  gluUnProject (x, realy,0,@mvmatrix, @projmatrix, @viewport, wx, wy, winz);
  tz:=winz/(Oeil_ez-winz);

//______ repère la case visée par la souris _____________  modif  _________

 col := round((tz*(wx-Oeil_ex )+wx +(g_Medio* g_Arete))/2)-1;
 rang :=round(((wy-Oeil_ey)*tz+wy +(g_Medio* g_Arete))/2) -1;

 if ((rang in [1..8]) and (col in [1..8])) then
  begin
      capture   :=0;   //init. variable temporaire pour ajustement du score
      promotion :=0;   //init. variable temporaire pour ajustement du score
//      depart    :=0;
//      arrivee   :=0;
//      piece     :=0;

  // gestion du coup
    if blanc_au_trait then
      trait_blanc := 1
    else
      trait_blanc := -1 ;

    if mode = 1 then
    begin
      case_en_cours :=cube[rang-1,col-1]; // [-1] : carré 8x8 dans carré 10x10
      num_clic := (rang-1)*8 + col-1;
    end
    else
    begin
      if coup_depart  then
      begin

        case_depart := cube[rang-1,col-1];      // coordonnées de depart
        num_depart := (rang-1)*8 + col-1;
        actif_selection := true ;              // surligne la case selectionnée
        if plateau_actuel[num_depart,1] = trait_blanc then
        begin

           FSOUND_PlaySound(FSOUND_FREE, clic); // Son de selection

           if blanc_au_trait then
             Btb_affichage_cible := Creer_BtB_cible(num_depart,Alliees[0])
           else
             Btb_affichage_cible := Creer_BtB_cible(num_depart,Alliees[1]);

           coup_depart := not coup_depart
        end
        else
           actif_selection := false ;        // case de départ deselectionnée
      end
      else
      begin
        case_arrive := cube[rang-1,col-1];      // coordonnées d'arrivée
        num_arrive := (rang-1)*8 + col-1;
        if (trait_blanc =1)then
          trait := 0
          else
          trait := 1 ;

        if ((Btb[num_arrive] and Btb_affichage_cible > 0 ) and //then
                   (not Coup_impossible(trait,num_depart,num_arrive ))) then
        begin
           MaJ_BtB_piece ;
           // on envisage un nouveau demi coup!
           inc(Mi_Coup_actuel); // on incrélmente le compteur de demi coups!

           promotion := 0 ;
           piece_deplacee := plateau_actuel[num_depart,0];
           piece_capturee := plateau_actuel[num_arrive,0];
           depart    := num_depart;
           arrivee   := num_arrive;
           piece     := plateau_actuel[num_depart,0];
           capture   := plateau_actuel[num_arrive,0]; // qu'elle existe ou pas !


          FSOUND_PlaySound(FSOUND_FREE, clic); // Son du mouvement

          plateau_actuel[num_arrive,0] := plateau_actuel[num_depart,0] ;
          plateau_actuel[num_depart,0] := A_zero ;
          plateau_actuel[num_arrive,1] := plateau_actuel[num_depart,1] ;
          plateau_actuel[num_depart,1] := 0;       // mouvement de la pièce
          Arbre_jeu^.pos.plateau[num_depart][trait] :=  plateau_actuel[num_depart,trait] ;
          Arbre_jeu^.pos.plateau[num_arrive][trait] :=  plateau_actuel[num_arrive,trait] ;

          // promotion  ; prise en passant


          if (plateau_actuel[num_arrive,0] = A_pion) then
          begin
             if num_arrive = En_passant then
             begin
               if num_depart < num_arrive then
               begin
                  capture := A_pion; // capture le pion noir ! (pour le score )
                  plateau_actuel[num_arrive-8,A_piece]:= A_zero ;
                  plateau_actuel[num_arrive-8,camp]:= 0 ;
                  arrivee   := num_arrive -8;

                  Arbre_jeu^.pos.plateau[blanc][num_arrive-8] :=
                                 plateau_actuel[num_arrive-8,blanc] ;
                  Arbre_jeu^.pos.plateau[noir][num_arrive-8] :=
                                 plateau_actuel[num_arrive-8,noir] ;

                  BtB_pions[1] := BtB_pions[1]and ((Btb_64) xor Btb[num_arrive-8]) ;
                  Alliees[1] := Alliees[1]and ((Btb_64) xor Btb[num_arrive-8]) ;
                  toutes := toutes and ((Btb_64) xor Btb[num_arrive-8]) ;
               end
               else
               begin
                  capture := A_pion; // capture le pion blanc! (pour le score )
                  plateau_actuel[num_arrive+8,0]:= A_zero ;
                  plateau_actuel[num_arrive+8,1]:= 0 ;
                  arrivee   := num_arrive +8;
                  BtB_pions[0] := BtB_pions[0]and ((Btb_64) xor Btb[num_arrive+8]) ;
                  Alliees[0] := Alliees[0]and ((Btb_64) xor Btb[num_arrive+8]) ;
                  toutes := toutes and ((Btb_64) xor Btb[num_arrive+8]) ;
               end;

             end;

             if ((Btb[Num_depart] and rang_7) > 0 and
                (Btb[num_arrive] and rang_5)) or
                ((Btb[Num_depart] and rang_2) > 0 and
                (Btb[num_arrive] and rang_4)) then
             begin
                En_passant := (num_depart + num_arrive) div 2 ;
             end
             else
                En_passant := -1 ;

             if ((Btb[num_arrive] and ( rang_1 or rang_8 )) > 0 ) then
             begin
               Ajuste_panel_promotion();  // pour affiche des pièces couleur
               Promotion_panel.Visible := True ;  // identique à la promotion
               promotion :=plateau_actuel[num_arrive,0];
               promue := false ;


               BtB_pions[1] := BtB_pions[1] and ((Btb_64) xor Btb[num_arrive]) ;
               BtB_pions[0] := BtB_pions[0] and ((Btb_64) xor Btb[num_arrive]) ;
             end;


          end
          else
             En_passant := -1 ;

          // roque

          if (plateau_actuel[num_arrive,0] = A_roi) then
          begin

            if num_depart = e1 then  // test du roque => mouvement de la tour
              begin
                if num_arrive = c1 then
                begin
                  plateau_actuel[d1,0] := plateau_actuel[a1,0] ;
                  plateau_actuel[d1,1] := plateau_actuel[a1,1] ;

                  plateau_actuel[a1,0] := A_zero ;
                  plateau_actuel[a1,1] := 0 ;
                  Alliees[0] := (Alliees[0] xor Btb[a1]) or Btb[d1] ;
                  toutes := (toutes xor Btb[a1]) or Btb[d1] ;
                  BtB_tour_dame[0]:= (BtB_tour_dame[0] xor Btb[a1]) or Btb[d1] ;
                end;

                if num_arrive = g1 then
                begin
                  plateau_actuel[f1,0] := plateau_actuel[h1,0] ;
                  plateau_actuel[f1,1] := plateau_actuel[h1,1] ;

                  plateau_actuel[h1,0] := A_zero ;
                  plateau_actuel[h1,1] := 0 ;
                  Alliees[0] := (Alliees[0] xor Btb[h1]) or Btb[f1] ;
                  toutes := (toutes  xor Btb[h1]) or Btb[f1] ;
                  BtB_tour_dame[0]:= (BtB_tour_dame[0] xor Btb[h1]) or Btb[f1] ;
                end;
              end;

            if num_depart = e8 then
              begin
                if num_arrive = c8 then
                begin
                  plateau_actuel[d8,0] := plateau_actuel[a8,0] ;
                  plateau_actuel[d8,1] := plateau_actuel[a8,1] ;

                  plateau_actuel[a8,0] := A_zero ;
                  plateau_actuel[a8,1] := 0 ;
                  Alliees[1] := (Alliees[1] xor Btb[a8]) or Btb[d8] ;
                  toutes := (toutes  xor Btb[a8]) or Btb[d8] ;
                  BtB_tour_dame[1]:= (BtB_tour_dame[1] xor Btb[a8]) or Btb[d8] ;
                end;

                if num_arrive = g8 then
                begin
                  plateau_actuel[f8,0] := plateau_actuel[h8,0] ;
                  plateau_actuel[f8,1] := plateau_actuel[h8,1] ;

                  plateau_actuel[h8,0] := A_zero ;
                  plateau_actuel[h8,1] := 0 ;
                  Alliees[1] := (Alliees[1] xor Btb[h8]) or Btb[f8] ;
                  toutes := (toutes  xor Btb[h8]) or Btb[f8] ;
                  BtB_tour_dame[1]:= (BtB_tour_dame[1] xor Btb[h8]) or Btb[f8] ;

                end;
              end;

            if (plateau_actuel[num_arrive,1] = 1) then
            begin                       // roi bouge => roque interdit
              O_O_O_B := O_O_O_B or Btb[e1];
              O_O_B := O_O_B or Btb[e1];
            end
            else
            begin
              O_O_O_N := O_O_O_N or Btb[e8];
              O_O_N := O_O_N or Btb[e8];
            end;

          end;

          // tour bouge , ou est prise
          if (num_depart = a1) or (num_arrive = a1) then
          begin
             O_O_O_B := O_O_O_B or Btb[e1];
          end;

          if (num_depart = h1) or (num_arrive = h1) then
          begin
             O_O_B := O_O_B or Btb[e1];
          end;

          if (num_depart = a8) or (num_arrive = a8) then
          begin
             O_O_O_N := O_O_O_N or Btb[e8];
          end;

          if (num_depart = h8) or (num_arrive = h8) then
          begin
             O_O_N := O_O_N or Btb[e8];
          end;

//          Arbre_jeu^.Liste_Coups[Mi_Coup_actuel]:=
//             empile_coup( capture, promotion,depart,arrivee, piece);

           blanc_au_trait := not blanc_au_trait ; // autre joueur de jouer


          // ù^ù  etablir la liste de coup possible ici

          coup_joue := empile_coup(piece_capturee,promotion_faite,num_depart,
                                   num_arrive,piece_deplacee);

          parcourt_liste := arbre_pos_actuelle ;

          while ((parcourt_liste <> NIL) and (coup_joue <> parcourt_liste^.coup)) do
          begin
            parcourt_liste := parcourt_liste^.coup_suivant ;
          end;


          if parcourt_liste = NIL then
            showmessage('crash')
          else
            arbre_pos_actuelle := parcourt_liste ;



          if blanc_au_trait
              then Lister_Essais(arbre_pos_actuelle^.pos_obtenu,blanc,Alliees[0],Alliees[1])
              else Lister_Essais(arbre_pos_actuelle^.pos_obtenu,noir,Alliees[1],Alliees[0]) ;

          arbre_pos_actuelle := arbre_pos_actuelle^.pos_obtenu ;



          // coup de l'ordi , s'il y a lieu
          if contre_ordi and (couleur_ordi = trait) and (arbre_pos_actuelle <> NIL) then
          begin
//            showmessage('flemme, fait le');
//            parcourt_liste := arbre_pos_actuelle ;
//            eval_max := 0 ;
//            test := 0 ;
//            while parcourt_liste <> NIL do
//            begin
//              if parcourt_liste^.eval > eval_max then
//              begin
//                eval_max := parcourt_liste^.eval ;
//                arbre_pos_actuelle := parcourt_liste ;
//              end;
//              parcourt_liste := parcourt_liste^.coup_suivant ;
//            end;
//
//            showmessage('j''ai fait ' + inttostr(test) + ' tests');
            ordi_joue;// jouer.pas
//
//            blanc_au_trait := not blanc_au_trait ;

//            coup_joue := empile_coup(piece_capturee,promotion_faite,num_depart,
//                                   num_arrive,piece_deplacee);
//
//          parcourt_liste := arbre_pos_actuelle ;
//
//          while ((parcourt_liste <> NIL) and (coup_joue <> parcourt_liste^.coup)) do
//          begin
//            parcourt_liste := parcourt_liste^.coup_suivant ;
//          end;
//
//
//          if parcourt_liste = NIL then
//            showmessage('crash')
//          else
//            arbre_pos_actuelle := parcourt_liste ;
//
//
//            if blanc_au_trait
//              then Lister_Essais(arbre_pos_actuelle^.pos_obtenu,blanc,Alliees[0],Alliees[1])
//              else Lister_Essais(arbre_pos_actuelle^.pos_obtenu,noir,Alliees[1],Alliees[0]) ;
//            arbre_pos_actuelle := arbre_pos_actuelle^.pos_obtenu ;
//
//          end;

          end;
          // reajustement de la camera si necessaire


          if mode_camera = 1 then
          begin
            if blanc_au_trait then
            begin
              Oeil_ex := 0 ;
              Oeil_ey := -25  ;
              Oeil_ez := 25 ;
            end
            else
            begin
              Oeil_ex := 0 ;
              Oeil_ey := 25  ;
              Oeil_ez := 25 ;
            end;
          end;



        end;
        actif_selection := false ;          // case de départ deselectionnée
        coup_depart := not coup_depart ;
        Btb_affichage_cible := 0 ;
      end;

    end;


  // gestion du coup


      Affiche_index(rang-1,col-1 );


       // ajuste le score score_matériel
       if (capture + promotion) > 0 then
         begin
         score_ajust(Arbre_jeu,trait_blanc,capture,promotion); // ajuste le score
         Arbre_jeu^.score:=score_matériel(Arbre_jeu );
         Str_score :=inttostr(Arbre_jeu^.score);
         pnl_score.Caption:= ' score = ' +Str_score;
        // showmessage(' score = ' +Str_score);
        // pour visualiser le score en mose débutant!
         end;
  end;


FormResize(Sender);

end;
 end;

//______________________________________________________________________________

procedure TForm3.Btn_OrionClick(Sender: TObject);
var temp : glUint;
begin

   temp:= texture[6];  //  swap orion et ciel_
   texture[6]:= texture[25];
   texture[25]:= temp;
end;

procedure TForm3.Btn_ResetClick(Sender: TObject);
begin

Oeil_ex :=25;
Oeil_ey :=0;
Oeil_ez :=25;
Cible_cx :=0;
Cible_cy :=0;
Cible_cz :=0;
Rep_upx  :=0;
Rep_upy  :=0;
Rep_upz  :=1;
coefzoom_rot := 1 ;
rotxOy   := 90  ;
fi     := 0  ;
teta   := 45 ;
rotxOy := 90  ;

piece_en_main := A_zero ;
FormResize(Sender);
end;


procedure TForm3.Btn_Split_2Click(Sender: TObject);
begin
  split2 := Not Split2;            // eclatement ou non?
  split:= false;
  if split2
      then g_Arete  :=7
      else g_Arete  :=2;        // distance entre les cubes
end;

//____________________________________________________________________________
//  gestion des actions clavier
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

// Timer pour gestion des rotations de shères ( variation des angles )

procedure TForm3.TimerIntroTimer(Sender: TObject);
var
   i,j : integer;
begin

   i:=num_en_cours and 7;
   j:= num_en_cours shr 3;

   Tic_intro:= (Tic_intro+1) mod 64; // mod 64 -> pour revenir au debut de table
   blanc_au_trait := not blanc_au_trait ;
   if Tic_Intro<>Tac_Intro then
     begin
         num_en_cours := Euler[Tic_intro] ;  // la valeur suivante dans la table!  mod 64
           cube[i,j].select := true;
           case_en_cours := cube[i,j] ;
           num_clic :=i*8 +j;
           Affiche_index(i,j);
           Affiche_mesh(piece_en_main,i,j);
           formpaint(Sender);

     end
     else
      begin
         num_en_cours := Euler[Tic_intro] ;  // la valeur suivante dans la table!  mod 64
           cube[i,j].select := true;
           case_en_cours := cube[i,j] ;
           num_clic :=i*8 +j;
           Affiche_index(i,j);
           Affiche_mesh(piece_en_main,i,j);
           formpaint(Sender);

         TimerIntro.Enabled:= false;  // stop timer! c'est la dernière boucle!
         TimerSpheres.Enabled:= true;  // relance le timer des spheres !
     end;


end;

procedure TForm3.TimerSpheresTimer(Sender: TObject);
begin
  formpaint(Sender);
  spin_x := spin_x +0.03; if spin_x >359.97 then spin_x :=0;
  spin_bat := spin_bat -2.5; if spin_bat < 2.5 then spin_bat :=360;
  spin_index := spin_index -36.0; if spin_index < 36.0 then spin_index :=360;
  spin_ext := spin_ext -5.0; if spin_ext < 5.0 then spin_ext :=360;
  spin_piece := spin_piece -5.0; if spin_piece < 5.0 then spin_piece :=360;
end;


 procedure TForm3.Tour_promClick(Sender: TObject);
var  Str_score: string;
begin
  plateau_actuel[num_arrive,0] := A_tour ;
  Promotion_panel.Visible := False ;
  promotion_faite := A_tour ;

   if plateau_actuel[num_arrive,1]>0
      then begin
               Arbre_jeu^.pos.plateau[noir][num_arrive] :=
                          plateau_actuel[num_arrive,blanc];
               inc(Arbre_jeu^.pos.pieces[blanc][rook]);
      end
      else begin
               Arbre_jeu^.pos.plateau[noir][num_arrive] :=
                          plateau_actuel[num_arrive,blanc];
               inc(Arbre_jeu^.pos.pieces[noir][rook]);
      end;

  if num_arrive > 40 then
    BtB_tour_dame[0] := BtB_tour_dame[0] or Btb[num_arrive]
  else
    BtB_tour_dame[1] := BtB_tour_dame[1] or Btb[num_arrive];

         Arbre_jeu^.score:=score_matériel(Arbre_jeu );
         Str_score :=inttostr(Arbre_jeu^.score);
    pnl_score.Caption:= ' score = ' +Str_score;
   promue:= true ;
end;

procedure TForm3.OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
     i,j: Integer;
 begin
  if mode_camera = 0 then
  begin
   Case  Key of
//    VK_UP, VK_NUMPAD8  :
//     begin
//        Oeil_ex := Oeil_ex /coefzoom;
//        Oeil_ey := Oeil_ey /coefzoom;
//        Oeil_ez := Oeil_ez /coefzoom;
//     end;
//
//    VK_DOWN, VK_NUMPAD2 :
//      begin
//        glRotate(-1, cos(rotxOy*6.28/360) , sin(rotxOy*6.28/360), 0);
//        teta := teta-1;
//      end;

    VK_RIGHT, VK_NUMPAD6:
      begin
        Oeil_ex := Oeil_ex + sin(fi*6.28/360);
        Oeil_ey := Oeil_ey + cos(fi*6.28/360);
        fi := fi - 2.15 / coefzoom_rot ;
      end;

    VK_LEFT ,VK_NUMPAD4 :
      begin
        Oeil_ex := Oeil_ex - sin(fi*6.28/360);
        Oeil_ey := Oeil_ey - cos(fi*6.28/360);
        fi := fi + 2.15 / coefzoom_rot ;
      end;

    VK_SHIFT :
      begin
        if bloczoom > 0 then
        begin
         Oeil_ex := Oeil_ex /coefzoom;
         Oeil_ey := Oeil_ey /coefzoom;
         Oeil_ez := Oeil_ez /coefzoom;
         coefzoom_rot := coefzoom_rot / coefzoom ;

         bloczoom := bloczoom -1 ;
        end;
      end;

   VK_CONTROL:
      begin
       if bloczoom < 27 then
       begin
        Oeil_ex := Oeil_ex *coefzoom;
        Oeil_ey := Oeil_ey *coefzoom;
        Oeil_ez := Oeil_ez *coefzoom;
        coefzoom_rot := coefzoom_rot *  coefzoom ;

        bloczoom := bloczoom + 1 ;
       end;
      end;

//    VK_F1     : pnl_score.Visible:= not pnl_score.Visible ;
//
//    VK_F2     : pnl_list_essais.Visible:= not pnl_list_essais.Visible ;
//
//    VK_F9     :begin
//
//             BtnSplitClick(self);        //  self et non sender!!
//            end;
//
//    word('A') :Btn_ResetClick(Self);        //  self et non sender!!
//
//    VK_NUMPAD1 : Oeil_ez :=Oeil_ez -1;
//    VK_NUMPAD3 : Oeil_ez :=Oeil_ez +1;
//
//
//    word('S') :begin
//              modif_taille  := true ;
//              modif_pos_rot :=false ;
//              modif_pos_tran :=false ;
//            end;
//    word('R') :begin
//               modif_taille := false ;
//              modif_pos_rot := true;
//              modif_pos_tran :=false ;
//            end;
//    word('T') :begin
//              modif_taille  :=  false;
//              modif_pos_rot := false ;
//              modif_pos_tran := true;
//            end;
//
//    word('D') :begin
//                 glbindtexture(gl_texture_2d,texture[13]);
//                 Mpiece[piece_en_main].draw;
//
//               case (piece_en_main ) of   // on dessine l'objet adapté
//                    A_pion     :  Mpiece[A_pion].draw;
//                    A_cavalier :  Mpiece[A_cavalier].draw;
//                    A_fou      :  Mpiece[M_fou].draw;
//                    A_tour     :  Mpiece[M_tour].draw;
//                    A_dame     :  Mpiece[M_dame].draw;
//                    A_roi      :  Mpiece[M_roi].draw;
//               end;
//             end;
//                les touches Shift sont élements d'un ensemble donc...
//                pour tester s'il y a conjonction de <key + shift >
//                il faut tester l'appartenance de shift à un ensemble
               //  i.e.  if < TShiftState> in < Shift>
  

//   word('V') : if ssShift in Shift THEN
//             begin
//
//             for i := 0 to 7  do
//               for j := 0 to 7  do
//                 begin
//                  cube[i,j].select := false;
//                  cube[i,j].index := false;
//                 end;
//            piece_en_main:=A_cavalier;
//
//            Randomize;
//            Tic_Intro :=Random(64);     // nombre pseudo-aléatoire 0..63
//            TimerIntro.Enabled:= true;  // on lance le timer d'intro
//            Tac_Intro:=Tic_Intro;       // on défini la valeur de boucle
//            num_en_cours := Euler[Tic_intro] ;  // valeur aleatoire de la table!
//            i:=num_en_cours and 7;
//            j:= num_en_cours shr 3;
//            cube[i,j].select := true;
//            case_en_cours := cube[i,j] ;
//            num_clic :=i*8 +j;
//            Affiche_index(i,j);
//            Affiche_mesh(piece_en_main,i,j);
//            formpaint(Sender);
//
//            end;
   End;

//     VK_NUMPAD0 :  blanc_au_trait := not blanc_au_trait;  // test du trait
  end;
   FormResize(self); // mise à jour de l'affichage
end;

procedure TForm3.Orion1Click(Sender: TObject);
var temp : glUint;
begin
temp:= texture[6];  //  swap orion et ciel_
texture[6]:= texture[25];
texture[25]:= temp;

end;

procedure TForm3.Aide1Click(Sender: TObject);
begin
Aide_dep := not Aide_dep ;
end;

procedure TForm3.Ajuste_panel_promotion();
var i : integer;
begin
  if Blanc_au_trait
     then i:= 0
     else i:= 4;

   Dame_prom.imageIndex     :=3 +i;
   Tour_prom.imageIndex     :=0+i;
   Fou_prom.imageIndex      :=2+i;
   Cavalier_prom.imageIndex :=1+i;

end;


end.

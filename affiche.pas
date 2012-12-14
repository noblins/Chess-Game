unit affiche;

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
    , UtilAffiche;   // unité définissant l'affichage

type

  TForm4 = class(TForm)
    Panel1: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label13: TLabel;
    Label11: TLabel;
    Label3: TLabel;
    Label12: TLabel;
    Label4: TLabel;
    Button1: TButton;
    BtnSplit: TButton;
    Btn_Reset: TButton;
    Label14: TLabel;
    lbl_Ligne: TLabel;
    Label2: TLabel;
    lbl_Colonne: TLabel;
    Pnl_Navig: TPanel;
    SBt_Nord: TSpeedButton;
    SBt_Sud: TSpeedButton;
    SBt_Ouest: TSpeedButton;
    SBt_Est: TSpeedButton;
    SBt_NO: TSpeedButton;
    SBt_NE: TSpeedButton;
    SBt_SE: TSpeedButton;
    SBt_SO: TSpeedButton;
    Pnl_Texture: TPanel;
    RG_Textures: TRadioGroup;
    RB_TextureBois: TRadioButton;
    RB_TextureMarbre: TRadioButton;
    Btn_Texture: TButton;
    lbl_XY: TLabel;
    BNtn_Horizon: TButton;
    TimerSpheres: TTimer;
    Btn_Orion: TButton;
    lbl_test: TLabel;
    Btn_Split_2: TButton;
    Lbl_case: TLabel;
    Pnl_TstBitBoard: TPanel;
    RG_TestBitboard: TRadioGroup;
    RB_Cavalier: TRadioButton;
    RB_Fou: TRadioButton;
    RB_Tour: TRadioButton;
    RB_Dame: TRadioButton;
    RB_Roi: TRadioButton;
    RB_Pion_N: TRadioButton;
    RB_Pion_Blanc: TRadioButton;
    TimerIntro: TTimer;
    RB_zero: TRadioButton;
    Lbl_Piece: TLabel;
    LBL_Num_en_Cours: TLabel;
    lbl_Btb_en_cours: TLabel;
    Btn_Pieces: TButton;
    testp: TButton;
    Partie: TRadioButton;

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
    procedure Btn_TextureClick(Sender: TObject);
    procedure RB_TextureBoisClick(Sender: TObject);
    procedure RB_TextureMarbreClick(Sender: TObject);
    procedure SBt_SOClick(Sender: TObject);
    procedure BNtn_HorizonClick(Sender: TObject);
    procedure TimerSpheresTimer(Sender: TObject);
    procedure Btn_OrionClick(Sender: TObject);
    procedure Pnl_NavigClick(Sender: TObject);
    procedure Btn_Split_2Click(Sender: TObject);
//    procedure parcoursCavalierEuler(Sender: TObject;ligne, colonne: integer);
    procedure TimerIntroTimer(Sender: TObject);
    procedure RB_CavalierClick(Sender: TObject);
    procedure RB_FouClick(Sender: TObject);
    procedure RB_TourClick(Sender: TObject);
    procedure RB_DameClick(Sender: TObject);
    procedure RB_RoiClick(Sender: TObject);
    procedure RB_Pion_NClick(Sender: TObject);
    procedure RB_Pion_BlancClick(Sender: TObject);
    procedure RB_zeroClick(Sender: TObject);
    procedure Btn_PiecesClick(Sender: TObject);
    procedure testpClick(Sender: TObject);
    procedure PartieClick(Sender: TObject);
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
   Form4: TForm4;
   split,split2 :Boolean;
   index_x,index_y : integer;
   tic_Intro:integer;
   tac_Intro:integer;

 implementation

{$R *.dfm}

//  La fonction qui nous permet de définir la texture active est la suivante
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


procedure TForm4.PartieClick(Sender: TObject);
begin
piece_en_main := A_Partie ;
end;

procedure TForm4.Pnl_NavigClick(Sender: TObject);
begin
panel1.Visible :=  not panel1.Visible ;
end;

procedure TForm4.RB_CavalierClick(Sender: TObject);
begin
 piece_en_main := A_cavalier;
 Lbl_Piece.Caption:= 'cavalier';

end;

procedure TForm4.RB_DameClick(Sender: TObject);
begin
 piece_en_main := A_dame;
 Lbl_Piece.Caption:= 'dame';
end;

procedure TForm4.RB_FouClick(Sender: TObject);
begin
piece_en_main := A_fou;
 Lbl_Piece.Caption:= 'fou';
end;

procedure TForm4.RB_Pion_BlancClick(Sender: TObject);
begin
piece_en_main := A_pion;
couleur_en_cours:= true;  //  true = blanc;
 Lbl_Piece.Caption:= 'pion blanc';
end;

procedure TForm4.RB_Pion_NClick(Sender: TObject);
begin
piece_en_main := A_pion;
couleur_en_cours:= false;  // false =noir;
 Lbl_Piece.Caption:= 'pion Noir';
end;

procedure TForm4.RB_RoiClick(Sender: TObject);
begin
piece_en_main := A_roi;
 Lbl_Piece.Caption:= 'roi';
end;

procedure TForm4.RB_TextureBoisClick(Sender: TObject);
begin
   texture[14]:= texture[7];
   texture[15]:= texture[8];
   texture[16]:= texture[9];
   formpaint(self);
end;

procedure TForm4.RB_TextureMarbreClick(Sender: TObject);
begin
   texture[14]:= texture[10];
   texture[15]:= texture[11];
   texture[16]:= texture[12];
   formpaint(self);
end;

procedure TForm4.RB_TourClick(Sender: TObject);
begin
piece_en_main := A_tour ;
 Lbl_Piece.Caption:= 'tour';
end;

procedure TForm4.RB_zeroClick(Sender: TObject);
begin
piece_en_main := A_zero ;
 Lbl_Piece.Caption:= 'vide';
end;

procedure TForm4.SBt_SEClick(Sender: TObject);
begin
 Oeil_ez := Oeil_ez  + 1 ;
 FormResize(Sender);
end;

procedure TForm4.SBt_SOClick(Sender: TObject);
begin
Oeil_ez := Oeil_ez  - 1 ;
FormResize(Sender);
end;

procedure TForm4.SBt_SudClick(Sender: TObject);
begin
Oeil_ex := Oeil_ex  - 1 ;
//glRotate(1, cos(rotxOy*6.28/360), sin(rotxOy*6.28/360), 0);
teta := teta+1;

FormResize(Sender);
end;


procedure TForm4.SBt_SudMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Oeil_ex := Oeil_ex  - 1 ;  if Oeil_ex<1 then Oeil_ex  := 1 ;
 FormResize(Sender);
end;

procedure TForm4.testpClick(Sender: TObject);
begin
piece_en_main := A_partie ;
init_plateau ;
end;

procedure TForm4.SBt_EstClick(Sender: TObject);
begin
 Oeil_ey := Oeil_ey  + 1 ;
 FormResize(Sender);
end;

procedure TForm4.SBt_OuestClick(Sender: TObject);
begin
Oeil_ey := Oeil_ey  - 1 ;
FormResize(Sender);
end;

procedure TForm4.SBt_NOClick(Sender: TObject);
begin
 Oeil_ez := Oeil_ez  + 1 ;
 FormResize(Sender);
end;

procedure TForm4.SBt_NordClick(Sender: TObject);
begin
 Oeil_ez := Oeil_ez  + 1 ;
 FormResize(Sender);
end;

procedure TForm4.SBt_NordMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 Oeil_ex := Oeil_ex  + 1 ;
 FormResize(Sender);
end;


procedure TForm4.FormCreate(Sender: TObject);
var
pfd: TPixelFormatDescriptor;
FormatIndex: integer;
i,j,k: integer;

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
  Oeil_ex :=40;       // oeil camera   : x
  Oeil_ey :=0;        // oeil camera   : y
  Oeil_ez :=40;       // oeil camera   : z
  Cible_cx :=0;       // centre scene  : x
  Cible_cy :=0;       // centre scene  : y
  Cible_cz :=0;       // centre scene  : z
  Rep_upx  :=0;
  Rep_upy  :=0;
  Rep_upz  :=1;
  vitesse_rot := 1;
  coefzoom := 1.05 ;
  coefzoom_rot := 1 ; // influence du zoom sur la rotation

  bloczoom := 15 ;

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

  modif_taille  := false ;
  modif_pos_rot :=false ;
  modif_pos_tran :=false ;
  num_en_cours := 0;
  piece_en_main := A_zero ;
  Lbl_Piece.Caption:= 'vide';

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

procedure TForm4.FormDestroy(Sender: TObject);
begin
wglMakeCurrent(Canvas.Handle,0);
wglDeleteContext(GLContext);
end;

procedure TForm4.FormResize(Sender: TObject);
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



procedure TForm4.FormPaint(Sender: TObject);

begin
  glClearColor(0.7, 0.7, 0.7, 1.0);
  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);        // Clear the colour buffer
  AfficheCases();
  swapbuffers(gldc);
end;


procedure TForm4.BNtn_HorizonClick(Sender: TObject);
begin
horizon_b := not horizon_b ;
end;

procedure TForm4.BtnSplitClick(Sender: TObject);
begin
  split := Not Split;            // eclatement ou non?
  if split
      then g_Arete  :=3
      else g_Arete  :=2;        // distance entre les cubes
  formpaint(self);
end;


procedure TForm4.Btn_TextureClick(Sender: TObject);
begin
Pnl_Texture.Visible := not Pnl_Texture.Visible;
end;

procedure TForm4.Button1Click(Sender: TObject);
begin
Close;
end;


procedure TForm4.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
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
  label3.Caption :=floattostr(x);
  label4.Caption :=floattostr(y);
  if( Y = 0 )then Y := 1;
  glReadPixels(	X, -Y, width, 1, GL_DEPTH_COMPONENT, GL_FLOAT, @winZ );

  gluUnProject (x,  realy,0,
  @mvmatrix, @projmatrix, @viewport, wx, wy, winz);
  tz:=winz/(Oeil_ez-winz);

  label5.Caption :=floattostr(tz*(wx-Oeil_ex )+wx);
  label6.Caption :=floattostr((wy-Oeil_ey)*tz+wy);
  label8.Caption :=floattostr(tz);

//______ repère la case visée par la souris _____________________

 col := round((tz*(wx-Oeil_ex )+wx +(g_Medio* g_Arete))/2)-1;
 rang :=round(((wy-Oeil_ey)*tz+wy +(g_Medio* g_Arete))/2) -1;
 str_rang :='';
 str_col:='';

   if ((rang in [1..8]) and (col in [1..8]))
      then
        begin     // souris sur une case
             lbl_Ligne.Caption := floattostr(rang);
             lbl_Colonne.Caption := floattostr(col);
             str_col:= string(char(64+col));
             lbl_test.Caption:= 'BitBoard['+IntToStr( cube[rang-1,col-1].colonne *8 +
                                cube[rang-1,col-1].ligne)+']';
        end

     else begin    // la souris est hors de l'échiquier
              lbl_Ligne.Caption := '';
              lbl_Colonne.Caption := '';
           end;
                  //  on affiche la case en alpha numérique [A1..H8]
           lbl_XY.Caption:= str_col +' '+ lbl_ligne.Caption  ;

end;

//______________________________________________________________________________

procedure TForm4.FormMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);

var   rang,col : integer;             // ligne & colonne en chiffre      str_col: string ;      // ligne & colonne en lettres

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
      case_en_cours :=cube[rang-1,col-1]; // [-1] : carré 8x8 dans carré 10x10
      num_clic := (rang-1)*8 + col-1;
      Affiche_index(rang-1,col-1 );
      case piece_en_main of

         A_cavalier: lbl_Btb_en_cours.Caption := floattostr(Cavalier_BtB[num_clic]);

         A_Fou     : lbl_Btb_en_cours.Caption  := floattostr(Fou_Btb[num_clic]);

         A_Tour    : lbl_Btb_en_cours.Caption  := floattostr(Tour_BtB[num_clic]);

         A_Roi     : lbl_Btb_en_cours.Caption  := floattostr(Roi_BtB[num_clic]);

         A_Pion  :
                  case couleur_en_cours of   // surtypage d'un integer en Booleen
                       boolean( noir) : lbl_Btb_en_cours.Caption  :=
                                         floattostr(pion_N_Mvmt_pas[num_clic]);

                       boolean( blanc): lbl_Btb_en_cours.Caption  :=
                                         floattostr(pion_B_Mvmt_pas[num_clic]);
                  end;

         A_Dame    : lbl_Btb_en_cours.Caption  := floattostr(Tour_Btb[num_clic]
                                           and Fou_Btb[num_clic]);

         else   lbl_Btb_en_cours.Caption  := floattostr(Btb[num_clic]);
            end ;

  end;

 lbl_num_en_cours.Caption:= InttoStr(num_clic);


end;
 end;

//______________________________________________________________________________

procedure TForm4.Btn_OrionClick(Sender: TObject);
var temp : glUint;
begin

   temp:= texture[6];  //  swap orion et ciel_
   texture[6]:= texture[25];
   texture[25]:= temp;
end;

procedure TForm4.Btn_PiecesClick(Sender: TObject);
begin
Pnl_TstBitBoard.Visible := not Pnl_TstBitBoard.Visible ;
end;

procedure TForm4.Btn_ResetClick(Sender: TObject);
begin

Oeil_ex :=40;
Oeil_ey :=0;
Oeil_ez :=40;
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


FormResize(Sender);
end;


procedure TForm4.Btn_Split_2Click(Sender: TObject);
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

procedure TForm4.TimerIntroTimer(Sender: TObject);
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
     end

end;

procedure TForm4.TimerSpheresTimer(Sender: TObject);
begin
  formpaint(Sender);
  spin_x := spin_x +0.03; if spin_x >359.97 then spin_x :=0;
  spin_bat := spin_bat -2.5; if spin_bat < 2.5 then spin_bat :=360;
  spin_index := spin_index -36.0; if spin_index < 36.0 then spin_index :=360;
  spin_ext := spin_ext -5.0; if spin_ext < 5.0 then spin_ext :=360;
  spin_piece := spin_piece -5.0; if spin_piece < 5.0 then spin_piece :=360;
end;


 procedure TForm4.OnKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
     i,j: Integer;
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
        fi := fi - 1.5 / coefzoom_rot ;
      end;

    VK_LEFT ,VK_NUMPAD4 :
      begin
        Oeil_ex := Oeil_ex - sin(fi*6.28/360);
        Oeil_ey := Oeil_ey - cos(fi*6.28/360);
        fi := fi + 1.5 / coefzoom_rot ;
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
       if bloczoom < 24 then
       begin
        Oeil_ex := Oeil_ex *coefzoom;
        Oeil_ey := Oeil_ey *coefzoom;
        Oeil_ez := Oeil_ez *coefzoom;
        coefzoom_rot := coefzoom_rot *  coefzoom ;

        bloczoom := bloczoom + 1 ;
       end;
      end;

    VK_F9     :begin
             lbl_Ligne.Caption := 'key ';
             lbl_Colonne.Caption := 'F9';
             BtnSplitClick(self);        //  self et non sender!!
            end;
    word('Z') :Btn_TextureClick(Self);        //  self et non sender!!

    word('A') :Btn_ResetClick(Self);        //  self et non sender!!

//    VK_NUMPAD1 : Oeil_ez :=Oeil_ez -1;
//    VK_NUMPAD3 : Oeil_ez :=Oeil_ez +1;


    word('S') :begin
              modif_taille  := true ;
              modif_pos_rot :=false ;
              modif_pos_tran :=false ;
            end;
    word('R') :begin
               modif_taille := false ;
              modif_pos_rot := true;
              modif_pos_tran :=false ;
            end;
    word('T') :begin
              modif_taille  :=  false;
              modif_pos_rot := false ;
              modif_pos_tran := true;
            end;

    word('D') :begin
                 glbindtexture(gl_texture_2d,texture[13]);
                 Mpiece[piece_en_main].draw;

          //     case (piece_en_main ) of   // on dessine l'objet adapté
          //          A_pion     :  Mpiece[A_pion].draw;
          //          A_cavalier :  Mpiece[A_cavalier].draw;
          //          A_fou      :  Mpiece[M_fou].draw;
          //          A_tour     :  Mpiece[M_tour].draw;
          //          A_dame     :  Mpiece[M_dame].draw;
          //          A_roi      :  Mpiece[M_roi].draw;
         //      end;
             end;
               // les touches Shift sont élements d'un ensemble donc...
               // pour tester s'il y a conjonction de <key + shift >
               // il faut tester l'appartenance de shift à un ensemble
               //  i.e.  if < TShiftState> in < Shift>
    word('B') :  if ssShift in Shift THEN   //  Touches SHIFT + B
                  Pnl_TstBitBoard.Visible := not Pnl_TstBitBoard.Visible;

 //   word('P') :Modifie_mesh(model,+1, segment );

//    word('M') :Modifie_mesh(model,-1, segment );      //  self et non sender!!

   word('V') :if ssShift in Shift THEN
             begin

             for i := 0 to 7  do
               for j := 0 to 7  do
                 begin
                  cube[i,j].select := false;
                  cube[i,j].index := false;
                 end;
            piece_en_main:=A_cavalier;

            Randomize;
            Tic_Intro :=Random(64);     // nombre pseudo-aléatoire 0..63
            TimerIntro.Enabled:= true;  // on lance le timer d'intro
            Tac_Intro:=Tic_Intro;       // on défini la valeur de boucle
            num_en_cours := Euler[Tic_intro] ;  // valeur aleatoire de la table!
            i:=num_en_cours and 7;
            j:= num_en_cours shr 3;
            cube[i,j].select := true;
            case_en_cours := cube[i,j] ;
            num_clic :=i*8 +j;
            Affiche_index(i,j);
            Affiche_mesh(piece_en_main,i,j);
            formpaint(Sender);

            end;

     VK_NUMPAD0 :  blanc_au_trait := not blanc_au_trait;  // test du trait
  end;
   FormResize(self); // mise à jour de l'affichage
end;

end.

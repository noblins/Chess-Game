unit two_players;

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
  TForm3 = class(TForm)
    TimerIntro: TTimer;
    TimerSpheres: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure TimerSpheresTimer(Sender: TObject);
    procedure TimerIntroTimer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
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
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
   Form3: TForm3;
   split,split2 :Boolean;
   index_x,index_y : integer;
   tic_Intro:integer;
   tac_Intro:integer;
implementation

{$R *.dfm}

procedure FormPaint(Sender: TObject);

begin
  glClearColor(0.7, 0.7, 0.7, 1.0);
  glClear (GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);        // Clear the colour buffer
  AfficheCases();
  swapbuffers(gldc);
end;

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
     end

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
procedure TForm3.FormCreate(Sender: TObject);
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

  horizon := false;
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
//  RB_TextureBoisClick(Sender); // en simulant un clic sur le radio_bouton
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


end.

unit UtilAffiche;

//________________________________________________________
//                                                        |
//         projet Battle Chess  promo epita 2013          |
//              unité définissant l'affichage             |
//________________________________________________________|

interface

uses
 Windows
 ,Unit3ds
 ,Opengl
 ,Dialogs
 ,BMP             // unité gérant le chargement de textures en BMP!
 ,UnitBtbInit ;  // unité où sont définis les bitboards

//________________________________________________________________________
//   constantes pièces   pour la table case[j,i]
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
// ref : 'Rotated bitboards'  par Robert Hyatt,
//       pour sont logiciel d'échecs  crafty.
// le lien ici : http://www.cis.uab.edu/info/faculty/hyatt/hyatt.html
//
// Sous crafty Type de la pièce est cencodé  comme suit :
//  Pion=1, Cavalier=2, roi=3, Fou=5, Tour=6 and Dame=7.
// Si (type_piece and 4) !=0 c’est une piece glissante et
// Si (type_piece and 2) !=0 elle glisse sur un rang/colonne  = tour/dame
// Si (type_piece and 1) !=0 elle glisse sur une diagonale    = fou/dame
//  ( simple et élégant )
// nous garderons donc cette définition des constantes du Pr Hyatt
// pour la compatibilité avec la suite ( unité IA à venir )

const     // valeur de 1 à 7 pouvant etre codée sur 3 bits en partie IA

  Pion     =1;       // OOI valeur du pion pour la partie IA
  Cavalier =2;       // OIO valeur du Cavalier pour la partie IA
  roi      =3;       // OII valeur du roi  pour la partie IA
  Fou      =5;       // IOI valeur du Fou  pour la partie IA
  Tour     =6;       // IIO valeur de la Tour pour la partie IA
  Dame     =7;       // III valeur de la Dame pour la partie IA
  zero     =0;       // OOO valeur vide pour compatibilité avec la partie affichage
// Star     =4       // IOO valeur inutilisée ???  marque?
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
// par ailleurs des définitions différentes propres à l'affichage sont
// maintenues en attendant mieux   : compatibles avec les précedentes
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
  camp     =1;     //  pour l'indice de plateau_actuel[x][camp]
  A_piece    =0;     //  pour l'indice de plateau_actuel[A_piece][x]
  A_pion     =1;     // valeur du pion pour la partie affichage
  A_cavalier =2;     // valeur du Cavalier pour la partie affichage
  A_roi      =3;     // valeur du roi pour la partie affichage
  A_fou      =5;     // valeur du Fou pour la partie affichage
  A_tour     =6;     // valeur de la Tour pour la partie affichage
  A_dame     =7;     // valeur de la Dame pour la partie affichage
  A_zero     =0;     // valeur du vide pour la partie affichage
  A_Partie   =4 ;    // valeur pour une éventuelle pièce fantôme/etoile

  noir=0;
  blanc=1;
  aucune=-1;

type

  PCase = ^Tcase;
  TCase = Record                     //  un type case (échiquier )
      ligne,colonne : integer;       //  coordonnée de la case ( ou bord )
      num           : integer;       //  rotation.. X,Y,Z de cette case
      select        : boolean;       //  rotation.. X,Y,Z de cette case
      index         : boolean;       //  rotation.. X,Y,Z de cette case
      piece         : integer;       // type de pièce occupant la case
      couleur       : integer;       // couleur de la pioece occupant la case
      end;

  PPiece = ^TPiece ;
  TPiece = Record                // que des entiers ... c'est léger!!
     siege   : integer;          // case ou se pose la pièce ( -1=hors jeu??)
     genre   : integer;          // A_pion=0; A_cavalier=1 ... A_roi=5;
     couleur : integer;          // blanc=1, noir=0
//     mesh    : integer;          //
    end;

var
   cube : Array[0..7,0..7] of TCase; //le plateau: 64 cubes/cases
   texture : Array[0..30] of glUint;  // 18 Textures rangées dans un tableau
   plateau_actuel : Array[0..63] of Array[0..1] of integer  ; // case et couleur
   plateau_calcul : Array[0..63] of Array[0..1] of integer  ;

   g_Count:integer;            // Nombre de cube par arète
   g_Medio:integer;            // milieu échiquier
   g_Arete :integer;           // distance entre les cubes
   blanc_au_trait : boolean;
   piece_en_main : integer;
   trait_blanc : integer ;

   case_en_cours : TCase;
   case_depart : TCase;
   case_arrive : TCase;

   num_en_cours : integer;
   num_depart : integer;
   num_arrive : integer;

   coup_depart : boolean ;
   selection : boolean ;
   actif_selection : boolean ;

   Aide_dep : boolean ;

   num_clic : integer;


   promue : boolean ;

   contre_ordi : boolean ;
   couleur_ordi : integer ;
   mode_camera : integer ;     // 0  : libre
                               // 1  : placé pour le joueur au trait
                               // 2  : fixe devant les blancs
                               // 3  : fixe devant les noirs

   spin_index:real;            // un spin pour blanc au trait B.A.T.
   spin_ext:real;              // un spin pour blanc au trait B.A.T.
   spin_piece:real;            // un spin pour la pièce affichée
   spin_BAT:real;              // un spin pour blanc au trait B.A.T.

   sphere_index:GLUquadricObj;
   sphere_trait:GLUquadricObj;
   sphere_Int,sphere_Ext:GLUquadricObj;

   spin_x:real;                // un réel pour les angles de rotation  X
   spin_y:real;                // un réel pour les angles de rotation   Y
   spin_z:real;                // un réel pour les angles de rotation    Z
   horizon_b : Boolean;
   modif_taille   : Boolean ;
   modif_pos_rot  : Boolean ;
   modif_pos_tran : Boolean ;
   angle:real;
   segment: real;
   taille:real;

   couleur_en_cours:boolean;

   En_passant : integer ;

   Mpiece : Array[0..7] of  File3ds; // table de 6 pointeurs sur les six pieces

 function   Btb_Select(valeur_piece, siege_piece, num_case: integer): boolean;
 procedure  AfficheCube( num_i,num_j,num_k : integer);
 procedure  Affiche_index( num_i, num_j: integer);
 procedure  Affiche_select( num_i, num_j: integer);
 procedure  Affiche_sphere_trait( num_i,num_j : integer);
 procedure  AfficheCases();
 procedure  Affiche_decors;
 procedure  Modifie_mesh(model : File3ds; signe : integer;var taille : real);
 procedure  Affiche_mesh(_piece, i,j : integer);
 procedure  init_piece_mesh ;
 procedure  init_textures ;
 procedure  init_echi ;
 procedure  init_plateau ;
 procedure  affiche_piece( case_actuelle : integer ) ;
 function  score_matériel( v_arbre:PArbre ):integer;
procedure  score_ajust( var v_arbre:PArbre;trait:integer;capture,promo:integer);

implementation

///////////////////////////////////////////////////////////////////////////////
//____________________________________________________________________________
//  La fonction qui nous permet de définir la texture active est la suivante
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
procedure glBindTexture(target: GLenum; texture: GLuint); stdcall; external opengl32;


 //////////////////////////////////////////////////////////////////////////////
 //____________________________________________________________________________
 // chargement des objets meshs ( type File3ds , fichiers 3ds )
 // const :  A_pion=0; A_cavalier=1; A_fou=2; A_tour=3; A_dame=4; A_roi=5;
 // les six types mesh sont chargés une fois pour toute
 //  il seront utilisés indépendemment pour les blancs/les noirs à l'affichage
 //¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
 //  un jeu de pieces open source = libre de droits  : lien ci-dessous
 //  http://www.planit3d.com/source/meshes_files/dwood/chess1.html
 //¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
 procedure init_piece_mesh ;
// var
//    model: TMesh3Ds;                // les Staunton en attendant
 begin
 Mpiece[A_pion].load3ds('mesh/StauntonPawn.3DS');        // pion
 Mpiece[A_cavalier].load3ds('mesh/StauntonKnight.3DS');  // cavalier
 Mpiece[A_fou].load3ds('mesh/StauntonBishop.3DS');       // fou
 Mpiece[A_tour].load3ds('mesh/StauntonRook.3DS');        // tour
 Mpiece[A_dame].load3ds('mesh/StauntonQueen.3DS');       // dame
 Mpiece[A_roi].load3ds('mesh/StauntonKing.3DS');         // roi
 end;

//_____________________________________________________________________________
//////////////////////////////////////////////////////////////////////////////


  procedure init_textures ;
  begin
       //on charge les textures depuis le dossier images
   LoadTexture('images\img_V0A.bmp', texture[0]);
   LoadTexture('images\img_V0B.bmp', texture[1]);
   LoadTexture('images\img_V0C.bmp', texture[2]);
   LoadTexture('images\img_V0D.bmp', texture[3]);
   LoadTexture('images\img_V0E.bmp', texture[4]);
   LoadTexture('images\img_V0F.bmp', texture[5]);

   LoadTexture('images\Cyl_Ciel.bmp', texture[6]);
   // textures bois pour l'échiquier
   LoadTexture('images\Bord_Bois.bmp', texture[7]);
   LoadTexture('images\Blanc_Bois.bmp', texture[8]);
   LoadTexture('images\Noir_Bois.bmp', texture[9]);
   // textures marbre pour l'échiquier
   LoadTexture('images\Bord_Marbre.bmp', texture[10]);
   LoadTexture('images\Blanc_Marbre.bmp', texture[11]);
   LoadTexture('images\Noir_Marbre.bmp', texture[12]);

   // textures  pour l'index de case sélectionnée
   LoadTexture('images\sphere.bmp', texture[13]);



   //LoadTexture('images\ciel_fire.bmp', texture[24]);
   LoadTexture('images\ciel_fire_BC.bmp', texture[24]);
   LoadTexture('images\orion.bmp', texture[25]);
   LoadTexture('images\fond_grotte.bmp', texture[26]); // textures  pour le cube décor
   LoadTexture('images\noir.bmp', texture[27]);
   LoadTexture('images\piece_blanche.bmp', texture[29]);
   LoadTexture('images\piece_noire.bmp', texture[30]);

   // textures  pour les pieces
//   LoadTexture('images\_cavalier.bmp', texture[28]);

   texture[14]:= texture[7];     // le bord
   texture[15]:= texture[3];     // le noir
   texture[16]:= texture[0];     // le blanc

  end;

///////////////////////////////////////////////////////////////////////////////
//____________________________________________________________________________
//   Btb_select_() est une fonction qui vérifie si la case [num_case ]
//                 est visée par la pièce [valeur_piece]
//                 posée sur la case [siege_piece ]
//   en faisant un simple 'and' entre  Btb_typepiece[case] & Btb[case]
//  retourne faux si le bitboard résultant est nul, vrai sinon
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

 function Btb_Select(valeur_piece, siege_piece, num_case: integer): boolean;
 var
 V_ok: boolean;

begin
  V_ok := false;
            case valeur_piece of

                 A_cavalier: if (cavalier_BtB[siege_piece] and BtB[num_case])>0
                                 then  V_ok:= true;

                 A_Fou: if (Fou_Btb[siege_piece] and BtB[num_case] )>0
                                 then V_ok:= true;

                 A_Tour: if (Tour_Btb[siege_piece] and BtB[num_case])>0
                                 then V_ok:= true;

                 A_Roi: if (Roi_Btb[siege_piece] and BtB[num_case] )>0
                                 then V_ok:= true;

                 A_Pion :
                            case couleur_en_cours of
                            boolean( noir):  // surtypage d'un intéger en Booleen
                               if ((pion_N_Mvmt_prise[siege_piece]  or
                                   pion_N_Mvmt_pas[siege_piece]) and BtB[num_case])>0
                                     then V_ok:= true;
                           boolean( blanc):
                               if ((pion_B_Mvmt_prise[siege_piece]  or
                                  pion_B_Mvmt_pas[siege_piece]) and BtB[num_case])>0
                                     then V_ok:= true;
                            end;

                 A_Dame: if ((Tour_Btb[siege_piece] or Fou_Btb[siege_piece])
                              and BtB[num_case] )>0
                                 then V_ok:= true;
              end ;
     result := V_ok;
end;


///////////////////////////////////////////////////////////////////////////////
//____________________________________________________________________________
//   affiche la case donnée en coordonnée 3D x,y,z
//   distingue les bors des cases
//   distingues les case marquées ( select)  des cases visées(index)
//   distingue les texture propres aux case blanches et noires
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

 procedure AfficheCube( num_i,num_j,num_k : integer);

var bord : boolean;
    ligne,colonne,k: integer;  ///k_ref
    noire : boolean;
 //   c_select: boolean;      // est ce un cube marqué ? /sélect=true

begin
// c_select := false;
 colonne := num_i-1;
 ligne := num_j-1;

// selection :=  ((ligne-1)*8 + colonne -1) = num_depart ;
 k := (ligne)*8 + colonne;    // numéro  cube_en cours  [0..63]
 selection := 63-k = num_depart ;  // case de la piece selectionnée
           // bord est mis à true si le cube est hors de l'échiquier
 bord :=((num_i=(g_Count-1)) or (num_j=(g_Count-1)) or (num_i=0) or (num_j=0));

          // la case est elle noire ( true ) ou blanche ( false ) ?
 noire := ((num_i+num_j) mod 2)=1 ;

         // ramener les coordonnée relatives de la case en fonction
         // de l'arète de la case, de l'écart entre chaque case ( split)
         //  et du centre de l'échiquier.
 num_i := (num_i - g_Medio)*g_Arete ;
 num_j := (num_j- g_Medio)*g_Arete;
 num_k := num_k*g_Arete;

 glColor3f(1.0, 1.0, 1.0);       // mettre la couleur courante à blanc


 if bord   // c'est une case du bord
    then  glbindtexture(gl_texture_2d,texture[14])
    else   // c'est une case de l'échiquier
      begin
//         if (Btb[k] and BtB_pions[1])  > 0 then
//         begin
//            Affiche_index(  ligne,colonne );
//         end;

         if ( Aide_dep and ( (Btb[k] and Btb_affichage_cible)  > 0)) then
         begin
            Affiche_index(  ligne,colonne );
         end;
                                                    // une piece en main et
         if (Btb_Select(piece_en_main, num_clic, k) // case visée par la pièce
            and not cube[ligne,colonne].select)     // et case non marquée
             then
                  begin
                      glbindtexture(gl_texture_2d,texture[6]) ;
                      affiche_index(ligne,colonne);// afficher l'index : vert
                  end ;

        if cube[ligne,colonne].select             // si case marquée
           then   affiche_select(ligne,colonne);  // afficher select : rouge
         if (  selection and actif_selection ) then
           glbindtexture(gl_texture_2d,texture[22]) // Tex. case choisie
         else
           if noire     //si la case est noire
                 then glbindtexture(gl_texture_2d,texture[15])  // Tex. noire
                 else glbindtexture(gl_texture_2d,texture[16]); // Tex. blanche
      end;

  glpushmatrix;            // PUSH <
    glTranslatef(0.0,0.0,-1.0);
    glBegin(GL_QUADS);      // Face  Antérieure
      glNormal3f( 0.0, 0.0, 1.0);
      glTexCoord2f(0.0, 0.0); glVertex3f(-1.0-num_i, -1.0-num_j,  1.0-num_k);
      glTexCoord2f(1.0, 0.0); glVertex3f( 1.0-num_i, -1.0-num_j,  1.0-num_k);
      glTexCoord2f(1.0, 1.0); glVertex3f( 1.0-num_i,  1.0-num_j,  1.0-num_k);
      glTexCoord2f(0.0, 1.0); glVertex3f(-1.0-num_i,  1.0-num_j,  1.0-num_k);
    glend;
  glpopmatrix;         // POP >

end;


///////////////////////////////////////////////////////////////////////////////
//____________________________________________________________________________
//   affiche une sphères Select sur la case donnée en coordonnée
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

procedure   Affiche_select(num_i , num_j: integer);
begin
        glpushmatrix;     // PUSH <   seul l'index subit spin_index

        glTranslatef((num_j - g_Medio+2)*g_Arete ,(num_i - g_Medio+2)*g_Arete ,+0.30);
        glrotate(spin_index,spin_index,spin_index,1.0);
        if cube[num_i,num_j].select then
             begin
                glbindtexture(gl_texture_2d,texture[25]);
                gluSphere(sphere_trait,0.2,16,16);   // affiche sphere select
             end ;

      glpopmatrix;         // POP >

end;

///////////////////////////////////////////////////////////////////////////////
//____________________________________________________________________________
//   affiche une sphères INDEX sur la case donnée en coordonnée
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

procedure   Affiche_index( num_i ,num_j: integer);
begin
       glpushmatrix;     // PUSH <   seul l'index subit spin_index
          glTranslatef((num_j - g_Medio+2)*g_Arete ,(num_i - g_Medio+2)*g_Arete ,+0.30);
          glrotate(spin_index,spin_index,spin_index,1.0);
          glbindtexture(gl_texture_2d,texture[13]);
          gluSphere(sphere_trait,0.7,16,16);   // affiche sphere index
      glpopmatrix;         // POP >

end;

///////////////////////////////////////////////////////////////////////////////
//____________________________________________________________________________
//   affiche une sphères du coté et de la couleur du joueur au trait
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

procedure   Affiche_sphere_trait( num_i,num_j : integer);
begin
       glpushmatrix;            // PUSH <   seules les sphères tournent
          glTranslatef((num_j - g_Medio+1.5)*g_Arete ,(num_i - g_Medio+1.0)*g_Arete ,+0.25);
          glrotate(spin_bat,spin_bat,spin_bat,1.0);
          if blanc_au_trait
            then glbindtexture(gl_texture_2d,texture[26])  // sphere blanche
            else glbindtexture(gl_texture_2d,texture[27]);  // sphere noire
          gluSphere(sphere_trait,0.5,16,16);
      glpopmatrix;         // POP >
end;

///////////////////////////////////////////////////////////////////////////////
//____________________________________________________________________________
//   affiche la scènes :  les 64 cases et 36 cases-bords
//   puis les mesh
//   enfin le décor
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

procedure AfficheCases();
 var rg,cl : integer;

begin

  for cl := 0 to g_Count - 1 do             //  cl = colonnes
     for rg := 0 to g_Count - 1 do       //  lg = lignes
         begin
           AfficheCube(rg,cl,0);       // construit le cube d'indice I,j
         end;

 if blanc_au_trait
      then  Affiche_sphere_trait(0,9)
      else  Affiche_sphere_trait(9,9);

 Affiche_mesh(piece_en_main,case_en_cours.ligne,case_en_cours.colonne);
 Affiche_decors;
end;

///////////////////////////////////////////////////////////////////////////////
//____________________________________________________________________________
//   affiche le décor de fond de l'espace
//    un cube ou une sphère selon le choix du bouton Horizon
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

procedure   Affiche_decors;
begin
 if horizon_b     // affiche un decor de sphères plutot que de cubes
                //  2 sphères imbriquées (1 pixel d'écart) de spin différent
  then  // décor sphèrique
     begin
      glpushmatrix;            // PUSH <  sphère interne : spin_x,y,z
        glrotate(spin_x,1.0,0.0,0.0);   // c'est le ciel de notre univers
        glrotate(spin_y,0.0,1.0,0.0);
        glrotate(spin_z,0.0,0.0,1.0);
        glbindtexture(gl_texture_2d,texture[6]);  // sphere intérieure :bleu
        gluSphere(sphere_Int,107,128,128);
      glpopmatrix;         // POP >

      glpushmatrix;            // PUSH <  sphère externe : spin_ext
        glrotate(spin_ext,1.0,0.0,0.0);  // c'est la texture externe
        glrotate(spin_ext,0.0,1.0,0.0);    // de la sphères (Soleil)
        glrotate(spin_ext,0.0,0.0,1.0);    // contenant l'aire de bataille
        glbindtexture(gl_texture_2d,texture[24]); // sphere extérieure :feu
        gluSphere(sphere_ext,108,128,128);
      glpopmatrix;         // POP >
     end
    else // décor cubique
      begin
       glColor3f(1.0, 1.0, 1.0);
       glbindtexture(gl_texture_2d,texture[26]);

       glBegin (GL_QUADS);
         glNormal3f( 0.0, 0.0, 1.0);
         glTexCoord2f(1.0, 1.0); glVertex3f (66, 65, 66);
         glTexCoord2f(0.0, 1.0); glVertex3f (-66, 65, 66);
         glTexCoord2f(0.0, 0.0); glVertex3f (-66, 65, -66);
         glTexCoord2f(1.0, 0.0); glVertex3f (66, 65, -66);
       glEnd ();

       glbindtexture(gl_texture_2d,texture[26]);
       glBegin (GL_QUADS);
         glNormal3f( 1.0, 0.0, 1.0);
         glTexCoord2f(-1.0, 1.0);glVertex3f (66, -65, 66);
         glTexCoord2f(0.0, 1.0);glVertex3f (-66, -65, 66);
         glTexCoord2f(0.0, 0.0);glVertex3f (-66, -65, -66);
         glTexCoord2f(-1.0, 0.0);glVertex3f (66, -65, -66);
       glEnd ();

       glbindtexture(gl_texture_2d,texture[26]);
       glBegin (GL_QUADS);
         glNormal3f( 1.0, 1.0, 1.0);
         glTexCoord2f(1.0, 1.0);glVertex3f (65, 66, 66);
         glTexCoord2f(0.0, 1.0);glVertex3f (65, -66, 66);
         glTexCoord2f(0.0, 0.0);glVertex3f (65, -66, -66);
         glTexCoord2f(1.0, 0.0);glVertex3f (65, 66, -66);
       glEnd ();

       glbindtexture(gl_texture_2d,texture[26]);
       glBegin (GL_QUADS);
         glNormal3f( 1.0, 1.0, 0.0);
         glTexCoord2f(1.0, 0.0);glVertex3f (66, 66, -5);
         glTexCoord2f(1.0, 1.0);glVertex3f (-66, 66, -5);
         glTexCoord2f(0.0, 1.0);glVertex3f (-66, -66, -5);
         glTexCoord2f(0.0, 0.0);glVertex3f (66, -66, -5);
       glEnd ();

       glbindtexture(gl_texture_2d,texture[26]);
       glBegin (GL_QUADS);
         glNormal3f( 1.0, 0.0, 1.0);
         glTexCoord2f(1.0, 1.0);glVertex3f (65, 65, 65);
         glTexCoord2f(0.0, 1.0);glVertex3f (-65, 65, 65);
         glTexCoord2f(0.0, 0.0);glVertex3f (-65, -65, 65);
         glTexCoord2f(1.0, 0.0);glVertex3f (65, -65, 65);
       glEnd ();

       glbindtexture(gl_texture_2d,texture[26]);
       glBegin (GL_QUADS);
         glNormal3f( 0.0, 1.0, 1.0);
         glTexCoord2f(-1.0, 1.0);glVertex3f (-65, 66, 66);
         glTexCoord2f(0.0, 1.0);glVertex3f (-65, -66, 66);
         glTexCoord2f(0.0, 0.0);glVertex3f (-65, -66, -66);
         glTexCoord2f(-1.0, 0.0);glVertex3f (-65, 66, -66);
       glEnd ();
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//____________________________________________________________________________
// adaptation  loader mesh     // shuntée par affiche mesh... donc obsolète
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

 procedure Modifie_mesh(model : File3ds; signe : integer;var taille : real);

begin

   if   modif_taille  then
          begin
           if taille > 0.03
              then taille := taille + signe*0.03
              else taille := 0.03 ;
           glpushmatrix;
           glTranslatef(0,0,10);
           glscaled( taille +0.32,taille +0.32,taille +0.32);
           glbindtexture(gl_texture_2d,texture[13]);
           model.draw();
           glpopmatrix;
          end
   else if  modif_pos_rot then
          begin
            if angle > 1
               then angle  := angle + signe*1
               else angle := 0;
          glpushmatrix;
             glrotatef(0 + angle ,1  ,0,0);
            glTranslatef(0,0,10);
            glscaled( 0.32,0.32,0.32);
            glbindtexture(gl_texture_2d,texture[13]);
            model.draw();
           glpopmatrix;
          end
   else if    modif_pos_tran then
           begin
            if segment >0.2
                then segment:= segment + signe*0.2
                 else segment := 0;
             glpushmatrix;
             glTranslatef(0,0,10 + segment);
             glscaled( 0.32,0.32,0.32);
            glbindtexture(gl_texture_2d,texture[13]);
             model.draw();
           glpopmatrix;
           end;

end;

///////////////////////////////////////////////////////////////////////////////
//___________________________________________________________________________
//    Affiche_mesh : identité de la pièce et coorconnées sur l'échiquier
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

procedure Affiche_mesh(_piece, i,j : integer);
var
   coefx,coefy,coefz:GlDouble;
begin

//  ici une portion de test pour :
//  le chargement
//  le mise à l'échelle
// et le positionnement d'un objet Mesh sur l'échiquier
//
//  cette étape devra être intégrée dans une fonction propre à l'objet lui-même
//  de façon à pouvoir manipuler divers objets de ce type, indépendemment.

 glpushmatrix;      // PUSH  on isole les matrice de  modification
 if _piece = a_partie then
 begin
//   init_echi ;
   i := 0 ;
   while i < 64 do
   begin
    affiche_piece(I);
    i := i +1 ;
   end;


 end
 else
 begin
  // positionnement sur x/y/z  de cet objet particulier
                      // le cavalier doit être remonté un peu ( z +1.4)
   case _piece of
     A_cavalier: glTranslatef((j-g_Medio+2)*g_Arete,(i-g_Medio+2)*g_Arete,1.4);
     else        glTranslatef((j-g_Medio+2)*g_Arete,(i-g_Medio+2)*g_Arete,0);
   end;

  // mise à l'échelle   de cet objet particulier
  // parceque les objet 3ds ne sont pas  tous proportionés
  // de façon harmonieuse...
  // il est ainsi possible de donner à chaque pièce, indépendemment,
  // une hauteur, une largeur et une profondeur propre
        coefx := 0 ;
        coefy := 0 ;
        coefz := 0 ;

        case _piece of
        //    A_pion     : begin coefx:=0.0075;coefy:=0.0075;coefz:=0.0065; end;
              A_pion     : begin coefx:=0.007;coefy:=0.007;coefz:=0.006; end;
              A_cavalier : begin coefx:=0.01;coefy:=0.01;coefz:=0.01; end;
              A_fou      : begin coefx:=0.0085;coefy:=0.0085;coefz:=0.008; end;
              A_tour     : begin coefx:=0.0085;coefy:=0.0085;coefz:=0.007; end;
              A_dame     : begin coefx:=0.01;coefy:=0.01;coefz:=0.01; end;
              A_roi      : begin coefx:=0.01;coefy:=0.01;coefz:=0.01; end;
        end;

          glScalef(coefx, coefy, coefz);

  // rotation sur l'axe x     de cet objet particulier
          glrotate(90,1.0,0.0,0.0);

   //     et en général , orientation de l'objet, :
   //     glScalef( coef_x, coef_y, coef_z);  --> echelle d'objet type en x,y,z
   //     glrotate( objet.angle_x,1.0,0.0,0.0);   //  axe x   objet type
   //     glrotate( objet.angle_y,0.0,1.0,0.0);   //  axe y   objet type
   //     glrotate( objet.angle_z,0.0,0.0,1.0);   //  axe z   objet type
  //      if blanc_au_trait
   //       then glbindtexture(gl_texture_2d,texture[13])  // sphere blanche
   //       else glbindtexture(gl_texture_2d,texture[10]);  // sphere noire

           glbindtexture(gl_texture_2d,texture[13]);
           Mpiece[_piece].draw;     // on dessine l'objet adapté

           glScalef(1.0, 1.0, 1.0);
 end;



      glpopmatrix;     // PUSH  on supprime les matrices de  modification
///////////////////////////////////////////////////////////////////////////////
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
end;

procedure  init_echi ;

var
   coefx,coefy,coefz:GlDouble;
   I : integer ;
begin

coefx:=0.007;coefy:=0.007;coefz:=0.006;

     for I := 0 to 8 - 1 do
     begin
       glTranslatef((i-g_Medio+2)*g_Arete,(1-g_Medio+2)*g_Arete,0);


       glScalef(coefx, coefy, coefz);
       glrotate(90,1.0,0.0,0.0);
       glbindtexture(gl_texture_2d,texture[29]);
       Mpiece[1].draw;
       glrotate(-90,1.0,0.0,0.0);
       glScalef(1/coefx, 1/coefy, 1/coefz);
       glTranslatef(-(i-g_Medio+2)*g_Arete,-(1-g_Medio+2)*g_Arete,0);

     end;

     for I := 0 to 8 - 1 do
     begin

       glTranslatef((i-g_Medio+2)*g_Arete,(6-g_Medio+2)*g_Arete,0);


       glScalef(coefx, coefy, coefz);
       glrotate(90,1.0,0.0,0.0);
       glbindtexture(gl_texture_2d,texture[30]);
       Mpiece[1].draw;
       glrotate(-90,1.0,0.0,0.0);
       glScalef(1/coefx, 1/coefy, 1/coefz);
       glTranslatef(-(i-g_Medio+2)*g_Arete,-(6-g_Medio+2)*g_Arete,0);

     end;

end;

procedure  init_plateau ;

var
  i : byte ;
  j : integer ;

begin



  Arbre_jeu  := new(PArbre);  //%%creer arbre
  coup_essai := new(P_List_essai);  //%%creer listye des coups /position
  Mi_Coup_actuel := 0;
//  Rule50Moves(0) := 0;       //%% règle des 50 coups
//  Repetition(noir) := 0;     //%% triple répétition noir
//  Repetition(blanc) := 0;    //%% triple répétition blanc

  En_passant := -1 ;

  blanc_au_trait := true ;

  plateau_actuel[0,0] := A_tour ;
  plateau_actuel[1,0] := A_cavalier ;
  plateau_actuel[2,0] := A_Fou ;
  plateau_actuel[3,0] := A_Dame ;

  plateau_actuel[4,0] := A_roi ;
  plateau_actuel[5,0] := A_Fou ;
  plateau_actuel[6,0] := A_cavalier ;
  plateau_actuel[7,0] := A_tour ;

  for I := 0 to 8 - 1 do
    plateau_actuel[i+8,0] := A_pion ;

  for I := 0 to 32 - 1 do
    plateau_actuel[i+16,0] := A_zero ;

  for I := 0 to 8 - 1 do
    plateau_actuel[i+48,0] := A_pion ;

  plateau_actuel[56,0] := A_tour ;
  plateau_actuel[57,0] := A_cavalier ;
  plateau_actuel[58,0] := A_Fou ;
  plateau_actuel[59,0] := A_Dame ;

  plateau_actuel[60,0] := A_roi ;
  plateau_actuel[61,0] := A_Fou ;
  plateau_actuel[62,0] := A_cavalier ;
  plateau_actuel[63,0] := A_tour ;

  for I := 0 to 16 - 1 do
    plateau_actuel[i,1] := 1 ;

  for I := 0 to 32 - 1 do
    plateau_actuel[i+16,1] := 0 ;

  for I := 0 to 16 - 1 do
    plateau_actuel[i+48,1] := -1 ;

  Alliees[0] := Btb[a3] -1 ;                       // bitboard blanc
  Alliees[1] := (Btb[h8] - Btb[a7] + Btb[h8]) ;    // bitboard noir

  toutes := Alliees[0]+Alliees[1] ;                // bitboard blanc et noir

  O_O_O_B:= Btb[b1] or Btb[c1] or Btb[d1];    // grand roque blanc
  O_O_B:= Btb[f1] or Btb[g1];                 // petit roque blanc
  O_O_N:= Btb[f8] or Btb[g8];                 // petit roque noir
  O_O_O_N:= Btb[b8] or Btb[c8] or Btb[d8];    // grand roque noir

  BtB_fou_dame[0]  := Btb[c1] or Btb[d1] or Btb[f1]; // les fous/dames blancs
  BtB_fou_dame[1]  := Btb[c8] or Btb[d8] or Btb[f8]; // les fous/dames noirs

  BtB_tour_dame[0] := Btb[a1] or Btb[d1] or Btb[h1]; ; // les tours/dames blancs
  BtB_tour_dame[1] := Btb[a8] or Btb[d8] or Btb[h8]; ; // les tours/dames noires

  BtB_cavalier[0]  := Btb[b1] or Btb[g1];  // les cavaliers blancs
  BtB_cavalier[1]  := Btb[b8] or Btb[g8];  // les cavaliers noirss

  pos_roiB := e1 ;
  BtB_roi[0]       := Btb[e1];       // le roi blanc
  pos_roiN := e8 ;
  BtB_roi[1]       := Btb[e8];       // le roi noir
  BtB_pions[0]     :=(Btb[a3]-1) xor (Btb[a2] -1) ;     // les pions blancs
  BtB_pions[1]     :=(Btb[a8]-1) xor (Btb[a7] -1) ;     // les pions noirs

   Arbre_jeu^.pos.FousDames := BtB_fou_dame[blanc] or BtB_fou_dame[noir]; //%%
   Arbre_jeu^.pos.ToursDames := BtB_fou_dame[blanc] or BtB_fou_dame[noir]; //%%

   Arbre_jeu^.pos.pieces[blanc][knight]:=2;
   Arbre_jeu^.pos.pieces[noir][knight] :=2 ;
   Arbre_jeu^.pos.pieces[blanc][bishop]:=2;
   Arbre_jeu^.pos.pieces[noir][bishop] :=2 ;
   Arbre_jeu^.pos.pieces[blanc][rook]:=2;
   Arbre_jeu^.pos.pieces[noir][rook] :=2 ;
   Arbre_jeu^.pos.pieces[blanc][queen]:=1;
   Arbre_jeu^.pos.pieces[noir][queen] :=1 ;
   Arbre_jeu^.pos.pieces[blanc][king]:=1 ;
   Arbre_jeu^.pos.pieces[noir][king] :=1 ;
   Arbre_jeu^.pos.pieces[blanc][pawn]:=8 ;
   Arbre_jeu^.pos.pieces[noir][pawn] :=8 ;

   Arbre_jeu^.pos.total_pieces :=32 ;

   Arbre_jeu^.TousPions := BtB_pions[blanc] or BtB_pions[noir] ;
  // showmessage('début  compte 5120 ! ');     pour estimer la durée
   for j:= 0 to 5120 do
   Arbre_jeu^.Liste_Coups[j] :=0;
  //  showmessage(' fin compte 5120 ! ');      ben c'est rapide!!

   Arbre_jeu^.alpha:=0;
   Arbre_jeu^.beta:=0;
   Arbre_jeu^.score:=0;
   Arbre_jeu^.au_trait:=blanc;
   Arbre_jeu^.profondeur:=0;
   Arbre_jeu^.mi_coup:=0;         // on compte en mi_coup ( ply) !!

   for i := 0 to 63 do
     begin
         if ( plateau_actuel[i,camp]=blanc )
             then begin
                  Arbre_jeu^.pos.plateau[blanc][i] :=  plateau_actuel[i,A_piece] ;
                  Arbre_jeu^.pos.plateau[noir][i] :=  A_zero ;
             end
             else begin
                  Arbre_jeu^.pos.plateau[noir][i] :=  plateau_actuel[i,A_piece] ;
                  Arbre_jeu^.pos.plateau[blanc][i] :=  A_zero ;
             end;
     end;
end;

//________________________________________________________________________
//     la balance matérielle sur l'échiquier : première évaluation
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
procedure  xxscore_ajust(var  v_arbre:PArbre;trait:integer;capture,promo:integer);
begin

if Trait=1 then
  begin
    case capture  of
         A_pion     : v_arbre^.score:= v_arbre^.score + Pion_valeur;
         A_cavalier : v_arbre^.score:= v_arbre^.score + Cavalier_valeur;
         A_Fou      : v_arbre^.score:= v_arbre^.score + Fou_valeur;
         A_Tour     : v_arbre^.score:= v_arbre^.score + Tour_valeur;
         A_Dame     : v_arbre^.score:= v_arbre^.score + Dame_valeur;
         else ;
    end;

    case promo  of
         A_cavalier : v_arbre^.score:= v_arbre^.score + Cavalier_valeur;
         A_Fou      : v_arbre^.score:= v_arbre^.score + Fou_valeur;
         A_Tour     : v_arbre^.score:= v_arbre^.score + Tour_valeur;
         A_Dame     : v_arbre^.score:= v_arbre^.score + Dame_valeur;
         else ;
    end;
  end
  else
  begin
    case capture  of
         A_pion     : v_arbre^.score:= v_arbre^.score - Pion_valeur;
         A_cavalier : v_arbre^.score:= v_arbre^.score - Cavalier_valeur;
         A_Fou      : v_arbre^.score:= v_arbre^.score - Fou_valeur;
         A_Tour     : v_arbre^.score:= v_arbre^.score - Tour_valeur;
         A_Dame     : v_arbre^.score:= v_arbre^.score - Dame_valeur;
         else ;
    end;

    case promo  of
         A_cavalier : v_arbre^.score:= v_arbre^.score - Cavalier_valeur;
         A_Fou      : v_arbre^.score:= v_arbre^.score - Fou_valeur;
         A_Tour     : v_arbre^.score:= v_arbre^.score - Tour_valeur;
         A_Dame     : v_arbre^.score:= v_arbre^.score - Dame_valeur;
         else ;
    end;
  end

   // pour ajuster Arbre_jeu^.score en fonction d'une prise ou promotion
end;
//________________________________________________________________________
//     la balance matérielle sur l'échiquier : première évaluation
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
procedure  score_ajust(var  v_arbre:PArbre;trait:integer;capture,promo:integer);
begin

if Trait=1 then
  begin
    case capture  of
         A_pion     : inc(v_arbre^.pos.pieces[blanc][pawn]);
         A_cavalier : inc(v_arbre^.pos.pieces[blanc][knight]);
         A_Fou      : inc(v_arbre^.pos.pieces[blanc][bishop]);
         A_Tour     : inc(v_arbre^.pos.pieces[blanc][rook]);
         A_Dame     : inc(v_arbre^.pos.pieces[blanc][queen]);
         else ;
    end;
  end
  else
  begin
    case capture  of
         A_pion     : dec(v_arbre^.pos.pieces[blanc][pawn]);
         A_cavalier : dec(v_arbre^.pos.pieces[blanc][knight]);
         A_Fou      : dec( v_arbre^.pos.pieces[blanc][bishop]);
         A_Tour     : dec(v_arbre^.pos.pieces[blanc][rook]);
         A_Dame     : dec(v_arbre^.pos.pieces[blanc][queen]);
         else ;
    end;
  end

   // pour ajuster Arbre_jeu^.score en fonction d'une prise ou promotion
end;
//________________________________________________________________________
//     la balance matérielle sur l'échiquier : première évaluation
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
function  score_matériel( v_arbre:PArbre ):integer;
begin
        // %%  on fait le bilan matériel simple des pieces en jeu.

result := ( v_arbre^.pos.pieces[blanc][knight] * Cavalier_valeur
         - v_arbre^.pos.pieces[noir ][knight] * Cavalier_valeur
         + v_arbre^.pos.pieces[blanc][bishop] * Fou_valeur
         - v_arbre^.pos.pieces[noir ][bishop] * Fou_valeur
         + v_arbre^.pos.pieces[blanc][rook]   * Tour_valeur
         - v_arbre^.pos.pieces[noir ][rook]   * Tour_valeur
         + v_arbre^.pos.pieces[blanc][queen]  * Dame_valeur
         - v_arbre^.pos.pieces[noir ][queen]  * Dame_valeur
         + v_arbre^.pos.pieces[blanc][pawn]   * Pion_valeur
         - v_arbre^.pos.pieces[noir ][pawn]   * Pion_valeur) ;

        // !!  on peut modifier en tenant comàpte
        // !!  de bonus pour la paire de fou ... etc ...
        // !!  à implémenter dès que cela fonctionne simplement
end;

//________________________________________________________________________
//     afficher la pièce
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

procedure  affiche_piece( case_actuelle : integer ) ;

var
  piece_sur_case, i, j : integer ;
  coefx,coefy,coefz:GlDouble;

begin
  piece_sur_case := plateau_actuel[case_actuelle,0] ;
  if piece_sur_case <> A_zero then
  begin

   i := case_actuelle div 8 ;
   j := case_actuelle mod 8 ;

   case piece_sur_case of
     A_cavalier: glTranslatef((j-g_Medio+2)*g_Arete,(i-g_Medio+2)*g_Arete,1.4);
     else        glTranslatef((j-g_Medio+2)*g_Arete,(i-g_Medio+2)*g_Arete,0);
   end;
        coefx := 0 ;
        coefy := 0 ;
        coefz := 0 ;

        case piece_sur_case of
              A_pion     : begin coefx:=0.007;coefy:=0.007;coefz:=0.006; end;
              A_cavalier : begin coefx:=0.01;coefy:=0.01;coefz:=0.01; end;
              A_fou      : begin coefx:=0.0085;coefy:=0.0085;coefz:=0.008; end;
              A_tour     : begin coefx:=0.0085;coefy:=0.0085;coefz:=0.007; end;
              A_dame     : begin coefx:=0.01;coefy:=0.01;coefz:=0.01; end;
              A_roi      : begin coefx:=0.01;coefy:=0.01;coefz:=0.01; end;
        end;


        glScalef(coefx, coefy, coefz);
        glrotate(90,1.0,0.0,0.0);

        if plateau_actuel[case_actuelle,1] = 1 then
        begin
//            glRotate(90,0.0,1.0,0.0);
            glbindtexture(gl_texture_2d,texture[26]);
            Mpiece[piece_sur_case].draw;
//            glRotate(-90,0.1,0.0,0.0);

       end
       else
       begin
//           glRotate(-90,0.0,1.0,0);
           glbindtexture(gl_texture_2d,texture[27]);
           Mpiece[piece_sur_case].draw;
//           glRotate(90,0.0,1.0,0.0);
       end;

       glrotate(-90,1.0,0.0,0.0);

       glScalef(1/coefx, 1/coefy, 1/coefz);

      case piece_sur_case of
        A_cavalier: glTranslatef(-(j-g_Medio+2)*g_Arete,-(i-g_Medio+2)*g_Arete,-1.4);
        else        glTranslatef(-(j-g_Medio+2)*g_Arete,-(i-g_Medio+2)*g_Arete,0);
      end;

  end;
end;


end.


unit UnitBtbInit;

//________________________________________________________
//                                                        |
//         projet Battle Chess  promo epita 2013          |
//              unité définissant les bitboards           |
//________________________________________________________|


interface

uses
    Windows;
//___________________________________________________________________________
//  définition des représentation alpha numériques des cases de l'échiquier  |
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
  const

  Nom_piece : Array[0..7] of string      // nommer les pièces
      = ('vide','pion','cavalier','roi','vide','fou','tour','dame');

  Coordonnees : Array[0..63] of string   // nommer les cases
       =('a1','b1','c1','d1','e1','f1','g1','h1',
         'a2','b2','c2','d2','e2','f2','g2','h2',
         'a3','b3','c3','d3','e3','f3','g3','h3',
         'a4','b4','c4','d4','e4','f4','g4','h4',
         'a5','b5','c5','d5','e5','f5','g5','h5',
         'a6','b6','c6','d6','e6','f6','g6','h6',
         'a7','b7','c7','d7','e7','f7','g7','h7',
         'a8','b8','c8','d8','e8','f8','g8','h8');

         a1= 0; b1= 1; c1= 2; d1= 3; e1= 4; f1= 5; g1= 6; h1= 7;
         a2= 8; b2=9;  c2=10; d2=11; e2=12; f2=13; g2=14; h2=15;
         a3=16; b3=17; c3=18; d3=19; e3=20; f3=21; g3=22; h3=23;
         a4=24; b4=25; c4=26; d4=27; e4=28; f4=29; g4=30; h4=31;
         a5=32; b5=33; c5=34; d5=35; e5=36; f5=37; g5=38; h5=39;
         a6=40; b6=41; c6=42; d6=43; e6=44; f6=45; g6=46; h6=47;
         a7=48; b7=49; c7=50; d7=51; e7=52; f7=53; g7=54; h7=55;
         a8=56; b8=57; c8=58; d8=59; e8=60; f8=61; g8=62; h8=63;

        p9=64; // une 'case imaginaire' qui nous sera bien utile
                // notemment dans l'attaque des pièces glissantes
                // pour le cas ou index_LSB(btb) ou index_MSB(btb)
                // seront appelés avec btb=0;
                // cette idée ne marche pas
//_____________________________________________________________________________
//  on crèe la table pour le parcours du cavalier d'Euler:  constante tableau
//  cette partie n'a pas d'intérèt particulier pour le programme
//  c'est juste pour le fun et la mise au point ... voire, une intro.                                      |                                           |
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
     Euler : Array[0..63] of integer =  // 'la' solution d'Euler lui même.
      ( a1,c2,e1,g2,h4,g6,h8,f7         //  simple suite des cases suivies
       ,d8,b7,c5,a6,b4,a2,c1,e2         //  par le cavalier pour boucler
       ,g1,h3,g5,h7,f8,e6,f4,d3         //  sa course sur l'échiquier
       ,e5,f3,d4,f5,e3,d5,c3,a4         //  et comme de a1 il peut sauter en b3
       ,b2,d1,f2,h1,g3,h5,g7,e8         //  nous pouvons initier la suite
       ,c7,a8,b6,c8,e7,g8,h6,g4         // depuis n'importe quelle avleur
       ,h2,f1,d2,b1,a3,b5,a7,c6         // du tableau
       ,b8,d7,f6,e4,d6,c4,a5,b3);

// ____________________________________________________________________________
//
// petite section Algorithme de De Bruijn  Nicolas.
//            -- importance théorique réelle pour le programe ++
//                            et pour les bitboards en particulier
// "Using de Bruijn Sequences to Index a in a Computer Word 1 Introduction "
//  ref bibliographique :http://supertech.csail.mit.edu/papers/debruijn.pdf
// l'idée part du fait que le reste de la division par 67 des 64 premières
// puissances de deux sont toutes différentes. ce fait remarquable, lié
//  à la primalité de 37 ( plus petit premier supérieur à 64) permet d'établir
//  une bijection entre  (2^n modulo 67) et n , n in [0..63]
//  par exemple :
//            BtB[a1] mod 67 = 64;
//            BtB[a2] mod 67 = 0;
//            BtB[a3] mod 67 = 1;   etc...
// d'où la table suivante:
//_____________________________________________________________________________
//  on crèe la table pour bit_Index :                                          |
//   Bit_mod67[reste%67]:=index_case;                                           |
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
//
    Bit_mod67: Array[0..66] of integer =(64, 0, 1,39, 2,15,40,23
                                        , 3,12,16,59,41,19,24,54
                                        , 4,-1,13,10,17,62,60,28
                                        ,42,30,20,51,25,44,55,47
                                        ,5,32,-1,38,14,22,11,58
                                        ,18,53,63,9,61,27,29,50
                                        ,43,46,31,37,21,57,52, 8
                                        ,26,49,45,36,56,7,48,35
                                        ,6,34,33);


   Btb_64  = $8000000000000000 - 1 + $8000000000000000 ; // btb remplie
   rang_1  = $100 - 1 ;
   rang_2  = ($10000 -1) xor ( $100 - 1 ) ;
   rang_3  = ($1000000 -1) xor (rang_1 or rang_2 ) ;
   rang_4  = ($100000000 -1) xor (rang_1 or rang_2 or rang_3)  ;
   rang_5  = ($10000000000 -1) xor (rang_1 or rang_2 or rang_3 or rang_4)  ;
   rang_6  = ($1000000000000 -1) xor (rang_1 or rang_2 or rang_3
                                      or rang_4 or rang_5) ;
   rang_7  = ($100000000000000 -1) xor (rang_1 or rang_2 or rang_3 or rang_4
                                        or rang_5 or rang_6) ;
   rang_8  =  Btb_64 -  ($100000000000000 - 1) ;


   OOO_B  = 1;      // constante grand roque blanc
   OO_B   = 2;     // constante petit roque blanc
   OOO_N  = 3;     // constante grand roque noir
   OO_N   = 4;    // constante petit roque noir

   empty    = 0;  // %%  type piece dans arbre^.position[couleur][piece]
   occupied = 0;  // %%
   pawn     = 1;  // %%      -> arbre^.position[couleur][pawn]
   knight   = 2;  // %%      -> ^^^^^^^^^^^^^^^^^^^^^^^^[knight]
   bishop   = 3;  // %%      -> ^^^^^^^^^^^^^^^^^^^^^^^^[bishop]
   rook     = 4;  // %%      -> ^^^^^^^^^^^^^^^^^^^^^^^^[rook]
   queen    = 5;  // %%      -> ^^^^^^^^^^^^^^^^^^^^^^^^[queen]
   king     = 6;  // %%      -> ^^^^^^^^^^^^^^^^^^^^^^^^[king]
   blanc = 0;
   noir  = 1;

  Mat                = 32768;
  Pion_valeur        = 100 ;
  Cavalier_valeur    = 325 ;
  Fou_valeur         = 325 ;
  Tour_valeur        = 500 ;
  Dame_valeur        = 970 ;
  Roi_valeur         = 40000 ;

const
   CPUs = 1;

 const
MAXPLY              = 65 ;
MAX_TC_NODES        = 3000000 ;
MAX_BLOCKS_PER_CPU  = 64;
MAX_BLOCKS          = MAX_BLOCKS_PER_CPU*CPUS ;
BOOK_CLUSTER_SIZE   = 8000 ;
BOOK_POSITION_SIZE  = 16;
MERGE_BLOCK         = 1000;
SORT_BLOCK          = 4000000 ;
LEARN_INTERVAL      = 10 ;
LEARN_WINDOW_LB     =-40;
LEARN_WINDOW_UB     =+40;
LEARN_COUNTER_BAD   =-80;
LEARN_COUNTER_GOOD  =+100 ;

EG_MAT              = 14 ;
MAX_DRAFT           = 256 ;

CLOCKS_PER_SEC  = 1000000 ;

 type

SEARCH_POSITION = record
   enpassant_target : byte;
   castle           : Array[0..1] of byte;
   rule_50_moves    : byte;
end;

 KILLER  = record
     move1:integer;
     move2:integer;
 end;



//_____________________________________________________________________________
//
// définition du type TBitboard    :::   BITBOARD  :::
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
    TBitboard  =    UInt64;        // un entier  64 bits non signé
                                     // " ... cela et rien de plus! "
                                     //                       E.Poe
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
 BtB_Pieces = record
    pieces : Array[0..6] of TBitboard;  // un bitboard par type de pièce
 end;

 position = record
     couleur        : Array[0..1] of BtB_Pieces;
     ToursDames     : TBitboard;                     // toutes  tour / dames
     FousDames      : TBitboard;                     // tous  fous / dames
   //  clef_hashage   : TBitboard;
   //  clef_hash_pion : TBitboard;
     materiel_eval  : integer;                        // balance matérielle
     SiegeRoi       : Array[0..1] of integer;         // siege roi (B/N)
     plateau        : Array[0..1] of Array[0..63]  of byte;    // position
     pieces         : Array[0..1] of Array[0..6] of byte;    // nb de pièce(B/N)
     pions          : Array[0..1] of byte;                 // nb de pions(B/N)
     total_pieces   : byte;                              // total pièces
      end;

 P_List_essai = ^T_List_essai;
 T_List_essai = Array[0..255] of integer;  // liste des coups envisagés sur une position

 PArbre = ^TArbre;
 TArbre = record
   pos         : position;
   TousPions   : TBitboard;
   Liste_Coups : Array[0..512] of integer;
   alpha       : integer;
   beta        : integer;
   score       : integer;
   au_trait    : integer;
   profondeur  : integer;
   mi_coup     : integer;
 end;

 Parbre_coups =  ^TArbre_coups;
 TArbre_coups = record
   coup         : integer ;
   eval         : integer ;
   pos_obtenu   : Parbre_coups ;
   coup_suivant : Parbre_coups ;
 end;





//______________________________________________________________________________
//
//  représenter l'échiquier, et les mouvements de pièce en mémoire ordi!
//__________________________________________________
// 17 tables de 64 Bitboards =  1088 Btb...         |
//    ces 1088 btb ont un rôle de constantes car    |
//    non modifiés par les calculs ultérieurs       |
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
var

  Btb                : Array[0..64] of TBitboard ; // Btb[n] représente: case n
                                                   //  puis pour chaque case:
  pion_B_Mvmt_pas    : Array[0..63] of TBitboard ; // marche en avant du pion B
  pion_B_Mvmt_prise  : Array[0..63] of TBitboard ; // la prise par le pion B
  pion_N_Mvmt_pas    : Array[0..63] of TBitboard ; // marche en avant ,pion N
  pion_N_Mvmt_prise  : Array[0..63] of TBitboard ; // la prise par le pion N
  Cavalier_BtB       : Array[0..63] of TBitboard ; // marche du cavalier
  Roi_BtB            : Array[0..63] of TBitboard ; // marche du roi
  Tour_BtB           : Array[0..63] of TBitboard ; // marche de la tour
  Fou_Btb            : Array[0..63] of TBitboard ; // marche du fou

  Tour_Mvmt_Ouest    : Array[0..63] of TBitboard ; // ces valeurs
  Tour_Mvmt_Est      : Array[0..63] of TBitboard ; // en "rose des vents "
  Tour_Mvmt_Sud      : Array[0..63] of TBitboard ; // seront utilisées
  Tour_Mvmt_Nord     : Array[0..63] of TBitboard ; // dans la partie IA
                                                   // pour le calcul
  Fou_Mvmt_NO        : Array[0..63] of TBitboard ; // des cases attaquées
  Fou_Mvmt_NE        : Array[0..63] of TBitboard ; // par les pièce 'glissantes'
  Fou_Mvmt_SO        : Array[0..63] of TBitboard ; // sur une ligne, un rang
  Fou_Mvmt_SE        : Array[0..63] of TBitboard ; // ou une diagonale

  // BitBoard contenant les pieces d'une couleur

  Alliees : array [0..1] of TBitboard ; // 0 : blancs ;
  Btb_affichage_cible : TBitboard ;
  O_O_O_B : TBitboard ;
  O_O_B : TBitboard ;
  O_O_O_N : TBitboard ;
  O_O_N : TBitboard ;

  toutes :   TBitboard ; // 0 : blancs ;  toutes pièces
  Btb_test : TBitboard ;

  BtB_fou_dame  : array [0..1] of TBitboard ;     //  les fous et les dames/camp
  BtB_tour_dame : array [0..1] of TBitboard ;    //  les tours et les dames/camp
  BtB_cavalier  : array [0..1] of TBitboard ;     //  les cavaliers/camp
  BtB_roi       : array [0..1] of TBitboard ;    //  les rois/camp
  BtB_pions     : array [0..1] of TBitboard ;    //  les pions/camp
  pos_roiB  : integer ;
  pos_roiN  : integer ;

  calcul_BtB_fou_dame  : array [0..1] of TBitboard ;     //  les fous et les dames/camp
  calcul_BtB_tour_dame : array [0..1] of TBitboard ;    //  les tours et les dames/camp
  calcul_BtB_cavalier  : array [0..1] of TBitboard ;     //  les cavaliers/camp
  calcul_BtB_roi       : array [0..1] of TBitboard ;    //  les rois/camp
  calcul_BtB_pions     : array [0..1] of TBitboard ;    //  les pions/camp
  calcul_pos_roiB  : integer ;
  calcul_pos_roiN  : integer ;

  calcul_alliees : array [0..1] of TBitboard ;
  calcul_toutes : TBitboard ;

  promotion_faite :integer  ;
  piece_deplacee  :integer  ;
  piece_capturee  :integer  ;


  OOxOOO :integer; //  la valeur en cours du roque dans cible_Roi()

  Arbre_jeu   : PArbre;         //%% l'arbre pour l'IA
  coup_essai : P_List_essai;   //%% liste des coups de la position en cours
  Mi_Coup_actuel: integer;     // Mi_Coup en cours -> la position en cours

  Arbre_calcul : PArbre_coups ;
  arbre_pos_actuelle : PArbre_coups ;


  procedure   initbitboards;                       //  initialisation!!!
  function bit_Index( iBitboard : TBitboard):integer; // function : 'De Bruijn'
  function index_MSB( val :TBitBoard ):integer;     //calc. Bit de poids Fort
  function MSB( val :TBitBoard ):TBitBoard;
  function index_LSB( val :TBitBoard ):integer;     //calc. Bit de poids Faible
  function LSB( val :TBitBoard ):TBitBoard;
  function Ote_LSB( val :TBitBoard ):TBitBoard;    //ote   Bit de poids faible
  function x_StrUInt64Digits(val: TBitboard; width: Integer; sign: Boolean): ShortString;


implementation

//_____________________________________________________________________________
//                                                                             |
//  la fonction  bit_Index() appliquée à un bitboard ("monobit")               |
//  ramène l'index de la case désignée par ce bit                              |
//  elle utilise une  propriété remarquable du nombre 67 :                     |
//     - plus petit nombre premier supérieur à 64                              |
//     - les restes de la division par 67 des 64 puissances de 2 sont tous     |
//        distincts. une table permet donc d'associer chaque reste à           |
//        une case donnée, ( c'est une bijection vraie ) par ex.               |
//        -->  2^17 mod 67 = 20;  lecture de table: --> Bit_mod67[20]:= 17;    |
//  ainsi: bit_Index(Btb[17])=17;                                              |
//  tout sauf triviale,cette fonction est très rapide, simple et économique    |
//                                                                             |
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
   function bit_Index( iBitboard : TBitboard):integer;
     begin
         result :=  Bit_mod67[(iBitboard) mod 67];
     end;

//_____________________________________________________________________________
//
//   calcul de l'index du bit de poids fort d'un bitboard    (24/03/2009)
//    attention : l'index!  et non  le BitBoard[index]
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
function index_MSB( val :TBitBoard ):integer;
var memo:integer;
  begin
    memo := 0;

    if val > $80000000  then    // > h4
        begin
           memo:= memo or $20;
           val :=  val shr 32;
       end;

    if val > $8000 then         // > h2
        begin
           memo:= memo or $10;
           val :=  val shr 16;
        end;

    if val > $80 then           // > h1
        begin
           memo:= memo or $8;
           val :=  val shr 8;
        end;

     if val > $8 then           // > d1
        begin
           memo:= memo or $4;
           val :=  val shr 4;
        end;

    if val > $2 then            // > b1
        begin
           memo:= memo or $2;
           val :=  val shr 2;
        end;

     if val >$1 then            // > a1
        begin
         memo:= memo or $1;
          val:=  val shr 1;
        end;

     result := memo +val-1;
    end;

 //___________________________________________________________________________
 //
 //  la fonction MSB retourne le BitBoard correspondant au Bit de poids fort
 //         ramène $FFFFFFFF00000000 si le Bitboard val = 0;
 //¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
 function MSB( val :TBitBoard ):TBitBoard;
 begin
    result := Btb[index_MSB(val)];
 end;

//_____________________________________________________________________________
//
//   calcul de l'index du bit de poids faible d'un bitboard
//    attention : l'index!  et non  le BitBoard[index]
//
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
function index_LSB( val :TBitBoard ):integer;
  begin
   result:=bit_Index( val and - val) ;
  end;

function LSB( val :TBitBoard ):TBitBoard;  //N.B.  ramène 0 si val=0
  begin
   result:= val and - val ;
  end;

//_____________________________________________________________________________
//
//   ote le bit de poids faible d'un bitboard
//
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
function Ote_LSB( val :TBitBoard ):TBitBoard;
  begin
        result := val and (val-1) ;
  end;



//_____________________________________________________________________________
//                                                                             |
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨|
//                Version Pascal des mouvements de pièces                      |
//                                                                             |
//   cette liste de tableau peut sembler rédhibitoire, mais elle permet de     |
//   s’affranchir de calculs répétitifs lors de la recherche des coups et      |
//   fait gagner un temps de calcul, la fonction générer coup revient alors    |
//   à une simple lecture de ces tables, sans calcul.                          |
//                                                                             |
// ces Tableaux permettent l’usage d’Opérateurs d’ensembles                    |
// Opérateur     Opération   Types d’opérande  Type du résultat   Exemple      |
//     +            union            ensemble         ensemble    Set1 + Set2  |
//     –          différence         ensemble         ensemble     S - T       |
//     *         intersection        ensemble         ensemble     S * T       |
//     <=       sous-ensemble        ensemble         Boolean      Q <= MySet  |
//     >=        sur-ensemble        ensemble         Boolean      S1 >= S2    |
//     =          égalité            ensemble         Boolean      S2 = MySet  |
//     <>         différence         ensemble         Boolean      MySet <> S1 |
//     in     inclusion scalaire,    ensemble         Boolean      A in Set1   |
//                                                                             |
//_________________________________________________________________________    |
//                                                                             |
//       tables des mouvements proprements dits                                |
//  TCible =0..63       (échiquier complet)                                    |                     |
// un ensemble d’entiers listant toutes  les cases cibles possibles            |
//                                                                             |
//   +----+----+----+----+----+----+----+----+                                 |
//   | 56 | 57 | 58 | 59 | 60 | 61 | 62 | 63 |                                 |
//   +----+----+----+----+----+----+----+----+                                 |
//   | 48 | 49 | 50 | 51 | 52 | 53 | 54 | 55 |                                 |
//   +----+----+----+----+----+----+----+----+                                 |
//   | 40 | 41 | 42 | 43 | 44 | 45 | 46 | 47 |       N                         |
//   +----+----+----+----+----+----+----+----+   NO      NE                    |
//   | 32 | 33 | 34 | 35 | 36 | 37 | 38 | 39 |                                 |
//   +----+----+----+----+----+----+----+----+ O     *     E                   |
//   | 24 | 25 | 26 | 27 | 28 | 29 | 30 | 31 |                                 |
//   +----+----+----+----+----+----+----+----+   SO     SE                     |
//   | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 |       S                         |
//   +----+----+----+----+----+----+----+----+   rose des vents                |
//   | 8  | 9  | 10 | 11 | 12 | 13 | 14 | 15 |                                 |
//   +----+----+----+----+----+----+----+----+                                 |
//   | 0  | 1  |  2 |  3 | 4  | 5  | 6  | 7  |                                 |
//   +----+----+----+----+----+----+----+----+                                 |
//                                                                             |
//    0 = a1  1 = b1  ...  63 = h8                                             |
//                                                                             |
//  partant de cet ensemble de cibles, chaque type de pièces                   |
//  possède  son ensemble de cibles                                            |
//  deux dimension pour les pions : un ensemble de cibles d’avance du pion [0] |
//   un ensemble de cibles de prise par ce pion  [b1]                          |
//                                                                             |
//__________________________________________________________________________   |
//                                                                             |
//  les Types  pion, Tour, Fou, Roi Cavalier                                   |
//          ( pas de Type Dame,  Type Dame = Type Tour & Type Fou)             |
//__________________________________________________________________________   |
//__________________________________________________________________________   |
//                                                                             |
  procedure  initbitboards;
  var i:integer;
begin

//______________________________________________________________________________
//  on crèe les 64 Bitboard représentant les cases a1 .. h8
//   chaque case est définie par un nombre de 64 bits ( non signé)
//   le bit corespondant à la case est mis à 1
//           tous les autres bits sont mis à 0                 |
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

Btb[p9] := - $0 ;                 //bitboard de la case ->  a1.

Btb[a1] :=  $1 ;                 //bitboard de la case ->  a1.
Btb[b1] :=  $2;                  //bitboard de la case ->  b1.
Btb[c1] :=  $4;                  //bitboard de la case ->  c1.
Btb[d1] :=  $8;                  //bitboard de la case ->  d1.
Btb[e1] :=  $10;                 //bitboard de la case ->  e1.
Btb[f1] :=  $20;                 //bitboard de la case ->  f1.
Btb[g1] :=  $40;                 //bitboard de la case ->  g1.
Btb[h1] :=  $80;                 //bitboard de la case ->  h1.
Btb[a2] :=  $100;                //bitboard de la case ->  a2.
Btb[b2] :=  $200;                //bitboard de la case ->  b2.
Btb[c2] :=  $400;                //bitboard de la case ->  c2.
Btb[d2] :=  $800;                //bitboard de la case ->  d2.
Btb[e2] :=  $1000;               //bitboard de la case ->  e2.
Btb[f2] :=  $2000;               //bitboard de la case ->  f2.
Btb[g2] :=  $4000;               //bitboard de la case ->  g2.
Btb[h2] :=  $8000;               //bitboard de la case ->  h2.
Btb[a3] :=  $10000;              //bitboard de la case ->  a3.
Btb[b3] :=  $20000;              //bitboard de la case ->  b3.
Btb[c3] :=  $40000;              //bitboard de la case ->  c3.
Btb[d3] :=  $80000;              //bitboard de la case ->  d3.
Btb[e3] :=  $100000;             //bitboard de la case ->  e3.
Btb[f3] :=  $200000;             //bitboard de la case ->  f3.
Btb[g3] :=  $400000;             //bitboard de la case ->  g3.
Btb[h3] :=  $800000;             //bitboard de la case ->  h3.
Btb[a4] :=  $1000000;            //bitboard de la case ->  a4.
Btb[b4] :=  $2000000;            //bitboard de la case ->  b4.
Btb[c4] :=  $4000000;            //bitboard de la case ->  c4.
Btb[d4] :=  $8000000;            //bitboard de la case ->  d4.
Btb[e4] :=  $10000000;           //bitboard de la case ->  e4.
Btb[f4] :=  $20000000;           //bitboard de la case ->  f4.
Btb[g4] :=  $40000000;           //bitboard de la case ->  g4.
Btb[h4] :=  $80000000;           //bitboard de la case ->  h4.
Btb[a5] :=  $100000000;          //bitboard de la case ->  a5.
Btb[b5] :=  $200000000;          //bitboard de la case ->  b5.
Btb[c5] :=  $400000000;          //bitboard de la case ->  c5.
Btb[d5] :=  $800000000;          //bitboard de la case ->  d5.
Btb[e5] :=  $1000000000;         //bitboard de la case ->  e5.
Btb[f5] :=  $2000000000;         //bitboard de la case ->  f5.
Btb[g5] :=  $4000000000;         //bitboard de la case ->  g5.
Btb[h5] :=  $8000000000;         //bitboard de la case ->  h5.
Btb[a6] :=  $10000000000;        //bitboard de la case ->  a6.
Btb[b6] :=  $20000000000;        //bitboard de la case ->  b6.
Btb[c6] :=  $40000000000;        //bitboard de la case ->  c6.
Btb[d6] :=  $80000000000;        //bitboard de la case ->  d6.
Btb[e6] :=  $100000000000;       //bitboard de la case ->  e6.
Btb[f6] :=  $200000000000;       //bitboard de la case ->  f6.
Btb[g6] :=  $400000000000;       //bitboard de la case ->  g6.
Btb[h6] :=  $800000000000;       //bitboard de la case ->  h6.
Btb[a7] :=  $1000000000000;      //bitboard de la case ->  a7.
Btb[b7] :=  $2000000000000;      //bitboard de la case ->  b7.
Btb[c7] :=  $4000000000000;      //bitboard de la case ->  c7.
Btb[d7] :=  $8000000000000;      //bitboard de la case ->  d7.
Btb[e7] :=  $10000000000000;     //bitboard de la case ->  e7.
Btb[f7] :=  $20000000000000;     //bitboard de la case ->  f7.
Btb[g7] :=  $40000000000000;     //bitboard de la case ->  g7.
Btb[h7] :=  $80000000000000;     //bitboard de la case ->  h7.
Btb[a8] :=  $100000000000000;    //bitboard de la case ->  a8.
Btb[b8] :=  $200000000000000;    //bitboard de la case ->  b8.
Btb[c8] :=  $400000000000000;    //bitboard de la case ->  c8
Btb[d8] :=  $800000000000000;    //bitboard de la case ->  d8
Btb[e8] :=  $1000000000000000;   //bitboard de la case ->  e8.
Btb[f8] :=  $2000000000000000;   //bitboard de la case ->  f8.
Btb[g8] :=  $4000000000000000;   //bitboard de la case ->  g8.
Btb[h8] :=  $8000000000000000;   //bitboard de la case ->  h8.




//______________________________________________________________________
// on crèe les 64 Bitboards représentant les possibilités d'avance de pions N
//      et les 64 Bitboards représentant les possibilités de prise de pions N
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
//_________________________________________________________________________
//
//          tables des déplacements de pion noirs
//_________________________________________________________________________
//

    pion_N_Mvmt_pas[a1]:=0;
    pion_N_Mvmt_prise[a1]:=0;

    pion_N_Mvmt_pas[b1]:=0;
    pion_N_Mvmt_prise[b1]:=0;

    pion_N_Mvmt_pas[c1]:=0;
    pion_N_Mvmt_prise[c1]:=0;

    pion_N_Mvmt_pas[d1]:=0;
    pion_N_Mvmt_prise[d1]:=0;

    pion_N_Mvmt_pas [e1]:=0;
    pion_N_Mvmt_prise[e1]:=0;

    pion_N_Mvmt_pas[f1]:=0;
    pion_N_Mvmt_prise[f1]:=0;

    pion_N_Mvmt_pas[g1]:=0;
    pion_N_Mvmt_prise[g1]:=0;

    pion_N_Mvmt_pas[h1]:=0;
    pion_N_Mvmt_prise[h1]:=0;

    pion_N_Mvmt_pas[a2]:=  Btb[a1];
    pion_N_Mvmt_prise[a2]:=  Btb[b1];

    pion_N_Mvmt_pas[b2]:=  Btb[b1];
    pion_N_Mvmt_prise[b2]:=  Btb[a1] or Btb[c1];

    pion_N_Mvmt_pas[c2]:=  Btb[c1];
    pion_N_Mvmt_prise[c2]:=  Btb[b1] or Btb[d1];

    pion_N_Mvmt_pas[d2]:=  Btb[d1];
    pion_N_Mvmt_prise[d2]:=  Btb[c1] or Btb[e1];

    pion_N_Mvmt_pas[e2]:=  Btb[e1];
    pion_N_Mvmt_prise[e2]:=  Btb[d1] or Btb[f1];

    pion_N_Mvmt_pas[f2]:=  Btb[f1];
    pion_N_Mvmt_prise[f2]:=  Btb[e1]or Btb[g1];

    pion_N_Mvmt_pas[g2]:=  Btb[g1];
    pion_N_Mvmt_prise[g2]:=  Btb[f1] or Btb[h1];

    pion_N_Mvmt_pas[h2]:=  Btb[h1];
    pion_N_Mvmt_prise[h2]:=  Btb[g1];

    pion_N_Mvmt_pas[a3]:=  Btb[a2];
    pion_N_Mvmt_prise[a3]:=  Btb[b2];

    pion_N_Mvmt_pas[b3]:=  Btb[b2];
    pion_N_Mvmt_prise[b3]:=  Btb[a2] or Btb[c2];

    pion_N_Mvmt_pas[c3]:=  Btb[c2];
    pion_N_Mvmt_prise[c3]:=  Btb[b2] or Btb[d2];

    pion_N_Mvmt_pas[d3]:=  Btb[d2];
    pion_N_Mvmt_prise[d3]:=  Btb[c2] or Btb[e2];

    pion_N_Mvmt_pas[e3]:=  Btb[e2];
    pion_N_Mvmt_prise[e3]:=  Btb[d2] or Btb[f2];

    pion_N_Mvmt_pas[f3]:=  Btb[f2];
    pion_N_Mvmt_prise[f3]:=  Btb[e2] or Btb[g2];

    pion_N_Mvmt_pas[g3]:=  Btb[g2];
    pion_N_Mvmt_prise[g3]:=  Btb[f2] or Btb[h2];

    pion_N_Mvmt_pas[h3]:=  Btb[h2];
    pion_N_Mvmt_prise[h3]:=  Btb[g2];

    pion_N_Mvmt_pas[a4]:=  Btb[a3];
    pion_N_Mvmt_prise[a4]:=  Btb[b3];

    pion_N_Mvmt_pas[b4]:=  Btb[b3];
    pion_N_Mvmt_prise[b4]:=  Btb[a3] or Btb[c3];

    pion_N_Mvmt_pas[c4]:=  Btb[c3];
    pion_N_Mvmt_prise[c4]:=  Btb[b3] or Btb[d3];

    pion_N_Mvmt_pas[d4]:=  Btb[d3];
    pion_N_Mvmt_prise[d4]:=  Btb[c3] or Btb[e3];

    pion_N_Mvmt_pas[e4]:=  Btb[e3];
    pion_N_Mvmt_prise[e4]:=  Btb[d3] or Btb[f3];

    pion_N_Mvmt_pas[f4]:=  Btb[f3];
    pion_N_Mvmt_prise[f4]:=  Btb[e3] or Btb[g3];

    pion_N_Mvmt_pas[g4]:=  Btb[g3];
    pion_N_Mvmt_prise[g4]:=  Btb[f3] or Btb[h3];

    pion_N_Mvmt_pas[h4]:=  Btb[h3];
    pion_N_Mvmt_prise[h4]:=  Btb[g3];

    pion_N_Mvmt_pas[a5]:=  Btb[a4];
    pion_N_Mvmt_prise[a5]:=  Btb[b4];

    pion_N_Mvmt_pas[b5]:=  Btb[b4];
    pion_N_Mvmt_prise[b5]:=  Btb[a4]or Btb[c4];

    pion_N_Mvmt_pas[c5]:=  Btb[c4];
    pion_N_Mvmt_prise[c5]:=  Btb[b4] or Btb[d4];

    pion_N_Mvmt_pas[d5]:=  Btb[d4];
    pion_N_Mvmt_prise[d5]:=  Btb[c4] or Btb[e4];

    pion_N_Mvmt_pas[e5]:=  Btb[e4];
    pion_N_Mvmt_prise[e5]:=  Btb[d4] or Btb[f4];

    pion_N_Mvmt_pas[f5]:=  Btb[f4];
    pion_N_Mvmt_prise[f5]:=  Btb[e4] or Btb[g4];

    pion_N_Mvmt_pas[g5]:=  Btb[g4];
    pion_N_Mvmt_prise[g5]:=  Btb[f4] or Btb[h4];

    pion_N_Mvmt_pas[h5]:=  Btb[h4];
    pion_N_Mvmt_prise[h5]:=  Btb[g4];

    pion_N_Mvmt_pas[a6]:=  Btb[a5];
    pion_N_Mvmt_prise[a6]:=  Btb[b5];

    pion_N_Mvmt_pas[b6]:=  Btb[b5];
    pion_N_Mvmt_prise[b6]:=  Btb[a5] or Btb[c5];

    pion_N_Mvmt_pas[c6]:=  Btb[c5];
    pion_N_Mvmt_prise[c6]:=  Btb[b5] or Btb[d5];

    pion_N_Mvmt_pas[d6]:=  Btb[d5];
    pion_N_Mvmt_prise[d6]:=  Btb[c5] or Btb[e5];

    pion_N_Mvmt_pas[e6]:=  Btb[e5];
    pion_N_Mvmt_prise[e6]:=  Btb[d5] or Btb[f5];

    pion_N_Mvmt_pas[f6]:=  Btb[f5];
    pion_N_Mvmt_prise[f6]:=  Btb[e5] or Btb[g5];

    pion_N_Mvmt_pas[g6]:=  Btb[g5];
    pion_N_Mvmt_prise[g6]:=  Btb[f5] or Btb[h5];

    pion_N_Mvmt_pas[h6]:=  Btb[h5];
    pion_N_Mvmt_prise[h6]:=  Btb[g5];

    pion_N_Mvmt_pas[a7]:=  Btb[a6] or Btb[a5];
    pion_N_Mvmt_prise[a7]:=  Btb[b6];

    pion_N_Mvmt_pas[b7]:=  Btb[b6] or Btb[b5];
    pion_N_Mvmt_prise[b7]:=  Btb[a6] or Btb[c6];

    pion_N_Mvmt_pas[c7]:=  Btb[c6] or Btb[c5];
    pion_N_Mvmt_prise[c7]:=  Btb[b6] or Btb[d6];

    pion_N_Mvmt_pas[d7]:=  Btb[d6] or Btb[d5];
    pion_N_Mvmt_prise[d7]:=  Btb[c6] or Btb[e6];

    pion_N_Mvmt_pas[e7]:=  Btb[e6] or Btb[e5];
    pion_N_Mvmt_prise[e7]:=  Btb[d6] or Btb[f6];

    pion_N_Mvmt_pas[f7]:=  Btb[f6] or Btb[f5];
    pion_N_Mvmt_prise[f7]:=  Btb[e6] or Btb[g6];

    pion_N_Mvmt_pas[g7]:=  Btb[g6] or Btb[g5];
    pion_N_Mvmt_prise[g7]:=  Btb[f6] or Btb[h6];

    pion_N_Mvmt_pas[h7]:=  Btb[h6] or Btb[h5];
    pion_N_Mvmt_prise[h7]:=  Btb[g6];


// les valeurs suivantes sont pour des pions imaginaires...
// dont le rôle réside dans dans les menaces d'échecs
//  voir si elles sont indispensables] or Btb[

    pion_N_Mvmt_pas[a8]:=  0;
    pion_N_Mvmt_prise[a8]:=             Btb[b7];

    pion_N_Mvmt_pas[b8]:=  0;
    pion_N_Mvmt_prise[b8]:=  Btb[a7] or Btb[c7];

    pion_N_Mvmt_pas[c8]:=  0;
    pion_N_Mvmt_prise[c8]:= Btb[b7] or Btb[d7];

    pion_N_Mvmt_pas[d8]:=  0;
    pion_N_Mvmt_prise[d8]:= Btb[c7] or Btb[e7];

    pion_N_Mvmt_pas[e8]:=  0;
    pion_N_Mvmt_prise[e8]:= Btb[d7] or Btb[f7];

    pion_N_Mvmt_pas[f8]:=  0;
   pion_N_Mvmt_prise[f8]:= Btb[e7] or Btb[g7];

    pion_N_Mvmt_pas[g8]:=  0;
    pion_N_Mvmt_prise[g8]:=  Btb[f7] or  Btb[h7];

    pion_N_Mvmt_pas[h8]:=0;
    pion_N_Mvmt_prise[h8]:= Btb[g7];

//_________________________________________________________________________
//
//          tables des déplacements de pion blancs
//_________________________________________________________________________
//

 // ***> 0..7  deplacement de pions noirs imaginaires pour le contrôle des échecs de pions

    pion_B_Mvmt_pas[a1]:=0;
    pion_B_Mvmt_prise[a1]:=             Btb[b2];


    pion_B_Mvmt_pas[b1]:=0;
    pion_B_Mvmt_prise[b1]:= Btb[a2]  or Btb [c2];

    pion_B_Mvmt_pas[c1]:=0;
    pion_B_Mvmt_prise[c1]:= Btb[b2] or Btb [d2];

    pion_B_Mvmt_pas[d1]:=0;
    pion_B_Mvmt_prise[d1]:= Btb [c2] or Btb [e2];

    pion_B_Mvmt_pas [e1]:=0;
    pion_B_Mvmt_prise[e1]:= Btb [d2] or Btb [f2];

    pion_B_Mvmt_pas[f1]:=0;
    pion_B_Mvmt_prise[f1]:= Btb [e2] or Btb [g2];

    pion_B_Mvmt_pas[g1]:=0;
    pion_B_Mvmt_prise[g1]:= Btb [f2] or Btb [h2];

    pion_B_Mvmt_pas[h1]:=0;
    pion_B_Mvmt_prise[h1]:= Btb [g2];

// 8..63  deplacement des autres  pions noirs

    pion_B_Mvmt_pas[a2]:=  Btb[a3] or Btb [a4];
    pion_B_Mvmt_prise[a2]:= Btb [b3];

    pion_B_Mvmt_pas[b2]:= Btb [b3] or Btb [b4];
    pion_B_Mvmt_prise[b2]:= Btb [a3] or Btb [c3];

    pion_B_Mvmt_pas[c2]:=  Btb[c3] or Btb [c4];
    pion_B_Mvmt_prise[c2]:=  Btb[b3] or Btb [d3];

    pion_B_Mvmt_pas[d2]:=  Btb[d3] or Btb[d4];
    pion_B_Mvmt_prise[d2]:=  Btb[c3] or Btb[e3];

    pion_B_Mvmt_pas[e2]:=  Btb[e3] or Btb[e4];
    pion_B_Mvmt_prise[e2]:=  Btb[d3] or Btb[f3];

    pion_B_Mvmt_pas[f2]:=  Btb[f3] or Btb[f4];
    pion_B_Mvmt_prise[f2]:=  Btb[e3] or Btb[g3];

    pion_B_Mvmt_pas[g2]:=  Btb[g3] or Btb[g4];
    pion_B_Mvmt_prise[g2]:=  Btb[f3] or Btb[h3];

    pion_B_Mvmt_pas[h2]:=  Btb[h3] or Btb[h4];
    pion_B_Mvmt_prise[h2]:=  Btb[g3];

    pion_B_Mvmt_pas[a3]:=  Btb[a4];
    pion_B_Mvmt_prise[a3]:=  Btb[b4];

    pion_B_Mvmt_pas[b3]:=  Btb[b4];
    pion_B_Mvmt_prise[b3]:=  Btb[a4] or Btb[c4];

    pion_B_Mvmt_pas[c3]:=  Btb[c4];
    pion_B_Mvmt_prise[c3]:=  Btb[b4] or Btb[d4];

    pion_B_Mvmt_pas[d3]:=  Btb[d4];
    pion_B_Mvmt_prise[d3]:=  Btb[c4] or Btb[e4];

    pion_B_Mvmt_pas[e3]:=  Btb[e4];
    pion_B_Mvmt_prise[e3]:=  Btb[d4] or Btb[f4];

    pion_B_Mvmt_pas[f3]:=  Btb[f4];
    pion_B_Mvmt_prise[f3]:=  Btb[e4] or Btb[g4];

    pion_B_Mvmt_pas[g3]:=  Btb[g4];
    pion_B_Mvmt_prise[g3]:=  Btb[f4] or Btb[h4];

    pion_B_Mvmt_pas[h3]:=  Btb[h4];
    pion_B_Mvmt_prise[h3]:=  Btb[g4];

    pion_B_Mvmt_pas[a4]:=  Btb[a5];
    pion_B_Mvmt_prise[a4]:=  Btb[b5];

    pion_B_Mvmt_pas[b4]:=  Btb[b5];
    pion_B_Mvmt_prise[b4]:=  Btb[a5] or Btb[c5];

    pion_B_Mvmt_pas[c4]:=  Btb[c5];
    pion_B_Mvmt_prise[c4]:=  Btb[b5] or Btb[d5];

    pion_B_Mvmt_pas[d4]:=  Btb[d5];
    pion_B_Mvmt_prise[d4]:=  Btb[c5] or Btb[e5];

    pion_B_Mvmt_pas[e4]:=  Btb[e5];
    pion_B_Mvmt_prise[e4]:=  Btb[d5] or Btb[f5];

    pion_B_Mvmt_pas[f4]:=  Btb[f5];
    pion_B_Mvmt_prise[f4]:=  Btb[e5]or Btb[g5];

    pion_B_Mvmt_pas[g4]:=  Btb[g5];
    pion_B_Mvmt_prise[g4]:=  Btb[f5] or Btb[h5];

    pion_B_Mvmt_pas[h4]:=  Btb[h5];
    pion_B_Mvmt_prise[h4]:=  Btb[g5];

    pion_B_Mvmt_pas[a5]:=  Btb[a6];
    pion_B_Mvmt_prise[a5]:=  Btb[b6];

    pion_B_Mvmt_pas[b5]:=  Btb[b6];
    pion_B_Mvmt_prise[b5]:=  Btb[a6] or Btb[c6];

    pion_B_Mvmt_pas[c5]:=  Btb[c6];
    pion_B_Mvmt_prise[c5]:=  Btb[b6] or Btb[d6];

    pion_B_Mvmt_pas[d5]:=  Btb[d6];
    pion_B_Mvmt_prise[d5]:=  Btb[c6] or Btb[e6];

    pion_B_Mvmt_pas[e5]:=  Btb[e6];
    pion_B_Mvmt_prise[e5]:=  Btb[d6] or Btb[f6];

    pion_B_Mvmt_pas[f5]:=  Btb[f6];
    pion_B_Mvmt_prise[f5]:=  Btb[e6] or Btb[g6];

    pion_B_Mvmt_pas[g5]:=  Btb[g6];
    pion_B_Mvmt_prise[g5]:=  Btb[f6] or Btb[h6];

    pion_B_Mvmt_pas[h5]:=  Btb[h6];
    pion_B_Mvmt_prise[h5]:=  Btb[g6];

    pion_B_Mvmt_pas[a6]:=  Btb[a7];
    pion_B_Mvmt_prise[a6]:=  Btb[b7];

    pion_B_Mvmt_pas[b6]:=  Btb[b7];
    pion_B_Mvmt_prise[b6]:=  Btb[a7] or Btb[c7];

    pion_B_Mvmt_pas[c6]:=  Btb[c7];
    pion_B_Mvmt_prise[c6]:=  Btb[b7] or Btb[d7];

    pion_B_Mvmt_pas[d6]:=  Btb[d7];
    pion_B_Mvmt_prise[d6]:=  Btb[c7] or Btb[e7];

    pion_B_Mvmt_pas[e6]:=  Btb[e7];
    pion_B_Mvmt_prise[e6]:=  Btb[d7] or Btb[f7];

    pion_B_Mvmt_pas[f6]:=  Btb[f7];
    pion_B_Mvmt_prise[f6]:=  Btb[e7] or Btb[g7];

    pion_B_Mvmt_pas[g6]:=  Btb[g7];
    pion_B_Mvmt_prise[g6]:=  Btb[f7] or Btb[h7];

    pion_B_Mvmt_pas[h6]:=  Btb[h7];
    pion_B_Mvmt_prise[h6]:=  Btb[g7];

    pion_B_Mvmt_pas[a7]:=  Btb[a8];
    pion_B_Mvmt_prise[a7]:=  Btb[b8];

    pion_B_Mvmt_pas[b7]:=  Btb[b8];
    pion_B_Mvmt_prise[b7]:=  Btb[a8] or Btb[c8];

    pion_B_Mvmt_pas[c7]:=  Btb[c8];
    pion_B_Mvmt_prise[c7]:=  Btb[b8] or Btb[d8];

    pion_B_Mvmt_pas[d7]:=  Btb[d8];
    pion_B_Mvmt_prise[d7]:=  Btb[c8] or Btb[e8];

    pion_B_Mvmt_pas[e7]:=  Btb[e8];
    pion_B_Mvmt_prise[e7]:=  Btb[d8] or Btb[f8];

    pion_B_Mvmt_pas[f7]:=  Btb[f8];
    pion_B_Mvmt_prise[f7]:=  Btb[e8] or Btb[g8];

    pion_B_Mvmt_pas[g7]:=  Btb[g8];
    pion_B_Mvmt_prise[g7]:=  Btb[f8] or Btb[h8];

    pion_B_Mvmt_pas[h7]:=  Btb[h8];
    pion_B_Mvmt_prise[h7]:=  Btb[g8];

    pion_B_Mvmt_pas[a8]:=0;
    pion_B_Mvmt_prise[a8]:=0;

    pion_B_Mvmt_pas[b8]:=0;
    pion_B_Mvmt_prise[b8]:=0;

    pion_B_Mvmt_pas[c8]:=0;
    pion_B_Mvmt_prise[c8]:=0;

    pion_B_Mvmt_pas[d8]:=0;
    pion_B_Mvmt_prise[d8]:=0;

    pion_B_Mvmt_pas[e8]:=0;
    pion_B_Mvmt_prise[e8]:=0;

    pion_B_Mvmt_pas[f8]:=0;
    pion_B_Mvmt_prise[f8]:=0;

    pion_B_Mvmt_pas[g8]:=0;
    pion_B_Mvmt_prise[g8]:=0;

    pion_B_Mvmt_pas[h8]:=0;
    pion_B_Mvmt_prise[h8]:=0;

//______________________________________________________________________
// on crèe les 64 Bitboards représentant les mouvements du roi
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨


    Roi_Btb[a1] :=  Btb[b1] or Btb[a2] or Btb[b2];
    Roi_Btb[b1] :=  Btb[a1] or Btb[c1] or Btb[a2] or Btb[b2] or Btb[c2];
    Roi_Btb[c1] :=  Btb[b1] or Btb[d1] or Btb[b2] or Btb[c2] or Btb[d2];
    Roi_Btb[d1] :=  Btb[c1] or Btb[e1] or Btb[c2] or Btb[d2] or Btb[e2];
    Roi_BtB [e1]:=  Btb[d1] or Btb[f1] or Btb[d2] or Btb[e2] or Btb[f2];
    Roi_Btb[f1] :=  Btb[e1] or Btb[g1] or Btb[e2] or Btb[f2] or Btb[g2];
    Roi_Btb[g1] :=  Btb[f1] or Btb[h1] or Btb[f2] or Btb[g2] or Btb[h2];
    Roi_Btb[h1] :=  Btb[g1] or Btb[g2] or Btb[h2];

    Roi_Btb[a2] :=  Btb[a1] or Btb[b1] or Btb[b2] or Btb[b3] or Btb[a3];
    Roi_Btb[b2] :=  Btb[a1] or Btb[b1] or Btb[c1] or Btb[a2] or Btb[c2] or Btb[a3] or Btb[b3] or Btb[c3];
    Roi_Btb[c2] :=  Btb[b1] or Btb[c1] or Btb[d1] or Btb[b2] or Btb[d2] or Btb[b3] or Btb[c3] or Btb[d3];
    Roi_Btb[d2] :=  Btb[c1] or Btb[d1] or Btb[e1] or Btb[c2] or Btb[e2] or Btb[c3] or Btb[d3] or Btb[e3];
    Roi_Btb[e2] :=  Btb[d1] or Btb[e1] or Btb[f1] or Btb[d2] or Btb[f2] or Btb[d3] or Btb[e3] or Btb[f3];
    Roi_Btb[f2] :=  Btb[e1] or Btb[f1] or Btb[g1] or Btb[e2] or Btb[g2] or Btb[e3] or Btb[f3] or Btb[g3];
    Roi_Btb[g2] :=  Btb[f1] or Btb[g1] or Btb[h1] or Btb[f2] or Btb[h2] or Btb[f3] or Btb[g3] or Btb[h3];
    Roi_Btb[h2] :=  Btb[g1] or Btb[h1] or Btb[g2] or Btb[g3] or Btb[h3];

    Roi_Btb[a3] := Btb[b2] or Btb[a2] or Btb[b3] or Btb[a4] or Btb[b4];
    Roi_Btb[b3] := Btb[a2] or Btb[b2] or Btb[c2] or Btb[a3] or Btb[c3] or Btb[a4] or Btb[b4] or Btb[c4];
    Roi_Btb[c3] := Btb[b2] or Btb[c2] or Btb[d2] or Btb[b3] or Btb[d3] or Btb[b4] or Btb[c4] or Btb[d4];
    Roi_Btb[d3] := Btb[c2] or Btb[d2] or Btb[e2] or Btb[c3] or Btb[e3] or Btb[c4] or Btb[d4] or Btb[e4];
    Roi_Btb[e3] := Btb[d2] or Btb[e2] or Btb[f2] or Btb[d3] or Btb[f3] or Btb[d4] or Btb[e4] or Btb[f4];
    Roi_Btb[f3] := Btb[e2] or Btb[f2] or Btb[g2] or Btb[e3] or Btb[g3] or Btb[e4] or Btb[f4] or Btb[g4];
    Roi_Btb[g3] := Btb[f2] or Btb[g2] or Btb[h2] or Btb[f3] or Btb[h3] or Btb[f4] or Btb[g4] or Btb[h4];
    Roi_Btb[h3] := Btb[g2] or Btb[h2] or Btb[g3] or Btb[g4] or Btb[h4];

    Roi_Btb[a4] := Btb[a3] or Btb[b3] or Btb[b4] or Btb[a5] or Btb[b5];
    Roi_Btb[b4] := Btb[a3] or Btb[b3] or Btb[c3] or Btb[a4] or Btb[c4] or Btb[a5] or Btb[b5] or Btb[c5];
    Roi_Btb[c4] := Btb[b3] or Btb[c3] or Btb[d3] or Btb[b4] or Btb[d4] or Btb[b5] or Btb[c5] or Btb[d5];
    Roi_Btb[d4] := Btb[c3] or Btb[d3] or Btb[e3] or Btb[c4] or Btb[e4] or Btb[c5] or Btb[d5] or Btb[e5];
    Roi_Btb[e4] := Btb[d3] or Btb[e3] or Btb[f3] or Btb[d4] or Btb[f4] or Btb[d5] or Btb[e5] or Btb[f5];
    Roi_Btb[f4] := Btb[e3] or Btb[f3] or Btb[g3] or Btb[e4] or Btb[g4] or Btb[e5] or Btb[f5] or Btb[g5];
    Roi_Btb[g4] := Btb[f3] or Btb[g3] or Btb[h3] or Btb[f4] or Btb[h4] or Btb[f5] or Btb[g5] or Btb[h5];
    Roi_Btb[h4] := Btb[g3] or Btb[h3] or Btb[g4] or Btb[g5] or Btb[h5];

    Roi_Btb[a5] := Btb[a4] or Btb[b4] or Btb[b5] or Btb[b6] or Btb[a6];
    Roi_Btb[b5] := Btb[a4] or Btb[b4] or Btb[c4] or Btb[a5] or Btb[c5] or Btb[a6] or Btb[b6] or Btb[c6];
    Roi_Btb[c5] := Btb[b4] or Btb[c4] or Btb[d4] or Btb[b5] or Btb[d5] or Btb[b6] or Btb[c6] or Btb[d6];
    Roi_Btb[d5] := Btb[c4] or Btb[d4] or Btb[e4] or Btb[c5] or Btb[e5] or Btb[c6] or Btb[d6] or Btb[e6];
    Roi_Btb[e5] := Btb[d4] or Btb[e4] or Btb[f4] or Btb[d5] or Btb[f5] or Btb[d6] or Btb[e6] or Btb[f6];
    Roi_Btb[f5] := Btb[e4] or Btb[f4] or Btb[g4] or Btb[e5] or Btb[g5] or Btb[e6] or Btb[f6] or Btb[g6];
    Roi_Btb[g5] := Btb[f4] or Btb[g4] or Btb[h4] or Btb[f5] or Btb[h5] or Btb[f6] or Btb[g6] or Btb[h6];
    Roi_Btb[h5] := Btb[g4] or Btb[h4] or Btb[g5] or Btb[g6] or Btb[h6];

    Roi_Btb[a6] := Btb[a5] or Btb[b5] or Btb[b6] or Btb[a7] or Btb[b7];
    Roi_Btb[b6] := Btb[a5] or Btb[b5] or Btb[c5] or Btb[a6] or Btb[c6] or Btb[a7] or Btb[b7] or Btb[c7];
    Roi_Btb[c6] := Btb[b5] or Btb[c5] or Btb[d5] or Btb[b6] or Btb[d6] or Btb[b7] or Btb[c7] or Btb[d7];
    Roi_Btb[d6] := Btb[c5] or Btb[d5] or Btb[e5] or Btb[c6] or Btb[e6] or Btb[c7] or Btb[d7] or Btb[e7];
    Roi_Btb[e6] := Btb[d5] or Btb[e5] or Btb[f5] or Btb[d6] or Btb[f6] or Btb[d7] or Btb[e7] or Btb[f7];
    Roi_Btb[f6] := Btb[e5] or Btb[f5] or Btb[g5] or Btb[e6] or Btb[g6] or Btb[e7] or Btb[f7] or Btb[g7];
    Roi_Btb[g6] := Btb[f5] or Btb[g5] or Btb[h5] or Btb[f6] or Btb[h6] or Btb[f7] or Btb[g7] or Btb[h7];
    Roi_Btb[h6] := Btb[g5] or Btb[h5] or Btb[g6] or Btb[g7] or Btb[h7];

    Roi_Btb[a7] := Btb[a6] or Btb[b6] or Btb[b7] or Btb[a8] or Btb[b8];
    Roi_Btb[b7] := Btb[a6] or Btb[b6] or Btb[c6] or Btb[a7] or Btb[c7] or Btb[a8] or Btb[b8] or Btb[c8];
    Roi_Btb[c7] := Btb[b6] or Btb[c6] or Btb[d6] or Btb[b7] or Btb[d7] or Btb[b8] or Btb[c8] or Btb[d8];
    Roi_Btb[d7] := Btb[c6] or Btb[d6] or Btb[e6] or Btb[c7] or Btb[e7] or Btb[c8] or Btb[d8] or Btb[e8];
    Roi_Btb[e7] := Btb[d6] or Btb[e6] or Btb[f6] or Btb[d7] or Btb[f7] or Btb[d8] or Btb[e8] or Btb[f8];
    Roi_Btb[f7] := Btb[e6] or Btb[f6] or Btb[g6] or Btb[e7] or Btb[g7] or Btb[e8] or Btb[f8] or Btb[g8];
    Roi_Btb[g7] := Btb[f6] or Btb[g6] or Btb[h6] or Btb[f7] or Btb[h7] or Btb[f8] or Btb[g8] or Btb[h8];
    Roi_Btb[h7] := Btb[g6] or Btb[h6] or Btb[g7] or Btb[g8] or Btb[h8];

    Roi_Btb[a8] := Btb[a7] or Btb[b7] or Btb[b8];
    Roi_Btb[b8] := Btb[a7] or Btb[b7] or Btb[c7] or Btb[a8] or Btb[c8];
    Roi_Btb[c8] := Btb[b7] or Btb[c7] or Btb[d7] or Btb[b8] or Btb[d8];
    Roi_Btb[d8] := Btb[c7] or Btb[d7] or Btb[e7] or Btb[c8] or Btb[e8];
    Roi_Btb[e8] := Btb[d7] or Btb[e7] or Btb[f7] or Btb[d8] or Btb[f8];
    Roi_Btb[f8] := Btb[e7] or Btb[f7] or Btb[g7] or Btb[e8] or Btb[g8];
    Roi_Btb[g8] := Btb[f7] or Btb[g7] or Btb[h7] or Btb[f8] or Btb[h8];
    Roi_Btb[h8] := Btb[g7] or Btb[h7] or Btb[g8];

//______________________________________________________________________
// on crèe les 64 Bitboards représentant les mouvements du cavalier
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

   Cavalier_Btb[a1]  := Btb[c2] or Btb[b3];
   Cavalier_Btb[b1] :=  Btb[a3] or Btb[c3] or Btb[d2];
   Cavalier_Btb[c1] :=  Btb[a2] or Btb[e2] or Btb[b3] or Btb[d3];
   Cavalier_Btb[d1] :=  Btb[b2] or Btb[f2] or Btb[c3] or Btb[e3];
   Cavalier_Btb[e1] :=  Btb[c2] or Btb[g2] or Btb[f3] or Btb[d3];
   Cavalier_Btb[f1] :=  Btb[d2] or Btb[h2] or Btb[g3] or Btb[e3];
   Cavalier_Btb[g1] :=  Btb[e2] or Btb[f3] or Btb[h3];
   Cavalier_Btb[h1] :=  Btb[f2] or Btb[g3];

   Cavalier_Btb[a2] :=  Btb[c1] or Btb[c3] or Btb[b4];
   Cavalier_Btb[b2] :=  Btb[d1] or Btb[d3] or Btb[a4] or Btb[c4];
   Cavalier_Btb[c2] :=  Btb[a1] or Btb[e1] or Btb[e3] or Btb[d4] or Btb[b4] or Btb[a3];
   Cavalier_Btb[d2] :=  Btb[b1] or Btb[f1] or Btb[f3] or Btb[e4] or Btb[c4] or Btb[b3];
   Cavalier_Btb[e2] :=  Btb[c1] or Btb[g1] or Btb[g3] or Btb[f4] or Btb[d4] or Btb[c3];
   Cavalier_Btb[f2] :=  Btb[d1] or Btb[h1] or Btb[h3] or Btb[g4] or Btb[e4] or Btb[d3];
   Cavalier_Btb[g2] :=  Btb[h4] or Btb[f4] or Btb[e3] or Btb[e1];
   Cavalier_Btb[h2] :=  Btb[f1] or Btb[f3] or Btb[g4];

   Cavalier_Btb[a3] :=  Btb[b1] or Btb[c2] or Btb[c4] or Btb[b5];
   Cavalier_Btb[b3] :=  Btb[a1] or Btb[c1] or Btb[d2] or Btb[d4] or Btb[c5] or Btb[a5];
   Cavalier_Btb[c3] :=  Btb[b1] or Btb[d1] or Btb[e2] or Btb[e4] or Btb[d5] or Btb[b5] or Btb[a4] or Btb[a2];
   Cavalier_Btb[d3] :=  Btb[c1] or Btb[e1] or Btb[f2] or Btb[f4] or Btb[e5] or Btb[c5] or Btb[b4] or Btb[b2];
   Cavalier_Btb[e3] :=  Btb[d1] or Btb[f1] or Btb[g2] or Btb[g4] or Btb[f5] or Btb[d5] or Btb[c4] or Btb[c2];
   Cavalier_Btb[f3] :=  Btb[e1] or Btb[g1] or Btb[h2] or Btb[h4] or Btb[g5] or Btb[e5] or Btb[d4] or Btb[d2];
   Cavalier_Btb[g3] :=  Btb[f1] or Btb[h1] or Btb[h5] or Btb[f5] or Btb[e4] or Btb[e2];
   Cavalier_Btb[h3] :=  Btb[g1] or Btb[g5] or Btb[f4] or Btb[f2];

   Cavalier_Btb[a4] :=  Btb[b2] or Btb[c3] or Btb[c5] or Btb[b6];
   Cavalier_Btb[b4] :=  Btb[a2] or Btb[c2] or Btb[d3] or Btb[d5] or Btb[c6] or Btb[a6];
   Cavalier_Btb[c4] :=  Btb[b2] or Btb[d2] or Btb[e3] or Btb[e5] or Btb[d6] or Btb[b6] or Btb[a5] or Btb[a3];
   Cavalier_Btb[d4] :=  Btb[c2] or Btb[e2] or Btb[f3] or Btb[f5] or Btb[e6] or Btb[c6] or Btb[b5] or Btb[b3];
   Cavalier_Btb[e4] :=  Btb[d2] or Btb[f2] or Btb[g3] or Btb[g5] or Btb[f6] or Btb[d6] or Btb[c5] or Btb[c3];
   Cavalier_Btb[f4] :=  Btb[e2] or Btb[g2] or Btb[h3] or Btb[h5] or Btb[g6] or Btb[e6] or Btb[d5] or Btb[d3];
   Cavalier_Btb[g4] :=  Btb[f2] or Btb[h2] or Btb[h6] or Btb[f6] or Btb[e5] or Btb[e3];
   Cavalier_Btb[h4] :=  Btb[g2] or Btb[g6] or Btb[f5] or Btb[f3];

   Cavalier_Btb[a5] :=  Btb[b3] or Btb[c4] or Btb[c6] or Btb[b7];
   Cavalier_Btb[b5] :=  Btb[a3] or Btb[c3] or Btb[d4] or Btb[d6] or Btb[c7] or Btb[a7];
   Cavalier_Btb[c5] :=  Btb[b3] or Btb[d3] or Btb[e4] or Btb[e6] or Btb[d7] or Btb[b7] or Btb[a6] or Btb[a4];
   Cavalier_Btb[d5] :=  Btb[c3] or Btb[e3] or Btb[f4] or Btb[f6] or Btb[e7] or Btb[c7] or Btb[b6] or Btb[b4];
   Cavalier_Btb[e5] :=  Btb[d3] or Btb[f3] or Btb[g4] or Btb[g6] or Btb[f7] or Btb[d7] or Btb[c6] or Btb[c4];
   Cavalier_Btb[f5] :=  Btb[e3] or Btb[g3] or Btb[h4] or Btb[h6] or Btb[g7] or Btb[e7] or Btb[d6] or Btb[d4];
   Cavalier_Btb[g5] :=  Btb[f3] or Btb[h3] or Btb[h7] or Btb[f7] or Btb[e6] or Btb[e4];
   Cavalier_Btb[h5] :=  Btb[g3] or Btb[g7] or Btb[f6] or Btb[f4];

   Cavalier_Btb[a6] :=  Btb[b4] or Btb[c5] or Btb[c7] or Btb[b8];
   Cavalier_Btb[b6] :=  Btb[c4] or Btb[a4] or Btb[d5] or Btb[d7] or Btb[c8] or Btb[a8];
   Cavalier_Btb[c6] :=  Btb[b4] or Btb[d4] or Btb[e5] or Btb[e7] or Btb[d8] or Btb[b8] or Btb[a7] or Btb[a5];
   Cavalier_Btb[d6] :=  Btb[c4] or Btb[e4] or Btb[f5] or Btb[f7] or Btb[e8] or Btb[c8] or Btb[b7] or Btb[b5];
   Cavalier_Btb[e6] :=  Btb[d4] or Btb[f4] or Btb[g5] or Btb[g7] or Btb[f8] or Btb[d8] or Btb[c7] or Btb[c5];
   Cavalier_Btb[f6] :=  Btb[e4] or Btb[g4] or Btb[h5] or Btb[h7] or Btb[g8] or Btb[e8] or Btb[d7] or Btb[d5];
   Cavalier_Btb[g6] :=  Btb[f4] or Btb[h4] or Btb[h8] or Btb[f8] or Btb[e7] or Btb[e5];
   Cavalier_Btb[h6] :=  Btb[g4] or Btb[g8] or Btb[f7] or Btb[f5];

   Cavalier_Btb[a7] :=  Btb[b5] or Btb[c6] or Btb[c8];
   Cavalier_Btb[b7] :=  Btb[a5] or Btb[c5] or Btb[d6] or Btb[d8];
   Cavalier_Btb[c7] :=  Btb[a6] or Btb[b5] or Btb[d5] or Btb[e6] or Btb[e8] or Btb[a8];
   Cavalier_Btb[d7] :=  Btb[b6] or Btb[c5] or Btb[e5] or Btb[f6] or Btb[f8] or Btb[b8];
   Cavalier_Btb[e7] :=  Btb[c6] or Btb[d5] or Btb[f5] or Btb[g6] or Btb[g8] or Btb[c8];
   Cavalier_Btb[f7] :=  Btb[d6] or Btb[e5] or Btb[g5] or Btb[h6] or Btb[h8] or Btb[d8];
   Cavalier_Btb[g7] :=  Btb[h5] or Btb[e8] or Btb[e6] or Btb[f5];
   Cavalier_Btb[h7] :=  Btb[g5] or Btb[f6] or Btb[f8];

   Cavalier_Btb[a8] :=  Btb[b6] or Btb[c7];
   Cavalier_Btb[b8] :=  Btb[a6] or Btb[c6] or Btb[d7];
   Cavalier_Btb[c8] :=  Btb[a7] or Btb[b6] or Btb[d6] or Btb[e7];
   Cavalier_Btb[d8] :=  Btb[b7] or Btb[c6] or Btb[e6] or Btb[f7];
   Cavalier_Btb[e8] :=  Btb[c7] or Btb[d6] or Btb[f6] or Btb[g7];
   Cavalier_Btb[f8] :=  Btb[d7] or Btb[e6] or Btb[g6] or Btb[h7];
   Cavalier_Btb[g8] :=  Btb[e7] or Btb[f6] or Btb[h6];
   Cavalier_Btb[h8] :=  Btb[f7] or Btb[g6];


//_________________________________________________________________________
//
//      les Pièces glissantes :           Tour/ Dame  &  Fou/Dame
//
//_________________________________________________________________________

//_________________________________________________________________________
//
//                               320   Bitboards :
//     tables des déplacements de Tour en:={ ouest ,  Nord, Est, sud, }
//_________________________________________________________________________
//
//______________________________________________________________________
// on crèe les 64 Bitboards représentant les mouvements Ouest des Tours
// on crèe les 64 Bitboards représentant les mouvements est des Tours
// on crèe les 64 Bitboards représentant les mouvements Sud des Tours
// on crèe les 64 Bitboards représentant les mouvements Nord des Tours
// on crèe les 64 Bitboards représentant les mouvements complets des Tours
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

    Tour_Mvmt_Ouest[a1] := 0;
    Tour_Mvmt_Est[a1] := Btb[b1] or  Btb[c1] or Btb[d1] or Btb[e1] or Btb[f1] or Btb[g1] or Btb[h1];
    Tour_Mvmt_Sud[a1] := 0;
    Tour_Mvmt_Nord[a1] := Btb[a2] or Btb[a3] or Btb[a4] or Btb[a5] or Btb[a6] or Btb[a7] or Btb[a8];

    Tour_Mvmt_Ouest[b1] := Btb[a1] ;
    Tour_Mvmt_Est[b1] := Btb[c1] or Btb[d1] or Btb[e1] or Btb [f1] or Btb[g1] or Btb [h1];
    Tour_Mvmt_Sud[b1] := 0;
    Tour_Mvmt_Nord[b1] := Btb[b2] or Btb[b3] or Btb[b4] or Btb[b5] or Btb[b6] or Btb[b7] or Btb[b8];

    Tour_Mvmt_Ouest[c1] := Btb[b1] or Btb[a1];
    Tour_Mvmt_Est[c1] := Btb[d1] or Btb [e1] or Btb[f1] or Btb[g1] or Btb[h1];
    Tour_Mvmt_Sud[c1] := 0;
    Tour_Mvmt_Nord[c1] := Btb[c2] or Btb[c3] or Btb[c4] or Btb[c5] or Btb[c6] or Btb[c7] or Btb[c8];

    Tour_Mvmt_Ouest[d1] := Btb[c1] or Btb[b1] or Btb[a1];
    Tour_Mvmt_Est[d1] := Btb[e1] or Btb[f1] or Btb[g1] or Btb [h1];
    Tour_Mvmt_Sud[d1] := 0;
    Tour_Mvmt_Nord[d1] := Btb[d2] or Btb[d3] or Btb[d4] or Btb[d5] or Btb[d6] or Btb[d7] or Btb[d8];

    Tour_Mvmt_Ouest[e1] := Btb[d1] or Btb[c1] or Btb[b1] or Btb[a1];
    Tour_Mvmt_Est [e1] := Btb [f1] or Btb[g1] or Btb[h1];
    Tour_Mvmt_Sud[e1] := 0;
    Tour_Mvmt_Nord[e1] := Btb[e2] or Btb[e3] or Btb[e4] or Btb[e5] or Btb[e6] or Btb[e7] or Btb[e8];

    Tour_Mvmt_Ouest[f1] :=   Btb[e1] or Btb[d1] or Btb[c1] or Btb[b1] or Btb[a1];
    Tour_Mvmt_Est[f1] :=   Btb[g1] or Btb[h1];
    Tour_Mvmt_Sud[f1] := 0;
    Tour_Mvmt_Nord[f1] := Btb[f2] or Btb[f3] or Btb[f4] or Btb[f5] or Btb[f6] or Btb[f7] or Btb[f8];

    Tour_Mvmt_Ouest [g1] :=  Btb[f1] or Btb[e1] or Btb[d1] or Btb[c1] or Btb[b1] or Btb[a1];
    Tour_Mvmt_Est[g1] :=  Btb[h1];
    Tour_Mvmt_Sud[g1] := 0;
    Tour_Mvmt_Nord[g1] := Btb[g2] or Btb[g3] or Btb[g4] or Btb[g5] or Btb[g6] or Btb[g7] or Btb[g8];

    Tour_Mvmt_Ouest[h1] :=  Btb[g1] or Btb[f1] or Btb[e1] or Btb[d1] or Btb[c1] or Btb[b1] or Btb[a1];
    Tour_Mvmt_Est[h1] := 0;
    Tour_Mvmt_Sud[h1] := 0;
    Tour_Mvmt_Nord[h1] := Btb[h2] or Btb[h3] or Btb[h4] or Btb[h5] or Btb[h6] or Btb[h7] or Btb[h8];

    Tour_Mvmt_Est[a2] :=  Btb [b2] or Btb[c2] or Btb[d2] or Btb[e2] or Btb[f2] or Btb[g2] or Btb[h2];
    Tour_Mvmt_Sud[a2] :=  Btb[a1];
    Tour_Mvmt_Ouest[a2] := 0;
    Tour_Mvmt_Nord[a2] := Btb[a3] or Btb[a4] or Btb[a5] or Btb[a6] or Btb[a7] or Btb[a8];

    Tour_Mvmt_Ouest[b2] :=  Btb[a2];
    Tour_Mvmt_Est[b2] :=  Btb[c2] or Btb[d2] or Btb[e2] or Btb[f2] or Btb[g2] or Btb[h2];
    Tour_Mvmt_Sud[b2] :=  Btb[b1];
    Tour_Mvmt_Nord[b2] :=  Btb[b3] or Btb[b4] or Btb[b5] or Btb[b6] or Btb[b7] or Btb[b8];

    Tour_Mvmt_Ouest[c2] :=  Btb[b2] or Btb[a2];
    Tour_Mvmt_Est[c2] :=  Btb[d2] or Btb[e2] or Btb[f2] or Btb[g2] or Btb[h2];
    Tour_Mvmt_Sud[c2] :=  Btb[c1];
    Tour_Mvmt_Nord[c2] :=  Btb[c3] or Btb[c4] or Btb[c5] or Btb[c6] or Btb[c7] or Btb[c8];

    Tour_Mvmt_Ouest[d2] :=  Btb[c2] or Btb[b2] or Btb[a2];
    Tour_Mvmt_Est[d2] :=  Btb[e2] or Btb[f2] or Btb[g2] or Btb[h2];
    Tour_Mvmt_Sud[d2] := Btb[d1];
    Tour_Mvmt_Nord[d2] :=  Btb[d3] or Btb[d4] or Btb[d5] or Btb[d6] or Btb[d7] or Btb[d8];

    Tour_Mvmt_Ouest[e2] :=  Btb[d2] or Btb[c2] or Btb[b2] or Btb[a2];
    Tour_Mvmt_Est[e2] :=  Btb[f2] or Btb[g2] or Btb[h2];
    Tour_Mvmt_Sud[e2] :=  Btb[e1];
    Tour_Mvmt_Nord[e2] :=  Btb[e3] or Btb[e4] or Btb[e5] or Btb[e6] or Btb[e7] or Btb[e8];

    Tour_Mvmt_Ouest[f2] :=  Btb[e2] or Btb[d2] or Btb[c2] or Btb [b2] or Btb[a2];
    Tour_Mvmt_Est[f2] :=  Btb[g2] or Btb[h2];
    Tour_Mvmt_Sud[f2] :=  Btb[f1];
    Tour_Mvmt_Nord[f2] :=  Btb[f3] or Btb[f4] or Btb[f5] or Btb[f6] or Btb[f7] or Btb[f8];

    Tour_Mvmt_Ouest[g2] :=  Btb[f2] or Btb[e2] or Btb[d2] or Btb[c2] or Btb[b2] or Btb[a2];
    Tour_Mvmt_Est[g2] :=  Btb[h2];
    Tour_Mvmt_Sud[g2] :=  Btb[g1];
    Tour_Mvmt_Nord[g2] :=  Btb[g3] or Btb[g4] or Btb[g5] or Btb[g6] or Btb [g7] or Btb[g8];

    Tour_Mvmt_Ouest[h2] :=  Btb[g2] or Btb[f2] or Btb [e2] or Btb[d2] or Btb[c2] or Btb[b2] or Btb[a2];
    Tour_Mvmt_Est[h2] :=  0;
    Tour_Mvmt_Sud[h2] := Btb[h1];
    Tour_Mvmt_Nord[h2] := Btb[h3] or Btb[h4] or Btb [h5] or Btb[h6] or Btb[h7] or Btb[h8];

    Tour_Mvmt_Ouest[a3] := 0;
    Tour_Mvmt_Est[a3] :=  Btb[b3] or Btb[c3] or Btb[d3] or Btb[e3] or Btb[f3] or Btb[g3] or Btb[h3];
    Tour_Mvmt_Sud[a3] :=  Btb[a2] or Btb[a1];
    Tour_Mvmt_Nord[a3] := Btb[a4] or Btb[a5] or Btb[a6] or Btb[a7] or Btb[a8];

    Tour_Mvmt_Ouest[b3] := Btb[a3];
    Tour_Mvmt_Est[b3] := Btb[c3] or Btb[d3] or Btb[e3] or Btb[f3] or Btb[g3] or Btb[h3];
    Tour_Mvmt_Sud[b3] := Btb[b2] or Btb[b1];
    Tour_Mvmt_Nord[b3] := Btb[b4] or Btb[b5] or Btb[b6] or Btb[b7] or Btb[b8];

    Tour_Mvmt_Ouest[c3] :=  Btb[b3] or Btb[a3];
    Tour_Mvmt_Est[c3] :=  Btb[d3] or Btb[e3] or Btb[f3] or Btb[g3] or Btb[h3];
    Tour_Mvmt_Sud[c3] :=  Btb[c2] or Btb[c1];
    Tour_Mvmt_Nord[c3] :=  Btb[c4] or Btb[c5] or Btb[c6] or Btb[c7] or Btb[c8];

    Tour_Mvmt_Ouest[d3] :=  Btb [c3] or Btb[b3] or Btb[a3];
    Tour_Mvmt_Est[d3] := Btb[e3] or Btb[f3] or Btb[g3] or Btb[h3];
    Tour_Mvmt_Sud[d3] :=  Btb[d2] or Btb[d1];
    Tour_Mvmt_Nord[d3] := Btb[d4] or Btb[d5] or Btb[d6] or Btb[d7] or Btb[d8];

    Tour_Mvmt_Ouest[e3] :=  Btb[d3] or Btb[c3] or Btb[b3] or Btb[a3];
    Tour_Mvmt_Est[e3] :=  Btb[f3] or Btb[g3] or Btb[h3];
    Tour_Mvmt_Sud[e3] :=  Btb[e2] or Btb[e1];
    Tour_Mvmt_Nord[e3] := Btb[e4] or Btb[e5] or Btb[e6] or Btb[e7] or Btb[e8];

    Tour_Mvmt_Ouest[f3] :=  Btb[e3] or Btb[d3] or Btb[c3] or Btb[b3] or Btb[a3];
    Tour_Mvmt_Est[f3] :=  Btb[g3] or Btb[h3];
    Tour_Mvmt_Sud[f3] :=  Btb[f2] or Btb[f1];
    Tour_Mvmt_Nord[f3] :=  Btb[f4] or Btb[f5] or Btb[f6] or Btb[f7] or Btb[f8];

    Tour_Mvmt_Ouest[g3] :=  Btb[f3] or Btb[e3] or Btb[d3] or Btb[c3] or Btb[b3] or Btb[a3];
    Tour_Mvmt_Est[g3] :=  Btb[h3];
    Tour_Mvmt_Sud[g3] :=  Btb[g2] or Btb[g1];
    Tour_Mvmt_Nord[g3] :=  Btb[g4] or Btb[g5] or Btb[g6] or Btb[g7] or Btb[g8];

    Tour_Mvmt_Ouest[h3] :=  Btb[g3] or Btb[f3] or Btb[e3] or Btb[d3] or Btb[c3] or Btb[b3] or Btb[a3];
    Tour_Mvmt_Sud[h3] :=  Btb[h2] or Btb[h1];
    Tour_Mvmt_Nord[h3] :=  Btb[h4] or Btb[h5] or Btb[h6] or Btb[h7] or Btb[h8];
    Tour_Mvmt_Est[h3] :=  0;

    Tour_Mvmt_Sud[a4] :=  Btb[a3] or Btb[a2] or Btb[a1];
    Tour_Mvmt_Nord[a4] :=  Btb[a5] or Btb[a6] or Btb[a7] or Btb[a8];
    Tour_Mvmt_Est[a4] :=  Btb[b4] or Btb[c4] or Btb[d4] or Btb[e4] or Btb[f4] or Btb[g4] or Btb[h4];
    Tour_Mvmt_Ouest[a4] := 0;

    Tour_Mvmt_Ouest[b4] :=  Btb[a4];
    Tour_Mvmt_Est[b4] :=  Btb[c4] or Btb[d4] or Btb[e4] or Btb[f4] or Btb[g4] or Btb[h4];
    Tour_Mvmt_Sud[b4] :=  Btb[b3] or Btb [b2] or Btb[b1];
    Tour_Mvmt_Nord[b4] :=  Btb[b5] or Btb[b6] or Btb[b7] or Btb[b8];

    Tour_Mvmt_Ouest[c4] :=  Btb[b4] or Btb[a4];
    Tour_Mvmt_Est[c4] :=  Btb[d4] or Btb[e4] or Btb[f4] or Btb[g4] or Btb[h4];
    Tour_Mvmt_Sud[c4] :=  Btb[c3] or Btb[c2] or Btb[c1];
    Tour_Mvmt_Nord[c4] :=  Btb[c5] or Btb[c6] or Btb[c7] or Btb[c8];

    Tour_Mvmt_Ouest[d4] :=  Btb[c4] or Btb[b4] or Btb[a4];
    Tour_Mvmt_Est[d4] :=  Btb[e4] or Btb[f4] or Btb[g4] or Btb[h4];
    Tour_Mvmt_Sud[d4] :=  Btb[d3] or Btb[d2] or Btb[d1];
    Tour_Mvmt_Nord[d4] :=  Btb[d5] or Btb[d6] or Btb[d7] or Btb[d8];

    Tour_Mvmt_Ouest[e4] :=  Btb[d4] or Btb[c4] or Btb[b4] or Btb[a4];
    Tour_Mvmt_Est[e4] :=  Btb[f4] or Btb[g4] or Btb[h4];
    Tour_Mvmt_Sud[e4] :=  Btb[e3] or Btb[e2] or Btb[e1];
    Tour_Mvmt_Nord[e4] :=  Btb[e5] or Btb[e6] or Btb[e7] or Btb[e8];

    Tour_Mvmt_Ouest[f4] :=  Btb[e4] or Btb[d4] or Btb [c4] or Btb[b4] or Btb[a4];
    Tour_Mvmt_Est[f4] :=  Btb[g4] or Btb[h4];
    Tour_Mvmt_Sud[f4] :=  Btb[f3] or Btb[f2] or Btb[f1];
    Tour_Mvmt_Nord[f4] :=  Btb[f5] or Btb[f6] or Btb[f7] or Btb[f8];

    Tour_Mvmt_Ouest[g4] :=  Btb[f4] or Btb[e4] or Btb[d4] or Btb[c4] or Btb[b4] or Btb[a4];
    Tour_Mvmt_Est[g4] :=  Btb[h4];
    Tour_Mvmt_Sud[g4] :=  Btb[g3] or Btb[g2] or Btb[g1];
    Tour_Mvmt_Nord[g4] :=  Btb [g5] or Btb[g6] or Btb[g7] or Btb[g8];

    Tour_Mvmt_Ouest[h4] :=  Btb[g4] or Btb[f4] or Btb[e4] or Btb[d4] or Btb[c4] or Btb[b4] or Btb[a4];
    Tour_Mvmt_Sud[h4] :=  Btb[h3] or Btb[h2] or Btb[h1];
    Tour_Mvmt_Nord[h4] :=  Btb[h5] or Btb[h6] or Btb[h7] or Btb[h8];
    Tour_Mvmt_Est[h4] :=  0;

    Tour_Mvmt_Est[a5] :=  Btb[b5] or Btb[c5] or Btb[d5] or Btb[e5] or Btb[f5] or Btb[g5] or Btb[h5];
    Tour_Mvmt_Nord[a5] :=  Btb[a6] or Btb[a7] or Btb[a8];
    Tour_Mvmt_Sud[a5] :=  Btb[a4] or Btb[a3] or Btb[a2] or Btb[a1];
    Tour_Mvmt_Ouest[a5] := 0;

    Tour_Mvmt_Ouest[b5] :=  Btb[a5];
    Tour_Mvmt_Est[b5] :=  Btb[c5] or Btb[d5] or Btb[e5] or Btb[f5] or Btb [g5] or Btb[h5];
    Tour_Mvmt_Sud[b5] :=  Btb[b4] or Btb[b3] or Btb[b2] or Btb[b1];
    Tour_Mvmt_Nord[b5] :=  Btb[b6] or Btb[b7] or Btb[b8];

    Tour_Mvmt_Ouest[c5] :=  Btb[b5] or Btb[a5];
    Tour_Mvmt_Est[c5] :=  Btb[d5] or Btb[e5] or Btb[f5] or Btb[g5] or Btb[h5];
    Tour_Mvmt_Sud[c5] :=  Btb[c4] or Btb[c3] or Btb[c2] or Btb[c1];
    Tour_Mvmt_Nord[c5] :=  Btb[c6] or Btb[c7] or Btb[c8];

    Tour_Mvmt_Ouest[d5] :=  Btb[c5] or Btb[b5] or Btb[a5];
    Tour_Mvmt_Est[d5] :=  Btb[e5] or Btb[f5] or Btb[g5] or Btb[h5];
    Tour_Mvmt_Sud[d5] :=  Btb[d4] or Btb [d3] or Btb[d2] or Btb[d1];
    Tour_Mvmt_Nord[d5] :=  Btb[d6] or Btb[d7] or Btb[d8];

    Tour_Mvmt_Ouest[e5] :=  Btb[d5] or Btb [c5] or Btb[b5] or Btb[a5];
    Tour_Mvmt_Est[e5] :=  Btb[f5] or Btb[g5] or Btb[h5];
    Tour_Mvmt_Sud[e5] :=  Btb[e4] or Btb[e3] or Btb[e2] or Btb[e1];
    Tour_Mvmt_Nord[e5] :=  Btb[e6] or Btb[e7] or Btb[e8];

    Tour_Mvmt_Ouest[f5] :=  Btb[e5] or Btb[d5] or Btb[c5] or Btb[b5] or Btb[a5];
    Tour_Mvmt_Est[f5] :=  Btb[g5] or Btb[h5];
    Tour_Mvmt_Sud[f5] :=  Btb[f4] or Btb[f3] or Btb[f2] or Btb[f1];
    Tour_Mvmt_Nord[f5] :=  Btb[f6] or Btb[f7] or Btb[f8];

    Tour_Mvmt_Ouest[g5] :=  Btb[f5] or Btb[e5] or Btb[d5] or Btb[c5] or Btb[b5] or Btb[a5];
    Tour_Mvmt_Est[g5] :=  Btb[h5];
    Tour_Mvmt_Sud[g5] :=  Btb[g4] or Btb[g3] or Btb[g2] or Btb[g1];
    Tour_Mvmt_Nord[g5] :=  Btb[g6] or Btb[g7] or Btb[g8];

    Tour_Mvmt_Ouest[h5] :=  Btb[g5] or Btb[f5] or Btb[e5] or Btb[d5] or Btb[c5] or Btb[b5] or Btb[a5];
    Tour_Mvmt_Sud[h5] :=  Btb[h4] or Btb[h3] or Btb[h2] or Btb[h1];
    Tour_Mvmt_Nord[h5] :=  Btb[h6] or Btb[h7] or Btb[h8];
    Tour_Mvmt_Est[h5] := 0;

    Tour_Mvmt_Est[a6] :=  Btb[b6] or Btb[c6] or Btb[d6] or Btb[e6] or Btb[f6] or Btb[g6] or Btb[h6];
    Tour_Mvmt_Sud[a6] :=  Btb[a5] or Btb[a4] or Btb[a3] or Btb[a2] or Btb[a1];
    Tour_Mvmt_Nord[a6] :=  Btb[a7] or Btb[a8];
    Tour_Mvmt_Ouest[a6] := 0;

    Tour_Mvmt_Ouest[b6] :=  Btb[a6];
    Tour_Mvmt_Est[b6] :=  Btb[c6] or Btb[d6] or Btb[e6] or Btb[f6] or Btb[g6] or Btb[h6];
    Tour_Mvmt_Sud[b6] :=  Btb[b5] or Btb[b4] or Btb[b3] or Btb[b2] or Btb[b1];
    Tour_Mvmt_Nord[b6] := Btb[b7] or Btb[b8];

    Tour_Mvmt_Ouest[c6] :=  Btb[b6] or Btb[a6];
    Tour_Mvmt_Est[c6] :=  Btb[d6] or Btb [e6] or Btb[f6] or Btb[g6] or Btb[h6];
    Tour_Mvmt_Sud[c6] :=  Btb[c5] or Btb[c4] or Btb[c3] or Btb[c2] or Btb[c1];
    Tour_Mvmt_Nord[c6] :=  Btb[c7] or Btb[c8];

    Tour_Mvmt_Ouest[d6] :=  Btb[c6] or Btb[b6] or Btb[a6];
    Tour_Mvmt_Est[d6] :=  Btb[e6] or Btb[f6] or Btb[g6] or Btb[h6];
    Tour_Mvmt_Sud[d6] :=  Btb[d5] or Btb[d4] or Btb[d3] or Btb[d2] or Btb[d1];
    Tour_Mvmt_Nord[d6] :=  Btb[d7] or Btb[d8];

    Tour_Mvmt_Ouest[e6] :=  Btb[d6] or Btb[c6] or Btb[b6] or Btb[a6];
    Tour_Mvmt_Est[e6] :=  Btb[f6] or Btb[g6] or Btb[h6];
    Tour_Mvmt_Sud[e6] :=  Btb[e5] or Btb[e4] or Btb[e3] or Btb[e2] or Btb[e1];
    Tour_Mvmt_Nord[e6] :=  Btb[e7] or Btb[e8];

    Tour_Mvmt_Ouest[f6] :=  Btb[e6] or Btb[d6] or Btb[c6] or Btb[b6] or Btb[a6];
    Tour_Mvmt_Est[f6] :=  Btb[g6] or Btb[h6];
    Tour_Mvmt_Sud[f6] :=  Btb[f5] or Btb[f4] or Btb[f3] or Btb[f2] or Btb[f1];
    Tour_Mvmt_Nord[f6] :=  Btb[f7] or Btb[f8];

    Tour_Mvmt_Ouest[g6] :=  Btb[f6] or Btb[e6] or Btb[d6] or Btb[c6] or Btb[b6] or Btb[a6];
    Tour_Mvmt_Est[g6] :=  Btb[h6];
    Tour_Mvmt_Sud[g6] :=  Btb[g5] or Btb[g4] or Btb[g3] or Btb[g2] or Btb[g1];
    Tour_Mvmt_Nord[g6] :=  Btb [g7] or Btb[g8];

    Tour_Mvmt_Ouest[h6] :=  Btb[g6] or Btb[f6] or Btb[e6] or Btb[d6] or Btb[c6] or Btb[b6] or Btb[a6];
    Tour_Mvmt_Sud[h6] :=  Btb[h5] or Btb[h4] or Btb[h3] or Btb[h2] or Btb[h1];
    Tour_Mvmt_Nord[h6] :=  Btb[h7] or Btb[h8];
    Tour_Mvmt_Est[h6] := 0;

    Tour_Mvmt_Est[a7] :=  Btb[b7] or Btb[c7] or Btb [d7] or Btb[e7] or Btb[f7] or Btb[g7] or Btb[h7];
    Tour_Mvmt_Sud[a7] :=  Btb [a6] or Btb[a5] or Btb[a4] or Btb[a3] or Btb[a2] or Btb[a1];
    Tour_Mvmt_Nord[a7] := Btb[a8];
    Tour_Mvmt_Ouest[a7] := 0;

    Tour_Mvmt_Ouest[b7] :=  Btb[a7];
    Tour_Mvmt_Est[b7] :=  Btb[c7] or Btb[d7] or Btb[e7] or Btb[f7] or Btb[g7] or Btb[h7];
    Tour_Mvmt_Sud[b7] :=  Btb[b6] or Btb[b5] or Btb[b4] or Btb [b3] or Btb[b2] or Btb[b1];
    Tour_Mvmt_Nord[b7] :=  Btb[b8];

    Tour_Mvmt_Ouest[c7] :=  Btb[b7] or Btb[a7];
    Tour_Mvmt_Est[c7] :=  Btb [d7] or Btb[e7] or Btb[f7] or Btb[g7] or Btb[h7];
    Tour_Mvmt_Sud[c7] :=  Btb [c6] or Btb[c5] or Btb[c4] or Btb[c3] or Btb[c2] or Btb[c1];
    Tour_Mvmt_Nord[c7] :=  Btb[c8];

    Tour_Mvmt_Ouest[d7] :=  Btb[c7] or Btb[b7] or Btb[a7];
    Tour_Mvmt_Est[d7] :=  Btb[e7] or Btb[f7] or Btb[g7] or Btb[h7];
    Tour_Mvmt_Sud[d7] :=  Btb[d6] or Btb[d5] or Btb[d4] or Btb[d3] or Btb[d2] or Btb[d1];
    Tour_Mvmt_Nord[d7] :=  Btb[d8];

    Tour_Mvmt_Ouest[e7] :=  Btb[d7] or Btb[c7] or Btb[b7] or Btb[a7];
    Tour_Mvmt_Est[e7] :=  Btb[f7] or Btb[g7] or Btb[h7];
    Tour_Mvmt_Sud[e7] :=  Btb[e6] or Btb[e5] or Btb[e4] or Btb[e3] or Btb[e2] or Btb[e1];
    Tour_Mvmt_Nord[e7] :=  Btb[e8];

    Tour_Mvmt_Ouest[f7] :=  Btb [e7] or Btb[d7] or Btb[c7] or Btb[b7] or Btb[a7];
    Tour_Mvmt_Est[f7] :=  Btb[g7] or Btb[h7];
    Tour_Mvmt_Sud[f7] :=  Btb[f6] or Btb[f5] or Btb[f4] or Btb[f3] or Btb[f2] or Btb[f1];
    Tour_Mvmt_Nord[f7] :=  Btb[f8];

    Tour_Mvmt_Ouest[g7] :=  Btb[f7] or Btb[e7] or Btb[d7] or Btb[c7] or Btb[b7] or Btb[a7];
    Tour_Mvmt_Est[g7] :=  Btb[h7];
    Tour_Mvmt_Sud[g7] :=  Btb[g6] or Btb[g5] or Btb[g4] or Btb[g3] or Btb[g2] or Btb[g1];
    Tour_Mvmt_Nord[g7] :=  Btb[g8];

    Tour_Mvmt_Ouest[h7] :=  Btb[g7] or Btb[f7] or Btb[e7] or Btb[d7] or Btb[c7] or Btb[b7] or Btb[a7];
    Tour_Mvmt_Sud[h7] :=  Btb[h6] or Btb[h5] or Btb[h4] or Btb[h3] or Btb[h2] or Btb[h1];
    Tour_Mvmt_Nord[h7] :=  Btb[h8];
    Tour_Mvmt_Est[h7] := 0;

    Tour_Mvmt_Est[a8] :=  Btb[b8] or Btb[c8] or Btb[d8] or Btb[e8] or Btb[f8] or Btb[g8] or Btb[h8];
    Tour_Mvmt_Sud[a8] :=  Btb[a7] or Btb[a6] or Btb[a5] or Btb[a4] or Btb[a3] or Btb[a2] or Btb[a1];
    Tour_Mvmt_Ouest[a8] := 0;
    Tour_Mvmt_Nord[a8] := 0;

    Tour_Mvmt_Ouest[b8] :=  Btb[a8];
    Tour_Mvmt_Est[b8] :=  Btb[c8] or Btb[d8] or Btb[e8] or Btb[f8] or Btb [g8] or Btb[h8];
    Tour_Mvmt_Sud[b8] :=  Btb[b7] or Btb[b6] or Btb[b5] or Btb[b4] or Btb[b3] or Btb[b2] or Btb[b1];
    Tour_Mvmt_Nord[b8] := 0;

    Tour_Mvmt_Ouest[c8] :=  Btb[b8] or Btb[a8];
    Tour_Mvmt_Est[c8] :=  Btb[d8] or Btb[e8] or Btb[f8] or Btb[g8] or Btb[h8];
    Tour_Mvmt_Sud[c8] :=  Btb[c7] or Btb[c6] or Btb[c5] or Btb[c4] or Btb[c3] or Btb[c2] or Btb[c1];
    Tour_Mvmt_Nord[c8] := 0;

    Tour_Mvmt_Ouest[d8] :=  Btb[c8] or Btb[b8] or Btb[a8];
    Tour_Mvmt_Est[d8] :=  Btb[e8] or Btb[f8] or Btb[g8] or Btb[h8];
    Tour_Mvmt_Sud[d8] :=  Btb[d7] or Btb[d6] or Btb[d5] or Btb[d4] or Btb[d3] or Btb[d2] or Btb[d1];
    Tour_Mvmt_Nord[d8] := 0;

    Tour_Mvmt_Ouest[e8] :=  Btb[d8] or Btb[c8] or Btb[b8] or Btb[a8];
    Tour_Mvmt_Est[e8] := Btb[f8] or Btb[g8] or Btb[h8];
    Tour_Mvmt_Sud[e8] :=  Btb[e7] or Btb[e6] or Btb[e5] or Btb[e4] or Btb[e3] or Btb[e2] or Btb[e1];
    Tour_Mvmt_Nord[e8] := 0;

    Tour_Mvmt_Ouest[f8] :=  Btb[e8] or Btb[d8] or Btb[c8] or Btb[b8] or Btb[a8];
    Tour_Mvmt_Est[f8] :=  Btb[g8] or Btb[h8];
    Tour_Mvmt_Sud[f8] :=  Btb [f7] or Btb[f6] or Btb[f5] or Btb[f4] or Btb[f3] or Btb[f2] or Btb[f1];
    Tour_Mvmt_Nord[g8] := 0;

    Tour_Mvmt_Ouest[g8] :=  Btb[f8] or Btb[e8] or Btb[d8] or Btb[c8] or Btb[b8] or Btb[a8];
    Tour_Mvmt_Est[g8] :=  Btb[h8];
    Tour_Mvmt_Sud[g8] :=  Btb[g7] or Btb[g6] or Btb[g5] or Btb[g4] or Btb[g3] or Btb[g2] or Btb[g1];
    Tour_Mvmt_Nord[g8] := 0;

    Tour_Mvmt_Ouest[h8] :=  Btb[g8] or Btb [f8] or Btb[e8] or Btb[d8] or Btb[c8] or Btb[b8] or Btb[a8];
    Tour_Mvmt_Est[h8] := 0;
    Tour_Mvmt_Sud[h8] := Btb[h7] or Btb[h6] or Btb[h5] or Btb[h4] or Btb[h3] or Btb[h2] or Btb[h1];
    Tour_Mvmt_Nord[h8] := 0;

//_________________________________________________________________________
//
//       tables des déplacements de Tour  proprements dits
//_________________________________________________________________________
//

For i := a1 to h8 do
    Tour_BtB[i] := Tour_Mvmt_Ouest[i] or Tour_Mvmt_Est[i]
                  or Tour_Mvmt_Sud[i] or Tour_Mvmt_Nord[i];

//_________________________________________________________________________
//
//              320 Bitboards :    tables des déplacements de Fou
//_________________________________________________________________________
//
//______________________________________________________________________
// on crèe les 64 Bitboards représentant les mouvements Ouest des Fous
// on crèe les 64 Bitboards représentant les mouvements est des Fous
// on crèe les 64 Bitboards représentant les mouvements Sud des Fous
// on crèe les 64 Bitboards représentant les mouvements Nord des Fous
// on crèe les 64 Bitboards représentant les mouvements complets des Fous
//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨


    Fou_Mvmt_NO[a1] := 0;
    Fou_Mvmt_NE[a1] := Btb[b2] or Btb[c3] or Btb[d4] or Btb[e5] or Btb[f6] or Btb[g7] or Btb[h8];
    Fou_Mvmt_SO[a1] := 0;
    Fou_Mvmt_SE[a1] := 0;

    Fou_Mvmt_NO[b1] := Btb[a2];
    Fou_Mvmt_NE[b1] := Btb[c2] or Btb[d3] or Btb[e4] or Btb[f5] or Btb[g6] or Btb[h7];
    Fou_Mvmt_SO[b1] := 0;
    Fou_Mvmt_SE[b1] := 0;

    Fou_Mvmt_NO[c1] := Btb[b2] or Btb[a3];
    Fou_Mvmt_NE[c1] := Btb[d2] or Btb[e3] or Btb[f4] or Btb[g5] or Btb[h6];
    Fou_Mvmt_SO[c1] := 0;
    Fou_Mvmt_SE[c1] := 0;

    Fou_Mvmt_NO[d1] := Btb[c2] or Btb[b3] or Btb[a4];
    Fou_Mvmt_NE[d1] := Btb[e2] or Btb[f3] or Btb[g4] or Btb[h5];
    Fou_Mvmt_SO[d1] := 0;
    Fou_Mvmt_SE[d1] := 0;


    Fou_Mvmt_NO[e1] := Btb[d2] or Btb[c3] or Btb[b4] or Btb[a5];
    Fou_Mvmt_NE[e1] := Btb[f2] or Btb[g3] or Btb[h4];
    Fou_Mvmt_SO[e1] := 0;
    Fou_Mvmt_SE[e1] := 0;


    Fou_Mvmt_NO[f1] := Btb[e2] or Btb[d3] or Btb[c4] or Btb[b5] or Btb[a6];
    Fou_Mvmt_NE[f1] := Btb[g2] or Btb[h3];
    Fou_Mvmt_SO[f1] := 0;
    Fou_Mvmt_SE[f1] := 0;


    Fou_Mvmt_NO[g1] := Btb[f2] or Btb[e3] or Btb[d4] or Btb[c5] or Btb[b6] or Btb[a7];
    Fou_Mvmt_NE[g1] := Btb[h2];
    Fou_Mvmt_SO[g1] := 0;
    Fou_Mvmt_SE[g1] := 0;


    Fou_Mvmt_NO[h1] := Btb[g2] or Btb[f3] or Btb[e4] or Btb[d5] or Btb[c6] or Btb[b7] or Btb[a8];
    Fou_Mvmt_NE[h1 ] := 0;
    Fou_Mvmt_SO[h1] := 0;
    Fou_Mvmt_SE[h1] := 0;


    Fou_Mvmt_SE[a2] := Btb[b1];
    Fou_Mvmt_NE[a2] := Btb[b3] or Btb[c4] or Btb[d5] or Btb[e6] or Btb[f7] or Btb[g8];
    Fou_Mvmt_SO[a2] := 0;
    Fou_Mvmt_NO[a2] := 0;

    Fou_Mvmt_NO[b2] := Btb[a3];
    Fou_Mvmt_SE[b2] := Btb[c1];
    Fou_Mvmt_SO[b2] := Btb[a1];
    Fou_Mvmt_NE[b2] := Btb[c3] or Btb[d4] or Btb[e5] or Btb[f6] or Btb[g7] or Btb[h8];

    Fou_Mvmt_SO[c2] := Btb[b1];
    Fou_Mvmt_SE[c2] := Btb[d1];
    Fou_Mvmt_NO[c2] := Btb[b3] or Btb[a4];
    Fou_Mvmt_NE[c2] := Btb[d3] or Btb[e4] or Btb[f5] or Btb[g6] or Btb[h7];

    Fou_Mvmt_SO[d2] := Btb[c1];
    Fou_Mvmt_SE[d2] := Btb[e1];
    Fou_Mvmt_NO[d2] := Btb[c3] or Btb[b4] or Btb[a5];
    Fou_Mvmt_NE[d2] := Btb[e3] or Btb[f4] or Btb[g5] or Btb[h6];

    Fou_Mvmt_SO[e2] := Btb[d1];
    Fou_Mvmt_SE[e2] := Btb[f1];
    Fou_Mvmt_NO[e2] := Btb[d3] or Btb[c4] or Btb[b5] or Btb[a6];
    Fou_Mvmt_NE[e2] := Btb[f3] or Btb[g4] or Btb[h5];

    Fou_Mvmt_SO[f2] := Btb[e1];
    Fou_Mvmt_SE[f2] :=  Btb[g1];
    Fou_Mvmt_NO[f2] := Btb[e3] or Btb[d4] or Btb[c5] or Btb[b6] or Btb[a7];
    Fou_Mvmt_NE[f2] := Btb[g3] or Btb[h4];

    Fou_Mvmt_SO[g2] := Btb[f1]  ;
    Fou_Mvmt_SE[g2] := Btb[h1];
    Fou_Mvmt_NO[g2] := Btb[f3] or Btb[e4] or Btb[d5] or Btb[c6] or Btb[b7] or Btb[a8];
    Fou_Mvmt_NE[g2] := Btb[h3];

    Fou_Mvmt_SO[h2] := Btb[g1];
    Fou_Mvmt_NO[h2] := Btb[g3] or Btb[f4] or Btb[e5] or Btb[d6] or Btb[c7] or Btb[b8];
    Fou_Mvmt_NE[h2] := 0;
    Fou_Mvmt_SE[h2] := 0;

    Fou_Mvmt_SE[a3] := Btb[b2] or Btb[c1];
    Fou_Mvmt_NE[a3] := Btb[b4] or Btb[c5] or Btb[d6] or Btb[e7] or Btb[f8];
    Fou_Mvmt_SO[a3] := 0;
    Fou_Mvmt_NO[a3] := 0;

    Fou_Mvmt_SO[b3] := Btb[a2];
    Fou_Mvmt_SE[b3] := Btb[c2] or Btb[d1];
    Fou_Mvmt_NO[b3] := Btb[a4];
    Fou_Mvmt_NE[b3] := Btb[c4] or Btb[d5] or Btb[e6] or Btb[f7] or Btb[g8];

    Fou_Mvmt_SO[c3] := Btb[b2] or Btb[a1];
    Fou_Mvmt_SE[c3] := Btb[d2] or Btb[e1];
    Fou_Mvmt_NO[c3] := Btb[b4] or Btb[a5];
    Fou_Mvmt_NE[c3] := Btb[d4] or Btb[e5] or Btb[f6] or Btb[g7] or Btb[h8];

    Fou_Mvmt_SO[d3] := Btb[c2] or Btb[b1];
    Fou_Mvmt_SE[d3] := Btb[e2] or Btb[f1];
    Fou_Mvmt_NO[d3] := Btb[c4] or Btb[b5] or Btb[a6];
    Fou_Mvmt_NE[d3] := Btb[e4] or Btb[f5] or Btb[g6] or Btb[h7];

    Fou_Mvmt_SO[e3] := Btb[d2] or Btb[c1];
    Fou_Mvmt_SE[e3] := Btb[f2] or Btb[g1];
    Fou_Mvmt_NO[e3] := Btb[d4] or Btb[c5] or Btb[b6] or Btb[a7];
    Fou_Mvmt_NE[e3] := Btb[f4] or Btb[g5] or Btb[h6];

    Fou_Mvmt_SO[f3] := Btb[e2] or Btb[d1];
    Fou_Mvmt_SE[f3] := Btb[g2] or Btb[h1];
    Fou_Mvmt_NO[f3] := Btb[e4] or Btb[d5] or Btb[c6] or Btb[b7] or Btb[a8];
    Fou_Mvmt_NE[f3] := Btb[g4] or Btb[h5];

    Fou_Mvmt_SO[g3] := Btb[f2] or Btb[e1];
    Fou_Mvmt_SE[g3] := Btb[h2];
    Fou_Mvmt_NO[g3] := Btb[f4] or Btb[e5] or Btb[d6] or Btb[c7] or Btb[b8];
    Fou_Mvmt_NE[g3] := Btb[h4];

    Fou_Mvmt_SO[h3] := Btb[g2] or Btb[f1];
    Fou_Mvmt_NO[h3] := Btb[g4] or Btb[f5] or Btb[e6] or Btb[d7] or Btb[c8];
    Fou_Mvmt_SE[h3] := 0;
    Fou_Mvmt_NE[h3] := 0;

    Fou_Mvmt_SE[a4] := Btb[b3] or Btb[c2] or Btb[d1];
    Fou_Mvmt_NE[a4] := Btb[b5] or Btb[c6] or Btb[d7] or Btb[e8];
    Fou_Mvmt_NO[a4] := 0;
    Fou_Mvmt_SO[a4] := 0;

    Fou_Mvmt_NO[b4] := Btb[a3];
    Fou_Mvmt_NE[b4] := Btb[c3] or Btb[d2] or Btb[e1];
    Fou_Mvmt_SO[b4] := Btb[a5];
    Fou_Mvmt_SE[b4] := Btb[c5] or Btb[d6] or Btb[e7] or Btb[f8];

    Fou_Mvmt_SO[c4] := Btb[b3] or Btb[a2];
    Fou_Mvmt_SE[c4] := Btb[d3] or Btb[e2] or Btb[f1];
    Fou_Mvmt_NO[c4] := Btb[b5] or Btb[a6];
    Fou_Mvmt_NE[c4] := Btb[d5] or Btb[e6] or Btb[f7] or Btb[g8];

    Fou_Mvmt_SO[d4] := Btb[c3] or Btb[b2] or Btb[a1];
    Fou_Mvmt_SE[d4] := Btb[e3] or Btb[f2] or Btb[g1];
    Fou_Mvmt_NO[d4] := Btb[c5] or Btb[b6] or Btb[a7];
    Fou_Mvmt_NE[d4] := Btb[e5] or Btb[f6] or Btb[g7] or Btb[h8];

    Fou_Mvmt_SO[e4] := Btb[d3] or Btb[c2] or Btb[b1];
    Fou_Mvmt_SE[e4] := Btb[f3] or Btb[g2] or Btb[h1];
    Fou_Mvmt_NO[e4] := Btb[d5] or Btb[c6] or Btb[b7] or Btb[a8];
    Fou_Mvmt_NE[e4] := Btb[f5] or Btb[g6] or Btb[h7];

    Fou_Mvmt_SO[f4] := Btb[e3] or Btb[d2] or Btb[c1];
    Fou_Mvmt_SE[f4] := Btb[g3] or Btb[h2];
    Fou_Mvmt_NO[f4] := Btb[e5] or Btb[d6] or Btb[c7] or Btb[b8];
    Fou_Mvmt_NE[f4] := Btb[g5] or Btb[h6];

    Fou_Mvmt_SO[g4] := Btb[f3] or Btb[e2] or Btb[d1];
    Fou_Mvmt_SE[g4] := Btb[h3];
    Fou_Mvmt_NO[g4] := Btb[f5] or Btb[e6] or Btb[d7] or Btb[c8];
    Fou_Mvmt_NE[g4] := Btb[h5];

    Fou_Mvmt_SO[h4] := Btb[g3] or Btb[f2] or Btb[e1];
    Fou_Mvmt_NO[h4] := Btb[g5] or Btb[f6] or Btb[e7] or Btb[d8];
    Fou_Mvmt_SE[h4] := 0;
    Fou_Mvmt_NE[h4] := 0;

    Fou_Mvmt_SE[a5] := Btb[b4] or Btb[c3] or Btb[d2] or Btb[e1];
    Fou_Mvmt_NE[a5] := Btb[b6] or Btb[c7] or Btb[d8];
    Fou_Mvmt_NO[a5] := 0;
    Fou_Mvmt_SO[a5] := 0;

    Fou_Mvmt_SO[b5] := Btb[a4];
    Fou_Mvmt_SE[b5] := Btb[c4] or Btb[d3] or Btb[e2] or Btb[f1];
    Fou_Mvmt_NO[b5] := Btb[a6];
    Fou_Mvmt_NE[b5] := Btb[c6] or Btb[d7] or Btb[e8];

    Fou_Mvmt_SO[c5] := Btb[b4] or Btb[a3];
    Fou_Mvmt_SE[c5] := Btb[d4] or Btb[e3] or Btb[f2] or Btb[g1];
    Fou_Mvmt_NO[c5] := Btb[b6] or Btb[a7];
    Fou_Mvmt_NE[c5] := Btb[d6] or Btb[e7] or Btb[f8];

    Fou_Mvmt_SO[d5] := Btb[c4] or Btb[b3] or Btb[a2];
    Fou_Mvmt_SE[d5] := Btb[e4] or Btb[f3] or Btb[g2] or Btb[h1];
    Fou_Mvmt_NO[d5] := Btb[c6] or Btb[b7] or Btb[a8];
    Fou_Mvmt_NE[d5] := Btb[e6] or Btb[f7] or Btb[g8];

    Fou_Mvmt_SO[e5] := Btb[d4] or Btb[c3] or Btb[b2] or Btb[a1];
    Fou_Mvmt_SE[e5] := Btb[f4] or Btb[g3] or Btb[h2];
    Fou_Mvmt_NO[e5] := Btb[d6] or Btb[c7] or Btb[b8];
    Fou_Mvmt_NE[e5] := Btb[f6] or Btb[g7] or Btb[h8];

    Fou_Mvmt_SO[f5] := Btb[e4] or Btb[d3] or Btb[c2] or Btb[b1];
    Fou_Mvmt_SE[f5] := Btb[g4] or Btb[h3];
    Fou_Mvmt_NO[f5] := Btb[e6] or Btb[d7] or Btb[c8];
    Fou_Mvmt_NE[f5] := Btb[g6] or Btb[h7];

    Fou_Mvmt_SO[g5] := Btb[f4] or Btb[e3] or Btb[d2] or Btb[c1];
    Fou_Mvmt_SE[g5] := Btb[h4];
    Fou_Mvmt_NO[g5] := Btb[f6] or Btb[e7] or Btb[d8];
    Fou_Mvmt_NE[g5] := Btb[h6];

    Fou_Mvmt_SO[h5] := Btb[g4] or Btb[f3] or Btb[e2] or Btb[d1];
    Fou_Mvmt_NO[h5] := Btb[g6] or Btb[f7] or Btb[e8];
    Fou_Mvmt_NE[h5] := 0;
    Fou_Mvmt_SE[h5] := 0;

    Fou_Mvmt_SE[a6] := Btb[b5] or Btb[c4] or Btb[d3] or Btb[e2] or Btb[f1];
    Fou_Mvmt_NE[a6] := Btb[b7] or Btb[c8];
    Fou_Mvmt_NO[a6] := 0;
    Fou_Mvmt_SO[a6] := 0;

    Fou_Mvmt_SO[b6] := Btb[a5];
    Fou_Mvmt_SE[b6] := Btb[c5] or Btb[d4] or Btb[e3] or Btb[f2] or Btb[g1];
    Fou_Mvmt_NO[b6] := Btb[a7];
    Fou_Mvmt_NE[b6] := Btb[c7] or Btb[d8];

    Fou_Mvmt_SO[c6] := Btb[b5] or Btb[a4];
    Fou_Mvmt_SE[c6] := Btb[d5] or Btb[e4] or Btb[f3] or Btb[g2] or Btb[h1];
    Fou_Mvmt_NO[c6] := Btb[b7] or Btb[a8];
    Fou_Mvmt_NE[c6] := Btb[d7] or Btb[e8];

    Fou_Mvmt_SO[d6] := Btb[c5] or Btb[b4] or Btb[a3];
    Fou_Mvmt_SE[d6] := Btb[e5] or Btb[f4] or Btb[g3] or Btb[h2];
    Fou_Mvmt_NO[d6] := Btb[c7] or Btb[b8];
    Fou_Mvmt_NE[d6] := Btb[e7] or Btb[f8];

    Fou_Mvmt_SO[e6] := Btb[d5] or Btb[c4] or Btb[b3] or Btb[a2];
    Fou_Mvmt_SE[e6] := Btb[f5] or Btb[g4] or Btb[h3];
    Fou_Mvmt_NO[e6] := Btb[d7] or Btb[c8];
    Fou_Mvmt_NE[e6] := Btb[f7] or Btb[g8];

    Fou_Mvmt_SO[f6] := Btb[e5] or Btb[d4] or Btb[c3] or Btb[b2] or Btb[a1];
    Fou_Mvmt_SE[f6] := Btb[g5] or Btb[h4];
    Fou_Mvmt_NO[f6] := Btb[e7] or Btb[d8];
    Fou_Mvmt_NE[f6] := Btb[g7] or Btb[h8];

    Fou_Mvmt_SO[g6] := Btb[f5] or Btb[e4] or Btb[d3] or Btb[c2] or Btb[b1];
    Fou_Mvmt_SE[g6] := Btb[h5];
    Fou_Mvmt_NO[g6] := Btb[f7] or Btb[e8];
    Fou_Mvmt_NE[g6] := Btb[h7];

    Fou_Mvmt_SO[h6] := Btb[g5] or Btb[f4] or Btb[e3] or Btb [d2] or Btb[c1];
    Fou_Mvmt_NO[h6] := Btb[g7] or Btb[f8];
    Fou_Mvmt_NE[h6] := 0;
    Fou_Mvmt_SE[h6] := 0;

    Fou_Mvmt_SE[a7] := Btb[b6] or Btb[c5] or Btb[d4] or Btb[e3] or Btb[f2] or Btb[g1];
    Fou_Mvmt_NE[a7] := Btb[b8];
    Fou_Mvmt_NO[a7] := 0;
    Fou_Mvmt_SO[a7] := 0;

    Fou_Mvmt_SO[b7] :=  Btb[a6];
    Fou_Mvmt_SE[b7] := Btb[c6] or Btb[d5] or Btb[e4] or Btb[f3] or Btb[g2] or Btb[h1];
    Fou_Mvmt_NO[b7] := Btb[a8];
    Fou_Mvmt_NE[b7] := Btb[c8];

    Fou_Mvmt_SO[c7] := Btb[b6] or Btb[a5];
    Fou_Mvmt_SE[c7] := Btb[d6] or Btb[e5] or Btb[f4] or Btb[g3] or Btb[h2];
    Fou_Mvmt_NO[c7] := Btb[b8];
    Fou_Mvmt_NE[c7] := Btb[d8];

    Fou_Mvmt_SO[d7] := Btb[c6] or Btb[b5] or Btb[a4];
    Fou_Mvmt_SE[d7] := Btb[e6] or Btb[f5] or Btb[g4] or Btb[h3];
    Fou_Mvmt_NO[d7] := Btb[c8];
    Fou_Mvmt_NE[d7] := Btb[e8];

    Fou_Mvmt_SO[e7] := Btb[d6] or Btb[c5] or Btb[b4] or Btb[a3];
    Fou_Mvmt_SE[e7] := Btb[f6] or Btb[g5] or Btb[h4];
    Fou_Mvmt_NO[e7] := Btb[d8];
    Fou_Mvmt_NE[e7] := Btb[f8];

    Fou_Mvmt_SO[f7] := Btb[e6] or Btb[d5] or Btb [c4] or Btb[b3] or Btb[a2];
    Fou_Mvmt_SE[f7] := Btb[g6] or Btb[h5];
    Fou_Mvmt_NO[f7] := Btb[e8];
    Fou_Mvmt_NE[f7] := Btb[g8];

    Fou_Mvmt_SO[g7] := Btb[f6] or Btb[e5] or Btb[d4] or Btb[c3] or Btb[b2] or Btb[a1];
    Fou_Mvmt_SE[g7] := Btb[h6];
    Fou_Mvmt_NO[g7] := Btb[f8];
    Fou_Mvmt_NE[g7] := Btb[h8];

    Fou_Mvmt_SO[h7] := Btb[g6] or Btb[f5] or Btb[e4] or Btb[d3] or Btb[c2] or Btb[b1];
    Fou_Mvmt_NO[h7] := Btb[g8];
    Fou_Mvmt_NE[h7] := 0;
    Fou_Mvmt_SE[h7] := 0;

    Fou_Mvmt_SE[a8] := Btb[b7] or Btb[c6] or Btb[d5] or Btb[e4] or Btb [f3] or Btb[g2] or Btb[h1];
    Fou_Mvmt_NE[a8] := 0;
    Fou_Mvmt_SO[a8] := 0;
    Fou_Mvmt_NO[a8] := 0;

    Fou_Mvmt_SO[b8] := Btb[a7];
    Fou_Mvmt_SE[b8] := Btb[c7] or Btb[d6] or Btb[e5] or Btb[f4] or Btb[g3] or Btb[h2];
    Fou_Mvmt_NO[b8] := 0;
    Fou_Mvmt_NE[b8] := 0;

    Fou_Mvmt_SO[c8] := Btb[b7] or Btb[a6];
    Fou_Mvmt_SE[c8] := Btb[d7] or Btb[e6] or Btb[f5] or Btb[g4] or Btb[h3];
    Fou_Mvmt_NO[c8] := 0;
    Fou_Mvmt_NE[c8] := 0;

    Fou_Mvmt_SO[d8] := Btb[c7] or Btb [b6] or Btb[a5];
    Fou_Mvmt_SE[d8] := Btb[e7] or Btb[f6] or Btb[g5] or Btb[h4];
    Fou_Mvmt_NO[d8] := 0;
    Fou_Mvmt_NE[d8] := 0;

    Fou_Mvmt_SO[e8] := Btb[d7] or Btb[c6] or Btb[b5] or Btb[a4];
    Fou_Mvmt_SE[e8] := Btb[f7] or Btb[g6] or Btb[h5];
    Fou_Mvmt_NO[e8] := 0;
    Fou_Mvmt_NE[e8] := 0;

    Fou_Mvmt_SO[f8] := Btb[e7] or Btb[d6] or Btb[c5] or Btb[b4] or Btb[a3];
    Fou_Mvmt_SE[f8] := Btb[g7] or Btb[h6];
    Fou_Mvmt_NO[f8] := 0;
    Fou_Mvmt_NE[f8] := 0;

    Fou_Mvmt_SO[g8] := Btb[f7] or Btb[e6] or Btb[d5] or Btb[c4] or Btb[b3] or Btb[a2];
    Fou_Mvmt_SE[g8] := Btb[h7];
    Fou_Mvmt_NO[g8] := 0;
    Fou_Mvmt_NE[g8] := 0;

    Fou_Mvmt_SO[h8] := Btb[g7] or Btb[f6] or Btb[e5] or Btb[d4] or Btb[c3] or Btb[b2] or Btb[a1];
    Fou_Mvmt_NE[h8] := 0 ;
    Fou_Mvmt_NO[h8] := 0;
    Fou_Mvmt_SE[h8] := 0;


For i := a1 to h8 do
        Fou_BtB[i] := Fou_Mvmt_NO[i] or Fou_Mvmt_NE[i] or Fou_Mvmt_SO[i] or Fou_Mvmt_SE[i];


  end; // function   initbitboards;

//_____________________________________________________________
//
// représentation entière ( base 10 )du Bitboard binaire
//_____________________________________________________________
//

 //function TBitBoard_Test.StrUInt64Digits(val: UInt64; width: Integer; sign: Boolean): ShortString;
 function x_StrUInt64Digits(val: TBitboard; width: Integer; sign: Boolean): ShortString;
var
  d: array[0..31] of Char;  // need 19 digits and a sign
  i, k: Integer;
  spaces: Integer;
begin
  // Produit unerepresentation  ASCII du nombre en ordre inverse
  i := 0;
  repeat
    d[i] := Chr( (val mod 10) + Ord('0') );
    Inc(i);
    val := val div 10;
  until val = 0;
  if sign then
  begin
    d[i] := '-';
    Inc(i);
  end;

  // rempli le resultat avec l nombre approprié d'espace
  if width > 255 then
    width := 255;
  k := 1;
  spaces := width - i;
  while k <= spaces do
  begin
    Result[k] := AnsiChar(' ');
    Inc(k);
  end;

  //rempli le resultat avec l nombre
  while i > 0 do
  begin
    Dec(i);
    Result[k] := AnsiChar(d[i]);
    Inc(k);
  end;

  //le Resultat est long de k-1 caractère
    SetLength(Result, k-1);
end;

end.

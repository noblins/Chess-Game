unit Cible_piece;

interface
 uses
    UnitBtbInit,
    UtilAffiche,
    SysUtils,
    Dialogs;

 Function CiblesDuFou( siege :integer; Toutes,alliees: Tbitboard): Tbitboard ;
 Function CiblesDeTour( siege :integer; Toutes,alliees: Tbitboard): Tbitboard ;

 Function CiblesCavalier( siege :integer; Alliees: Tbitboard): Tbitboard ;
 Function CiblesRoi( siege :integer; Allies: Tbitboard): Tbitboard ;
 Function CiblespionN( siege :integer; Allies: Tbitboard): Tbitboard ;

 function dep( siege : integer):integer;    // d้part
 function arr( siege : integer):integer;    // arriv้e
 function Piece( siege : integer):integer;
 function Capture( siege : integer):integer;
 function Promotion( siege : integer):integer;
 function CaptureOuPromotion( siege : integer):integer;
 function type_Echec( coup : integer):integer;    // echecs

function Creer_BtB_cible(depuis:byte; Btb_alliees : TBitboard ):TBitboard ;
 procedure MaJ_BtB_piece();
 function Case_roque_menacee(roque, trait: integer): boolean ;
 function case_menacee (siege, trait : integer) : boolean;

 function Coup_impossible( trait,num_dep, num_arr : integer ) : boolean ;
 function empile_coup(_capture,_promotion,_depart,_arrivee,_piece:byte):integer;
 procedure Lister_Essais(var  Arbre : Parbre_coups ;  camp:integer;
                          Allies,adverses:TBitboard);
procedure Arbre_add_coup( var arbre : PArbre_coups ; depuis, vers : integer );
procedure Initarbre(arbre : Parbre_coups);
Procedure Ia_play(coup : integer);
procedure ordi_joue ;

implementation
 uses
  two_play ;
//________________________________________________________________________
//   cette fonction retourne le bitboard des cases accessibles au fou
//   situ้ en case siege, en fonction  des pi่ces sur l'้chiquier
//   ces fonction sont de mon cru et je ne les ai test้es que sur le papier
//   mais elles ้vitent les "rotations de bitboard" et les "magics bitboards"
//    d'illeurs j'en suis fier!
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ

Function CiblesDuFou( siege :integer; Toutes,alliees: Tbitboard): Tbitboard ;
Var
     attaqueNO, attaqueNE, attaqueSO, attaqueSE : Tbitboard ;
begin

attaqueNO  := Fou_Mvmt_NO[siege] AND Toutes ;
if attaqueNO=0
    then attaqueNO  := Fou_Mvmt_NO[siege]
    else attaqueNO  := Fou_Mvmt_NO[siege] and (Fou_Mvmt_SE[index_LSB (attaqueNO )] or Btb[index_LSB (attaqueNO )]);

attaqueNE := Fou_Mvmt_NE[siege] AND  Toutes ;
if attaqueNE=0
    then attaqueNE  := Fou_Mvmt_NE[siege]
    else attaqueNE  := Fou_Mvmt_NE[siege] and (Fou_Mvmt_SO [index_LSB (attaqueNE)] or Btb[index_LSB (attaqueNE )]);

attaqueSE := Fou_Mvmt_SE[siege]   AND  Toutes ;
if attaqueSE=0
    then attaqueSE  := Fou_Mvmt_SE[siege]
    else attaqueSE  :=  Fou_Mvmt_SE[siege] and (Fou_Mvmt_NO [index_MSB (attaqueSE)] or Btb[index_MSB (attaqueSE )]);

attaqueSO := Fou_Mvmt_SO [siege]    AND  Toutes ;
if attaqueSO=0
    then attaqueSO  := Fou_Mvmt_SO[siege]
    else attaqueSO  :=  Fou_Mvmt_SO[siege] and (Fou_Mvmt_NE[index_MSB (attaqueSO)] or Btb[index_MSB (attaqueSO )]);

result  :=  (attaqueNO or attaqueNE or  attaqueSE or attaqueSO)  and NOT alliees ;

end;

//________________________________________________________________________
//    cette fonction retourne le bitboard des cases accessibles เ la tour
//      situ้e en case siege, en fonction  des pi่ces sur l'้chiquier
//      elle est calqu้e/adapt้e sur/de la function  CiblesDuFou() ci-dessus.
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ

Function CiblesDeTour( siege :integer; Toutes,alliees: Tbitboard): Tbitboard ;
Var
     attaqueN , attaqueE , attaqueS , attaqueO : Tbitboard ;
begin

attaqueN := Tour_Mvmt_Nord[siege] and  Toutes;
if  attaqueN= 0
   then attaqueN := Tour_Mvmt_Nord[siege]
   else  attaqueN := Tour_Mvmt_Nord[siege] and (Tour_Mvmt_Sud[index_LSB (attaqueN)] or Btb[index_LSB (attaqueN )]);

attaqueE := Tour_Mvmt_Est[siege] and  Toutes;
if  attaqueE= 0
   then attaqueE := Tour_Mvmt_Est [siege]
   else  attaqueE := Tour_Mvmt_Est [siege] and (Tour_Mvmt_Ouest [index_LSB (attaqueE)] or Btb[index_LSB (attaqueE )]);


attaqueS  := Tour_Mvmt_Sud[siege] and  Toutes ;
if  attaqueS= 0
   then attaqueS := Tour_Mvmt_Sud [siege]
   else  attaqueS:= Tour_Mvmt_Sud [siege] and (Tour_Mvmt_Nord [index_MSB (attaqueS)] or Btb[index_MSB (attaqueS )]);

attaqueO := Tour_Mvmt_Ouest[siege] and  Toutes;
if  attaqueO= 0
   then attaqueO := Tour_Mvmt_Ouest [siege]
   else  attaqueO:= Tour_Mvmt_Ouest [siege] and (Tour_Mvmt_Est [index_MSB (attaqueO)] or Btb[index_MSB (attaqueO )]);

result :=  (attaqueO or attaqueN or  attaqueS or attaqueE)  and NOT alliees ;

end;

//________________________________________________________________________
//    cette fonction retourne le bitboard des cases accessibles au cavalier
//      situ้e en case siege, en fonction  des pi่ces sur l'้chiquier
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ

 Function CiblesCavalier( siege :integer; Alliees: Tbitboard): Tbitboard ;
begin
   result :=  Cavalier_Btb[siege] and NOT alliees ;
end;

//________________________________________________________________________
//    cette fonction retourne le bitboard des cases accessibles au roi
//      situ้e en case siege, en fonction  des pi่ces sur l'้chiquier
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ

Function CiblesRoi( siege :integer; Allies: Tbitboard): Tbitboard ;


begin


   result :=  Roi_Btb[siege] and NOT allies ;

   if ((siege = e1 )and (plateau_actuel[a1,0]=A_tour )) then
   begin
     if (((O_O_O_B and ( Alliees[0] or Alliees[1])) =0) and
                 ( Case_roque_menacee(OOO_B,0)))
       then  result := result or Btb[c1];
   end;

   if ((siege = e1 )and (plateau_actuel[h1,0]=A_tour )) then
   begin
     if (((O_O_B and ( Alliees[0] or Alliees[1])) =0) and
                 ( Case_roque_menacee(OO_B,0)))
        then result := result or Btb[g1];
             // valide petit roque blanc
    end;

   if ((siege = e8 )and (plateau_actuel[a8,0]=A_tour )) then
   begin
     if (((O_O_O_N and ( Alliees[0] or Alliees[1])) =0) and
                 ( Case_roque_menacee(OOO_N,1)))
        then result := result or Btb[c8];
             // valide grand roque noir

   end;

   if ((siege = e8 )and (plateau_actuel[h8,0]=A_tour )) then
   begin
     if (((O_O_N and ( Alliees[0] or Alliees[1])) =0) and
                 ( Case_roque_menacee(OO_N,1)))
      then result := result or Btb[g8];
         // valide petit roque noir
   end;

end;

//________________________________________________________________________
//    cette fonction retourne le bitboard des cases accessibles au pion Noir
//      situ้e en case siege, en fonction  des pi่ces sur l'้chiquier
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ

Function CiblesPionN( siege :integer; Allies: Tbitboard): Tbitboard ;
begin
 if En_passant = -1 then
 begin
   result :=     (pion_N_Mvmt_prise[siege] and  alliees[0])
              or (pion_N_Mvmt_pas[siege] and NOT (Alliees[0]or Alliees[1])) ;
 end
 else
   result :=     (pion_N_Mvmt_prise[siege] and  (alliees[0] or Btb[En_passant]))
              or (pion_N_Mvmt_pas[siege] and NOT (Alliees[0]or Alliees[1])) ;

 if  (BtB[siege-8] and (Alliees[0]or Alliees[1])) > 0
      then result := result and not ( BtB[siege-16]);


end;

//________________________________________________________________________
//    cette fonction retourne le bitboard des cases accessibles au pion Blanc
//      situ้e en case siege, en fonction  des pi่ces sur l'้chiquier
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ

Function CiblesPionB( siege :integer; Allies: Tbitboard): Tbitboard ;
begin

 if En_passant = -1 then
 begin
   result :=  (pion_B_Mvmt_prise[siege] and alliees[1])
          or  (pion_B_Mvmt_pas[siege] and NOT (Alliees[0]or Alliees[1])) ;
 end
 else
   result :=     (pion_B_Mvmt_prise[siege] and  (alliees[1] or Btb[En_passant]))
              or (pion_B_Mvmt_pas[siege] and NOT (Alliees[0]or Alliees[1])) ;

 if  (BtB[siege+8] and (Alliees[0]or Alliees[1])) > 0
      then result := result and not ( BtB[siege+16]);


end;


//________________________________________________________________________
//
//  m้morisation du coup
//  et fonctions de recup้ration de ces valeurs compress้es
//________________________________________________________________________
//     le coup est m้moris้ dans une variable enti่re
//  sur le mod่le du pr Hyatt, les donn้es sont cod้es sur 21 bits
//   il utilise un mode compress้  de la mani่re suivante:
//              _____       _____             ___________
//  21 bits :  |d|d|d|x|x|x|p|p|p|a|a|a|a|a|a|d|d|d|d|d|d|  pour chaque coup
//                    จจจจจ       จจจจจจจจจจจ
//   echec   promotion capture  piece     arriv้e         depart
//   |_|_|_|จจ|_|_|_|จจ|_|_|_|จจ|_|_|_|จจ|_|_|_|_|_|_|จจ|_|_|_|_|_|_|
//   232221   201918   171615   141312   1110 9 8 7 6    5 4 3 2 1 0   nฐ bit
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
//  les fonctions suivantes extraient les valeurs appropri้es de ce
//  format compress้.
//  dep ();        arr();
//  piece();       capture();
//  promotion();   captureOuPromotion();
//

//________________________________________________________________________
//  empile_coup ();  compacte le coup dans un entier
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
 function empile_coup(_capture,_promotion,_depart,_arrivee,_piece:byte):integer;
 var  _coup:integer;
 begin
     _coup:= _promotion;
     _coup := (_coup shl 3) +  _capture ;
     _coup := (_coup shl 3) +  _piece ;
     _coup := (_coup shl 6) +  _arrivee ;
     _coup := (_coup shl 6) +  _depart ;
 result := _coup;
 end;

//________________________________________________________________________
//  dep ();   retourne la case de d้part de la pi่ce  จ: mouvement
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ

 function dep( siege : integer):integer;    // d้part
 begin
      result := siege and 63;       // un masque de 6 bits
 end;

//________________________________________________________________________
//   arr();  retourne la case de d'arriv้e de la pi่ce  จ: mouvement
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
 function arr( siege : integer):integer;    // arriv้e
 begin
      result := (siege shr 6)and 63;   // shift R 6 + un masque de 6 bits
 end;

//________________________________________________________________________
//  piece();   retourne le type de la pi่ce qui effectue le d้placement
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
 function Piece( siege : integer):integer;
 begin
      result := (siege shr 12)and 7;   // shift R 12 + un masque de 3 bits
 end;

//________________________________________________________________________
// capture();  retourne le type de la pi่ce captur้e lors du d้placement
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
 function Capture( siege : integer):integer;
 begin
      result := (siege shr 15)and 7;  // shift R 15 + un masque de 3 bits
 end;

//________________________________________________________________________
// promotion();  retourne le type de la pi่ce promue lors du d้placement
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
function Promotion( siege : integer):integer;
 begin
      result := (siege shr 18)and 7;  // shift R 18 + un masque de 3 bits
 end;

//________________________________________________________________________
//     retourne le type de la pi่ce promue ou captur้e lors du d้placement
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
 function CaptureOuPromotion( siege : integer):integer;
 begin
      result := (siege shr 15)and 63;  // shift R 15 + un masque de 6 bits
 end;

//________________________________________________________________________
//  type_Echec();   retourne le type d'้chec s'il existe
//  cod้ sur trois bit : 1:(direct) 2:( indirect ) 3:(rayon de l'indirect)
//                b001 : c'est un ้chec direct
//                b010 : c'est un ้chec indirect  ( d้couverte d'une tour/dame)
//                b110 : c'est un ้chec indirect  ( d้couverte d'un   fou/dame)
//                b011 : c'est un ้chec double    ( d้couverte d'une tour/dame)
//                b110 : c'est un ้chec double    ( d้couverte d'un   fou/dame)
//
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ

 function type_Echec( coup : integer):integer;    // echecs
 begin
      result := (coup shr 21) and 7;       // un masque de 6 bits
 end;


function Creer_BtB_cible(depuis:byte; Btb_alliees : TBitboard ):TBitboard ;
begin

  result := 0 ;

  case plateau_actuel[depuis,0] of

     A_cavalier  :  result := CiblesCavalier(depuis, Btb_Alliees  ) ;
     A_roi       :  result := CiblesRoi(depuis, Btb_alliees);
     A_fou       :  result := CiblesDuFou(depuis,
                                   Alliees[0] or Alliees[1], Btb_Alliees  ) ;
     A_tour      :  result := CiblesDeTour(depuis,
                                   Alliees[0] or Alliees[1], Btb_Alliees  ) ;
     A_dame      :  result := CiblesDeTour(depuis,
                                   Alliees[0] or Alliees[1], Btb_Alliees  ) or
                              CiblesDuFou(depuis,
                                   Alliees[0] or Alliees[1], Btb_Alliees  ) ;

    A_pion      : if plateau_actuel[depuis,1] = 1
                    then
                       result := CiblespionB(depuis,Btb_alliees)
                    else
                       result := CiblespionN(depuis,Btb_alliees) ;
  end;
end;

procedure MaJ_BtB_piece();
begin
   if plateau_actuel[num_depart,1] = 1 then
   begin
     Alliees[0] := (Alliees[0] xor Btb[num_depart]) or Btb[num_arrive] ;
     Alliees[1] := Alliees[1] and ( (Btb_64) xor Btb[num_arrive] );
     toutes :=  Alliees[0] or Alliees[1] ;


     case plateau_actuel[num_depart,0] of
          fou  : BtB_fou_dame[0] := (BtB_fou_dame[0] xor Btb[num_depart])
                                      or Btb[num_arrive];
          tour : BtB_tour_dame[0]:= (BtB_tour_dame[0] xor Btb[num_depart])
                                     or Btb[num_arrive];
          dame : begin
                    BtB_fou_dame[0] := (BtB_fou_dame[0] xor Btb[num_depart])
                                        or Btb[num_arrive] ;
                    BtB_tour_dame[0]:= (BtB_tour_dame[0] xor Btb[num_depart])
                                         or Btb[num_arrive] ;
                  end;
          cavalier : BtB_cavalier[0] :=  (BtB_cavalier[0] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
          roi :  begin BtB_roi[0] :=  (BtB_roi[0] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
                         pos_roiB := num_arrive ;

                 end;
          pion :   BtB_pions[0] :=  (BtB_pions[0] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
     end;

     BtB_fou_dame[1] := BtB_fou_dame[1] and ((Btb_64) xor Btb[num_arrive]) ;
     BtB_tour_dame[1]:= BtB_tour_dame[1] and ((Btb_64) xor Btb[num_arrive]);
     BtB_cavalier[1] := BtB_cavalier[1] and ((Btb_64) xor Btb[num_arrive]) ;
     BtB_roi[1] := BtB_roi[1] and ((Btb_64) xor Btb[num_arrive]) ;
     BtB_pions[1] := BtB_pions[1] and ((Btb_64) xor Btb[num_arrive]) ;

   end
   else
   begin

     Alliees[1] := (Alliees[1] xor Btb[num_depart]) or Btb[num_arrive] ;
     Alliees[0] := Alliees[0] and ( (Btb_64) xor Btb[num_arrive] ) ;
     toutes :=  Alliees[0] or Alliees[1] ;


     case plateau_actuel[num_depart,0] of
          fou  : BtB_fou_dame[1] := (BtB_fou_dame[1] xor Btb[num_depart])
                                      or Btb[num_arrive];
          tour : BtB_tour_dame[1]:= (BtB_tour_dame[1] xor Btb[num_depart])
                                     or Btb[num_arrive];
          dame : begin
                    BtB_fou_dame[1] := (BtB_fou_dame[1] xor Btb[num_depart])
                                        or Btb[num_arrive] ;
                    BtB_tour_dame[1]:= (BtB_tour_dame[1] xor Btb[num_depart])
                                         or Btb[num_arrive] ;
                  end;
          cavalier : BtB_cavalier[1] :=  (BtB_cavalier[1] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
          roi :begin  BtB_roi[1] :=  (BtB_roi[1] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
                                          pos_roiN := num_arrive ;
//                      if Aide_dep then showmessage(inttostr(Pos_roiN));
              end;
          pion :   BtB_pions[1] :=  (BtB_pions[1] xor Btb[num_depart])
                                           or Btb[num_arrive] ;
     end;

     BtB_fou_dame[0] := BtB_fou_dame[0] and ((Btb_64) xor Btb[num_arrive]) ;
     BtB_tour_dame[0]:= BtB_tour_dame[0] and ((Btb_64) xor Btb[num_arrive]);
     BtB_cavalier[0] := BtB_cavalier[0] and ((Btb_64) xor Btb[num_arrive]) ;
     BtB_roi[0] := BtB_roi[0] and ((Btb_64) xor Btb[num_arrive]) ;
     BtB_pions[0] := BtB_pions[0] and ((Btb_64) xor Btb[num_arrive]) ;

   end;



end;



function Case_roque_menacee(roque, trait: integer): boolean ;

var
  // variable : trois cases ne tol้rant pas l'้chec en cas de roque
  //            seules ces trois cases doivent ๊tre explor้es
  //            si aucun n'est en prise...
  //            la condition du roque ( "non echec" )  est remplie
  //            restent les condition  ( "non mouvement Tour & Roi" )  !!

  siege_a, siege_b,siege_c :  integer;
//  toutes:TBitboard;  // toutes les pi่ces de l'้chiquier;
  adverse : integer ;

begin
//  toutes:= alliees[0] or alliees[1];
  if trait = 1 then
    adverse := 0
  else
    adverse := 1 ;


  siege_a:=e1;
  siege_b:=f1;
  siege_c:=g1;

  result:= true;
  case roque of

       OO_B :  begin      // s'il s'agit d'un petit roque blanc
                       siege_a:=e1;
                       siege_b:=f1;
                       siege_c:=g1;
                end;
       OOO_B :  begin      // s'il s'agit d'un grand roque blanc
                       siege_a:=e1;
                       siege_b:=d1;
                       siege_c:=c1;
                end;
       OO_N :  begin      // s'il s'agit d'un petit roque noir
                       siege_a:=e8;
                       siege_b:=f8;
                       siege_c:=g8;
                    end;
       OOO_N :  begin      // s'il s'agit d'un grand roque noir
                       siege_a:=e8;
                       siege_b:=d8;
                       siege_c:=c8;
                    end;
    end;

      // maintenant on teste si l'une de ces trois cases est en echec !


  if ((CiblesDuFou( siege_a,toutes,alliees[trait]) and BtB_fou_dame[adverse]) or
      (CiblesDuFou( siege_b,toutes,alliees[trait]) and BtB_fou_dame[adverse]) or
      (CiblesDuFou( siege_c,toutes,alliees[trait]) and BtB_fou_dame[adverse])) >0
      then begin result:= false;  end;

  if ((CiblesDeTour( siege_a,toutes,alliees[trait]) and BtB_Tour_dame[adverse]) or
      (CiblesDeTour( siege_b,toutes,alliees[trait]) and BtB_Tour_dame[adverse]) or
      (CiblesDeTour( siege_c,toutes,alliees[trait]) and BtB_Tour_dame[adverse])) >0
     then  begin result:= false;  end;

  if ((CiblesCavalier( siege_a,alliees[trait]) and BtB_cavalier[adverse]) or
      (CiblesCavalier( siege_b,alliees[trait]) and BtB_cavalier[adverse]) or
      (CiblesCavalier( siege_c,alliees[trait]) and BtB_cavalier[adverse])) >0
      then  begin result:= false;  end;


  if ((CiblesRoi( siege_b,alliees[trait]) and BtB_Roi[adverse]) or
      (CiblesRoi( siege_c,alliees[trait]) and BtB_Roi[adverse])) >0
      then  begin result:= false;  end;


  if (trait = 1)
     then
        begin
            if (((pion_N_Mvmt_prise[siege_a]) and BtB_pions[adverse]) or
                ((pion_N_Mvmt_prise[siege_b]) and BtB_pions[adverse]) or
                ((pion_N_Mvmt_prise[siege_c]) and BtB_pions[adverse])) >0
                then  begin result:= false;  end;
        end
     else
        begin
            if (((pion_B_Mvmt_prise[siege_a]) and BtB_pions[adverse]) or
                ((pion_B_Mvmt_prise[siege_b]) and BtB_pions[adverse]) or
                ((pion_B_Mvmt_prise[siege_c]) and BtB_pions[adverse])) >0
                then  begin result:= false;  end;
        end ;

end;

function case_menacee (siege, trait : integer) : boolean;

var
  adverse : integer ;

begin

 if trait = 1 then     // c'est au tour des noirs de jouer
 begin
    adverse:= 0 ;
    result := ((pion_N_Mvmt_prise[siege] and BtB_pions[0]) > 0)  ;
 end
 else
 begin
    adverse:= 1;
    result := ((pion_B_Mvmt_prise[siege] and BtB_pions[1]) > 0)  ;
 end;

   if (((CiblesDuFou( siege, toutes, alliees[trait]) and BtB_fou_dame[adverse]) or  // menacee par un fou adverse ou par une dame  OU
   (CiblesDeTour( siege, toutes, alliees[trait]) and BtB_Tour_dame[adverse]) or   // menacee par une tour adverse ou par une dame  OU
   ((CiblesCavalier( siege, alliees[trait]) and BtB_cavalier[adverse])) or      // menacee par un cavalier adverse OU
   ((CiblesRoi( siege, alliees[trait]) and BtB_Roi[adverse]))) > 0) then         // menacee par roi adverse

      result:=true ; // la case est menacee

 end;

function Coup_impossible( trait,num_dep, num_arr : integer ) : boolean ;


var
  tours_blanc : TBitboard ;
  tours_noir : TBitboard ;

  fou_blanc : TBitboard ;
  fou_noir : TBitboard ;

  roi_blanc : TBitboard ;
  roi_noir : TBitboard ;

  Cavalier_blanc : TBitboard ;
  Cavalier_noir : TBitboard ;

  roi_blanc_pos : integer;
  roi_noir_pos : integer ;

  pions_blancs : TBitboard ;
  pions_noir : TBitboard ;

  Alliees_blanc : TBitboard ;
  Alliees_noir : TBitboard ; // apres le coup effectu้
//                                              pour conserver les originaux

  num_dep_test ,num_arr_test : integer ;

begin

  Alliees_blanc := Alliees[0] ;
  Alliees_noir := Alliees[1] ;

  fou_blanc  := BtB_fou_dame[0] ;
  fou_noir  := BtB_fou_dame[1] ;

  tours_blanc := BtB_tour_dame[0] ;
  tours_noir := BtB_tour_dame[1] ;

  cavalier_blanc := BtB_cavalier[0] ;
  cavalier_noir := BtB_cavalier[1] ;

  pions_blancs := BtB_pions[0] ;
  pions_noir := BtB_pions[1] ;

  roi_blanc := BtB_roi[0]  ;
  roi_noir := BtB_roi[1]  ;

  roi_blanc_pos := pos_roiB ;
  roi_noir_pos := pos_roiN ;

  num_dep_test := num_depart ;
  num_arr_test := num_arrive ;

  num_depart := num_dep ;
  num_arrive := num_arr ;

  MaJ_BtB_piece ;

  if trait = 1 then
  begin
    if case_menacee(pos_roiN , trait ) then
    begin
      result := true ;
//      showmessage('Coup impossible : Echec ! ');

    end
    else
      result := false ;
  end
  else
  begin
    if case_menacee(pos_roiB , trait ) then
    begin
      result := true ;
//      showmessage('Coup impossible : Echec ! ');

    end
    else
      result := false ;
  end;

  Alliees[0] := Alliees_blanc ;
  Alliees[1] := Alliees_noir ;
  toutes := Alliees[0] or Alliees[1] ;

  BtB_fou_dame[0]  := fou_blanc ;
  BtB_fou_dame[1]  := fou_noir ;

  BtB_tour_dame[0] := tours_blanc ;
  BtB_tour_dame[1] := tours_noir ;

  BtB_cavalier[0] := cavalier_blanc ;
  BtB_cavalier[1] := cavalier_noir;

  BtB_pions[0] :=  pions_blancs;
  BtB_pions[1] := pions_noir ;

  BtB_roi[0] := roi_blanc  ;
  BtB_roi[1] := roi_noir  ;

  pos_roiB := roi_blanc_pos ;
  pos_roiN := roi_noir_pos ;


  num_depart := num_dep_test ;
  num_arrive := num_arr_test ;
end;

// ____________________________________________________________________________
// ____________________________________________________________________________
//   Lister_Essais() liste les coups l้gaux d'une position
//   et ram่ne en param่te( outre cette liste) le nombre de ces coups l้gaux
//   ainsi si ( Lister_Essais()=0 ) alors il y a mat ou pat!
//    pour cela :  on d้fini le bitboard des pieces alli้s[camp]
//    et on extrait, bit เ bit, les index des pi่ces...
//            on calcule le bitboard cible de chaque pi่ce...
//                  on empile chaque coup l้gal de cette pi่ce
//  puis on fait disparaitre le bit ce cette piece du bitboard Alli้s[camp]
//       on r้it่re, tant qu'il reste un bit dans ce bitboard.
// en fait nous utilisons un allias de ce Bitboatd Alli้s que nous appelerons,
// du fait de son rapi่cement progressif, peau_de_chagrin ! (merci Balzac)
// en fait dexu peaux de chagrin emboit้es   (n * pieces ->(m * cibles ))
//
//จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ

procedure Lister_Essais(var Arbre : Parbre_coups ; camp: integer ;
                         Allies,adverses:TBitboard) ;
var
   peau_de_chagrin : TBitboard;  // Btb(allies): se vide comme peau de chagrin
   le_Bit          : TBitboard;  // Bitboard ne contenant qu'un bit ( LSB)
   depuis          : integer ;       //  la case de d้part de la pi่ce envisag้e
   vers            : integer ;        // la(les) case(s) d'arrivee de la pi่ce ...
   _piece          : integer ;       // la piece en phase d'essai
   cibles_piece    : TBitboard;  // le bitboard cible de la piece ci dessus
   nb_essai        : integer;       // on compte tous les coups l้gaux!
   memo            :string;
//   V_Allies      : TBitboard;  // le bitboard cible de la piece ci dessus
//   V_adverses    : TBitboard;  // le bitboard cible de la piece ci dessus
   adv           : integer ;
   trone         : integer ;       // le siege du "roi menac้"

begin

    if camp = blanc
      then begin trone := pos_roiB; adv := noir ;  end
      else begin trone := pos_roiN; adv := blanc ; end;

//     empile_coup();
     memo:='';       // la liste est vide
     nb_essai:= 0;  //  pour l'instant, "j'ai rien fait"
     peau_de_chagrin :=Allies; // toutes les pi่ces alli้es doivent essayer!
                              // de jouer... un coup l้gal.

 // nous allons prendre chaque pi่ce une เ une... et les ้tudier
 //จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
  While  peau_de_chagrin >0 do  // rapi่็ons cette peau_chagrin principale
     begin

        le_Bit := LSB(peau_de_chagrin); // on consid่re le bit le moins signifiant

               // maintenant, il faut retrouver l'index de ce bitboard singulier
               // on utilise le reste de la division de le_Bit par 67
        depuis :=  Bit_mod67[le_Bit mod 67]; // la technique de Brujin (Cf Initboard)

               //  on rep่re la pi่ce  situ้e เ cet endroi ( index )
        _piece := plateau_actuel[depuis][A_piece];


        //  on ้tabli le bitboard cible de cette piece
        cibles_piece := Creer_BtB_cible(depuis,Allies);

        // et voici une nouvelle peau de chagrin qu'il faut rapi่cer
        //  nous allons prendre chaque cible une เ une... et les empiler !
        //จจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจจ
         While  cibles_piece >0 do  // rapi้็ons cette peau_chagrin secondaire
            begin
                le_Bit := LSB(cibles_piece); // on ้num่re les cibles, une เ une
                vers :=  Bit_mod67[le_Bit mod 67];// par la technique de Brujin

             if (not Coup_impossible( adv,depuis, vers ))  then
             begin

                   // nous avons tout pour empiler ce coup dans notre liste
                   // empile_essai( V_liste,camp,depuis,vers );

                    inc(nb_essai);

                    Arbre_add_coup(arbre, depuis, vers );

             end;

               cibles_piece :=  Ote_LSB(cibles_piece);
            end;
        // ici  on empile les coups l้gaux parmis ces cibles
        // เ impl้menter

        peau_de_chagrin := Ote_LSB(peau_de_chagrin); // on fait disparaitre ce bit !

     end;
//                      Form3.Memo_essais.Text:= memo;

    if nb_essai=0 then
    begin
       if  case_menacee(trone,adv) then
           showmessage(' Mat ! Partie termin้e !')
       else
           showmessage(' Pat ! Match nul !')
    end;
end;



procedure Arbre_add_coup( var arbre : PArbre_coups ; depuis, vers : integer );

var
  _promotion :byte;
  _capture   :byte;
  _piece     :byte;
  _PriseEP   :byte;
  I : integer ;

  parcour_arbre :  PArbre_coups ;
begin


   if ((plateau_actuel[depuis,0] = A_pion) and ( (vers < a2) or (vers > h7 ))) then
   begin
        parcour_arbre := NIL ;
        new(parcour_arbre);
        parcour_arbre^.pos_obtenu := NIL ;
        parcour_arbre^.coup_suivant := arbre ;
        parcour_arbre^.coup := empile_coup(plateau_actuel[vers,0],
                                           A_cavalier, depuis , vers,
                                           plateau_actuel[depuis,0] ) ;
        parcour_arbre^.eval := random(100);
        arbre := parcour_arbre ;

        parcour_arbre := NIL ;
        new(parcour_arbre);
        parcour_arbre^.pos_obtenu := NIL ;
        parcour_arbre^.coup_suivant := arbre ;
        parcour_arbre^.coup := empile_coup(plateau_actuel[vers,0],
                                           A_fou, depuis , vers,
                                           plateau_actuel[depuis,0] ) ;
        parcour_arbre^.eval := random(100);
        arbre := parcour_arbre ;

        parcour_arbre := NIL ;
        new(parcour_arbre);
        parcour_arbre^.pos_obtenu := NIL ;
        parcour_arbre^.coup_suivant := arbre ;
        parcour_arbre^.coup := empile_coup(plateau_actuel[vers,0],
                                           A_tour, depuis , vers,
                                           plateau_actuel[depuis,0] ) ;
        parcour_arbre^.eval := random(100);
        arbre := parcour_arbre ;

        parcour_arbre := NIL ;
        new(parcour_arbre);
        parcour_arbre^.pos_obtenu := NIL ;
        parcour_arbre^.coup_suivant := arbre ;
        parcour_arbre^.coup := empile_coup(plateau_actuel[vers,0],
                                           A_dame, depuis , vers,
                                           plateau_actuel[depuis,0] ) ;
        parcour_arbre^.eval := random(100);
        arbre := parcour_arbre ;



   end
   else
   begin
     new(parcour_arbre);
     parcour_arbre^.pos_obtenu := NIL ;
     parcour_arbre^.coup_suivant := arbre ;
     parcour_arbre^.coup := empile_coup(plateau_actuel[vers,0],
                                        0, depuis , vers,
                                        plateau_actuel[depuis,0] ) ;
     randomize;
     parcour_arbre^.eval :=  Random(55) ;
     arbre := parcour_arbre ;
   end;





end;

procedure Initarbre(arbre : Parbre_coups);

begin

 if arbre <> NIL then
 begin

  Initarbre(arbre^.pos_obtenu);
  Initarbre(arbre^.coup_suivant);
  dispose(arbre);
  arbre := NIL ;

 end;


end;

Procedure Ia_play(coup : integer);

begin

  num_depart := coup and 63 ;
  coup := coup shr 6 ;
  num_arrive := coup and 63 ;

  MaJ_BtB_piece ;
           // on envisage un nouveau demi coup!
           inc(Mi_Coup_actuel); // on incr้lmente le compteur de demi coups!

//           promotion := 0 ;
           piece_deplacee := plateau_actuel[num_depart,0];
           piece_capturee := plateau_actuel[num_arrive,0];
//           depart    := num_depart;
//           arrivee   := num_arrive;
//           piece     := plateau_actuel[num_depart,0];
//           capture   := plateau_actuel[num_arrive,0]; // qu'elle existe ou pas !


//          FSOUND_PlaySound(FSOUND_FREE, clic); // Son du mouvement

          plateau_actuel[num_arrive,0] := plateau_actuel[num_depart,0] ;
          plateau_actuel[num_depart,0] := A_zero ;
          plateau_actuel[num_arrive,1] := plateau_actuel[num_depart,1] ;
          plateau_actuel[num_depart,1] := 0;       // mouvement de la pi่ce
//          Arbre_jeu^.pos.plateau[num_depart][trait] :=  plateau_actuel[num_depart,trait] ;
//          Arbre_jeu^.pos.plateau[num_arrive][trait] :=  plateau_actuel[num_arrive,trait] ;

          // promotion  ; prise en passant


          if (plateau_actuel[num_arrive,0] = A_pion) then
          begin
             if num_arrive = En_passant then
             begin
               if num_depart < num_arrive then
               begin
//                  capture := A_pion; // capture le pion noir ! (pour le score )
                  plateau_actuel[num_arrive-8,A_piece]:= A_zero ;
                  plateau_actuel[num_arrive-8,camp]:= 0 ;
//                  arrivee   := num_arrive -8;

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
//                  capture := A_pion; // capture le pion blanc! (pour le score )
                  plateau_actuel[num_arrive+8,0]:= A_zero ;
                  plateau_actuel[num_arrive+8,1]:= 0 ;
//                  arrivee   := num_arrive +8;
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
//               Ajuste_panel_promotion();  // pour affiche des pi่ces couleur
//               Promotion_panel.Visible := True ;  // identique เ la promotion
//               promotion :=plateau_actuel[num_arrive,0];

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

end;

procedure ordi_joue ;
         // variable temporaire pour ajustement du score       // variable temporaire pour ajustement du score
var

      coup_joue : integer ;
      parcourt_liste : Parbre_coups ;
      eval_max : integer ;
      test : integer ;
begin



            parcourt_liste := arbre_pos_actuelle ;
            eval_max := 0 ;
            test := 0 ;
            while parcourt_liste <> NIL do
            begin
              if parcourt_liste^.eval > eval_max then
              begin
                eval_max := parcourt_liste^.eval ;
                arbre_pos_actuelle := parcourt_liste ;
              end;
              parcourt_liste := parcourt_liste^.coup_suivant ;
            end;

//            showmessage('j''ai fait ' + inttostr(test) + ' tests');
            Ia_play( arbre_pos_actuelle^.coup);// jouer.pas

            blanc_au_trait := not blanc_au_trait ;

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
          if parcourt_liste = NIL then
//            showmessage('crash')
          else
            arbre_pos_actuelle := parcourt_liste ;


            if blanc_au_trait
              then Lister_Essais(arbre_pos_actuelle^.pos_obtenu,blanc,Alliees[0],Alliees[1])
              else Lister_Essais(arbre_pos_actuelle^.pos_obtenu,noir,Alliees[1],Alliees[0]) ;
            arbre_pos_actuelle := arbre_pos_actuelle^.pos_obtenu ;


end;


end.

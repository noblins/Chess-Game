unit Ia_versions;

interface

uses
  UnitBtbInit
  ,Cible_piece
  ,UtilAffiche ;
//  ,joue ;


procedure Ia_play2(coup , prof : integer) ;
//function evaluation() : integer ;
//procedure joue_coup(coup : integer );
//procedure MaJ_calcul_BtB_piece ;

implementation

procedure Ia_play2(coup , prof : integer) ;

var
  parcourt_liste : Parbre_coups ;
  eval_max : integer ;
begin
//  plateau_calcul := plateau_actuel ;
//  calcul_BtB_fou_dame[0]  := BtB_fou_dame[0] ;
//  calcul_BtB_tour_dame[0] := BtB_tour_dame[0];
//  calcul_BtB_cavalier[0]  := BtB_cavalier[0];
//  calcul_BtB_roi[0]       := BtB_roi[0] ;
//  calcul_BtB_pions[0]     := BtB_pions[0]   ;
//  calcul_pos_roiB := pos_roiB ;
//
//  calcul_pos_roiN  := pos_roiN ;
//  calcul_BtB_fou_dame[1]  :=  BtB_fou_dame[1];
//  calcul_BtB_tour_dame[1] := BtB_tour_dame[1];
//  calcul_BtB_cavalier[1] := BtB_cavalier[1];
//  calcul_BtB_roi[1]       := BtB_roi[1] ;
//  calcul_BtB_pions[1]     := BtB_pions[1]   ;


//  arbre_pos_actuelle

  // joue_coup

  //evalue position

  //dejoue coup




// regarde ensuite quelle est la meilleur avaluation
  parcourt_liste := arbre_pos_actuelle ;
  eval_max := parcourt_liste^.eval ;
  while parcourt_liste <> NIL do
  begin
    if parcourt_liste^.eval < eval_max then
    begin
       eval_max := parcourt_liste^.eval ;
       arbre_pos_actuelle := parcourt_liste ;
    end;
    parcourt_liste := parcourt_liste^.coup_suivant ;
  end;
end;
      {
function evaluation() : integer ;

var
  bitboard_compteur : TBitboard ;

begin
  result := 0 ;
  bitboard_compteur := calcul_BtB_fou_dame[0]  and calcul_BtB_tour_dame[0] ;
 // dames

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result +  Dame_valeur ;
  end;

  bitboard_compteur := calcul_BtB_fou_dame[1]  and calcul_BtB_tour_dame[1] ;

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result -  Dame_valeur ;
  end;

  // tours

    bitboard_compteur :=  calcul_BtB_tour_dame[0] and ( not calcul_BtB_fou_dame[0] ) ;

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result +  tour_valeur ;
  end;

  bitboard_compteur := calcul_BtB_tour_dame[1] and ( not calcul_BtB_fou_dame[1] ) ;

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result - tour_valeur ;
  end;

  // fous

  bitboard_compteur := calcul_BtB_fou_dame[0]  and (not  calcul_BtB_tour_dame[0]) ;

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result +  fou_valeur ;
  end;

    bitboard_compteur := calcul_BtB_fou_dame[1]  and ( not calcul_BtB_tour_dame[1] );

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result -  fou_valeur ;
  end;

  // pions

  bitboard_compteur := calcul_BtB_pions[0] ;

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result +  pion_valeur ;
  end;

    bitboard_compteur := calcul_BtB_pions[1] ;

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result -  pion_valeur ;
  end;

  //cavaliers

  bitboard_compteur := calcul_BtB_cavalier[0] ;

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result +  cavalier_valeur ;
  end;

    bitboard_compteur := calcul_BtB_cavalier[1] ;

  while bitboard_compteur > 0 do
  begin
    bitboard_compteur := bitboard_compteur xor LSB(bitboard_compteur) ;
    result := result -  cavalier_valeur ;
  end;


end;

procedure joue_coup(coup : integer );

begin

end;

procedure MaJ_calcul_BtB_piece ;

begin
   if plateau_calcul[num_depart,1] = 1 then
   begin
     Calcul_Alliees[0] := (Calcul_Alliees[0] xor Btb[num_depart]) or Btb[num_arrive] ;
     Calcul_Alliees[1] := Calcul_Alliees[1] and ( (Btb_64) xor Btb[num_arrive] );
     Calcul_toutes :=  Calcul_Alliees[0] or Calcul_Alliees[1] ;


     case plateau_calcul[num_depart,0] of
          fou  : Calcul_BtB_fou_dame[0] := (Calcul_BtB_fou_dame[0] xor Btb[num_depart])
                                      or Calcul_Btb[num_arrive];
          tour : Calcul_BtB_tour_dame[0]:= (Calcul_BtB_tour_dame[0] xor Btb[num_depart])
                                     or Calcul_Btb[num_arrive];
          dame : begin
                    Calcul_BtB_fou_dame[0] := (Calcul_BtB_fou_dame[0] xor Btb[num_depart])
                                        or Btb[num_arrive] ;
                    Calcul_BtB_tour_dame[0]:= (Calcul_BtB_tour_dame[0] xor Btb[num_depart])
                                         or Btb[num_arrive] ;
                  end;
          cavalier : Calcul_BtB_cavalier[0] :=  (Calcul_BtB_cavalier[0] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
          roi :  begin Calcul_BtB_roi[0] :=  (BtB_roi[0] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
                         Calcul_pos_roiB := num_arrive ;

                 end;
          pion :   Calcul_BtB_pions[0] :=  (Calcul_BtB_pions[0] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
     end;

     Calcul_BtB_fou_dame[1] := Calcul_BtB_fou_dame[1] and ((Btb_64) xor Btb[num_arrive]) ;
     Calcul_BtB_tour_dame[1]:= Calcul_BtB_tour_dame[1] and ((Btb_64) xor Btb[num_arrive]);
     Calcul_BtB_cavalier[1] := Calcul_BtB_cavalier[1] and ((Btb_64) xor Btb[num_arrive]) ;
     Calcul_BtB_roi[1] := Calcul_BtB_roi[1] and ((Btb_64) xor Btb[num_arrive]) ;
     Calcul_BtB_pions[1] := Calcul_BtB_pions[1] and ((Btb_64) xor Btb[num_arrive]) ;

   end
   else
   begin

     Calcul_Alliees[1] := (Calcul_Alliees[1] xor Btb[num_depart]) or Btb[num_arrive] ;
     Calcul_Alliees[0] := Calcul_Alliees[0] and ( (Btb_64) xor Btb[num_arrive] ) ;
     Calcul_toutes :=  Calcul_Alliees[0] or Alliees[1] ;


     case plateau_calcul[num_depart,0] of
          fou  : Calcul_BtB_fou_dame[1] := (Calcul_BtB_fou_dame[1] xor Btb[num_depart])
                                      or Btb[num_arrive];
          tour : Calcul_BtB_tour_dame[1]:= (Calcul_BtB_tour_dame[1] xor Btb[num_depart])
                                     or Btb[num_arrive];
          dame : begin
                    Calcul_BtB_fou_dame[1] := (Calcul_BtB_fou_dame[1] xor Btb[num_depart])
                                        or Btb[num_arrive] ;
                    Calcul_BtB_tour_dame[1]:= (Calcul_BtB_tour_dame[1] xor Btb[num_depart])
                                         or Btb[num_arrive] ;
                  end;
          cavalier : Calcul_BtB_cavalier[1] :=  (Calcul_BtB_cavalier[1] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
          roi :begin  Calcul_BtB_roi[1] :=  (Calcul_BtB_roi[1] xor Btb[num_depart])
                                          or Btb[num_arrive] ;
                                          Calcul_pos_roiN := num_arrive ;
//                      if Aide_dep then showmessage(inttostr(Pos_roiN));
              end;
          pion :   Calcul_BtB_pions[1] :=  (Calcul_BtB_pions[1] xor Btb[num_depart])
                                           or Btb[num_arrive] ;
     end;

     Calcul_BtB_fou_dame[0] := Calcul_BtB_fou_dame[0] and ((Btb_64) xor Btb[num_arrive]) ;
     Calcul_BtB_tour_dame[0]:= Calcul_BtB_tour_dame[0] and ((Btb_64) xor Btb[num_arrive]);
     Calcul_BtB_cavalier[0] := Calcul_BtB_cavalier[0] and ((Btb_64) xor Btb[num_arrive]) ;
     Calcul_BtB_roi[0] := Calcul_BtB_roi[0] and ((Btb_64) xor Btb[num_arrive]) ;
     Calcul_BtB_pions[0] := Calcul_BtB_pions[0] and ((Btb_64) xor Btb[num_arrive]) ;

   end;



end;   }

end.

unit joue;
// les fonctions de mise à jour des bitboards, pour parcourir l’arbre
// déplace la pièce qui se déplace, ote les éventuelles captures,et/ prise
// en passant ( epsq[]  en_passant_square[] ), ou promotion….
//  teste la règle des 50 coups sans prise ni mouvement de pion…
//  en effet , en cas d’utilisation des bitboards, il faut modifier chaque
//  bitboard concerné par la manoeuvre

interface


uses chess;

Procedure Jouer(v_arbre: Array of P_arbre; mi_coup, v_coup, wtm : integer);
Procedure JouerCoupRacine( v_arbre : Array of P_arbre; v_coup, wtm : integer);

implementation
Procedure Jouer( v_arbre : Array of P_arbre; mi_coup, v_coup, v_bat : integer);
Var
  v_piece : integer ;      // la piece selectionnée pour le déplacement
  v_dep : integer ;
  v_arr : integer ;
  v_capture : integer ;
  v_promotion : integer ;
  v_nat : integer ;        // bat: blanc au trait,  nat noir au trait
  v_Cpiece : integer ;     // la piece capturéée lors du déplacement
  coup_bit : Tbitboard ;   // le bit de la case/piece sélectionnée


Begin
V_nat := flip(v_bat);

//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
// 1) mise à jour de quelques données de base pour tous les coups
// avant de nous occuper du cas propre de cette pièce
// nous devons sauvegarder la position courante dans la liste de
//  répétition du camp au trait ( hashing) avant que le coup soit
//  effectif sur l’échiquier. Il faut aussi mettre à jour le compteur
// le la rêgle des 50 coups, qui doit être initialisé en cas de capture
// ou de déplacement de pion.
// le le drapeau de prise en passant existe au demi coup precedent
// nous devons également l’utiliser pour générer la liste des
//  déplacements à ce demi coup. + mise à jour de la hash table du fait
// que cette opportunité de prise en passant disparaît au demi coup
//  suivant
//______________________________________________________________________



v_arbre^.liste_repet[v_bat][inc(Repetition(v_bat))] := clef_hashage;
v_arbre^.position[mi_coup+1] := v_arbre^.position[mi_coup] ;
v_arbre^.save_hash_key[mi_coup+1]:= clef_hashage;
v_arbre^.sauve_clef_hash_pion [mi_coup+1]:=clef_hash_pion;


  if (EnPassant(mi_coup + 1)) then
     begin
          HashEP(EnPassant(mi_coup + 1), clef_hashage);
          EnPassant(mi_coup + 1) := 0;
     end ;
 Inc( Regle50coups(mi_coup + 1));


//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
//  maintenant les actions sont communes à l’ensemble des pièces
//  comme la  mise à jour des bitboards et le Hashache
//______________________________________________________________________


  V_piece     := Piece(v_coup);
  dep         := dep(v_coup);
  arr         := arr(v_coup);
  v_capture   := Capture(v_coup);
  v_promotion := Promotion(v_coup);
  coup_bit    := SetMask(dep) or  SetMask(arr);
  v_Cpiece    := PieceIci(arr);
  ClearSet(coup_bit , Pieces(v_bat, v_piece)); // on ote le bit correspondant
  ClearSet(coup_bit , Occupee(v_bat));         // à la piece dans qqs bitboards
  Hash(v_bat, v_piece, dep);                   // maj depart / hashage
  Hash(v_bat, v_piece, arr);                   // maj arrivee/ hashage
  PieceIci(dep) := 0;                          // on vide la case de depart
  PieceIci(arr) := pieces[v_bat][v_piece];     // la case d’aarivee reçois la piece







//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
//  maintenant, effectuer les  actions specifique à cette pièce
//  en appliquant les routines appropriées
//______________________________________________________________________

Case v_piece of

//¨  le pion  ¨¨ ( + prise en passant + promotion ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

   Pion :
     Begin
           HashP(v_bat, dep);
           HashP(v_bat, arr);
           If((capture =1) and not v_Cpiece ) then
              Begin
                 Clear(arr + EnPassant[v_bat],pion(v_nat));
                 Clear(arr + EnPassant[v_bat],occupee(v_nat));
                 Hash(v_nat,pion,arr+ EnPassant[v_bat]) ;
                 HashP(v_nat,arr+ EnPassant[v_bat]) ;
                 piecIci(arr + EnPassant[v_bat]) :=0 ;
                 materiel := materiel - PieceValeur(v_nat, pion);
                 dec(TotalPieces(v_nat, pion));            // diminuer d’un pion :nat
                 dec(ToutesPieces);                        // diminuer d’une piece
                 capture := 0 ;
              End;
           If(promotion) then
             Begin
                 dec(TotalPieces(v_bat, pion));           // diminuer d’un pion :bat
                 materiel := materiel - PieceValeur(v_bat, pion);
                 Clear(arr , pion(v_bat));
                 HashP(v_bat, dep);
                 HashP(v_bat, arr);
                 HashP(v_bat,promotion, arr);
                 pieceIci(arr):=pieces[v_bat][promotion] ;
                 TotalPieces(v_bat, accupee):= TotalPieces(v_bat, accupee)
                                                    +  p_vals[promotion];
                 materiel := materiel - PieceValeur(v_nat, promotion);
                 _Set(arr, Pieces(v_bat, promotion));
                 Case promotion of
                      Cavalier : ;
                      Fou      : _Set(arr, FouDame);
                      Tour     : _Set(arr, TourDame);
                      Dame     : Begin
                                   _Set(arr, FouDame);
                                   _Set(arr, TourDame);
                                 End;
                      End;
             End
            else  if ((Abs(arr - dep) = 16) and (mask_eptest[arr] and Piom(v_nat)))
                    Then begin
                           EnPassant(mi_coup + 1) = arr + epsq[v_bat];
                           HashEP(arr + epsq[v_bat], clef_hashage);
                      End;
          Regle50coups(mi_coup + 1):=0;

     End; // case : pion

//¨  le cavalier  ¨¨¨¨ rien à faire ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
   Cavalier : ;


//¨  le fou  ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

   Fou      : begin
                    Clear(dep , FouDame);
                    _Set(arr, FouDame);
                 End; // case : fou


//¨  la tour ( et le roque )  ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨

   Tour     : begin
                  Clear(dep , TourDame);
                  _Set(arr, TourDame);
                  If (Roque(mi_coup + 1 ,v_bat) >0 ) then
                    if ((dep = tour_A[v_bat]) and (Roque(mi_coup+ 1, v_bat) and 2))
                       then begin
                            Roque(mi_coup + 1 ,v_bat) := Roque(mi_coup + 1 ,v_bat) and 1;
                            HashRoque(1, clef_hashage) := HashRoque(1, clef_hashage, v_bat);
                         End
                   Else
                     if ((dep = Tour_H[v_bat]) and (Roque(mi_coup + 1, v_bat)and 1))
                       then begin
                         Roque(mi_coup + 1 ,v_bat) := Roque(mi_coup + 1 ,v_bat) and 2;
                         HashRoque(0, clef_hashage) := HashRoque(0, clef_hashage,v_bat);
                       End

                 End; // case : tour

//¨  la Dame  ¨¨¨¨¨¨  = fou + tour ( sans roque ) ¨¨¨¨¨¨¨¨¨¨¨¨¨
   Dame     : begin
                  Clear(dep , FouDame);
                  _Set(arr, FouDame);
                  Clear(dep , TourDame);
                  _Set(arr, TourDame);
                 End; // case : dame

//¨  Le roi ( et le roque )  ¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
   Roi     : begin
                   RoiSiege(v_bat) = arr;
                  If (Roque(mi_coup + 1 ,v_bat) >0 ) then
                   begin
                    If (Roque(mi_coup + 1 ,v_bat) and 2 ) then
                        HashRoque(1, clef_hashage,v_bat);
                    If (Roque(mi_coup + 1 ,v_bat) and 1 ) then
                        HashRoque(0, clef_hashage,v_bat);

                   if (abs(arr - dep) = 2) then
                      begin
                         Roque(mi_coup + 1 ,v_bat) := -mi_coup;
                         v_piece = Tour;
                         if (arr = tour_G[wtm, v_bat]) then
                             begin
                               dep = tour_H[v_bat];
                               arr = tour_F[v_bat];
                             end
                         else begin
                               dep = tour_A[v_bat];
                               arr = tour_D[v_bat];
                             end;
                      end;
                  Clear(dep , TouDame);
                  _Set(arr, TourDame);
                  Coup_bit = SetMask(dep) or SetMask(arr);
                  ClearSet(Coup_bit, Tour(v_bat));
                  ClearSet(Coup_bit, Occupee(v_bat));
                  Hash(v_bat,tour,dep) ;
                  Hash(v_bat,tour,arr) ;
                  pieceIci(dep):=0 ;
                  pieceIci(arr):=pieces[v_bat][tour] ;

                   end
                else Roque(mi_coup + 1 ,v_bat) := 0;
             // roque

       End; // case : roi

   End;      // case v_piece of

//¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨
//  si ce coup est une capture, nous devaons tenir compte des modifications
//  liées à la disparition de cette pièce de l’échiquier
//______________________________________________________________________

  if (capture) then
   begin
     Regle50coups(mi_coup + 1):=0;
     toutesPieces := toutesPieces-1;
     if (promotion) then v_piece := promotion;

    Hash(v_bat, capture, arr);
    Hash(v_nat, capture, dep);

    Clear(arr, Pieces(v_nat, capture));
    Clear(arr, Occupee(v_nat));

    Materiel := Materiel - PieceValues(v_nat, capture);
    Dec(TotalPieces(v_bat, capture));

    if (capture <> pion) then
      TotalPieces(v_nat, occupee) := TotalPieces(v_nat, occupee)-  p_vals[capture];

   case (capture)  of
     pion     :  HashP(v_nat, arr);
     cavalier :;
     fou      : if ((v_piece <> fou)  and (v_piece <> dame)) then
                   Clear(arr, FousDames);
     Tour     : begin
                  if ((v_piece <> tour) and (v_piece <> dame)) then
                        Clear(arr, Toursdames);

                  if (Croque(mi_coup+ 1, v_nat) > 0) then
                    if ((arr = tour_A[v_nat]) and (Roque(mi_coup + 1, v_nat) and 2))
                       then begin
                              Roque(mi_coup+ 1,v_nat):= Roque(mi_coup+ 1,v_nat) and 1;
                             HashRoque(1, clef_hashage,v_bat);
                          End
                   else if ((arr = Tour_H[v_nat])and (Roque(mi_coup+1, v_nat) and 1))
                       then begin
                             Roque(mi_coup+ 1,v_nat):= Roque(mi_coup+ 1,v_nat) and 2;
                             HashRoque(0, clef_hashage,v_bat);
                          End;
                 end;
     Dame    :  if (v_piece <> dame) then
        begin
          if (v_piece <> fou) then Clear(arr, FousDames);
          if (v_piece <> tour) then Clear(arr, ToursDames);
        end;

    roi     :  ; // on ne capture pas de le roi !!


     end; // case (capture)  of


end;  // capture

End;// ( procédure jouer )



//******************************************************************************
//                                                                             *
//   MakeMoveRoot() is used to make a v_coup at the root of the game tree,       *
//   before any searching is done.  It uses MakeMove() to execute the v_coup,    *
//   but then copies the resulting position back to position[0], the actual    *
//   board position.  It handles the special-case of the draw-by-repetition    *
//   rule by clearing the repetition list when a non-reversible v_coup is made,  *
//   since no repetitions are possible once such a v_coup is played.             *
//                                                                             *
//*****************************************************************************/
Procedure JouerCoupRacine( v_arbre : Array of P_arbre; v_coup, wtm : integer);

var
   i: integer;
begin
//***********************************************************
//                                                          *
//   First, make the v_coup and replace position[0] with the  *
//   new position.                                          *
//                                                          *
//**********************************************************/

  MakeMove(v_arbre, 0, v_coup, wtm);

//***********************************************************
//                                                          *
//   Now, if this is a non-reversible v_coup, reset the       *
//   repetition list pointer to start the count over.       *
//                                                          *
//   One odd action is to note if the castle status is      *
//   currently negative, which indicates that that side     *
//   castled during the previous search.  We simply set the *
//   castle status for that side to zero and we are done.   *
//                                                          *
//**********************************************************/

  if (Rule50Moves(1) = 0) then
    for i := 0 to 1 do v_arbre^.rep_index[i] := 0;
    Castle(1, black) := Max(0, Castle(1, black));
    Castle(1, white) := Max(0, Castle(1, white));
    v_arbre^.position[0] := v_arbre^.position[1];
end;


end.

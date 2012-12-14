unit Attaque;

interface

// uses   chess,data ;


  function AttacksTo(v_arbre : Array of P_arbre; siege: integer): TBITBOARD;
  function Attacks(v_arbre : Array of P_arbre; siege,camp: integer): integer;

implementation


// last modified 01/14/09 */

//*******************************************************************************
//  AttacksTo() produit un BITBOARD représentant les cases attaquant alors
//  cette case <siege>.  trivial à détecter pour les pieces non glissantes
//  mais pour les pieces glissant on utilise une astuce bitboard .  The idea is
// l'idée est de calculer les cases attaquées par une dame située en <siege>
// et de regarder quelle est la dernière case attaquée dans chaque direction
// pour determiner si c'est une pièce glissante qui se dirige dans cette direction
// on termine avec un simple 'OU' de toutes ces attaques conjuguées
//******************************************************************************/

function AttacksTo(v_arbre : Array of P_arbre; siege: integer): TBITBOARD;
begin
  result :=
     ((pawn_attacks[white][siege] and Pawns(black)) or
     (pawn_attacks[black][siege] and Pawns(white)) or
     (knight_attacks[siege] and (Knights(black) or
      Knights(white))) or (AttacksBishop(siege,OccupiedSquares) and
      BishopsQueens) or (AttacksRook(siege, OccupiedSquares) and
      RooksQueens) or (king_attacks[siege] and (Kings(black) or Kings(white))));
end;


//*******************************************************************************
//   Attacks() determine si <camp> attaque <siege>.
//  l'algorithme est simple et basé sur celui d'AttacksTo()
//  mais plutot que de retourner une carte des cases attaquant <siege>
// il retourne  "1" aussitôt qu'il detecte une attaque de <siege>.                               *
//**************************************************************************** */

function Attacks(v_arbre : Array of P_arbre; siege,camp: integer): integer;
begin
  if (pawn_attacks[Flip(camp)][siege] and Pawns(camp))
     then  result := 1
     else if (knight_attacks[siege] and Knights(camp))
            then  result := 1
            else if (AttacksBishop(siege, OccupiedSquares) and BishopsQueens and
                     Occupied(camp))
                   then  result := 1
                   else if (AttacksRook(siege, OccupiedSquares) and
                            RooksQueens and Occupied(camp))
                            then  result := 1
                            else if (king_attacks[siege] and Kings(camp))
                                  then result := 1
                                  else result := 0;
end;

end.

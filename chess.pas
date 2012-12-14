unit chess;

interface

uses
  UnitBtbinit ;

{
 *******************************************************************************
 *                                                                             *
 *   configuration information:  the following variables need to be set to     *
 *   indicate the machine configuration/capabilities.                          *
 *                                                                             *
 *   HAS_64BITS:  define this for a machine that has true 64-bit hardware      *
 *   including leading-zero hardware, population count, etc.  ie, a Cray-like  *
 *   machine.                                                                  *
 *                                                                             *
 *   UNIX:  define this if the program is being run on a unix-based system,    *
 *   which causes the executable to use unix-specific runtime utilities.       *
 *                                                                             *
 *   CPUS=N:  this sets up data structures to the appropriate size to support  *
 *   up to N simultaneous search engines.  note that you can set this to a     *
 *   value larger than the max processors you currently have, because the mt=n *
 *   command (added to the command line or your crafty.rc/.craftyrc file) will *
 *   control how many threads are actually spawned.                            *
 *                                                                             *
 *******************************************************************************

#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#if !defined(TYPES_INCLUDED)
#  include "lock.h"
#  if defined (_MSC_VER) && (_MSC_VER >= 1300) && \
    (!defined(_M_IX86) || (_MSC_VER >= 1400))
#    define RESTRICT __restrict
#  else
#    define RESTRICT
#  endif
#  if !defined(CPUS)
#    define CPUS 1
#  endif
#  if defined(NT_i386)
#    include <windows.h>
#    include <process.h>
#  endif
#  define TYPES_INCLUDED
#  define CDECL
#  define STDCALL
/* Provide reasonable defaults for UNIX systems. */
#  undef  HAS_64BITS    /* machine has 64-bit integers / operators    */
#  define UNIX  /* system is unix-based                       */
/* Architecture-specific definitions */
#  if defined(AIX)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    define UNIX        /* system is unix-based                       */
#  endif
#  if defined(AMIGA)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    undef  UNIX        /* system is unix-based                       */
#  endif
#  if defined(FreeBSD)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    define UNIX        /* system is unix-based                       */
#  endif
#  if defined(HP)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    define UNIX        /* system is unix-based                       */
#  endif
#  if defined(LINUX)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    define UNIX        /* system is unix-based                       */
#  endif
#  if defined(MIPS)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    define UNIX        /* system is unix-based                       */
#  endif
#  if defined(NetBSD)
#    if defined(__alpha__)
#      define HAS_64BITS        /* machine has 64-bit integers / operators   */
#      define UNIX      /* system is unix-based                      */
#    else
#      undef  HAS_64BITS        /* machine has 64-bit integers / operators   */
#      define UNIX      /* system is unix-based                      */
#    endif
#  endif
#  if defined(NEXT)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    define UNIX        /* system is unix-based                       */
#  endif
#  if defined(NT_i386)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    undef  UNIX        /* system is unix-based                       */
#    undef  STDCALL
#    define STDCALL __stdcall
#    ifdef  VC_INLINE32
#      undef  CDECL
#      define CDECL __cdecl
#    endif
#  endif
#  if defined(OS2)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    define UNIX        /* system is unix-based                       */
#  endif
#  if defined(SGI)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    define UNIX        /* system is unix-based                       */
#  endif
#  if defined(SUN)
#    undef  HAS_64BITS  /* machine has 64-bit integers / operators    */
#    define UNIX        /* system is unix-based                       */
#  endif
#  if !defined(BOOKDIR)
#    define     BOOKDIR        "."
#  endif
#  if !defined(LOGDIR)
#    define      LOGDIR        "."
#  endif
#  if !defined(TBDIR)
#    define       TBDIR     "./TB"
#  endif
#  if !defined(RCDIR)
#    define       RCDIR        "."
#  endif
#  if !defined(NOEGTB)
#    define     EGTB_CACHE_DEFAULT               1024*1024
#  endif
 }
 const
CPUS = 2 ;
MAXPLY              = 65 ;
MAX_TC_NODES       = 3000000 ;
MAX_BLOCKS_PER_CPU  = 64;
MAX_BLOCKS          = MAX_BLOCKS_PER_CPU* CPUS ;
BOOK_CLUSTER_SIZE   = 8000 ;
BOOK_POSITION_SIZE  = 16;
MERGE_BLOCK         = 1000;
SORT_BLOCK          = 4000000 ;
LEARN_INTERVAL      = 10 ;
LEARN_WINDOW_LB     =-40;
LEARN_WINDOW_UB     =+40;
LEARN_COUNTER_BAD   =-80;
LEARN_COUNTER_GOOD  =+100 ;
MATE                = 32768;
PAWN_VALUE          = 100 ;
KNIGHT_VALUE        = 325 ;
BISHOP_VALUE        = 325 ;
ROOK_VALUE          = 500 ;
QUEEN_VALUE         = 970 ;
KING_VALUE          = 40000 ;
EG_MAT              = 14 ;
MAX_DRAFT           = 256 ;



{
#  if defined(HAS_64BITS)
typedef unsigned long BITBOARD;
#  elif defined(NT_i386)
typedef unsigned __int64 BITBOARD;
#  else
typedef unsigned long long BITBOARD;
#  endif
#  if defined(NT_i386)
#    define BMF   "%I64u"
#    define BMF6  "%6I64u"
#    define BMF10 "%10I64u"
#  else
#    define BMF   "%llu"
#    define BMF6  "%6llu"
#    define BMF10 "%10llu"
#  endif
#  if defined(UNIX) & (CPUS > 1)
#    include <pthread.h>
#  endif
#  include <time.h>
#  if !defined(CLOCKS_PER_SEC)
#    define CLOCKS_PER_SEC 1000000
#  endif
  }


type

  Uchar = char ;
  BITBOARD = TBitboard ;
  Uint = integer ;
  Pchar = ^char ;
  tableau_char = array of char ;

 squares = (
  A1, B1, C1, D1, E1, F1, G1, H1,
  A2, B2, C2, D2, E2, F2, G2, H2,
  A3, B3, C3, D3, E3, F3, G3, H3,
  A4, B4, C4, D4, E4, F4, G4, H4,
  A5, B5, C5, D5, E5, F5, G5, H5,
  A6, B6, C6, D6, E6, F6, G6, H6,
  A7, B7, C7, D7, E7, F7, G7, H7,
  A8, B8, C8, D8, E8, F8, G8, H8,
  BAD_SQUARE);

 files = ( FILEA, FILEB, FILEC, FILED, FILEE, FILEF, FILEG, FILEH ) ;
 ranks = ( RANK1, RANK2, RANK3, RANK4, RANK5, RANK6, RANK7, RANK8 ) ;
 PIECE = ( empty = 0, occupied = 0, pawn = 1, knight = 2, bishop = 3,
  rook = 4, queen = 5, king = 6) ;

COLOR = ( black = 0, white = 1 ) ;
PHASE = ( mg = 0, eg = 1 ) ;
PIECE_V = ( empty_v = 0, pawn_v = 1, knight_v = 3,
  bishop_v = 3, rook_v = 5, queen_v = 9, king_v = 99) ;

EXTENSIONS = ( no_extension = 0, check_extension = 1,
  one_reply_extension = 2, mate_extension = 4) ;

SEARCH_TYPE = ( think = 1, puzzle = 2, book = 3, _annotate = 4 ) ;
PLAYING_MODE = ( normal_mode, tournament_mode ) ;
PLAYER = ( crafty, opponent ) ;
LEARNING_MODE = ( book_learning = 1, result_learning = 2) ;

SEARCH_POSITION = record
   enpassant_target : Uchar;
   castle           : Array[0..1] of  char;
   rule_50_moves    : Uchar;
end;

 KILLER  = record
     move1:integer ;
     move2:integer ;
 end;

 BB_PIECES  = record
      pieces: Array [0..6] of BITBOARD;
 end;


  POSITION  = record
       color               : Array[0..1] of BB_PIECES;
       rooks_queens        : BITBOARD;
       bishops_queens      : BITBOARD;
       hash_key            : BITBOARD;
       pawn_hash_key       : BITBOARD;
       material_evaluation : integer;
       kingsq              : Array[0..1] of integer;
       board               : Array[0..63] of Uchar;
       pieces              : Array[0..1]  of Array[0..6]  of Uchar;
       pawns               : Array[0..1]  of Uchar;
       total_all_pieces    : Uchar;
   end;

 HASH_ENTRY  = record
   word1:BITBOARD;
   word2:BITBOARD;
 end;

 PAWN_HASH_ENTRY  = record
         key                 : BITBOARD;
         score_mg, score_eg  : integer;
         defects_k           : Array[0..1]  of Uchar;
         defects_e           : Array[0..1]  of Uchar;
         defects_d           : Array[0..1]  of Uchar;
         defects_q           : Array[0..1]  of Uchar;
         all                 : Array[0..1]  of Uchar;
         passed              : Array[0..1]  of Uchar;
         candidates          : Array[0..1]  of Uchar;
         open_files          : Uchar;
         filler              : Uchar;
     end;


    PXOR = record
       entry:  Array[0..3] of BITBOARD;
    end;


   PATH = record
       path: Array[0..MAXPLY-1] of integer;
       pathh:Uchar;
       pathl:Uchar;
       pathd:Uchar;
   end;

   NEXT_MOVE = record
           phase:integer;
           remaining:integer;
           last:^integer;
       end;

   ROOT_MOVE = record
      nodes  : BITBOARD;
      move   : integer;
      {
         x..xx xxxx xxx1 = failed low once
         x..xx xxxx xx1x = failed low twice
         x..xx xxxx x1xx = failed low three times
         x..xx xxxx 1xxx = failed high once
         x..xx xxx1 xxxx = failed high twice
         x..xx xx1x xxxx = failed high three times
         x..xx x1xx xxxx = don't search in parallel
         x..xx 1xxx xxxx = do not reduce this move
         x..x1 xxxx xxxx = move has been searched
       }
      status : Uint;
         end;




{ if defined(NT_i386)
#    pragma pack(4)
#  endif  }

   BOOK_POSITION = record
       position    : BITBOARD;
      tatus_played : Uint;
      learn        : real ;
   end;

{#  if defined(NT_i386)
#    pragma pack()
#  endif  }

   BB_POSITION = record
      position     : Array[0..7] of Uchar;
      status       : Uchar;
      percent_play : Uchar;
   end;

   personality_term = record
       description : ^char ;
       _type       : integer ;
       size        : integer ;
       value       : ^integer;
   end;


  //type  TREE = tree;
  P_arbre = ^tree;

  tree = record
   pos                : POSITION;
   save_hash_key      : Array[0..MAXPLY + 1] of BITBOARD;
   rep_list           : Array[0..1] of Array[0..127] of BITBOARD;
   all_pawns          : BITBOARD;
   nodes_searched     : BITBOARD;
   save_pawn_hash_key : Array[0..MAXPLY + 1] of BITBOARD;
   pawn_score         : PAWN_HASH_ENTRY ;
   position           : Array[0..MAXPLY + 1] of SEARCH_POSITION;
   next_status        : Array[0..MAXPLY - 1] of NEXT_MOVE;
   pv                 : Array[0..MAXPLY - 1] of PATH;
   rep_index          : Array[0..1] of integer;
   curmv              : Array[0..MAXPLY - 1] of integer;
   hash_move          : Array[0..MAXPLY - 1] of integer;
   last               : Array[0..MAXPLY-1] of  integer;
   fail_high                     : Uint;
   fail_high_first               : Uint;
   evaluations                   : Uint;
   transposition_probes          : Uint;
   transposition_hits            : Uint;
   egtb_probes                   : Uint;
   egtb_probes_successful        : Uint;
   check_extensions_done         : Uint;
   qsearch_check_extensions_done : Uint;
   reductions_attempted          : Uint;
   reductions_done               : Uint;
   killers            : Array[0..MAXPLY - 1] of KILLER;
   move_list          : Array[0..5119] of integer;
   sort_value         : Array[0..255] of integer;
   inchk              : Array[0..MAXPLY - 1] of char;
   phase              : Array[0..MAXPLY - 1] of char;
   search_value       : integer;
   tropism            : Array[0..1] of integer;
   dangerous          : Array[0..1] of integer;
   score_mg, score_eg : integer;
   root_move          : integer;
{#  if (CPUS > 1)
   lock:lock_t;
#  endif  }
   thread_id            :  integer ;//long;
   stop                 : integer;
   root_move_text       : Array[0..15] of char;
   remaining_moves_text : Array[0..15] of char;
   siblings, parent     : Array[0..CPUS-1] of P_arbre;
   nprocs               : integer;
   alpha                : integer;
   beta                 : integer;
   value                : integer;
   wtm                  : integer;
   depth                : integer;
   ply                  : integer;
   cutmove              : integer;
   used                 : integer;
  end;





{
   DO NOT modify these.  these are constants, used in multiple modules.
   modification may corrupt the search in any number of ways, all bad.
}
{
WORTHLESS               =  0;
LOWER                   =  1;
UPPER                   =  2;
EXACT                   =  3;
AVOID_NULL_MOVE         =  4;
EXACTEGTB               =  5;
NULL_MOVE               =  0;
DO_NULL                 =  1;
NO_NULL                 =  0;
NONE                    =  0;
EVALUATION              = -1;
HASH_MOVE               =  1;
GENERATE_CAPTURE_MOVES  =  2;
CAPTURE_MOVES           =  3;
KILLER_MOVE_1           =  4;
KILLER_MOVE_2           =  5;
GENERATE_ALL_MOVES      =  6;
SORT_ALL_MOVES          =  7;
REMAINING_MOVES         =  8;
ROOT_MOVES              =  9;    }

{ if defined(VC_INLINE32)
#    include "vcinline.h"
#  else
#    if !defined(INLINE64) && !defined(INLINE32)
int CDECL PopCnt(BITBOARD);
int CDECL MSB(BITBOARD);
int CDECL LSB(BITBOARD);
#    endif
#  endif  }

procedure Analyze();
procedure Annotate();
procedure AnnotateHeaderHTML( ch :Array of char;fl : Array of FILE );
procedure AnnotateFooterHTML(fl : Array of FILE);
procedure AnnotatePositionHTML(v_arbre:Array of TREE ; int : integer; fl :Array of  FILE);
//function *AnnotateVtoNAG(int, int, int, int): char;
type AnnotateVtoNAG = function(var1,var2,var3,var4: integer): tableau_char;

{
  proposition de traduction possible :

 1° definir le type de fonction ou de procedure a transmettre.

Type
  Tfonction = procedure(var: TvarA) of TvarA;

 2° Utiliser le type de function que vous avez créé comme paramètre.

MaFonction( uneFonction: Tfonction);
begin
  Code ...
  uneFonction(nil); // déclenche la fonction auxilliaire
  Code ...
end;

ici:
type AnnotateVtoNAG = function(var1,var2,var3,var4: integer): of char;
}

//  http://fbeaulieu.developpez.com/guide/?page=page_11

procedure AnnotateHeaderTeX(ch:Array of char ;fl:Array of  FILE);
procedure AnnotateFooterTeX(fl: Array of FILE);
procedure AnnotatePositionTeX(v_arbre : Array of TREE; int:integer; fl:Array of  FILE);
function Attacks(v_arbre : Array of TREE; int1,int2:integer):integer;
function AttacksTo(v_arbre : Array of TREE; int:integer):BITBOARD;
procedure Bench();
//function Book(v_arbre : Array of TREE; int1,int2:integer):integer;
procedure BookClusterIn(fl:Array of FILE; int: integer; bk:Array of BOOK_POSITION);
procedure BookClusterOut(fl:Array of FILE; int: integer; bk:Array of BOOK_POSITION);
function BookIn32(ch: Pchar):integer;
function BookIn32f(ch: Pchar):real;
function BookIn64(ch: Pchar):BITBOARD;
function BookMask(ch: Pchar):integer;
// function *BookOut32( val:int):Uchar;
type   BookOut32 = function( val:integer): tableau_char;
//function *BookOut32f( val:float): Uchar;
 type   BookOut32f = function ( val:real): tableau_char;
//function *BookOut64( val:BITBOARD): Uchar;
 type   BookOut64 = function( val:TBITBOARD): tableau_char;

function BookPonderMove(P_arbre (* RESTRICT *) : integer):integer ;
//function BookUp(P_arbre (* RESTRICT *), int, Pchar);
//function BookSort(BB_POSITION(pointer), int, int);


implementation

end.

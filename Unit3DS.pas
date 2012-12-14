// =============================================================================
// =============================================================================
{                               Auteur : Vincent Nguyen aka Pheteon
         _.-'~~~~~~`-._         E-mail : nguyen_v@epita.fr
        /      ||      \        Sites web : http://www.pheteon.tk
       /       ||       \                   http://www.lifeinside.info
      |        ||        |      Version : 1.0
      | _______||_______ |      Date : 22 Janvier 2006
      |/ ----- \/ ----- \|      Description : Cette unité permet de charger et
     /  (     )  (     )  \                   dessiner différents modèles .3ds
    / \  ----- () -----  / \    Utilisation : C'est très simple, il y a deux
   /   \      /||\      /   \                 fonctions à utiliser
  /     \    /||||\    /     \                  M.load('repertoire/model.3ds');
 /       \  /||||||\  /       \                     pour charger le modèle
/_        \o========o/        _\                M.draw();
  `--...__|`-._  _.-'|__...--'                      pour dessiner
          |    `'    |                        Avec M étant une variable de type
                                                file3ds                        }
// =============================================================================

unit Unit3DS;

interface

uses
  windows,
  classes,
  opengl,
  sysutils;

const
     ID_HEADER = $4D4D;              // Bloc primaire
     ID_OBJECTINFO = $3D3D;          // Début des params
     ID_MESH_VERSION = $3D3E;
     ID_OBJECT = $4000;
     ID_OBJECT_MESH = $4100;
     ID_OBJECT_VERTICES = $4110;
     ID_OBJECT_FACES = $4120;
     ID_OBJECT_UV = $4140;
     ID_KEYFRAME = $B000;
     ID_MESH_MATRIX = $4160;      

type
     vertex=array[0..2] of single;
     faceData=array[0..3] of word;

     coord=record
            U,V:single;
           end;

     PFile3DS=^File3DS;
     PChunk=^Chunk;
     Chunk = object
              ID:word;
              length:longword;
              start:longword; // Début d'un chunk
              subChunks:array of PChunk;
              parent:PChunk;
              data:PFile3DS;  // Pointeur vers la structure du fichier .3ds
              function newSubchunk:integer;
              procedure read(var F:tfileStream);
              destructor destroy;
             end;



     File3ds = object
                x,y,z:extended;
                dir:integer;
                numVerts:cardinal;
                numFaces:cardinal;
                numCoords:cardinal;
                V:array of vertex;
                N:array of vertex;
                F:array of faceData;
                U:array of coord;
                C:PChunk;
                lastVCount:cardinal;
                lastFCount,lastUCount:cardinal;
                procedure draw;
                procedure calcNormals;
                function load3ds(filename:string):boolean;
                procedure clear;
               end;

var
    log:array of string;

implementation

procedure SkipChunk(var F:tfilestream;len:longword);
begin
  F.seek(len-6, soFromCurrent);
end;


destructor Chunk.destroy;
Var
  i:integer;
begin
   for i:=0 to high(subChunks) do
    if subChunks[i]<>nil then
    begin
      subChunks[i]^.destroy;
      dispose(subChunks[i]);
    end;
end;

function Chunk.newSubchunk:integer;
begin
  setLength(subChunks,high(subChunks)+2);
  new(subchunks[high(subChunks)]);
  subChunks[high(subChunks)].data:=self.data;
  result:=high(subChunks);
end;

procedure Chunk.read(var F:tfileStream);
var
  S:String;
  Ch:char;
  i:integer;
//  version:cardinal;
  temp:single;
  W:word;
begin
     start:=F.position;
     F.readBuffer(ID,2);
     F.readBuffer(length,4);

     case ID of
       ID_OBJECT_VERTICES:
       begin
          data^.lastVCount:=data^.numVerts;
          f.readBuffer(W,2);
          data^.numVerts:=W+data^.lastVCount;
          setLength(data^.V,data^.numVerts);
          for i:=data^.lastVCount to data^.numVerts-1 do
          begin
            F.readBuffer(Data^.V[I],sizeOf(vertex));
            // on échange y et z pour coller au système d'OpenGL... plus facile ^^
            temp:=data^.V[i][1];
            data^.V[i][1]:=data^.V[i][2];
            data^.V[i][2]:=-temp;
          end;
       end;

       ID_OBJECT_UV:
       begin
          data^.lastUCount:=data^.numCoords;
          f.readBuffer(W,2);
          data^.numCoords:=W+data^.lastUCount;
          setLength(data^.U,data^.numCoords);
          for i:=data^.lastUcount to data^.numCoords-1 do
            F.readBuffer(data^.U[i], sizeOf(coord));
       end;

       ID_OBJECT_FACES:
       begin
          data^.lastFCount:=data^.numFaces;
          f.readBuffer(W,2);
          data^.numFaces:=W+data^.lastFCount;

          setLength(data^.F,data^.numFaces);
          for i:=data^.lastFcount to data^.numFaces-1 do
          begin
            F.readBuffer(data^.F[i], sizeOf(faceData));
            // On balance tous les objets dans un tableau de vertices
            data^.F[i][0]:=data^.F[i][0]+data^.lastVCount;
            data^.F[i][1]:=data^.F[i][1]+data^.lastVCount;
            data^.F[i][2]:=data^.F[i][2]+data^.lastVCount;
          end;
       end;

       ID_OBJECTINFO,ID_HEADER,ID_OBJECT_MESH:
         begin
           repeat
             subChunks[newSubChunk]^.read(F);
           until F.position>=(start+length);
         end;

       ID_OBJECT:
         begin
           repeat
            F.readBuffer(Ch,1);
            S:=S+Ch;
           until Ch = #0;
           repeat
             subChunks[newSubChunk]^.read(F);
           until F.position>=(start+length);
         end;
       else
         skipChunk(F,length);
     end;
end;

procedure File3dS.Draw;
var
  i,j:integer;
  hasCoords:boolean;
begin
  if numCoords>0 then
    hasCoords:=true
  else
    hasCoords:=False;
  for i:=0 to NumFaces-1 do
  begin
   glBegin(GL_TRIANGLES);
    for j:=0 to 2 do
    begin
       if hasCoords then glTexCoord2f(U[F[i][j]].U,U[F[i][j]].V);
       glNormal3fv(@N[F[i][j]]);
       glVertex3fv(@V[F[i][j]]);
    end;
   glEnd;
  end;
end;


function getNormal(V1,V2,V3: array of single):vertex;
var
  res:vertex;
  l:single;
begin
  V2[0]:=-V2[0];
  V2[1]:=-V2[1];
  V2[2]:=-V2[2];

  V1[0]:=V1[0]+V2[0];
  V1[1]:=V1[1]+V2[1];
  V1[2]:=V1[2]+V2[2];

  V3[0]:=V3[0]+V2[0];
  V3[1]:=V3[1]+V2[1];
  V3[2]:=V3[2]+V2[2];

  res[0]:=v1[1]*v3[2]-v3[1]*v1[2];
  res[1]:=v3[0]*v1[2]-v1[0]*v3[2];
  res[2]:=v1[0]*v3[1]-v3[0]*v1[1];

  L:=sqrt(Res[0]*Res[0]+Res[1]*Res[1]+Res[2]*Res[2]);
  if l<>0 then
  begin
      res[0]:=res[0]/l;
      res[1]:=res[1]/l;
      res[2]:=res[2]/l;
  end;
  result:=res;
end;


procedure file3DS.CalcNormals;
var
   i,j:integer;
   Normal:vertex;
   L:single;
   faceNormals:array of vertex;
   count:integer;
begin
   setlength(N,high(V)+1);
   setlength(faceNormals,high(F)+1);

   for i:=0 to numFaces-1 do
   begin
     normal:=getNormal(V[F[i][0]],V[F[i][1]],V[F[i][2]]);
     faceNormals[i]:=normal;
   end;

   for i:=0 to NumVerts-1 do
   begin
      zeroMemory(@normal,sizeof(normal));
      Count:=0;
      for j:=0 to numFaces-1 do
      begin
          if (F[j][0]=i) or (F[j][1]=i) or (F[j][2]=i) then
          begin
             normal[0]:=normal[0]+faceNormals[J][0];
             normal[1]:=normal[1]+faceNormals[J][1];
             normal[2]:=normal[2]+faceNormals[J][2];
             inc(count);
          end;
      end;

      N[I][0]:=normal[0]/count;
      N[I][1]:=normal[1]/count;
      N[I][2]:=normal[2]/count;

      L:=sqrt(N[I][0]*N[I][0]+N[I][1]*N[I][1]+N[I][2]*N[I][2]);
      if L<>0 then
      begin
          N[I][0]:=N[I][0]/l;
          N[I][1]:=N[I][1]/l;
          N[I][2]:=N[I][2]/l;
      end;
   end;
end;

procedure file3ds.Clear;
begin
    setlength(V,0);
    setlength(F,0);
    setlength(U,0);
    setLength(N,0);
    numVerts:=0;
    numFaces:=0;
    numCoords:=0;
end;

function file3ds.Load3DS(Filename:string):boolean;
var
  Fl: tfilestream;
begin
   try
    result:=true;
    clear;
    Fl:=tfilestream.Create(Filename,fmOpenRead);
    New(C);
    C^.data := @self;
    C^.read(Fl);
   except
    result:=false;
    Messagebox(0, pchar('Erreur durant le chargement de '+filename), 'Desolé, envoyez-moi votre problème : nguyen_v@epita.fr', MB_OK or MB_ICONERROR);
   end;
    Fl.free;
    C^.destroy;
    dispose(C);
    calcNormals;
end;
end.

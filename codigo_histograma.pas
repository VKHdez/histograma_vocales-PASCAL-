unit codigo_histograma;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Menus;

type

  TCoordenada = record
      x,y : integer;
  end;

  TBarra = record
  		coordenadas : array [1..2] of TCoordenada;
        color  : TColor;
        titulo : string;
  end;

  { Tformulario_histograma }

  Tformulario_histograma = class(TForm)
    cuadro_abrir: TOpenDialog;
    grafico: TImage;
    menu_principal: TMainMenu;
    menu_archivo: TMenuItem;
    opciones: TMenuItem;
    colores: TMenuItem;
    abrir_archivo: TMenuItem;
    guardar_captura: TMenuItem;
    procedure abrir_archivoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public
  		procedure crearHistograma(arreglo_barra: array of TBarra);
        function crearBarra(identifier : integer): TBarra;
        procedure asignarCoordenadas(arreglo_barra: array of TBarra);
  		procedure pintarBarras( barra :TBarra );

  end;

var
  formulario_histograma: Tformulario_histograma;

  contador_a, contador_e, contador_i, contador_o, contador_u :integer;
  cantidad_barras : integer; // varibales para contar las barras en total del histograna;
  total : integer; // total de valores maximos
  Archivo : Textfile; // variable para el menu_archivo de texto

  arreglo_barra : array [0..4] of TBarra;
implementation

{$R *.frm}

{ Tformulario_histograma }

procedure Tformulario_histograma.FormCreate(Sender: TObject);
begin
     // Inicializacion de las variables
     cantidad_barras := 5;

     // Asignacion de tamaños
     formulario_histograma.Width  := 500;
     formulario_histograma.Height := 400;

     grafico.setbounds(0,0,0,0);
     grafico.Height:=400;
     grafico.Width :=500;
     grafico.Canvas.Rectangle(0,0,grafico.Width, grafico.Height);
end;

procedure Tformulario_histograma.abrir_archivoClick(Sender: TObject);
var
   arreglo_mayor : array [0..4] of integer;
   j : integer;
   caracter : char;
begin
     if cuadro_abrir.Execute then begin
        AssignFile(Archivo, cuadro_abrir.FileName);

        {$I-}
             Reset(Archivo);
        {$I+}

        if IOResult = 0 then begin
           while not EOF(Archivo) do begin
                 read(Archivo, caracter);
                 case caracter of
                      'a':contador_a := contador_a+1;
                      'e':contador_e := contador_e+1;
                      'i':contador_i := contador_i+1;
                      'o':contador_o := contador_o+1;
                      'u':contador_u := contador_u+1;
                 end;
           end;

           arreglo_mayor[0] := contador_a;
           arreglo_mayor[1] := contador_e;
           arreglo_mayor[2] := contador_i;
           arreglo_mayor[3] := contador_o;
           arreglo_mayor[4] := contador_u;

           for j := 0 to 3 do begin
           	   if arreglo_mayor[j] > arreglo_mayor[j+1] then begin
                  total := arreglo_mayor[j];
               end else begin
                   total := arreglo_mayor[j+1];
               end;
           end;

           crearHistograma(arreglo_barra);

           closefile(Archivo);
        end;

     end;

end;

{
    Procedimiento para graficar
}

procedure Tformulario_histograma.crearHistograma(arreglo_barra: array of TBarra);
var
   arreglo_aux : array [0..4] of TBarra;
   i : integer;

begin;
	  // Llamar a la funcion de crearBarras

      for  i := 0 to cantidad_barras-1 do begin
      	  arreglo_aux[i] := crearBarra(i);
      end;

      // llamar a la funcion de asignarCoordenadas
      asignarCoordenadas(arreglo_aux);
end;

{
 	procedimiento para crear las Barras
}
function Tformulario_histograma.crearBarra(identifier : integer) : TBarra;
var
   barraAux : TBarra;
   auxtitulo : string;
   auxcolor : TColor;
begin

	 case identifier of
      	  0 : begin
          	auxtitulo := 'A';
          	auxcolor  := ClPurple;
          	end;
          1 : begin
          	auxtitulo := 'E';
            auxcolor  := Clred;
            end;
          2 : begin
            auxtitulo := 'I';
            auxcolor  := Clgray;
            end;
          3 : begin
            auxtitulo := 'O';
            auxcolor := Clblue;
            end;
          4 :begin
            auxtitulo := 'U';
            auxcolor  := Clgreen;
            end;
     end;

	 barraAux.color  := auxcolor;
     barraAux.titulo := auxtitulo;

     crearBarra := barraAux;

end;

{
 	funcion para asignar coordenadas a las barras
}
procedure Tformulario_histograma.asignarCoordenadas(arreglo_barra: array of TBarra);
var
   i : integer; // variable para recorrer el arreglo de barras

   ancho_barra, espacio, altura, contador : integer;

   x,y,x2,y2 : integer;
begin

     altura := grafico.Height-125;
     ancho_barra := 40;
     espacio     := 25;

     x := 100;

     x2 := 100+ancho_barra;
     y2 := 350;

     grafico.canvas.Brush.Color := Clsilver;
	 grafico.canvas.Rectangle(0,0,grafico.Width, grafico.Height);

     for i :=0 to cantidad_barras-1 do begin

     	 case arreglo_barra[i].titulo of
         	  'A' : contador := contador_a;
              'E' : contador := contador_e;
              'I' : contador := contador_i;
              'O' : contador := contador_o;
              'U' : contador := contador_u;
         end;

         if total = 0 then begin
     	 	 y := 0;
         end else begin
         	 y := round(altura * ( 1-(contador/total) ));
         end;

     	 // calcular el alto de la barra
         arreglo_barra[i].coordenadas[1].x :=x;
 		 arreglo_barra[i].coordenadas[1].y :=y+75;

         // calcular la posicion mas baja de la barra
         arreglo_barra[i].coordenadas[2].x :=x2;
 		 arreglo_barra[i].coordenadas[2].y :=y2;

         x  := x + ancho_barra + espacio;
         x2 := x2 + espacio + ancho_barra;

         // llamar a la funcion de pintado
      	 pintarBarras( arreglo_barra[i] );
     end;
end;

{
 	procedimiento para pintar las Barras
}
procedure Tformulario_histograma.pintarBarras( barra : TBarra );
var
   x1,y1,x2,y2 : integer;
   cantidad : string;
begin
     // Asigna las coordenadas correspondientes para mayor facilidad en operacion
     x1 := barra.coordenadas[1].x;
     y1 := barra.coordenadas[1].y;
     x2 := barra.coordenadas[2].x;
     y2 := barra.coordenadas[2].y;

     // Coloca el color del pincle y lapiz del color de la barra
     grafico.canvas.Brush.Color := barra.color;
     grafico.canvas.Pen.Color   := barra.color;

     // grafica la barra
     grafico.Canvas.Rectangle( x2,y2,x1,y1 );

     // selecciona que contador colocar sobre que barra
     case barra.titulo of
      	  'A' : begin
          	cantidad := inttostr(contador_a);
          	end;
          'E': begin
          	cantidad := inttostr(contador_e);
            end;
          'I' : begin
            cantidad := inttostr(contador_i);
            end;
          'O' : begin
            cantidad := inttostr(contador_o);
            end;
          'U' :begin
            cantidad := inttostr(contador_u);
            end
     end;

     // Coloca los colores iguales al fondo
     grafico.canvas.Brush.Color := Clsilver;
     grafico.canvas.Pen.Color   := Clsilver;

     // Coloca el titulo y la cantidad correspondiente
     grafico.Canvas.TextOut(x1+15,y2-300, cantidad );
     grafico.Canvas.TextOut(x1+15,y2+5, barra.titulo );
end;

end.


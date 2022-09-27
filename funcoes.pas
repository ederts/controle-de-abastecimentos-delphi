unit funcoes;

interface

uses
  Vcl.Forms, Winapi.Windows, System.IniFiles, System.SysUtils, DBGrids,
  Vcl.Grids, Vcl.Graphics, System.StrUtils, Vcl.StdCtrls;

Type
  TUsuario = record
    ID: Integer;
    NomeOperador: String;
    Suporte : Boolean;
    inativo : Boolean;
  end;

var
  VBaseDados: String = 'POSTO.FDB';
  VNomeServidor: String = '';
  VCaminhoBase: String = '';
  VVendorLib: String = 'FBClient.DLL';
  vPOSTO_INI: TIniFile;
  VUsuario: TUsuario;

function Pergunta(Texto: string; Default: Char): Boolean;
Function IIF(Condicao: Boolean; Resposta1, Resposta2: Variant): Variant;
function AllTrim(Dados: string): string;
function Empty(Dados: string): Boolean;
procedure carregaDadosConexao;
procedure Mensagem(Texto: string);
function BoolTo(xVal: Boolean): String;
Function ToBool(xVal: String): Boolean;
function TestaValor(Sender: TObject; Key: Char): Char;
procedure PintaGrid(Sender: TObject; const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
function StringToFloat(NumString: String): Double;
function FloatToString(const AValue: Double; SeparadorDecimal: Char;
  const AFormat: String): String;
function EstaVazio(const AValue: String): Boolean;
function CountStr(const AString, SubStr : String ) : Integer ;

implementation

function Pergunta(Texto: string; Default: Char): Boolean;
begin
  Result := false;
  If Application.MessageBox(PChar(Texto), 'Confirma', MB_YESNO + MB_ICONQUESTION
    + IIF(Default = 'S', MB_DEFBUTTON1, MB_DEFBUTTON2)) = IDYES then
    Result := True;
end;

procedure PintaGrid(Sender: TObject; const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
Begin
  If (Sender as DBGrids.TDBGrid).SelectedRows.CurrentRowSelected then
  Begin
      (Sender as DBGrids.TDBGrid).Canvas.Brush.Color := clNavy;
      (Sender as DBGrids.TDBGrid).Canvas.Font.Color := clWhite;
      (Sender as DBGrids.TDBGrid).DefaultDrawDataCell(RECT,column.Field, State);
    exit;
  End;
  If (State <> [gdSelected]) and (State <> [gdSelected, gdFocused]) then
  begin
    with (Sender as DBGrids.TDBGrid).Canvas.Brush do
      if ((Sender as DBGrids.TDBGrid).DataSource.DataSet.RecNo mod 2) = 0 then
        Color := clWindow
      else
      begin
         Color := $00E2EFE2; // Verde claro;
      end;

    (Sender as DBGrids.TDBGrid).Canvas.FillRect(Rect);
    (Sender as DBGrids.TDBGrid).DefaultDrawDataCell(RECT,column.Field, State);
  end
  else
    Begin
      (Sender as DBGrids.TDBGrid).Canvas.Brush.Color := clNavy;
      (Sender as DBGrids.TDBGrid).Canvas.Font.Color := clWhite;
      (Sender as DBGrids.TDBGrid).Canvas.FillRect(Rect);
      (Sender as DBGrids.TDBGrid).DefaultDrawDataCell(RECT,column.Field, State);
    End;

End;

Function IIF(Condicao: Boolean; Resposta1, Resposta2: Variant): Variant;
Begin
  If Condicao then
    Result := Resposta1
  Else
    Result := Resposta2;
End;

procedure carregaDadosConexao;
Var
  INI: TIniFile;
Begin
  INI := TIniFile.Create(ExtractFilePath(Application.ExeName) +'POSTO.INI');

  VBaseDados := INI.ReadString('GERAL', 'Nome Arquivo', 'POSTO.FDB');
  VCaminhoBase := INI.ReadString('GERAL', 'BaseDados', '');
  VVendorLib := 'FBClient.dll';
  VNomeServidor := INI.ReadString('GERAL', 'Servidor', '');

  FreeAndNil(INI);

End;

function Empty(Dados: string): Boolean;
begin
  if (Length(Trim(Dados)) = 0) or (AllTrim(Dados) = '/  /') or
    (AllTrim(Dados) = '00:00:00') then
    Empty := True
  else
    Empty := false;
end;

function AllTrim(Dados: string): string;
begin
  Result := TrimLeft(TrimRight(Dados));
end;

procedure Mensagem(Texto: string);
begin
  Application.MessageBox(PChar(Texto), PChar('Mensagem'),MB_OK+MB_ICONINFORMATION);
end;

function BoolTo(xVal: Boolean): String;
Begin
  Result := 'F';
  if xVal then
    Result := 'T';
End;

Function ToBool(xVal: String): Boolean;
Begin
  Result := false;
  If (UpperCase(xVal) = 'T') or (xVal = '1') then
    Result := True;
End;

function TestaValor(Sender: TObject; Key: Char): Char;
begin

  Result := Key;

  If Key = #8 then
    exit; // BackSpace

  if Key in ['.', ','] then
    Key := FormatSettings.DecimalSeparator;

  if (Key = FormatSettings.DecimalSeparator) then
    if (Pos(FormatSettings.DECIMALSEPARATOR, (Sender as TCustomEdit).Text) > 0) then
    begin
      Key := #0;
      Result := Key;
      exit;
    end
    else
    begin
      Result := Key;
      exit;
    end;

  If (Key = '-') AND Empty((Sender as TCustomEdit).Text) then
    if (Pos('-', (Sender as TEdit).Text) > 0) then
    Begin
      Key := #0;
      Result := Key;
      exit;
    End
    else
    begin
      (Sender as TEdit).Text := '-' + (Sender as TEdit).Text;
      Key := #0;
      Result := Key;
      exit;
    end;

  if not(Key in ['0' .. '9']) then
  begin
    Key := #0;
    Result := Key;
    exit;
  end;

end;

{-----------------------------------------------------------------------------
  Retorna quantas ocorrencias de <SubStr> existem em <AString>
 ---------------------------------------------------------------------------- }
function CountStr(const AString, SubStr : String ) : Integer ;
Var ini : Integer ;
begin
  result := 0 ;
  if SubStr = '' then exit ;

  ini := Pos( SubStr, AString ) ;
  while ini > 0 do
  begin
     Result := Result + 1 ;
     ini    := PosEx( SubStr, AString, ini + 1 ) ;
  end ;
end ;

function EstaVazio(const AValue: String): Boolean;
begin
  Result := (AValue = '');
end;

{-----------------------------------------------------------------------------
  Converte um Double para string, semelhante a FloatToStr(), porém
  garante que não haverá separador de Milhar e o Separador Decimal será igual a
  "SeparadorDecimal" ( o default é .(ponto))
 ---------------------------------------------------------------------------- }
function FloatToString(const AValue: Double; SeparadorDecimal: Char;
  const AFormat: String): String;
var
  DS, TS: Char;
begin
  if EstaVazio(AFormat) then
    Result := FloatToStr(AValue)
  else
    Result := FormatFloat(AFormat, AValue);

  DS := FormatSettings.DecimalSeparator;
  TS := FormatSettings.ThousandSeparator;

  // Removendo Separador de milhar //
  if ( DS <> TS ) then
    Result := StringReplace(Result, TS, '', [rfReplaceAll]);

  // Verificando se precisa mudar Separador decimal //
  if DS <> SeparadorDecimal then
    Result := StringReplace(Result, DS, SeparadorDecimal, [rfReplaceAll]);
end;

{-----------------------------------------------------------------------------
  Converte uma <NumString> para Double, semelhante ao StrToFloat, mas
  verifica se a virgula é '.' ou ',' efetuando a conversão se necessário
  Se não for possivel converter, dispara Exception
 ---------------------------------------------------------------------------- }
function StringToFloat(NumString: String): Double;
var
  DS: Char;
begin
  NumString := Trim(NumString);

  DS := FormatSettings.DecimalSeparator;

  if DS <> '.' then
    NumString := StringReplace(NumString, '.', DS, [rfReplaceAll]);

  if DS <> ',' then
    NumString := StringReplace(NumString, ',', DS, [rfReplaceAll]);

  while CountStr(NumString, DS) > 1 do
    NumString := StringReplace(NumString, DS, '', []);

  Result := StrToFloat(NumString);
end;



//Esta seção é executado no momento que a aplicação é iniciada
initialization

//ReportMemoryLeaksOnShutdown := DebugHook <> 0;
Application.HintHidePause := 5000;

FormatSettings.DECIMALSEPARATOR := ',';
FormatSettings.THOUSANDSEPARATOR := '.';
FormatSettings.DateSeparator := '/';
FormatSettings.ShortDateFormat := 'dd/MM/yyyy';


Finalization

FreeAndNil(vPOSTO_INI);

end.

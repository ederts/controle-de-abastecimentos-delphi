unit uCOMBUSTIVELDAO;

interface

uses uCOMBUSTIVEL, uBASEDAO, System.Generics.Collections, FireDAC.Comp.Client,
  funcoes, System.SysUtils;

type
  TCombustivelDAO = class(TBaseDAO)
  private
    FListaCombustiveis: TObjectList<TCombustivel>;
    procedure PreencherColecao(Ds: TFDQuery);
  public
    constructor Create;
    destructor Destroy; override;
    function Inserir(pCombustivel: TCombustivel): Boolean;
    function Deletar(pCombustivel: TCombustivel): Boolean;
    function DeletarID(xID: integer): Boolean;
    function Alterar(pCombustivel: TCombustivel): Boolean;
    function Listar(pConteudo: String;pCampo: String): TObjectList<TCombustivel>;
    function BuscarPorID(pConteudo: Integer): TCombustivel;
  end;

implementation

{ TCombustivelDAO }


function TCombustivelDAO.Alterar(pCombustivel: TCombustivel): Boolean;
var
  Sql: String;
begin
  Sql := ' UPDATE combustiveis ' +
         '    SET descricao = ' + QuotedStr(pCombustivel.Descricao) + ', ' +
         '        precolitro  = ' + FloatToString(pCombustivel.PrecoLitro,'.','') + ', '+
         '        inativo   = ' + QuotedStr(BoolTo(pCombustivel.Inativo)) +
         '  WHERE ID = ' + IntToStr(pCombustivel.ID);
  Result := ExecutarComando(Sql) > 0;

end;

function TCombustivelDAO.BuscarPorID(pConteudo: Integer): TCombustivel;
var
  Sql: String;
  Combustivel : TCombustivel;
begin
  Result := Nil;
  Sql := ' SELECT * FROM combustiveis c ';
  Sql := Sql + ' WHERE c.id = ' + pConteudo.ToString;
  Sql := Sql + ' ORDER BY c.id ';

  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    Combustivel := TCombustivel.Create;
    Combustivel.ID     := FQry.FieldByName('ID').AsInteger;
    Combustivel.Descricao   := FQry.FieldByName('descricao').AsString;
    Combustivel.PrecoLitro  := FQry.FieldByName('precolitro').AsFloat;
    Combustivel.Inativo:= ToBool(FQry.FieldByName('inativo').AsString);
    Result := Combustivel;
  end;

end;

constructor TCombustivelDAO.Create;
begin
  inherited;
  FListaCombustiveis := TObjectList<TCombustivel>.Create;

end;

function TCombustivelDAO.Deletar(pCombustivel: TCombustivel): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM combustiveis '+
         '  WHERE ID = ' + IntToStr(pCombustivel.ID) ;
  Result := ExecutarComando(Sql) > 0;

end;

function TCombustivelDAO.DeletarID(xID: integer): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM combustiveis '+
         '  WHERE ID = ' + xID.ToString ;
  Result := ExecutarComando(Sql) > 0;

end;

destructor TCombustivelDAO.Destroy;
begin
  try
    inherited;
    if Assigned(FListaCombustiveis) then
      FreeAndNil(FListaCombustiveis);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

function TCombustivelDAO.Inserir(pCombustivel: TCombustivel): Boolean;
var
  Sql: String;
begin
  Sql := ' INSERT INTO combustiveis (descricao, precolitro, inativo) '+
         ' VALUES ( '+
                   QuotedStr(pCombustivel.Descricao)    + ',' +
                   FloatToString(pCombustivel.PrecoLitro,'.','') + ',' +
                   QuotedStr(BoolTo(pCombustivel.Inativo)) +
                   ')';
  Result := ExecutarComando(Sql) > 0;

end;

function TCombustivelDAO.Listar(pConteudo,
  pCampo: String): TObjectList<TCombustivel>;
var
  Sql: String;
begin
  Result := Nil;
  Sql := ' SELECT c.id, c.descricao, '+
         '        c.precolitro, c.inativo '+
         '   FROM combustiveis c ';
   if pConteudo <> '' then
   begin
     if pCampo='descrição' then
        begin
          Sql := Sql + '  WHERE c.descricao like ' + QuotedStr('%'+pConteudo+'%');
        end
     else if pCampo='inativo' then
        begin
          if pConteudo='F' then
             Sql := Sql + '  WHERE c.inativo    = ' + QuotedStr(pConteudo)
          else
             Sql := Sql + '  WHERE c.inativo    = ' + QuotedStr(pConteudo) + ' or c.inativo is null';
        end
     else if pCampo='id' then
       begin
          Sql := Sql + '  WHERE c.id    = ' + QuotedStr(pConteudo);
       end;
   end;

   if pCampo='descrição' then
     Sql := Sql + '  ORDER BY c.descricao '
   else
     Sql := Sql + '  ORDER BY c.id ';
  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    PreencherColecao(FQry);
    Result := FListaCombustiveis;
  end;

end;

procedure TCombustivelDAO.PreencherColecao(Ds: TFDQuery);
var
  I: Integer;
begin
  I := 0;
  FListaCombustiveis.Clear;
  while not Ds.eof do
  begin
    FListaCombustiveis.Add(TCombustivel.Create);
    FListaCombustiveis[I].ID          := Ds.FieldByName('ID').AsInteger;
    FListaCombustiveis[I].descricao   := Ds.FieldByName('descricao').AsString;
    FListaCombustiveis[I].precolitro  := Ds.FieldByName('precolitro').AsFloat;
    FListaCombustiveis[I].Inativo     := ToBool(Ds.FieldByName('inativo').AsString);
    Ds.Next;
    I := I + 1;
  end;

end;

end.

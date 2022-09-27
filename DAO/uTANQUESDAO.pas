unit uTANQUESDAO;

interface

uses uBASEDAO, System.Generics.Collections, FireDAC.Comp.Client,
  System.SysUtils, funcoes, uTANQUES, uCOMBUSTIVELDAO, uCOMBUSTIVEL;

type
  TTanqueDAO = class(TBaseDAO)
  private
    FListaTanques: TObjectList<TTanque>;
    procedure PreencherColecao(Ds: TFDQuery);
  public
    constructor Create;
    destructor Destroy; override;
    function Inserir(pTanque: TTanque): Boolean;
    function Deletar(pTanque: TTanque): Boolean;
    function DeletarID(xID: integer): Boolean;
    function Alterar(pTanque: TTanque): Boolean;
    function Listar(pConteudo: String;pCampo: String): TObjectList<TTanque>;
    function BuscarPorID(pTanque: Integer): TTanque;
  end;



implementation

{ TTanqueDAO }

function TTanqueDAO.Alterar(pTanque: TTanque): Boolean;
var
  Sql: String;
begin
  Sql := ' UPDATE tanques     ' +
         '    SET descricao     = ' + QuotedStr(pTanque.Descricao)    + ', ' +
         '        combustivel  = ' + IntToStr(pTanque.Combustivel.ID) + ', '+
         '        inativo   = ' + QuotedStr(BoolTo(pTanque.Inativo)) +
         '  WHERE ID = ' + IntToStr(pTanque.ID);
  Result := ExecutarComando(Sql) > 0;

end;

function TTanqueDAO.BuscarPorID(pTanque: Integer): TTanque;
var
  Sql: String;
  Tanque : TTanque;
  Combustivel : TCombustivel;
  CombustivelDAO : TCombustivelDAO;
begin
  Result := Nil;
  Sql := ' SELECT * FROM tanques t ';
  Sql := Sql + ' WHERE t.id = ' + pTanque.ToString;
  Sql := Sql + ' ORDER BY t.id ';

  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    try
      Tanque := TTanque.Create;
      Combustivel := TCombustivel.Create;
      CombustivelDAO := TCombustivelDAO.Create;
      Combustivel := CombustivelDAO.BuscarPorID(FQry.FieldByName('combustivel').AsInteger);
      Tanque.ID     := FQry.FieldByName('ID').AsInteger;
      Tanque.Descricao   := FQry.FieldByName('descricao').AsString;
      Tanque.Combustivel  := Combustivel;
      Tanque.Inativo:= ToBool(FQry.FieldByName('inativo').AsString);
      Result := Tanque;
    finally
      //Combustivel.Free;
      CombustivelDAO.Free;
    end;
  end;

end;

constructor TTanqueDAO.Create;
begin
  inherited;
  FListaTanques := TObjectList<TTanque>.Create;

end;

function TTanqueDAO.Deletar(pTanque: TTanque): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM tanques '+
         '  WHERE ID = ' + IntToStr(pTanque.ID) ;
  Result := ExecutarComando(Sql) > 0;

end;

function TTanqueDAO.DeletarID(xID: integer): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM tanques '+
         '  WHERE ID = ' + xID.ToString ;
  Result := ExecutarComando(Sql) > 0;

end;

destructor TTanqueDAO.Destroy;
begin
  inherited;
  try
    inherited;
    if Assigned(FListaTanques) then
      FreeAndNil(FListaTanques);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

function TTanqueDAO.Inserir(pTanque: TTanque): Boolean;
var
  Sql: String;
begin
  try
    Sql := ' INSERT INTO tanques (descricao, combustivel, inativo) '+
           ' VALUES ( '+
                     QuotedStr(pTanque.Descricao)    + ',' +
                     IntToStr(pTanque.Combustivel.ID) + ',' +
                     QuotedStr(BoolTo(pTanque.Inativo)) +
                     ')';
    Result := ExecutarComando(Sql) > 0;
  except
    Result := False;
  end;

end;

function TTanqueDAO.Listar(pConteudo,
  pCampo: String): TObjectList<TTanque>;
var
  Sql: String;
begin
  Result := Nil;
  Sql := ' SELECT t.id, t.descricao, '+
         '        t.combustivel, t.inativo '+
         '   FROM tanques t ';
   if pConteudo <> '' then
   begin
     if pCampo='descrição' then
        begin
          Sql := Sql + '  WHERE t.descricao like ' + QuotedStr('%'+pConteudo+'%');
        end
     else if pCampo='inativo' then
        begin
          if pConteudo='F' then
             Sql := Sql + '  WHERE t.inativo    = ' + QuotedStr(pConteudo)
          else
             Sql := Sql + '  WHERE t.inativo    = ' + QuotedStr(pConteudo) + ' or t.inativo is null';
        end
     else if pCampo='id' then
       begin
          Sql := Sql + '  WHERE t.id    = ' + QuotedStr(pConteudo);
       end;
   end;


   Sql := Sql + '  ORDER BY t.id     ';
  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    PreencherColecao(FQry);
    Result := FListaTanques;
  end;

end;

procedure TTanqueDAO.PreencherColecao(Ds: TFDQuery);
var
  I: Integer;
  Combustivel : TCombustivel;
  CombustivelDAO : TCombustivelDAO;
begin
  I := 0;
  FListaTanques.Clear;
  while not Ds.eof do
  begin
    try
      FListaTanques.Add(TTanque.Create);
      FListaTanques[I].ID          := Ds.FieldByName('ID').AsInteger;
      FListaTanques[I].descricao   := Ds.FieldByName('descricao').AsString;
      Combustivel := TCombustivel.Create;
      CombustivelDAO := TCombustivelDAO.Create;
      Combustivel := CombustivelDAO.BuscarPorID(Ds.FieldByName('combustivel').AsInteger);
      FListaTanques[I].Combustivel  := Combustivel;
      FListaTanques[I].Inativo     := ToBool(Ds.FieldByName('inativo').AsString);
      Ds.Next;
      I := I + 1;
    finally
      //Combustivel.Free;
      CombustivelDAO.Free;
    end;
  end;

end;

end.

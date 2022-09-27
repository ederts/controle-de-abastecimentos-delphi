unit uBOMBADAO;

interface

uses uBASEDAO, System.Generics.Collections, FireDAC.Comp.Client,
  System.SysUtils, funcoes, uBOMBA, uTANQUES, uTANQUESDAO;

type
  TBombaDAO = class(TBaseDAO)
  private
    FListaBombas: TObjectList<TBomba>;
    procedure PreencherColecao(Ds: TFDQuery);
  public
    constructor Create;
    destructor Destroy; override;
    function Inserir(pBomba: TBomba): Boolean;
    function Deletar(pBomba: TBomba): Boolean;
    function DeletarID(xID: integer): Boolean;
    function Alterar(pBomba: TBomba): Boolean;
    function Listar(pConteudo: String;pCampo: String): TObjectList<TBomba>;
    function BuscarPorID(pBomba: Integer): TBomba;
  end;

implementation

{ TBombaDAO }

function TBombaDAO.Alterar(pBomba: TBomba): Boolean;
var
  Sql: String;
begin
  Sql := ' UPDATE bombas     ' +
         '    SET descricao     = ' + QuotedStr(pBomba.Descricao)    + ', ' +
         '        tanque  = ' + IntToStr(pBomba.Tanque.ID) + ', '+
         '        inativo   = ' + QuotedStr(BoolTo(pBomba.Inativo)) +
         '  WHERE ID = ' + IntToStr(pBomba.ID);
  Result := ExecutarComando(Sql) > 0;

end;

function TBombaDAO.BuscarPorID(pBomba: Integer): TBomba;
var
  Sql: String;
  Bomba : TBomba;
  Tanque : TTanque;
  TanqueDAO : TTanqueDAO;
begin
  Result := Nil;
  Sql := ' SELECT * FROM bombas b ';
  Sql := Sql + ' WHERE b.id = ' + pBomba.ToString;
  Sql := Sql + ' ORDER BY b.id ';

  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    try
      Bomba := TBomba.Create;
      Tanque := TTanque.Create;
      TanqueDAO := TTanqueDAO.Create;
      Tanque := TanqueDAO.BuscarPorID(FQry.FieldByName('tanque').AsInteger);
      Bomba.ID     := FQry.FieldByName('ID').AsInteger;
      Bomba.Descricao   := FQry.FieldByName('descricao').AsString;
      Bomba.Tanque  := Tanque;
      Bomba.Inativo:= ToBool(FQry.FieldByName('inativo').AsString);
      Result := Bomba;
    finally
      TanqueDAO.Free;
    end;
  end;

end;

constructor TBombaDAO.Create;
begin
  inherited;
  FListaBombas := TObjectList<TBomba>.Create;

end;

function TBombaDAO.Deletar(pBomba: TBomba): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM bombas '+
         '  WHERE ID = ' + IntToStr(pBomba.ID) ;
  Result := ExecutarComando(Sql) > 0;
end;

function TBombaDAO.DeletarID(xID: integer): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM bombas '+
         '  WHERE ID = ' + xID.ToString ;
  Result := ExecutarComando(Sql) > 0;
end;

destructor TBombaDAO.Destroy;
begin
inherited;
  try
    inherited;
    if Assigned(FListaBombas) then
      FreeAndNil(FListaBombas);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

function TBombaDAO.Inserir(pBomba: TBomba): Boolean;
var
  Sql: String;
begin
  try
    Sql := ' INSERT INTO bombas (descricao, tanque, inativo) '+
           ' VALUES ( '+
                     QuotedStr(pBomba.Descricao)    + ',' +
                     IntToStr(pBomba.Tanque.ID) + ',' +
                     QuotedStr(BoolTo(pBomba.Inativo)) +
                     ')';
    Result := ExecutarComando(Sql) > 0;
  except
    Result := False;
  end;

end;

function TBombaDAO.Listar(pConteudo, pCampo: String): TObjectList<TBomba>;
var
  Sql: String;
begin
  Result := Nil;
  Sql := ' SELECT b.id, b.descricao, '+
         '        b.tanque, b.inativo '+
         '   FROM bombas b ';
   if pConteudo <> '' then
   begin
     if pCampo='descrição' then
        begin
          Sql := Sql + '  WHERE b.descricao like ' + QuotedStr('%'+pConteudo+'%');
        end
     else if pCampo='inativo' then
        begin
          if pConteudo='F' then
             Sql := Sql + '  WHERE b.inativo    = ' + QuotedStr(pConteudo)
          else
             Sql := Sql + '  WHERE b.inativo    = ' + QuotedStr(pConteudo) + ' or b.inativo is null';
        end
     else if pCampo='tanque' then
        begin
          Sql := Sql + '  WHERE b.tanque    = ' + QuotedStr(pConteudo) + ' and (b.inativo=''F'' or b.inativo is null)';
        end
     else if pCampo='id' then
       begin
          Sql := Sql + '  WHERE b.id    = ' + QuotedStr(pConteudo);
       end;
   end;

  if pCampo='descrição' then
   Sql := Sql + '  ORDER BY b.descricao '
  else
   Sql := Sql + '  ORDER BY b.id ';

  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    PreencherColecao(FQry);
    Result := FListaBombas;
  end;

end;

procedure TBombaDAO.PreencherColecao(Ds: TFDQuery);
var
  I: Integer;
  Tanque : TTanque;
  TanqueDAO : TTanqueDAO;
begin
  I := 0;
  FListaBombas.Clear;
  while not Ds.eof do
  begin
    try
      FListaBombas.Add(TBomba.Create);
      FListaBombas[I].ID          := Ds.FieldByName('ID').AsInteger;
      FListaBombas[I].descricao   := Ds.FieldByName('descricao').AsString;
      Tanque := TTanque.Create;
      TanqueDAO := TTanqueDAO.Create;
      Tanque := TanqueDAO.BuscarPorID(Ds.FieldByName('tanque').AsInteger);
      FListaBombas[I].Tanque  := Tanque;
      FListaBombas[I].Inativo     := ToBool(Ds.FieldByName('inativo').AsString);
      Ds.Next;
      I := I + 1;
    finally
      TanqueDAO.Free;
    end;
  end;

end;

end.

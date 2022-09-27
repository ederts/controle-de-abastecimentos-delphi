unit uUSUARIOSDAO;

interface

uses uUSUARIOS, uBASEDAO, System.Generics.Collections, FireDAC.Comp.Client,
  System.SysUtils, funcoes;

type
  TUsuariosDAO = class(TBaseDAO)
  private
    FListaUsuarios: TObjectList<TUsuarios>;
    procedure PreencherColecao(Ds: TFDQuery);
  public
    constructor Create;
    destructor Destroy; override;
    function Inserir(pUsuario: TUsuarios): Boolean;
    function Deletar(pUsuario: TUsuarios): Boolean;
    function DeletarID(xID: integer): Boolean;
    function Alterar(pUsuario: TUsuarios): Boolean;
    function ListarPorNome(pConteudo: String;pCampo: String): TObjectList<TUsuarios>;
    function BuscarPorID(pConteudo: Integer): TUsuarios;
  end;

implementation



{ TUsuariosDAO }

function TUsuariosDAO.Alterar(pUsuario: TUsuarios): Boolean;
var
  Sql: String;
begin
  Sql := ' UPDATE usuarios     ' +
         '    SET nome     = ' + QuotedStr(pUsuario.Nome)    + ', ' +
         '        senha  = ' + QuotedStr(pUsuario.Senha) + ', '+
         '        inativo   = ' + QuotedStr(BoolTo(pUsuario.Inativo)) +
         '  WHERE ID = ' + IntToStr(pUsuario.ID);
  Result := ExecutarComando(Sql) > 0;


end;

constructor TUsuariosDAO.Create;
begin
  inherited;
  FListaUsuarios := TObjectList<TUsuarios>.Create;

end;

function TUsuariosDAO.Deletar(pUsuario: TUsuarios): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM usuarios '+
         '  WHERE ID = ' + IntToStr(pUsuario.ID) ;
  Result := ExecutarComando(Sql) > 0;

end;

function TUsuariosDAO.DeletarID(xID: integer): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM usuarios '+
         '  WHERE ID = ' + xID.ToString ;
  Result := ExecutarComando(Sql) > 0;
end;

destructor TUsuariosDAO.Destroy;
begin
  try
    inherited;
    if Assigned(FListaUsuarios) then
      FreeAndNil(FListaUsuarios);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

function TUsuariosDAO.Inserir(pUsuario: TUsuarios): Boolean;
var
  Sql: String;
begin
  Sql := ' INSERT INTO usuarios (nome, senha, inativo) '+
         ' VALUES ( '+
                   QuotedStr(pUsuario.Nome)    + ',' +
                   QuotedStr(pUsuario.Senha) + ',' +
                   QuotedStr(BoolTo(pUsuario.Inativo)) +
                   ')';
  Result := ExecutarComando(Sql) > 0;

end;

function TUsuariosDAO.ListarPorNome(
  pConteudo: String;pCampo: String): TObjectList<TUsuarios>;
var
  Sql: String;
begin
  Result := Nil;
  Sql := ' SELECT u.id, u.nome, '+
         '        u.senha, u.inativo '+
         '   FROM usuarios u ';
   if pConteudo <> '' then
   begin
     if pCampo='nome' then
        begin
          Sql := Sql + '  WHERE u.nome    like ' + QuotedStr('%'+pConteudo+'%');
        end
     else if pCampo='senha' then
        begin
        Sql := Sql + '  WHERE u.senha    = ' + QuotedStr(pConteudo);
        end
     else if pCampo='inativo' then
        begin
          if pConteudo='F' then
             Sql := Sql + '  WHERE u.inativo    = ' + QuotedStr(pConteudo)
          else
             Sql := Sql + '  WHERE u.inativo    = ' + QuotedStr(pConteudo) + ' or u.inativo is null';
        end
     else if pCampo='id' then
       begin
          Sql := Sql + '  WHERE u.id    = ' + QuotedStr(pConteudo);
       end;
   end;


   Sql := Sql + '  ORDER BY u.id     ';
  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    PreencherColecao(FQry);
    Result := FListaUsuarios;
  end;

end;

function TUsuariosDAO.BuscarPorID(pConteudo: Integer): TUsuarios;
var
  Sql: String;
  Usuario : TUsuarios;
begin
  Result := Nil;
  Sql := ' SELECT * FROM usuarios u ';
  Sql := Sql + ' WHERE u.id = ' + pConteudo.ToString;
  Sql := Sql + ' ORDER BY u.id ';

  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    Usuario := TUsuarios.Create;
    Usuario.ID     := FQry.FieldByName('ID').AsInteger;
    Usuario.nome   := FQry.FieldByName('nome').AsString;
    Usuario.senha  := FQry.FieldByName('senha').AsString;
    Usuario.Inativo:= ToBool(FQry.FieldByName('inativo').AsString);
    Result := Usuario;
  end;

end;

procedure TUsuariosDAO.PreencherColecao(Ds: TFDQuery);
var
  I: Integer;
begin
  I := 0;
  FListaUsuarios.Clear;
  while not Ds.eof do
  begin
    FListaUsuarios.Add(TUsuarios.Create);
    FListaUsuarios[I].ID     := Ds.FieldByName('ID').AsInteger;
    FListaUsuarios[I].nome   := Ds.FieldByName('nome').AsString;
    FListaUsuarios[I].senha  := Ds.FieldByName('senha').AsString;
    FListaUsuarios[I].Inativo:= ToBool(Ds.FieldByName('inativo').AsString);
    Ds.Next;
    I := I + 1;
  end;


end;

end.

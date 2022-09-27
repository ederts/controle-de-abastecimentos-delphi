unit uBASEDAO;

interface

uses
  FireDAC.Comp.Client, uDMConexao, System.SysUtils,Data.DB, Vcl.Dialogs,
     System.Classes;

type
  TBaseDAO = Class(TObject)
  private

  protected
    FQry: TFDQuery;
    constructor Create;
    destructor Destroy; override;
    function RetornarDataSet(pSQL: String): TFDQuery;
    function ExecutarComando(pSQL: String): Integer;
  end;

implementation

{ TBaseDAO }

constructor TBaseDAO.Create;
begin
  inherited Create;
  FQry            := TFDQuery.Create(Nil);
  FQry.Connection := dmConexao.conexao;
end;

destructor TBaseDAO.Destroy;
begin
  try
    if Assigned(FQry) then
      FreeAndNil(FQry);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

function TBaseDAO.ExecutarComando(pSQL: String): Integer;
begin
  try
    dmConexao.conexao.StartTransaction;
    FQry.SQL.Text := pSQL;
    FQry.ExecSQL;
    Result := FQry.RowsAffected;
    dmConexao.conexao.Commit;
  except
    Result := 0;
    dmConexao.conexao.Rollback;
  end;

end;

function TBaseDAO.RetornarDataSet(pSQL: String): TFDQuery;
begin
  FQry.SQL.Text := pSQL;
  FQry.Active   := True;
  Result        := FQry;

end;

end.

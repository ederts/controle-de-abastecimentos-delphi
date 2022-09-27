unit uABASTECIMENTODAO;

interface

uses uBASEDAO, System.Generics.Collections, FireDAC.Comp.Client,
  System.SysUtils, funcoes, uBOMBA, uTANQUES, uTANQUESDAO, uBOMBADAO,
  uCOMBUSTIVEL, uCOMBUSTIVELDAO, uABASTECIMENTO;

type
  TAbastecimentoDAO = class(TBaseDAO)
  private
    FListaAbastecimentos: TObjectList<TAbastecimento>;
    procedure PreencherColecao(Ds: TFDQuery);
  public
    constructor Create;
    destructor Destroy; override;
    function Inserir(pAbastecimento: TAbastecimento): Boolean;
    function Deletar(pAbastecimento: TAbastecimento): Boolean;
    function DeletarID(xID: integer): Boolean;
    function Alterar(pAbastecimento: TAbastecimento): Boolean;
    function Listar(pConteudo: String;pCampo: String): TObjectList<TAbastecimento>;
    function BuscarPorID(pAbastecimento: Integer): TAbastecimento;
  end;

implementation

{ TAbastecimentoDAO }

function TAbastecimentoDAO.Alterar(pAbastecimento: TAbastecimento): Boolean;
var
  Sql: String;
begin
  Sql := ' UPDATE abastecimentos     ' +
         '    SET bomba     = ' + IntToStr(pAbastecimento.Bomba.ID)    + ', ' +
         '        tanque  = ' + IntToStr(pAbastecimento.Tanque.ID) + ', '+
         '        combustivel  = ' + IntToStr(pAbastecimento.Combustivel.ID) + ', '+
         '        valorunitario  = ' + FloatToString(pAbastecimento.ValorUnitario,'.','') + ', '+
         '        quantidade  = ' + FloatToString(pAbastecimento.Quantidade,'.','') + ', '+
         '        valortotalbruto  = ' + FloatToString(pAbastecimento.ValorTotalBruto,'.','') + ', '+
         '        valorimposto  = ' + FloatToString(pAbastecimento.ValorImposto,'.','') + ', '+
         '        valortotalcomimposto  = ' + FloatToString(pAbastecimento.ValorTotalComImposto,'.','') + ', '+
         '        datamovimento   = ' + QuotedStr(FormatDateTime('mm/dd/yyyy', pAbastecimento.DataMovimento)) +
         '  WHERE ID = ' + IntToStr(pAbastecimento.ID);
  Result := ExecutarComando(Sql) > 0;

end;

function TAbastecimentoDAO.BuscarPorID(pAbastecimento: Integer): TAbastecimento;
var
  Sql: String;
  Abastecimento : TAbastecimento;
  Tanque : TTanque;
  TanqueDAO : TTanqueDAO;
  Combustivel : TCombustivel;
  CombustivelDAO : TCombustivelDAO;
  Bomba : TBomba;
  BombaDAO : TBombaDAO;
begin
  Result := Nil;
  Sql := ' SELECT * FROM abastecimentos a ';
  Sql := Sql + ' WHERE a.id = ' + pAbastecimento.ToString;
  Sql := Sql + ' ORDER BY a.id ';

  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    try
      Abastecimento := TAbastecimento.Create;
      Tanque := TTanque.Create;
      TanqueDAO := TTanqueDAO.Create;
      Tanque := TanqueDAO.BuscarPorID(FQry.FieldByName('tanque').AsInteger);
      Combustivel := TCombustivel.Create;
      CombustivelDAO := TCombustivelDAO.Create;
      Combustivel := CombustivelDAO.BuscarPorID(FQry.FieldByName('combustivel').AsInteger);
      Bomba := TBomba.Create;
      BombaDAO := TBombaDAO.Create;
      Bomba := BombaDAO.BuscarPorID(FQry.FieldByName('bomba').AsInteger);
      Abastecimento.ID     := FQry.FieldByName('ID').AsInteger;
      Abastecimento.Tanque  := Tanque;
      Abastecimento.Combustivel  := Combustivel;
      Abastecimento.Bomba  := Bomba;
      Abastecimento.ValorUnitario  := FQry.FieldByName('valorunitario').AsFloat;
      Abastecimento.Quantidade  := FQry.FieldByName('quantidade').AsFloat;
      Abastecimento.ValorTotalBruto  := FQry.FieldByName('valortotalbruto').AsFloat;
      Abastecimento.ValorImposto  := FQry.FieldByName('valorimposto').AsFloat;
      Abastecimento.ValorTotalComImposto  := FQry.FieldByName('valortotalcomimposto').AsFloat;
      Abastecimento.DataMovimento  := FQry.FieldByName('datamovimento').AsDateTime;
      Result := Abastecimento;
    finally
      TanqueDAO.Free;
    end;
  end;


end;

constructor TAbastecimentoDAO.Create;
begin
  inherited;
  FListaAbastecimentos := TObjectList<TAbastecimento>.Create;

end;

function TAbastecimentoDAO.Deletar(pAbastecimento: TAbastecimento): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM abastecimentos '+
         '  WHERE ID = ' + IntToStr(pAbastecimento.ID) ;
  Result := ExecutarComando(Sql) > 0;

end;

function TAbastecimentoDAO.DeletarID(xID: integer): Boolean;
var
  Sql: String;
begin
  Sql := ' DELETE '+
         '   FROM abastecimmentos '+
         '  WHERE ID = ' + xID.ToString ;
  Result := ExecutarComando(Sql) > 0;

end;

destructor TAbastecimentoDAO.Destroy;
begin
  inherited;
  try
    inherited;
    if Assigned(FListaAbastecimentos) then
      FreeAndNil(FListaAbastecimentos);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

function TAbastecimentoDAO.Inserir(pAbastecimento: TAbastecimento): Boolean;
var
  Sql: String;
begin
  try
    Sql := ' INSERT INTO abastecimentos (bomba, tanque, combustivel, valorunitario, '+
           ' quantidade, valortotalbruto, valorimposto, valortotalcomimposto, datamovimento) '+
           ' VALUES ( '+
                     IntToStr(pAbastecimento.Bomba.ID) + ',' +
                     IntToStr(pAbastecimento.Tanque.ID) + ',' +
                     IntToStr(pAbastecimento.Combustivel.ID) + ',' +
                     FloatToString(pAbastecimento.ValorUnitario,'.','') + ',' +
                     FloatToString(pAbastecimento.Quantidade,'.','') + ',' +
                     FloatToString(pAbastecimento.ValorTotalBruto,'.','') + ',' +
                     FloatToString(pAbastecimento.ValorImposto,'.','') + ',' +
                     FloatToString(pAbastecimento.ValorTotalComImposto,'.','') + ',' +
                     QuotedStr(FormatDateTime('mm/dd/yyyy', pAbastecimento.DataMovimento)) +
                     ')';
    Result := ExecutarComando(Sql) > 0;
  except
    Result := False;
  end;

end;

function TAbastecimentoDAO.Listar(pConteudo,
  pCampo: String): TObjectList<TAbastecimento>;
var
  Sql: String;
begin
  Result := Nil;
  Sql := ' SELECT a.*, b.descricao descbomba, c.descricao desccomb, t.descricao desctanque '+
         '   FROM abastecimentos a '+
         '   left join bombas b on b.id=a.bomba '+
         '   left join combustiveis c on c.id=a.combustivel '+
         '   left join tanques t on t.id=a.tanque ';
   if pConteudo <> '' then
   begin
     if pCampo='bomba' then
        begin
          Sql := Sql + '  WHERE b.descricao like ' + QuotedStr('%'+pConteudo+'%');
        end
     else if pCampo='combustível' then
        begin
          Sql := Sql + '  WHERE c.descricao like ' + QuotedStr('%'+pConteudo+'%');
        end
     else if pCampo='tanque' then
        begin
          Sql := Sql + '  WHERE t.descricao like ' + QuotedStr('%'+pConteudo+'%');
        end
     else if pCampo='id bomba' then
        begin
          Sql := Sql + '  WHERE a.bomba = ' + QuotedStr(pConteudo)
        end
     else if pCampo='id combustível' then
        begin
          Sql := Sql + '  WHERE a.combustivel = ' + QuotedStr(pConteudo)
        end
     else if pCampo='id tanque' then
        begin
          Sql := Sql + '  WHERE a.tanque = ' + QuotedStr(pConteudo)
        end
     else if pCampo='data movimento' then
        begin
          Sql := Sql + '  WHERE a.datamovimento = '''+pConteudo+''''
        end
     else if pCampo='id' then
       begin
          Sql := Sql + '  WHERE a.id    = ' + QuotedStr(pConteudo);
       end;
   end;

   Sql := Sql + '  ORDER BY a.id desc';

  FQry := RetornarDataSet(Sql);

  if not (FQry.IsEmpty) then
  begin
    PreencherColecao(FQry);
    Result := FListaAbastecimentos;
  end;

end;

procedure TAbastecimentoDAO.PreencherColecao(Ds: TFDQuery);
var
  I: Integer;
  Tanque : TTanque;
  TanqueDAO : TTanqueDAO;
  Combustivel : TCombustivel;
  CombustivelDAO : TCombustivelDAO;
  Bomba : TBomba;
  BombaDAO : TBombaDAO;
begin
  I := 0;
  FListaAbastecimentos.Clear;
  while not Ds.eof do
  begin
    try
      FListaAbastecimentos.Add(TAbastecimento.Create);
      FListaAbastecimentos[I].ID  := Ds.FieldByName('ID').AsInteger;
      Tanque := TTanque.Create;

      TanqueDAO := TTanqueDAO.Create;
      Tanque := TanqueDAO.BuscarPorID(Ds.FieldByName('tanque').AsInteger);
      FListaAbastecimentos[I].Tanque  := Tanque;

      CombustivelDAO := TCombustivelDAO.Create;
      Combustivel := CombustivelDAO.BuscarPorID(Ds.FieldByName('combustivel').AsInteger);
      FListaAbastecimentos[I].Combustivel  := Combustivel;

      BombaDAO := TBombaDAO.Create;
      Bomba := BombaDAO.BuscarPorID(Ds.FieldByName('bomba').AsInteger);
      FListaAbastecimentos[I].Bomba  := Bomba;

      FListaAbastecimentos[I].ValorUnitario  := Ds.FieldByName('valorunitario').AsFloat;
      FListaAbastecimentos[I].Quantidade  := Ds.FieldByName('quantidade').AsFloat;
      FListaAbastecimentos[I].ValorTotalBruto  := Ds.FieldByName('valortotalbruto').AsFloat;
      FListaAbastecimentos[I].valorimposto  := Ds.FieldByName('valorimposto').AsFloat;
      FListaAbastecimentos[I].ValorTotalComImposto  := Ds.FieldByName('valortotalcomimposto').AsFloat;

      FListaAbastecimentos[I].DataMovimento  := Ds.FieldByName('datamovimento').AsDateTime;
      Ds.Next;
      I := I + 1;
    finally
      TanqueDAO.Free;
      CombustivelDAO.Free;
      BombaDAO.Free;
    end;
  end;

end;

end.

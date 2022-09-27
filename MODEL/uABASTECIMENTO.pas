unit uABASTECIMENTO;

interface

uses uTANQUES, uBOMBA, uCOMBUSTIVEL, System.SysUtils;

Type
  TAbastecimento = class
  private
    FTanque: TTanque;
    FBomba: TBomba;
    FCombustivel: TCombustivel;
    FValorUnitario: Double;
    FQuantidade: Double;
    FValorTotalBruto: Double;
    FValorImposto: Double;
    FValorTotalComImposto: Double;
    FDataMovimento: TDateTime;
    FID: Integer;
    procedure SetTanque(const Value: TTanque);
    procedure SetBomba(const Value: TBomba);
    procedure SetCombustivel(const Value: TCombustivel);
    procedure SetValorUnitario(const Value: Double);
    procedure SetQuantidade(const Value: Double);
    procedure SetValorTotalBruto(const Value: Double);
    procedure SetValorImposto(const Value: Double);
    procedure SetValorTotalComImposto(const Value: Double);
    procedure SetDataMovimento(const Value: TDateTime);
    procedure SetID(const Value: Integer);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    Destructor Destroy; Override;
    property ID: Integer read FID write SetID;
    property Tanque: TTanque read FTanque write SetTanque;
    property Bomba: TBomba read FBomba write SetBomba;
    property Combustivel: TCombustivel read FCombustivel write SetCombustivel;
    property ValorUnitario: Double read FValorUnitario write SetValorUnitario;
    property Quantidade: Double read FQuantidade write SetQuantidade;
    property ValorTotalBruto: Double read FValorTotalBruto write SetValorTotalBruto;
    property ValorImposto: Double read FValorImposto write SetValorImposto;
    property ValorTotalComImposto: Double read FValorTotalComImposto write SetValorTotalComImposto;
    property DataMovimento: TDateTime read FDataMovimento write SetDataMovimento;

  published
    { published declarations }
  end;

implementation

{ TAbastecimento }

constructor TAbastecimento.Create;
begin
  FID := 0;
  Tanque := TTanque.create;
  Bomba := TBomba.Create;
  Combustivel := TCombustivel.Create;
  FValorUnitario        := 0.00;
  FQuantidade           := 0.000;
  FValorTotalBruto      := 0.00;
  FValorImposto         := 0.00;
  FValorTotalComImposto := 0.00;
  FDataMovimento := Date;

end;

destructor TAbastecimento.Destroy;
begin
  Tanque.Free;
  Bomba.Free;
  Combustivel.Free;
  inherited;
end;

procedure TAbastecimento.SetBomba(const Value: TBomba);
begin
  FBomba := Value;
end;

procedure TAbastecimento.SetCombustivel(const Value: TCombustivel);
begin
  FCombustivel := Value;
end;

procedure TAbastecimento.SetDataMovimento(const Value: TDateTime);
begin
  FDataMovimento := Value;
end;

procedure TAbastecimento.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TAbastecimento.SetQuantidade(const Value: Double);
begin
  FQuantidade := Value;
end;

procedure TAbastecimento.SetTanque(const Value: TTanque);
begin
  FTanque := Value
end;

procedure TAbastecimento.SetValorImposto(const Value: Double);
begin
  FValorImposto := Value;
end;

procedure TAbastecimento.SetValorTotalBruto(const Value: Double);
begin
  FValorTotalBruto := Value;
end;

procedure TAbastecimento.SetValorTotalComImposto(const Value: Double);
begin
  FValorTotalComImposto := Value;
end;

procedure TAbastecimento.SetValorUnitario(const Value: Double);
begin
  FValorUnitario := Value;
end;

end.

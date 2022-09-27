unit uBOMBA;

interface

uses uTANQUES;

Type
  TBomba = class
  private
    FDescricao: String;
    FTanque: TTanque;
    FInativo : Boolean;
    FID: Integer;
    procedure SetDescricao(const Value: String);
    procedure SetTanque(const Value: TTanque);
    procedure SetID(const Value: Integer);
    procedure SetInativo(const Value: Boolean);
    { private declarations }
  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create;
    Destructor Destroy; Override;
    property ID: Integer read FID write SetID;
    property Descricao: String read FDescricao write SetDescricao;
    property Tanque: TTanque read FTanque write SetTanque;
    property Inativo: Boolean read FInativo write SetInativo;
  published
    { published declarations }
  end;


implementation

{ TBomba }

constructor TBomba.Create;
begin
  FID := 0;
  FDESCRICAO := '';
  Tanque := TTanque.create;
  FInativo   := False;

end;

destructor TBomba.Destroy;
begin
  Tanque.Free;
  inherited;
end;

procedure TBomba.SetDescricao(const Value: String);
begin
  FDescricao := Value;
end;

procedure TBomba.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TBomba.SetInativo(const Value: Boolean);
begin
   FInativo := Value;
end;

procedure TBomba.SetTanque(const Value: TTanque);
begin
  FTanque := Value;
end;

end.

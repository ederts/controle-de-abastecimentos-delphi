unit FRELATORIO;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  dxGDIPlusClasses, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TfrmRelatorio = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    lbTitulo: TLabel;
    Label2: TLabel;
    Image1: TImage;
    btnFechar: TBitBtn;
    btnImprimir: TBitBtn;
    FDQueryRel: TFDQuery;
    FDQueryRelDATAMOVIMENTO: TDateField;
    FDQueryRelDESCBOMBA: TStringField;
    FDQueryRelDESCTANQUE: TStringField;
    FDQueryRelVALOR: TBCDField;
    procedure btnFecharClick(Sender: TObject);
    procedure btnImprimirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRelatorio: TfrmRelatorio;

implementation

{$R *.dfm}

uses uDMConexao, FREPORT;

procedure TfrmRelatorio.btnFecharClick(Sender: TObject);
begin
  close;
end;

procedure TfrmRelatorio.btnImprimirClick(Sender: TObject);
begin
   if TfrmReport(Application.FindComponent('frmReport')) = nil then
     frmReport := TfrmReport.Create(Application);

   FDQueryRel.Close;
   FDQueryRel.Open;
   frmReport.RLReport1.Preview();

end;

procedure TfrmRelatorio.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   FreeAndNil(frmReport);
   action := caFree;
end;

end.

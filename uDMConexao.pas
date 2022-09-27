unit uDMConexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB, FireDAC.Comp.UI,
  FireDAC.Comp.Client, Data.DB, Vcl.Forms, Vcl.Controls,FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.Comp.DataSet;

type
  TdmConexao = class(TDataModule)
    conexao: TFDConnection;
    FDTransaction1: TFDTransaction;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    FQry: TFDQuery;
    dsQry: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmConexao: TdmConexao;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

uses funcoes, FSPLASH, FCONFBASE;

{$R *.dfm}

procedure TdmConexao.DataModuleCreate(Sender: TObject);
var
  vTexto : String;
  procedure Seleciona_base(xVerificaBase:Boolean);
  begin
    frmSPLASH.FormStyle := fsNormal;
    if TFrmConfBase(Application.FindComponent('FrmConfBase')) = nil then
       FrmConfBase := TFrmConfBase.Create(Application);
    frmConfBase.vCaminho := VCaminhoBase;
    frmConfBase.vServidor := vNomeServidor;
    if FrmConfBase.ShowModal = mrCancel then
       begin
          FreeAndNil(frmSPLASH);
          Application.Terminate;
       end;
  end;
begin
  dmConexao.conexao.Params.Values['database'] := vCaminhoBase;
  dmConexao.conexao.Params.Values['server'] := vNomeServidor;

  Conexao.Connected := false;
  Try
    Try
      Conexao.Connected := True;
    except
      Begin
         vTexto := '';
         if not Empty(vcaminhobase) then
            begin
                vTexto :=  'Não foi possível conectar em '+VCaminhoBase;
                if not Empty(VNomeServidor) then
                   vTexto := vTexto +#13+ 'Servidor: '+VNomeServidor;
            end
         else
           begin
             vTexto := 'Não existe base de dados configurada.';
           end;
         Mensagem(vTexto);
         Seleciona_base(true);
         //Conexao.Connected := True;
      End;
    end;
  Finally
    If not Conexao.Connected then Application.Terminate;
  end;
end;



end.

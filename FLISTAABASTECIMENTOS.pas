unit FLISTAABASTECIMENTOS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  dxGDIPlusClasses, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Vcl.Buttons, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, System.Generics.Collections,
  Vcl.ComCtrls, Helper.edit, System.Rtti, uABASTECIMENTO, uABASTECIMENTODAO;

type
  TfrmListaAbastecimentos = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    DBGrid1: TDBGrid;
    cdsAbastecimentos: TFDMemTable;
    dsAbastecimentos: TDataSource;
    cdsAbastecimentosID: TIntegerField;
    cbCampos: TComboBox;
    Label3: TLabel;
    edConteudo: TEdit;
    Label4: TLabel;
    btnBuscar: TBitBtn;
    btnFechar: TBitBtn;
    btnEditar: TBitBtn;
    btnInserir: TBitBtn;
    btnExcluir: TBitBtn;
    cdsAbastecimentosTANQUE: TStringField;
    cdsAbastecimentosBOMBA: TStringField;
    cdsAbastecimentosCOMBUSTIVEL: TStringField;
    cdsAbastecimentosDATAMOVIMENTO: TDateField;
    cdsAbastecimentosVALORTOTALCOMIMPOSTO: TFloatField;
    conteudoData: TDateTimePicker;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnInserirClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure DBGrid1DrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbCamposChange(Sender: TObject);
  private
    { Private declarations }
    AbastecimentoDAO: TAbastecimentoDAO;
    procedure Pesquisar;
    procedure CarregarDadosRTTI(pListaAbastecimento: TList<TAbastecimento>);
  public
    { Public declarations }
  end;

var
  frmListaAbastecimentos: TfrmListaAbastecimentos;

implementation

{$R *.dfm}

uses uDMConexao, funcoes, uTANQUES, uCOMBUSTIVEL, uBOMBA,
  FABASTECIMENTOS;

procedure TfrmListaAbastecimentos.btnInserirClick(Sender: TObject);
var
  vAbastecimentoNOVO : TAbastecimento;
begin
   try
      vAbastecimentoNOVO := TAbastecimento.Create;
       if TfrmAbastecimentos(Application.FindComponent('frmAbasteccimentos')) = nil then
         frmAbastecimentos := TfrmAbastecimentos.Create(Application,vAbastecimentoNOVO);

      frmAbastecimentos.vEdicao := False;

      frmAbastecimentos.ShowModal;

      Pesquisar;
   finally
     FreeAndNil(vAbastecimentoNOVO);
   end;
end;

procedure TfrmListaAbastecimentos.btnBuscarClick(Sender: TObject);
begin
   if (not edConteudo.isNumero) and ((cbCampos.ItemIndex=0) or (cbCampos.ItemIndex=5) or
      (cbCampos.ItemIndex=6) or (cbCampos.ItemIndex=7)) then
     begin
       mensagem('Conteúdo inválido, digite apenas números inteiros.');
       edConteudo.SelectAll;
       edConteudo.SetFocus;
       exit;
     end;

   Pesquisar;
end;

procedure TfrmListaAbastecimentos.Pesquisar;
var
  vConteudo : String;
begin
  try
    if cbCampos.ItemIndex=4 then
      vConteudo := FormatDateTime('mm/dd/yyyy',conteudoData.Date)
    else
      vConteudo :=  edConteudo.Text;
    CarregarDadosRTTI(AbastecimentoDAO.Listar(vConteudo,LowerCase(cbCampos.Text)));
    if cdsAbastecimentos.Active then
       cdsAbastecimentos.First;
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaAbastecimentos.btnEditarClick(Sender: TObject);
begin
   if cdsAbastecimentos.IsEmpty then
    begin
       exit;
    end;
   try
    frmAbastecimentos := TfrmAbastecimentos.Create(Self, AbastecimentoDAO.BuscarPorID(cdsAbastecimentosID.AsInteger));
    frmAbastecimentos.ShowModal;
    Pesquisar;
  finally
    //FreeAndNil(frmAbastecimentos);
  end;
end;

procedure TfrmListaAbastecimentos.btnExcluirClick(Sender: TObject);
begin
  if cdsAbastecimentos.IsEmpty then
    begin
       exit;
    end;

  if Pergunta('Deseja Excluir este Abastecimento?','S' ) then
    begin
      if AbastecimentoDAO.DeletarID(cdsAbastecimentosID.AsInteger) then
        begin
          Mensagem('Excluído com sucesso.');
          Pesquisar;
        end
      else
        begin
          Mensagem('Erro ao excluir Abastecimento.');
        end;
    end;
end;

procedure TfrmListaAbastecimentos.btnFecharClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmListaAbastecimentos.CarregarDadosRTTI(pListaAbastecimento: TList<TAbastecimento>);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  i : Integer;

begin
  if Assigned(pListaAbastecimento) then
    begin
      if cdsAbastecimentos.Active then
        begin
         cdsAbastecimentos.EmptyDataSet;
        end
      else
        begin
         cdsAbastecimentos.CreateDataSet;
        end;

      cdsAbastecimentos.DisableControls;
      // Cria o contexto do RTTI
      Contexto := TRttiContext.Create;
      try
        // Obtém as informações de RTTI da classe TAbastecimento
        Tipo := Contexto.GetType(TAbastecimento.ClassInfo);

        for I := 0 to pListaAbastecimento.Count -1 do
          begin
            cdsAbastecimentos.Append;
            cdsAbastecimentosID.AsInteger := Tipo.GetProperty('ID').GetValue(pListaAbastecimento[i]).asInteger;
            cdsAbastecimentosTANQUE.AsString := TAbastecimento(pListaAbastecimento[i]).Tanque.Descricao;
            cdsAbastecimentosCOMBUSTIVEL.AsString := TAbastecimento(pListaAbastecimento[i]).Combustivel.Descricao;
            cdsAbastecimentosBOMBA.AsString := TAbastecimento(pListaAbastecimento[i]).Bomba.Descricao;
            cdsAbastecimentosVALORTOTALCOMIMPOSTO.AsFloat := Tipo.GetProperty('ValorTotalComImposto').GetValue(pListaAbastecimento[i]).AsVariant;
            cdsAbastecimentosDATAMOVIMENTO.AsDateTime := TAbastecimento(pListaAbastecimento[i]).DataMovimento;
            cdsAbastecimentos.Post;
          end;
      finally
        Contexto.Free;
      end;
    end
  else
    begin
      if cdsAbastecimentos.Active then
         cdsAbastecimentos.EmptyDataSet;
      Mensagem('Nenhum Abastecimento encontrado.');
    end;

  cdsAbastecimentos.EnableControls;
end;

procedure TfrmListaAbastecimentos.cbCamposChange(Sender: TObject);
begin

   edConteudo.Visible := cbCampos.ItemIndex<>4;
   conteudoData.Visible := cbCampos.ItemIndex=4;

end;

procedure TfrmListaAbastecimentos.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
   PintaGrid(Sender,Rect,DataCol,Column,State);
end;

procedure TfrmListaAbastecimentos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caFree;
end;

procedure TfrmListaAbastecimentos.FormCreate(Sender: TObject);
begin
   AbastecimentoDAO  := TAbastecimentoDAO.Create;
end;

procedure TfrmListaAbastecimentos.FormDestroy(Sender: TObject);
begin
  try
    if Assigned(AbastecimentoDAO) then
      FreeAndNil(AbastecimentoDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaAbastecimentos.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmListaAbastecimentos.FormShow(Sender: TObject);
begin
  edConteudo.SetFocus;
end;

end.

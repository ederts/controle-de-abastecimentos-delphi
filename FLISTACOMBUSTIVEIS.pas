unit FLISTACOMBUSTIVEIS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  dxGDIPlusClasses, Vcl.ExtCtrls, Vcl.StdCtrls, Data.DB, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Vcl.Buttons, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids, System.Generics.Collections,
  Vcl.ComCtrls, Helper.edit, System.Rtti, uCOMBUSTIVELDAO,
  uCOMBUSTIVEL;

type
  TfrmListaCombustiveis = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    DBGrid1: TDBGrid;
    cdsCombustiveis: TFDMemTable;
    dsCombustiveis: TDataSource;
    cdsCombustiveisID: TIntegerField;
    cdsCombustiveisDESCRICAO: TStringField;
    cdsCombustiveisINATIVO: TStringField;
    cbCampos: TComboBox;
    Label3: TLabel;
    edConteudo: TEdit;
    Label4: TLabel;
    btnBuscar: TBitBtn;
    ckInativos: TCheckBox;
    btnFechar: TBitBtn;
    btnEditar: TBitBtn;
    btnInserir: TBitBtn;
    btnExcluir: TBitBtn;
    cdsCombustiveisPRECOLITRO: TFloatField;
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
  private
    { Private declarations }
    CombustivelDAO: TCombustivelDAO;
    procedure Pesquisar;
    procedure CarregarDados(pListaCombustivel: TList<TCombustivel>);
    procedure CarregarDadosRTTI(pListaCombustivel: TList<TCombustivel>);
  public
    { Public declarations }
  end;

var
  frmListaCombustiveis: TfrmListaCombustiveis;

implementation

{$R *.dfm}

uses uDMConexao, funcoes, FCOMBUSTIVEIS;

procedure TfrmListaCombustiveis.btnInserirClick(Sender: TObject);
var
  vCombustivelNOVO : TCombustivel;
begin
   try
      vCombustivelNOVO := TCombustivel.Create;
       if TfrmCOMBUSTIVEIS(Application.FindComponent('frmCOMBUSTIVEIS')) = nil then
         frmCOMBUSTIVEIS := TfrmCOMBUSTIVEIS.Create(Application,vCombustivelNOVO);

      frmCOMBUSTIVEIS.vEdicao := False;

      frmCOMBUSTIVEIS.ShowModal;

      Pesquisar;
   finally
     FreeAndNil(frmCOMBUSTIVEIS);
     FreeAndNil(vCombustivelNOVO);
   end;
end;

procedure TfrmListaCombustiveis.btnBuscarClick(Sender: TObject);
begin
   if (not edConteudo.isNumero) and (cbCampos.ItemIndex=0) then
     begin
       mensagem('Conteúdo inválido, digite apenas números inteiros.');
       edConteudo.SelectAll;
       edConteudo.SetFocus;
       exit;
     end;
   Pesquisar;
end;

procedure TfrmListaCombustiveis.Pesquisar;
begin
  try
    //CarregarDados(CombustiveisDAO.ListarPorNome(edConteudo.Text,LowerCase(cbCampos.Text)));
    CarregarDadosRTTI(CombustivelDAO.Listar(edConteudo.Text,LowerCase(cbCampos.Text)));
    if cdsCombustiveis.Active then
       cdsCombustiveis.First;
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaCombustiveis.btnEditarClick(Sender: TObject);
begin
   if cdsCombustiveis.IsEmpty then
    begin
       exit;
    end;
   try
    frmCOMBUSTIVEIS := TfrmCOMBUSTIVEIS.Create(Self, CombustivelDAO.BuscarPorID(cdsCombustiveisID.AsInteger));
    frmCOMBUSTIVEIS.ShowModal;
    Pesquisar;
  finally
    FreeAndNil(frmCOMBUSTIVEIS);
  end;
end;

procedure TfrmListaCombustiveis.btnExcluirClick(Sender: TObject);
begin
  if cdsCombustiveis.IsEmpty then
    begin
       exit;
    end;

  if Pergunta('Deseja Excluir este Combustível?','S' ) then
    begin
      //if CombustivelDAO.Deletar(CombustivelDAO.BuscarPorID(cdsCombustiveisID.AsInteger)) then
      if CombustivelDAO.DeletarID(cdsCombustiveisID.AsInteger) then
        begin
          Mensagem('Excluído com sucesso.');
          Pesquisar;
        end
      else
        begin
          Mensagem('Erro ao excluir combustível.');
        end;
    end;
end;

procedure TfrmListaCombustiveis.btnFecharClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmListaCombustiveis.CarregarDados(pListaCombustivel: TList<TCombustivel>);
var
  I: Integer;
  ItensTemporarios: TListItem;
begin
  if Assigned(pListaCombustivel) then
    begin
      if cdsCombustiveis.Active then
        begin
         cdsCombustiveis.EmptyDataSet;
        end
      else
        begin
         cdsCombustiveis.CreateDataSet;
        end;

      cdsCombustiveis.DisableControls;

      for I := 0 to pListaCombustivel.Count -1 do
      begin
        if ((not ckInativos.Checked) and  (TCombustivel(pListaCombustivel[I]).Inativo)) then
           continue;

        cdsCombustiveis.Append;
        cdsCombustiveisID.AsInteger := TCombustivel(pListaCombustivel[I]).ID;
        cdsCombustiveisDESCRICAO.AsString := TCombustivel(pListaCombustivel[I]).Descricao;
        if not TCombustivel(pListaCombustivel[I]).Inativo then
           cdsCombustiveisINATIVO.AsString := 'Não'
        else
           cdsCombustiveisINATIVO.AsString := 'Sim';
        cdsCombustiveisPRECOLITRO.AsFloat := TCombustivel(pListaCombustivel[I]).PrecoLitro;
        cdsCombustiveis.Post;
      end;
    end
  else
    begin
      cdsCombustiveis.EmptyDataSet;
      Mensagem('Nenhum Combustível encontrado.');
    end;

  cdsCombustiveis.EnableControls;
end;

procedure TfrmListaCombustiveis.CarregarDadosRTTI(pListaCombustivel: TList<TCombustivel>);
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  i : Integer;
begin
  if Assigned(pListaCombustivel) then
    begin
      if cdsCombustiveis.Active then
        begin
         cdsCombustiveis.EmptyDataSet;
         
        end
      else
        begin
         cdsCombustiveis.CreateDataSet;
        end;

      cdsCombustiveis.DisableControls;
      // Cria o contexto do RTTI
      Contexto := TRttiContext.Create;
      try
        // Obtém as informações de RTTI da classe TCombustivel
        Tipo := Contexto.GetType(TCombustivel.ClassInfo);

        for I := 0 to pListaCombustivel.Count -1 do
          begin
            if ((not ckInativos.Checked) and  (Tipo.GetProperty('Inativo').GetValue(pListaCombustivel[i]).asBoolean)) then
               continue;

            cdsCombustiveis.Append;
            cdsCombustiveisID.AsInteger := Tipo.GetProperty('ID').GetValue(pListaCombustivel[i]).asInteger;
            cdsCombustiveisDESCRICAO.AsString := Tipo.GetProperty('Descricao').GetValue(pListaCombustivel[i]).asString;
            if not Tipo.GetProperty('Inativo').GetValue(pListaCombustivel[i]).asBoolean then
               cdsCombustiveisINATIVO.AsString := 'Não'
            else
               cdsCombustiveisINATIVO.AsString := 'Sim';
            cdsCombustiveisPRECOLITRO.AsFloat := Tipo.GetProperty('PrecoLitro').GetValue(pListaCombustivel[i]).AsVariant;
            cdsCombustiveis.Post;
          end;
      finally
        Contexto.Free;
      end;
    end
  else
    begin
      if cdsCombustiveis.Active then
         cdsCombustiveis.EmptyDataSet;
      Mensagem('Nenhum Combustível encontrado.');
    end;

  cdsCombustiveis.EnableControls;
end;

procedure TfrmListaCombustiveis.DBGrid1DrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
   if cdsCombustiveisINATIVO.AsString='Sim' then
   begin
      dbGrid1.Canvas.Font.Style := dbGrid1.Canvas.Font.Style + [fsStrikeOut];
      DBGrid1.Canvas.Font.Color := clGray;
   end
   else
   begin
      DBGrid1.Canvas.Font.Color := clWindowText;
   end;
   PintaGrid(Sender,Rect,DataCol,Column,State);
end;

procedure TfrmListaCombustiveis.FormCreate(Sender: TObject);
begin
   CombustivelDAO  := TCombustivelDAO.Create;
end;

procedure TfrmListaCombustiveis.FormDestroy(Sender: TObject);
begin
  try
    if Assigned(CombustivelDAO) then
      FreeAndNil(CombustivelDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmListaCombustiveis.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmListaCombustiveis.FormShow(Sender: TObject);
begin
  edConteudo.SetFocus;
end;

end.

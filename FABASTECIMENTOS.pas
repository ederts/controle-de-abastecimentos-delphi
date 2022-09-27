unit FABASTECIMENTOS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  dxGDIPlusClasses, Vcl.ExtCtrls, funcoes, Helper.edit,
  uTANQUES, System.Generics.Collections, uBOMBA, uBOMBADAO,
  uTANQUESDAO, uCOMBUSTIVEL, uCOMBUSTIVELDAO, uABASTECIMENTO, uABASTECIMENTODAO,
  Vcl.ComCtrls;

type
  TfrmAbastecimentos = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    lbTitulo: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    btnFechar: TBitBtn;
    BitBtn1: TBitBtn;
    Label4: TLabel;
    cbBOMBAS: TComboBox;
    edDataMovimento: TDateTimePicker;
    Label9: TLabel;
    Label10: TLabel;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edPRECO: TEdit;
    Label5: TLabel;
    EdQtde: TEdit;
    Label6: TLabel;
    EdTotalBruto: TEdit;
    Label8: TLabel;
    edImposto: TEdit;
    edValLiquidolb: TLabel;
    EdValLiquido: TEdit;
    Label3: TLabel;
    Label7: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    procedure btnFecharClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edPRECOKeyPress(Sender: TObject; var Key: Char);
    procedure EdQtdeKeyPress(Sender: TObject; var Key: Char);
    procedure EdTotalBrutoKeyPress(Sender: TObject; var Key: Char);
    procedure edImpostoKeyPress(Sender: TObject; var Key: Char);
    procedure EdValLiquidoKeyPress(Sender: TObject; var Key: Char);
    procedure EdQtdeExit(Sender: TObject);
    procedure cbBOMBASChange(Sender: TObject);
  private
    { Private declarations }
     AbastecimentoDAO: TAbastecimentoDAO;
     Abastecimento: TAbastecimento;
     vAPrecos:Array of Double;
     procedure PreencherAbastecimento;
     procedure PreencherTela;
     procedure CarregaBombas;
     function BuscaDescricaoCombustivel(xIDTanque : Integer;xIndice : Integer) : String;
  public
    { Public declarations }
    vEdicao : Boolean;
    constructor Create(AOwner: TComponent; pAbastecimento: TAbastecimento);
  end;

var
  frmAbastecimentos: TfrmAbastecimentos;

implementation

{$R *.dfm}

procedure TfrmAbastecimentos.BitBtn1Click(Sender: TObject);
begin
  if cbBOMBAS.ItemIndex<=-1 then
    begin
      Mensagem('Informe uma Bomba!!..');
      cbBOMBAS.SetFocus;
      exit;
    end;

  if edPRECO.IsEmpty then
    begin
      Mensagem('Informe um valor!!..');
      edPRECO.SetFocus;
      exit;
    end
  else
    begin
      if StringToFloat(edPRECO.Text)<=0 then
        begin
          Mensagem('O preço informado não é válido, verifique!!..');
          edPRECO.SetFocus;
          exit;
        end;
    end;

  if EdQtde.IsEmpty then
    begin
      Mensagem('Informe uma Quantidade!!..');
      EdQtde.SetFocus;
      exit;
    end
  else
    begin
      if StringToFloat(EdQtde.Text)<=0 then
        begin
          Mensagem('A quantidade informada não é válida, verifique!!..');
          EdQtde.SetFocus;
          exit;
        end;
    end;

  if EdTotalBruto.IsEmpty then
    begin
      Mensagem('Informe um Total Bruto!!..');
      EdTotalBruto.SetFocus;
      exit;
    end
  else
    begin
      if StringToFloat(EdTotalBruto.Text)<=0 then
        begin
          Mensagem('O total bruto informado não é válido, verifique!!..');
          EdQtde.SetFocus;
          exit;
        end;
    end;

  if EdImposto.IsEmpty then
    begin
      Mensagem('Informe um Valor de Imposto!!..');
      edImposto.SetFocus;
      exit;
    end
  else
    begin
      if StringToFloat(edImposto.Text)<=0 then
        begin
          Mensagem('O valor do imposto não é válido, verifique!!..');
          edImposto.SetFocus;
          exit;
        end;
    end;

  if EdValLiquido.IsEmpty then
    begin
      Mensagem('Informe um Valor Liquido!!..');
      EdValLiquido.SetFocus;
      exit;
    end
  else
    begin
      if StringToFloat(EdValLiquido.Text)<=0 then
        begin
          Mensagem('O valor liquido não é válido, verifique!!..');
          EdValLiquido.SetFocus;
          exit;
        end;
    end;

 try
   PreencherAbastecimento;
   if vEdicao then
     begin
       if AbastecimentoDAO.Alterar(Abastecimento) then
         begin
           Mensagem('Abastecimento Alterado com Sucesso.');
           Close;
         end;
     end
   else
     begin
       if AbastecimentoDAO.Inserir(Abastecimento) then
         begin
           Mensagem('Abastecimento Inserido com Sucesso.');
           Close;
         end;
     end;
 except
   on e: exception do
      raise Exception.Create(E.Message);
 end;
end;

procedure TfrmAbastecimentos.btnFecharClick(Sender: TObject);
begin
   Close;
end;

constructor TfrmAbastecimentos.Create(AOwner: TComponent; pAbastecimento: TAbastecimento);
begin
  if pAbastecimento.ID>0 then
    begin
       inherited Create(AOwner);
       vEdicao := True;
       AbastecimentoDAO := TAbastecimentoDAO.Create;

      try
        if Assigned(pAbastecimento) then
        begin
          Abastecimento := pAbastecimento;
          PreencherTela;
        end;
      except
        on e: exception do
           raise Exception.Create(E.Message);
      end;
    end
  else
    begin
      inherited Create(AOwner);
      vEdicao := False;
    end;
end;

procedure TfrmAbastecimentos.edImpostoKeyPress(Sender: TObject; var Key: Char);
begin
   Key := TestaValor(Sender,Key);
end;

procedure TfrmAbastecimentos.EdTotalBrutoKeyPress(Sender: TObject; var Key: Char);
begin
   Key := TestaValor(Sender,Key);
end;

procedure TfrmAbastecimentos.EdValLiquidoKeyPress(Sender: TObject; var Key: Char);
begin
   Key := TestaValor(Sender,Key);
end;

procedure TfrmAbastecimentos.edPRECOKeyPress(Sender: TObject; var Key: Char);
begin
   Key := TestaValor(Sender,Key);
end;

procedure TfrmAbastecimentos.EdQtdeExit(Sender: TObject);
var
  vPreco,vQtde, vTotalBruto, vImposto, vValLiquido :Double;
begin
    vPreco := StringToFloat(edPRECO.Text);
    vQtde := StringToFloat(EdQtde.Text);
    vTotalBruto := vPreco*vQtde;
    vImposto := vTotalBruto*0.13;  //13% de imposto
    vValLiquido := vTotalBruto+vImposto;

    EdTotalBruto.Text    := FloatToString(vTotalBruto,',','###,###,##0.00');
    edImposto.Text       := FloatToString(vImposto,',','###,###,##0.00');
    EdValLiquido.Text    := FloatToString(vValLiquido,',','###,###,##0.00');

end;

procedure TfrmAbastecimentos.EdQtdeKeyPress(Sender: TObject; var Key: Char);
begin
   Key := TestaValor(Sender,Key);
end;

procedure TfrmAbastecimentos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caFree;
end;

procedure TfrmAbastecimentos.FormCreate(Sender: TObject);
begin
  if not vEdicao then
    begin
       Abastecimento    := TAbastecimento.Create;
       AbastecimentoDAO := TAbastecimentoDAO.Create;
    end;
end;

procedure TfrmAbastecimentos.FormDestroy(Sender: TObject);
begin
   try
    if Assigned(Abastecimento) then
      FreeAndNil(Abastecimento);
    if Assigned(AbastecimentoDAO) then
      FreeAndNil(AbastecimentoDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmAbastecimentos.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmAbastecimentos.FormShow(Sender: TObject);
begin
   CarregaBombas;
   if vEdicao then
     begin
       lbTitulo.Caption := 'Editar Abastecimento id: '+Abastecimento.ID.ToString;
       PreencherTela;
     end
   else
     begin
        lbTitulo.Caption := 'Cadastrar Abastecimento';
        edDataMovimento.Date := Date;
        edPRECO.Text         := FloatToString(Abastecimento.ValorUnitario,',','###,###,##0.00');
        EdQtde.Text          := FloatToString(0,',','###,###,##0.000');
        EdTotalBruto.Text    := FloatToString(0,',','###,###,##0.00');
        edImposto.Text       := FloatToString(0,',','###,###,##0.00');
        EdValLiquido.Text    := FloatToString(0,',','###,###,##0.00');
     end;

   cbBOMBAS.SetFocus;
end;



procedure TfrmAbastecimentos.CarregaBombas;
var
  BombaDAO: TBombaDAO;
  pListaBomba1: TList<TBomba>;
  i : Integer;
  vDesc : String;
  vIndice : Integer;
begin
  try
    BombaDAO  := TBombaDAO.Create;
    cbBOMBAS.Items.Clear;
    pListaBomba1 := TObjectList<TBomba>.Create;
    pListaBomba1 := BombaDAO.Listar('','descrição');
    SetLength(vAPrecos,pListaBomba1.Count);
    vIndice := 0;
    for I := 0 to pListaBomba1.Count -1 do
      begin
         //Quando é um novo registro só mostra os ativos, se estiver editando mostra também os inativos
         //pois pode ter cadastrado um combustível que foi inativado depois.
         if vEdicao then
           begin
             vDesc := pListaBomba1[I].Descricao;
             vDesc := vDesc + ' - ';
             vDesc := vDesc + BuscaDescricaoCombustivel(pListaBomba1[I].Tanque.ID,vIndice);
             inc(vIndice);
             cbBOMBAS.Items.AddObject(vDesc,TObject(pListaBomba1[I].ID));
           end
         else
           begin
             if (not TBomba(pListaBomba1[I]).Inativo) then
               begin
                  vDesc := pListaBomba1[I].Descricao;
                  vDesc := vDesc + ' - ';
                  vDesc := vDesc + BuscaDescricaoCombustivel(pListaBomba1[I].Tanque.ID,vIndice);
                  inc(vIndice);
                  cbBOMBAS.Items.AddObject(vDesc,TObject(pListaBomba1[I].ID));
               end;
           end;
      end;
  finally
    BombaDAO.Free;
  end;

end;

procedure TfrmAbastecimentos.cbBOMBASChange(Sender: TObject);
var
  vPreco : Double;
begin
   vPreco := vAPrecos[cbBOMBAS.ItemIndex];
   edPRECO.Text := FloatToString(vPreco,',','###,###,##0.00');
   EdQtdeExit(nil);
end;

function TfrmAbastecimentos.BuscaDescricaoCombustivel(xIDTanque : Integer;xIndice : Integer) : String;
var
  Combustivel : TCombustivel;
  CombustivelDAO : TCombustivelDAO;
  Tanque : TTanque;
  TanqueDAO : TTanqueDAO;
begin
  try
    TanqueDAO := TTanqueDAO.Create;
    Tanque := TanqueDAO.BuscarPorID(xIDTanque);
    CombustivelDAO := TCombustivelDAO.Create;
    Combustivel := CombustivelDAO.BuscarPorID(Tanque.Combustivel.ID);
    vAPrecos[xIndice] := Combustivel.PrecoLitro;
    Result := Combustivel.Descricao;
  finally
    TanqueDAo.Free;
    CombustivelDAO.Free;
  end;
end;

procedure TfrmAbastecimentos.PreencherAbastecimento;
var
  TanqueDAO: TTanqueDAO;
  BombaDAO: TBombaDAO;
  CombustivelDAO: TCombustivelDAO;
begin
  try
    TanqueDAO  := TTanqueDAO.Create;
    BombaDAO  := TBombaDAO.Create;
    CombustivelDAO := TCombustivelDAO.Create;
    Abastecimento.Bomba := BombaDAO.BuscarPorID(Integer(cbBOMBAS.Items.Objects[cbBOMBAS.ItemIndex]));
    Abastecimento.Tanque := TanqueDAO.BuscarPorID(Abastecimento.Bomba.Tanque.ID);
    Abastecimento.Combustivel := CombustivelDAO.BuscarPorID(Abastecimento.Tanque.Combustivel.ID);

    Abastecimento.ValorUnitario := StringToFloat(edPRECO.Text);
    Abastecimento.Quantidade := StringToFloat(EdQtde.Text);
    Abastecimento.ValorTotalBruto := StringToFloat(EdTotalBruto.Text);
    Abastecimento.ValorImposto := StringToFloat(edImposto.Text);
    Abastecimento.ValorTotalComImposto := StringToFloat(EdValLiquido.Text);

    Abastecimento.DataMovimento := edDataMovimento.Date;

  finally
    TanqueDAO.Free;
    bombaDAO.Free;
    CombustivelDAO.Free;
  end;
end;

procedure TfrmAbastecimentos.PreencherTela;
begin
  cbBOMBAS.ItemIndex   := cbBOMBAS.Items.IndexOf(Abastecimento.Bomba.Descricao+' - '+Abastecimento.Combustivel.Descricao);
  edDataMovimento.Date := Abastecimento.DataMovimento;
  edPRECO.Text         := FloatToString(Abastecimento.ValorUnitario,',','###,###,##0.00');
  EdQtde.Text          := FloatToString(Abastecimento.Quantidade,',','###,###,##0.000');
  EdTotalBruto.Text    := FloatToString(Abastecimento.ValorTotalBruto,',','###,###,##0.00');
  edImposto.Text       := FloatToString(Abastecimento.ValorImposto,',','###,###,##0.00');
  EdValLiquido.Text    := FloatToString(Abastecimento.ValorTotalComImposto,',','###,###,##0.00');

end;

end.

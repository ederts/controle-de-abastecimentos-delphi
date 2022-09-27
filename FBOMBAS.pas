unit FBOMBAS;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  dxGDIPlusClasses, Vcl.ExtCtrls, funcoes, Helper.edit,
  uTANQUES, System.Generics.Collections, uBOMBA, uBOMBADAO,
  uTANQUESDAO;

type
  TfrmBOMBAS = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    lbTitulo: TLabel;
    Label2: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    btnFechar: TBitBtn;
    BitBtn1: TBitBtn;
    edDESC: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    ckInativo: TCheckBox;
    cbTANQUES: TComboBox;
    procedure btnFecharClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
     BombaDAO: TBombaDAO;
     Bomba: TBomba;
     procedure PreencherBomba;
     procedure PreencherTela;
    procedure CarregaTanques;
  public
    { Public declarations }
    vEdicao : Boolean;
    constructor Create(AOwner: TComponent; pBomba: TBomba);
  end;

var
  frmBOMBAS: TfrmBOMBAS;

implementation

{$R *.dfm}

procedure TfrmBOMBAS.BitBtn1Click(Sender: TObject);
var
  pListaBombaCont: TList<TBomba>;
  BombaDAOCont : TBombaDAO;
  vQuantidade,i : Integer;
begin
  if edDESC.IsEmpty then
    begin
      Mensagem('Informe uma Descrição!!..');
      edDESC.SetFocus;
      exit;
    end;
  if cbTANQUES.ItemIndex<=-1 then
    begin
      Mensagem('Informe um Tanque!!..');
      cbTANQUES.SetFocus;
      exit;
    end;


  pListaBombaCont := TObjectList<TBomba>.Create;
  BombaDAOCont := TBombaDAO.Create;
  pListaBombaCont := BombaDAOCont.Listar(IntToStr(Integer(cbTANQUES.Items.Objects[cbTANQUES.ItemIndex])),'tanque');
  if Assigned(pListaBombaCont) then
    begin
       vQuantidade := 0;
       for I := 0 to pListaBombaCont.Count - 1 do
         begin
           if vEdicao then
             begin
               if pListaBombaCont[i].ID<>Bomba.ID then
                 vQuantidade := vQuantidade+1;
             end
           else
             begin
               vQuantidade := vQuantidade+1;
             end;
         end;

      if vQuantidade = 2 then
        begin
          Mensagem('Tanque '+cbTANQUES.Text+' já possui 2 Bombas ativas!!..');
          cbTANQUES.SetFocus;
          BombaDAOCont.Free;
          exit;
        end;
    end;
 BombaDAOCont.Free;
 try
   PreencherBomba;
   if vEdicao then
     begin
       if BombaDAO.Alterar(Bomba) then
         begin
           Mensagem('Bomba Alterada com Sucesso.');
           Close;
         end;
     end
   else
     begin
       if BombaDAO.Inserir(Bomba) then
         begin
           Mensagem('Bomba Inserida com Sucesso.');
           Close;
         end;
     end;
 except
   on e: exception do
      raise Exception.Create(E.Message);
 end;
end;

procedure TfrmBOMBAS.btnFecharClick(Sender: TObject);
begin
   Close;
end;

constructor TfrmBOMBAS.Create(AOwner: TComponent; pBomba: TBomba);
begin
  if pBomba.ID>0 then
    begin
       inherited Create(AOwner);
       vEdicao := True;
       BombaDAO := TBombaDAO.Create;

      try
        if Assigned(pBomba) then
        begin
          Bomba := pBomba;
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

procedure TfrmBOMBAS.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   Action := caFree;
end;

procedure TfrmBOMBAS.FormCreate(Sender: TObject);
begin
  if not vEdicao then
    begin
       Bomba    := TBomba.Create;
       BombaDAO := TBombaDAO.Create;
    end;
end;

procedure TfrmBOMBAS.FormDestroy(Sender: TObject);
begin
   try
    if Assigned(Bomba) then
      FreeAndNil(Bomba);
    if Assigned(BombaDAO) then
      FreeAndNil(BombaDAO);
  except
    on e: exception do
      raise Exception.Create(E.Message);
  end;
end;

procedure TfrmBOMBAS.FormKeyPress(Sender: TObject; var Key: Char);
begin
   if key=#13 then
     Perform(WM_nextdlgctl,0,0)
  else if Key =  #27 then
     Perform(WM_nextdlgctl,1,0);
end;

procedure TfrmBOMBAS.FormShow(Sender: TObject);
begin
   if vEdicao then
     lbTitulo.Caption := 'Editar Bomba id: '+Bomba.ID.ToString
   else
     lbTitulo.Caption := 'Cadastrar Bomba';

   CarregaTanques;
   if vEdicao then
     PreencherTela;

   edDESC.SetFocus;
end;



procedure TfrmBOMBAS.CarregaTanques;
var
  TanqueDAO: TTanqueDAO;
  pListaTanque1: TList<TTanque>;
  i : Integer;
begin
  try
    TanqueDAO  := TTanqueDAO.Create;
    cbTANQUES.Items.Clear;
    pListaTanque1 := TObjectList<TTanque>.Create;
    pListaTanque1 := TanqueDAO.Listar('','descrição');
    for I := 0 to pListaTanque1.Count -1 do
      begin
         //Quando é um novo registro só mostra os ativos, se estiver editando mostra também os inativos
         //pois pode ter cadastrado um combustível que foi inativado depois.
         if vEdicao then
           begin
             cbTANQUES.Items.AddObject(pListaTanque1[I].Descricao,TObject(pListaTanque1[I].ID));
           end
         else
           begin
             if (not TTanque(pListaTanque1[I]).Inativo) then
               cbTANQUES.Items.AddObject(pListaTanque1[I].Descricao,TObject(pListaTanque1[I].ID));
           end;
      end;
  finally
    TanqueDAO.Free;
  end;

end;

procedure TfrmBOMBAS.PreencherBomba;
var
  TanqueDAO: TTanqueDAO;
begin
  try
    TanqueDAO  := TTanqueDAO.Create;
    Bomba.Descricao  := edDESC.Text;
    Bomba.Tanque := TanqueDAO.BuscarPorID(Integer(cbTANQUES.Items.Objects[cbTANQUES.ItemIndex]));
    Bomba.Inativo    := ckInativo.Checked;
  finally
    TanqueDAO.Free;
  end;
end;

procedure TfrmBOMBAS.PreencherTela;
begin
  edDESC.Text       := Bomba.Descricao;
  ckInativo.Checked := Bomba.Inativo;
  cbTANQUES.ItemIndex := cbTANQUES.Items.IndexOf(Bomba.Tanque.Descricao);
end;

end.

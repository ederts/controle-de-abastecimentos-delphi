unit uMenu;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus,
  System.ImageList, Vcl.ImgList, Vcl.ToolWin;

type
  TfrmMenu = class(TForm)
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    x1: TMenuItem;
    Usurios1: TMenuItem;
    anques1: TMenuItem;
    Bombas1: TMenuItem;
    Combustvel1: TMenuItem;
    Movimento1: TMenuItem;
    Sair1: TMenuItem;
    Relatrios1: TMenuItem;
    Abastecimentos1: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ImageList1: TImageList;
    ImageList2: TImageList;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    RelatriodeAbastecimentos1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
    procedure Usurios1Click(Sender: TObject);
    procedure Combustvel1Click(Sender: TObject);
    procedure anques1Click(Sender: TObject);
    procedure Bombas1Click(Sender: TObject);
    procedure Abastecimentos1Click(Sender: TObject);
    procedure RelatriodeAbastecimentos1Click(Sender: TObject);
  private
    procedure actConectarExecute(Sender: TObject);
    function SenhaAcesso: Boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMenu: TfrmMenu;

implementation

{$R *.dfm}

uses funcoes, FSPLASH, FLOGIN, FLISTAUSUARIOS, FLISTACOMBUSTIVEIS,
  FLISTATANQUES, FLISTABOMBAS, FLISTAABASTECIMENTOS, FRELATORIO;

procedure TfrmMenu.anques1Click(Sender: TObject);
begin
   if TfrmListaTanques(Application.FindComponent('frmListaTanques')) = nil then
     frmListaTanques := TfrmListaTanques.Create(Application);

  frmListaTanques.ShowModal;
end;

procedure TfrmMenu.Bombas1Click(Sender: TObject);
begin
   if TfrmListaBombas(Application.FindComponent('frmListaBombas')) = nil then
     frmListaBombas := TfrmListaBombas.Create(Application);

  frmListaBombas.ShowModal;

end;

procedure TfrmMenu.Combustvel1Click(Sender: TObject);
begin
   if TfrmListaCombustiveis(Application.FindComponent('frmListaCombustiveis')) = nil then
     frmListaCombustiveis := TfrmListaCombustiveis.Create(Application);

  frmListaCombustiveis.ShowModal;
end;

procedure TfrmMenu.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  If not Pergunta('Confirma saída do sistema ?', 'S') then
  Begin
    Action := caNone;
    exit;
  End;

  Application.Terminate;
end;

procedure TfrmMenu.FormShow(Sender: TObject);
begin
   FreeAndNil(frmSPLASH); // Destroy o Splash
   actConectarExecute(nil);
end;

procedure TfrmMenu.RelatriodeAbastecimentos1Click(Sender: TObject);
begin
  if TfrmRelatorio(Application.FindComponent('frmRelatorio')) = nil then
     frmRelatorio := TfrmRelatorio.Create(Application);

  frmRelatorio.ShowModal;
end;

procedure TfrmMenu.Sair1Click(Sender: TObject);
begin
  Close;
end;

function TfrmMenu.SenhaAcesso: Boolean;
begin
  if TfrmLOGIN(Application.FindComponent('frmLOGIN')) = nil then
    frmLOGIN := TfrmLOGIN.Create(Application);
  frmLOGIN.ShowModal;
  Result := frmLOGIN.vOk;
  FreeAndNil(frmLOGIN);
end;

procedure TfrmMenu.Usurios1Click(Sender: TObject);
begin
  if TfrmListaUsuarios(Application.FindComponent('frmListaUsuarios')) = nil then
     frmListaUsuarios := TfrmListaUsuarios.Create(Application);

  frmListaUsuarios.ShowModal;
end;

procedure TfrmMenu.Abastecimentos1Click(Sender: TObject);
begin
   if TfrmListaAbastecimentos(Application.FindComponent('frmListaAbastecimentos')) = nil then
     frmListaAbastecimentos := TfrmListaAbastecimentos.Create(Application);

  frmListaAbastecimentos.ShowModal;
end;

procedure TfrmMenu.actConectarExecute(Sender: TObject);
begin
   If not SenhaAcesso then
    exit;

   StatusBar1.Panels[0].Text := 'Login em : '+FormatDateTime('dddd, dd/mmm/yyyy',Now);
   StatusBar1.Panels[1].Text := 'Usuário: '+VUsuario.NomeOperador;
end;

end.

program prjPosto;

uses
  Vcl.Forms,
  MidasLib,
  Winapi.Windows,
  uMenu in 'uMenu.pas' {frmMenu},
  uDMConexao in 'uDMConexao.pas' {dmConexao: TDataModule},
  funcoes in 'funcoes.pas',
  System.IniFiles,
  System.SysUtils,
  FSPLASH in 'FSPLASH.pas' {frmSplash},
  FCONFBASE in 'FCONFBASE.pas' {frmConfBase},
  FLOGIN in 'FLOGIN.pas' {frmLOGIN},
  uUSUARIOS in 'MODEL\uUSUARIOS.pas',
  uUSUARIOSDAO in 'DAO\uUSUARIOSDAO.pas',
  uBASEDAO in 'DAO\uBASEDAO.pas',
  FLISTAUSUARIOS in 'FLISTAUSUARIOS.pas' {frmListaUsuarios},
  Helper.edit in 'Helper.edit.pas',
  FUSUARIOS in 'FUSUARIOS.pas' {frmUSUARIOS},
  uCOMBUSTIVEL in 'MODEL\uCOMBUSTIVEL.pas',
  uCOMBUSTIVELDAO in 'DAO\uCOMBUSTIVELDAO.pas',
  FLISTACOMBUSTIVEIS in 'FLISTACOMBUSTIVEIS.pas' {frmListaCombustiveis},
  FCOMBUSTIVEIS in 'FCOMBUSTIVEIS.pas' {frmCOMBUSTIVEIS},
  uTANQUES in 'MODEL\uTANQUES.pas',
  uTANQUESDAO in 'DAO\uTANQUESDAO.pas',
  FLISTATANQUES in 'FLISTATANQUES.pas' {frmListaTanques},
  FTANQUES in 'FTANQUES.pas' {frmTANQUES},
  uBOMBA in 'MODEL\uBOMBA.pas',
  uBOMBADAO in 'DAO\uBOMBADAO.pas',
  FLISTABOMBAS in 'FLISTABOMBAS.pas' {frmListaBombas},
  FBOMBAS in 'FBOMBAS.pas' {frmBOMBAS},
  uABASTECIMENTO in 'MODEL\uABASTECIMENTO.pas',
  uABASTECIMENTODAO in 'DAO\uABASTECIMENTODAO.pas',
  FLISTAABASTECIMENTOS in 'FLISTAABASTECIMENTOS.pas' {frmListaAbastecimentos},
  FABASTECIMENTOS in 'FABASTECIMENTOS.pas' {frmAbastecimentos},
  FRELATORIO in 'FRELATORIO.pas' {frmRelatorio},
  FREPORT in 'FREPORT.pas' {frmReport};

{$R *.res}
Var
    MutexHandle: THandle;
    VSistema_OK : Boolean;

begin
  //para não abrir duas vezes o sistema
   MutexHandle := CreateMutex(nil, TRUE, 'PostoAppMutex');
   if MutexHandle <> 0 then
   begin
     if GetLastError = ERROR_ALREADY_EXISTS then
     begin
       if not Pergunta('O sistema Controle de abastecimento já está aberto neste computador, deseja abrir outra instância?','S') then
         begin
           //MessageBox(0, 'Este programa já está em execução!','', mb_IconHand);
           CloseHandle(MutexHandle);
           Halt(0);
         end;
     end
   end;

  CarregaDadosConexao;

  vPOSTO_INI := TIniFile.Create(ExtractFilePath(Application.ExeName) +'POSTO.INI');

  Application.Initialize;

  frmSPLASH := TfrmSPLASH.Create(Application);
  frmSPLASH.Show;
  frmSPLASH.Update;
  frmSPLASH.Progresso.Position  := 10;

  frmSPLASH.LblStatus.Caption := 'Conectando com o Servidor...';
  frmSPLASH.LblStatus.Refresh;

  Application.Title := 'Abastecimentos';
  Application.CreateForm(TdmCONEXAO, dmCONEXAO);
  VSistema_OK := DMConexao.Conexao.Connected;
  frmSPLASH.Progresso.Position  := 30;

  If VSistema_OK then
  Begin
    //Application.Initialize;
    frmSPLASH.Progresso.Position  := 60;
    Application.MainFormOnTaskbar := True;
    //Application.CreateForm(TdmConexao, dmConexao);
    frmSPLASH.Progresso.Position  := 90;
    Application.CreateForm(TfrmMenu, frmMenu);
    Application.Run;
  End;
end.

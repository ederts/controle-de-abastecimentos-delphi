object dmConexao: TdmConexao
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 284
  Width = 464
  object conexao: TFDConnection
    Params.Strings = (
      'Database=C:\Sistema\fortes\posto\dados\POSTO.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Server=localhost'
      'CharacterSet=WIN1252'
      'DriverID=FB')
    LoginPrompt = False
    Left = 32
    Top = 32
  end
  object FDTransaction1: TFDTransaction
    Connection = conexao
    Left = 104
    Top = 32
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 200
    Top = 40
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 280
    Top = 40
  end
  object FQry: TFDQuery
    Connection = conexao
    Left = 136
    Top = 168
  end
  object dsQry: TDataSource
    DataSet = FQry
    Left = 192
    Top = 176
  end
end

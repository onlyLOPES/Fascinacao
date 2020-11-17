unit uSalaDAO;

interface

uses sysUtils, uDAO, Vcl.CheckLst, uSala, FireDac.Comp.client, DB, uCurso;

type
  TSalaDao = class(TConectDAO)
  private
    FCLSalas: TCheckListBox;

  public
    function ListaSAla: TFDQuery;
    function CadastroCurso_sala(pCurso: Tcurso): boolean;
    Constructor Create;
    Destructor Destroy; override;
  end;

implementation

{ TSalaDao }

function TSalaDao.CadastroCurso_sala(pCurso: Tcurso): boolean;
var
  SQL : string;
  I: Integer;
begin
  for I := 0 to 4 do
    if pCurso.salas[I] <> '' then
    begin
      SQL := 'select id_sala From sala where nome = ' +
        QuotedStr(pCurso.salas[I]);

       FQuery := RetornarDataSet(SQL);

      pCurso.IDSala := FQuery.FieldByName('id_sala').Asinteger;

      SQL := 'select id_curso from curso where nome like ' +
        QuotedStr('%' + pCurso.Nome + '%');
      FQuery := RetornarDataSet(SQL);
      pCurso.id := FQuery.FieldByName('id_curso').Asinteger;

      SQL := 'insert into sala_curso values(' +
        QuotedStr(IntToStr(pCurso.IDSala)) + ', ' +
        QuotedStr(IntToStr(pCurso.id)) + ')';

      Result := ExecutarComando(SQL) >0;
    end;
end;

constructor TSalaDao.Create;
begin
  inherited;
end;

function TSalaDao.ListaSala: TFDQuery;
var
  SQL: string;
begin
  SQL := 'SELECT nome FROM sala';
  FQuery := RetornarDataSet(SQL);

  Result := FQuery;
end;

destructor TSalaDao.Destroy;
begin
  try
    inherited;

    if Assigned(FCLSalas) then
      FreeAndNil(FCLSalas);

  except
    on e: exception do
      raise exception.Create(e.Message);
  end;
end;

end.

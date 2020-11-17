unit uCursoDAO;

interface

uses uDAO, uCurso, FireDAC.Comp.Client, sysUtils, system.Generics.Collections;

type
  TCursoDAO = class(TconectDAO)
  private
    FListaCurso: TObjectList<TCurso>;
    procedure CriaLista(Ds: TFDQuery);
  public
    Constructor Create;
    Destructor Destroy; override;
    function ListaCurso: TFDQuery;
    function CadastraCurso(pCurso: TCurso): boolean;
    function PesquisaCurso(pCurso: TCurso): TObjectList<TCurso>;
  end;

implementation

{ TCursoDAO }

function TCursoDAO.CadastraCurso(pCurso: TCurso): boolean;
var
  SQL: string;
begin
  SQL := 'insert into curso values (default, ' + QuotedSTR(pCurso.nome) + ', ' +
    QuotedSTR(FloatToStr(pCurso.Preco)) + ')';

  Result := ExecutarComando(SQL) > 0;
end;

constructor TCursoDAO.Create;
begin
  inherited;
  FListaCurso := TObjectList<TCurso>.Create;
end;

procedure TCursoDAO.CriaLista(Ds: TFDQuery);
var
  I, count: integer;
  SQL: string;
begin
  I := 0;

  FListaCurso.Clear;

  while not Ds.eof do
  begin
    count := 0;
    FListaCurso.Add(TCurso.Create);
    FListaCurso[I].id := Ds.fieldByName('id_curso').AsInteger;
    FListaCurso[I].nome := Ds.fieldByName('nome').AsString;
    FListaCurso[I].Preco := Ds.fieldByName('preco').AsFloat;

    SQL := 'select nome from sala where id_sala in ' +
      '(select id_sala from sala_curso where id_curso = '
       + QuotedStr(IntToStr(FListaCurso[I].ID)) + ')';

    FQuery2 := RetornarDataSet2(SQL);
    while not FQuery2.eof do
    begin
      FListaCurso[I].salas[count] := FQuery2.fieldByName('nome').AsString;
      FQuery2.Next;
      count := count + 1;
    end;

    Ds.Next;
    I := I + 1;
  end;
end;

destructor TCursoDAO.Destroy;
begin
  inherited;
end;

function TCursoDAO.ListaCurso: TFDQuery;
var
  SQL: string;
begin
  SQL := 'SELECT * FROM curso ORDER BY nome';
  FQuery := RetornarDataSet(SQL);

  Result := FQuery;
end;

function TCursoDAO.PesquisaCurso(pCurso: TCurso): TObjectList<TCurso>;
var
  SQL: string;
begin
  Result := nil;
  SQL := 'select * from curso where nome like ' + QuotedSTR('%' + pCurso.nome + '%');
  FQuery := RetornarDataSet(SQL);

  if not (FQuery.IsEmpty) then
  begin
    CriaLista(FQuery);
    Result := FListaCurso
  end;
end;

end.

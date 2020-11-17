unit uAlunoDAO;

interface

uses uDAO, uAluno, system.generics.collections, FireDAC.Comp.Client, DB,
  system.sysUtils, uEndereco, uResponsavel, system.DateUtils;

type
  TAlunoDAO = class(TConectDAO)
  protected
    FListaAluno: TobjectList<TAluno>;
    procedure preencherlista(Ds: TFDQuery);
  public
    Constructor Create;
    Destructor Destroy; override;
    function CadastrarAluno(pAluno: TAluno; pEndereco: TEndereco;
      pResponsavel: Tresponsavel): boolean;
    function CadastrarResponsavel(pResponsavel: Tresponsavel): boolean;
    function PesquisarAluno(pAluno: TAluno): TObjectList<TAluno>;

  end;

implementation

{ TAlunoDAO }

function TAlunoDAO.CadastrarAluno(pAluno: TAluno; pEndereco: TEndereco;
  pResponsavel: Tresponsavel): boolean;
var
  SQL: string;
begin
  if YearsBetween(now, pAluno.DataNasc) >= 17 then
  begin
    SQL := 'SELECT id_endereco FROM ENDERECO WHERE CEP = ' +
      QuotedSTR(pEndereco.cep) + ' AND numero = ' +
      QuotedSTR(InttoStr(pEndereco.Numero)) + 'limit 1';

    FQuery := RetornarDataSet(SQL);

    pEndereco.id := FQuery.fieldByName('id_endereco').AsInteger;

    SQL := 'INSERT INTO aluno VALUES(default, ' + QuotedSTR(pAluno.Nome) + ', '
      + QuotedSTR(InttoStr(pEndereco.id)) + ', null, ' +
      QuotedSTR(FormatDateTime('dd/mm/yyyy', pAluno.DataNasc)) + ', ' +
      QuotedSTR(pAluno.Cpf) + ', ' + QuotedSTR(pAluno.rg) + ', ' +
      QuotedSTR(pAluno.contatocom) + ', ' + QuotedSTR(pAluno.contato) + ', ' +
      QuotedSTR(pAluno.email) + ')';

    result := executarComando(SQL) > 0;
  end
  else
  begin
     SQL := 'select id_endereco from endereco '+
  'where id_endereco not in (select id_endereco from aluno) '+
  'and id_endereco not in (select id_endereco from professor)';

    FQuery := RetornarDataSet(SQL);

    pEndereco.id := FQuery.fieldByName('id_endereco').AsInteger;

    SQL := 'SELECT id_responsavel FROM responsavel WHERE cpf = ' +
      QuotedSTR(pResponsavel.Cpf) + ' AND nome = ' +
      QuotedSTR(pResponsavel.Nome) + 'limit 1';

    FQuery := RetornarDataSet(SQL);

    pResponsavel.id := FQuery.fieldByName('id_responsavel').AsInteger;

    SQL := 'INSERT INTO aluno VALUES(default, ' + QuotedSTR(pAluno.Nome) + ', '
      + QuotedSTR(InttoStr(pEndereco.id)) + ', ' +
      QuotedStr(IntToStr(pResponsavel.ID)) + ', ' +
      QuotedSTR(FormatDateTime('dd/mm/yyyy', pAluno.DataNasc)) + ', ' +
      QuotedSTR(pAluno.Cpf) + ', ' + QuotedSTR(pAluno.rg) + ', ' +
      QuotedSTR(pAluno.contatocom) + ', ' + QuotedSTR(pAluno.contato) + ', ' +
      QuotedSTR(pAluno.email) + ')';

    result := executarComando(SQL) > 0;
  end;
end;

function TAlunoDAO.CadastrarResponsavel(pResponsavel: Tresponsavel): boolean;
Var
  SQL: string;
begin
  SQL := 'INSERT INTO responsavel VALUES (Default, ' +
    QuotedSTR(pResponsavel.Nome) + ', ' + QuotedSTR(pResponsavel.Cpf) + ', ' +
    QuotedSTR(pResponsavel.rg) + ', ' + QuotedSTR(pResponsavel.contato) + ', ' +
    QuotedSTR(pResponsavel.contatocom) + ', ' +
    QuotedStr(FormatDateTime('dd/mm/yyyy', pResponsavel.DataNasc)) + ')';

  result := executarComando(SQL) > 0;
end;

constructor TAlunoDAO.Create;
begin
  inherited;
  FListaAluno := TobjectList<TAluno>.Create;
end;

destructor TAlunoDAO.Destroy;
begin
  try
    inherited;

    if Assigned(FListaAluno) then
      FreeAndNil(FListaAluno);

  except
    on e: exception do
      raise exception.Create(e.Message);
  end;
end;

function TAlunoDAO.PesquisarAluno(pAluno: TAluno): TObjectList<TAluno>;
var
  SQL: string;
begin
  Result := nil;
  SQL := 'SELECT * FROM aluno WHERE nome LIKE ' + QuotedStr('%' + pAluno.Nome + '%') +
  'and cpf LIKE '+ QuotedStr('%' + pAluno.CPF + '%') + ' and telefone LIKE '+
  QuotedStr('%' + pAluno.Contato + '%');{ +
  ' and id_aluno in (select id_aluno from aluno_curso where id_curso in '+
  '(select id_curso from curso where nome like '
  + QuotedStr('%' + pAluno.Curso + '%') + ')) order by nome';}


  FQuery := RetornarDataSet(SQL);

  if not (FQuery.IsEmpty) then
  begin
    preencherlista(FQuery);
    Result:= FListaAluno;
  end;
end;

procedure TAlunoDAO.preencherlista(Ds: TFDQuery);
var
  I: integer;
begin

  I := 0;
  FListaAluno.Clear;

  while not Ds.eof do
  begin
    FListaAluno.Add(TAluno.Create);
    FListaAluno[I].id := Ds.fieldByName('id_aluno').AsInteger;
    FListaAluno[I].Nome := Ds.fieldByName('nome').AsString;
    FListaAluno[I].IDEndereco := Ds.fieldByName('id_endereco').AsInteger;
    FListaAluno[I].IDResponsavel := Ds.fieldByName('id_responsavel').AsInteger;
    FListaAluno[I].DataNasc := Ds.fieldByName('data_nasc').AsDateTime;
    FListaAluno[I].Cpf := Ds.fieldByName('cpf').AsString;
    FListaAluno[I].rg := Ds.fieldByName('rg').AsString;
    FListaAluno[I].contatocom := Ds.fieldByName('telefone_comercial').AsString;
    FListaAluno[I].contato := Ds.fieldByName('telefone').AsString;
    FListaAluno[I].email := Ds.fieldByName('email').AsString;


    Ds.Next;
    I := I + 1;
  end;
end;

end.

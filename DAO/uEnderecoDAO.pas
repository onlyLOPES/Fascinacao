unit uEnderecoDAO;

interface
uses uDAO, uEndereco, FireDac.comp.client, sysUtils;

type
  TEnderecoDAO = class (TconectDAO)
    public
    Constructor Create;
    Destructor Destroy; override;
    function CadastrarEndereco(pEndereco : Tendereco):boolean;
    function RetornarEndereco(id : integer): TEndereco;
  end;

implementation

{ TEnderecoDAO }

function TEnderecoDAO.CadastrarEndereco(pEndereco: Tendereco): boolean;
var SQL:string;
begin
SQL := 'INSERT INTO endereco VALUES(default, ' + QuotedSTR(pEndereco.rua) +
    ', ' + QuotedSTR(InttoStr(pEndereco.Numero)) + ', ' +
    QuotedSTR(pEndereco.bairro) + ', ' + QuotedSTR(pEndereco.cidade) + ', ' +
    QuotedSTR(pEndereco.cep) + ')';

  result := executarComando(SQL) > 0;
end;

constructor TEnderecoDAO.Create;
begin
  inherited;
end;

destructor TEnderecoDAO.Destroy;
begin
  inherited;
end;

function TEnderecoDAO.RetornarEndereco(id: integer): TEndereco;
var SQL : string;
endereco : TEndereco;
begin
  SQL := 'select * from endereco where id_endereco = '+
  '(select id_endereco from professor where id_professor = '+QuotedStr(IntToStr( id)) +')';

  FQuery := RetornarDataSet(SQL);

  endereco := TEndereco.Create;
  endereco.ID := FQuery.FieldByName('id_endereco').AsInteger;
  endereco.Rua := FQuery.FieldByName('rua').AsString;
  endereco.Numero := FQuery.FieldByName('numero').AsInteger;
  endereco.Cidade := FQuery.FieldByName('cidade').AsString;
  endereco.Bairro := FQuery.FieldByName('bairro').AsString;
  endereco.Cep := FQuery.FieldByName('cep').AsString;

  Result := endereco;
end;

end.

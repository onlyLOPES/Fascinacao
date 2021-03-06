unit uAdmDAO;

interface

uses uAdm, uDAO, System.SysUtils;

type
  TAdmDAO = class(TConectDAO)
  public
    constructor Create;
    destructor Destroy; override;

    function VerificaLogin(user, passw: string): boolean;
  end;

implementation

{ TAdmDAO }

constructor TAdmDAO.Create;
begin
  inherited;
end;

destructor TAdmDAO.Destroy;
begin
try
  inherited;
except
  on e:exception do
  raise Exception.Create(E.Message);

end;

end;

function TAdmDAO.VerificaLogin(user, passw: string): boolean;
var
  SQL: string;
begin
  SQL := 'Select * From adm Where login = ' +  QuotedStr(user) +
  ' and senha = ' + QuotedStr(passw);

  Result := ExecutarOpen(SQL) > 0;
end;

end.

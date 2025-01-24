SELECT
    a.nrorepresentante                  "Cód.Representante",
    b.apelido                           "Nome Representante",
    a.seqpessoa                         "Cód.Cliente",
    d.nomerazao                         "Nome Razão Social",
    d.fantasia                          "Nome Fantasia",
    e.limitecredito                     "Limite",
    f.nrotabvendaprinc                  "Tabela",
    f.percacrdesccomerc                 "Acrescimo/Desconto",
    d.logradouro||','||d.nrologradouro  "Endereco",
    d.bairro                            "Bairro",
    d.cidade                            "Cidade",
    d.uf                                "UF",
    d.fonenro1                          "Telefone 1",
    d.fonenro2                          "Telefone 2",
    d.fonenro3                          "Telefone 3"
FROM implantacao.mad_clienterep a
INNER JOIN implantacao.mad_representante b ON b.nrorepresentante = a.nrorepresentante
INNER JOIN implantacao.mrl_cliente c ON c.seqpessoa = a.seqpessoa
INNER JOIN implantacao.ge_pessoa d ON d.seqpessoa = c.seqpessoa
INNER JOIN implantacao.ge_pessoacadastro e ON e.seqpessoa = d.seqpessoa
INNER JOIN implantacao.mrl_clienteseg f ON f.seqpessoa = a.seqpessoa AND f.nrorepresentante = a.nrorepresentante
WHERE a.nrorepresentante = 11393
ORDER BY 1 ASC
SELECT 
    a.seqpessoa,
    NVL(MAX(a.vlrcreduso), 0)
FROM implantacao.mrl_clientecreduso a
INNER JOIN implantacao.mrl_cliente b
ON b.seqpessoa = a.seqpessoa AND b.seqpessoa NOT IN (1, 22401) AND b.statuscliente = 'A'
-- Tabela utilizada para tirar os clientes com os representantes de código "1,1000,22401,99999" e os inativos
INNER JOIN implantacao.mad_clienterep c 
ON c.seqpessoa = b.seqpessoa AND c.nrorepresentante NOT IN (1,1000,22401,99999) AND c.status = 'A'
-- Tabela utilizada para pegar os clientes onde os representantes sejam "Funcionário, Representante e Supervisor"
-- e que estejam ativos
INNER JOIN implantacao.mad_representante d 
ON d.nrorepresentante = c.nrorepresentante AND d.tiprepresentante IN ('F','R','S') AND d.status = 'A'
-- Tabela utilizada para pegar os clientes diferente de atividade "FORNECEDOR" e que estejam ativos campos a ser
-- utilizado: "STATUS,CEP,FISICAJURIDICA,NROCGCCPF,DIGCGCCPF,NOMERAZAO,ATIVIDADE,SEQCIDADE,CNAE,CMPLTOLOGRADOURO,
--             INDCONTRIBICMS,EMAIL,EMAILNFE,LOGRADOURO,UF,FANTASIA,FAXDDD,FAXNRO,INSCRICAOORG,INSCMUNICIPAL,
--             INDCONTRIBIPI,CIDADE,NROLOGRADOURO,ORGAOPUBLICO,ORGEXP,ORGEXPUF,PAIS,HOMEPAGE,NROINSCSUFRAMA,
--             FONEDDD1,FONENRO1,SEQBAIRRO,BAIRRO"
INNER JOIN implantacao.ge_pessoa e 
ON e.seqpessoa = c.seqpessoa AND e.atividade NOT IN ('FORNECEDOR') AND e.status = 'A'
-- Tabela utilizada para pegar a situação de crédito do cliente campo utilizado: "SITUACAOCREDITO"
INNER JOIN implantacao.ge_pessoacadastro f 
ON f.seqpessoa = e.seqpessoa
WHERE 1 = 1
AND a.seqpessoa NOT IN (1, 22401)
GROUP BY a.seqpessoa
ORDER BY 1 ASC;
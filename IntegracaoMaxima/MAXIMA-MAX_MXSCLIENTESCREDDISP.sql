SELECT
    DISTINCT
    a.seqpessoa                             AS codcli,
    e.limitecredito                         AS vllimite,
    0                                       AS vltitulos,
    0                                       AS vlpedidos,
    0                                       AS vlcheques,
    0                                       AS vlcredito,
    0                                       AS vllimitcredsuppli,
    a.statuscliente                         AS status,
    MAX(f.dtaalteracao)                     AS dtaalteracao
FROM implantacao.mrl_cliente a
-- Tabela utilizada para tirar os clientes com os representantes de código "1,1000,22401,99999" e os inativos
INNER JOIN implantacao.mad_clienterep b 
ON b.seqpessoa = a.seqpessoa AND b.nrorepresentante NOT IN (1,1000,22401,99999) AND b.status = 'A'
-- Tabela utilizada para pegar os clientes onde os representantes sejam "Funcionário, Representante e Supervisor"
-- e que estejam ativos
INNER JOIN implantacao.mad_representante c 
ON c.nrorepresentante = b.nrorepresentante AND c.tiprepresentante IN ('F','R','S') AND c.status = 'A'
-- Tabela utilizada para pegar os clientes diferente de atividade "FORNECEDOR" e que estejam ativos campos a ser
-- utilizado: "STATUS,CEP,FISICAJURIDICA,NROCGCCPF,DIGCGCCPF,NOMERAZAO,ATIVIDADE,SEQCIDADE,CNAE,CMPLTOLOGRADOURO,
--             INDCONTRIBICMS,EMAIL,EMAILNFE,LOGRADOURO,UF,FANTASIA,FAXDDD,FAXNRO,INSCRICAOORG,INSCMUNICIPAL,
--             INDCONTRIBIPI,CIDADE,NROLOGRADOURO,ORGAOPUBLICO,ORGEXP,ORGEXPUF,PAIS,HOMEPAGE,NROINSCSUFRAMA,
--             FONEDDD1,FONENRO1,SEQBAIRRO,BAIRRO"
INNER JOIN implantacao.ge_pessoa d 
ON d.seqpessoa = a.seqpessoa AND d.atividade NOT IN ('FORNECEDOR') AND d.status = 'A'
-- Tabela utilizada para pegar a situação de crédito do cliente campo utilizado: "SITUACAOCREDITO"
INNER JOIN implantacao.ge_pessoacadastro e 
ON e.seqpessoa = a.seqpessoa
INNER JOIN (SELECT DISTINCT seqpessoa AS codpessoa, MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.mrl_cliente
            WHERE statuscliente = 'A'
            AND seqpessoa NOT IN (1, 22401)
            GROUP BY seqpessoa
            UNION ALL
            SELECT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.ge_pessoa
            WHERE atividade NOT IN ('FORNECEDOR')
            AND status = 'A'
            GROUP BY seqpessoa
            UNION ALL
            SELECT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.ge_pessoacadastro
            GROUP BY seqpessoa) f 
ON f.codpessoa = b.seqpessoa
WHERE 1 = 1
AND a.seqpessoa NOT IN (1, 22401)
AND a.statuscliente = 'A'
GROUP BY a.seqpessoa,a.statuscliente,e.limitecredito;



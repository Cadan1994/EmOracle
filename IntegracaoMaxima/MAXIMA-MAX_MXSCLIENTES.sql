SELECT
    DISTINCT
    a.seqpessoa                           AS  codcli,
    a.seqpessoa                           AS  codclipalm,
    a.seqpessoa                           AS  codcliprin,
    (SELECT nroformapagto
     FROM implantacao.mrl_clientecredito
     WHERE 1 = 1
     AND indprincipal = 'S'
     AND seqpessoa = a.seqpessoa)         AS  codcob,
    a.nroempresa                          AS  codfilialnf,
    a.seqtransportador                    AS  codfornecfrete,
    a.usualteracao                        AS  codfuncultalter,
    NVL(
      TO_CHAR(
        a.dtainativou,
        'YYYY-MM-DD'
      ),
      NULL
    )                                     AS  dtbloq,
    NVL(
      TO_CHAR(
        a.dtaultcompra,
        'YYYY-MM-DD'
      ),
      NULL
    )                                     AS  dtultcomp,
    CASE
    WHEN a.statuscliente = 'A'
    THEN 'N'
    ELSE 'S'
    END                                   AS  bloqueiodefinitivo,
    a.statuscliente                       AS  status,
    d.bairro                              AS  bairrocom,
    SUBSTR(d.cep, 0, 5) || '-' ||
    SUBSTR(d.cep, 5, 3)                   AS  cepcom,
    CASE
    WHEN d.fisicajuridica = 'F'
    THEN SUBSTR(CONCAT(LPAD(d.nrocgccpf, 9, '0'),LPAD(d.digcgccpf, 2, '0')), 0, 3) || '.' ||
         SUBSTR(CONCAT(LPAD(d.nrocgccpf, 9, '0'),LPAD(d.digcgccpf, 2, '0')), 4, 3) || '.' ||
         SUBSTR(CONCAT(LPAD(d.nrocgccpf, 9, '0'),LPAD(d.digcgccpf, 2, '0')), 7, 3) || '-' ||
         SUBSTR(CONCAT(LPAD(d.nrocgccpf, 9, '0'),LPAD(d.digcgccpf, 2, '0')), 10, 2)
    ELSE SUBSTR(CONCAT(LPAD(d.nrocgccpf, 12, '0'),LPAD(d.digcgccpf, 2, '0')), 0, 2) || '.' || 
         SUBSTR(CONCAT(LPAD(d.nrocgccpf, 12, '0'),LPAD(d.digcgccpf, 2, '0')), 3, 3) || '.' ||
         SUBSTR(CONCAT(LPAD(d.nrocgccpf, 12, '0'),LPAD(d.digcgccpf, 2, '0')), 6, 3) || '/' ||
         SUBSTR(CONCAT(LPAD(d.nrocgccpf, 12, '0'),LPAD(d.digcgccpf, 2, '0')), 9, 4) || '-' ||
         SUBSTR(CONCAT(LPAD(d.nrocgccpf, 12, '0'),LPAD(d.digcgccpf, 2, '0')), 13, 2)
    END                                   AS  cgcent,
    d.nomerazao                           AS  cliente,
    REPLACE(
      REPLACE(
        REPLACE(
          d.atividade,' ',''
        ),'/',''
      ),'-',''
    )                                     AS  codatv1,
    d.seqcidade                           AS  codcidade,
    d.cnae                                AS  codcnae,
    d.cmpltologradouro                    AS  complementocom,
    CASE 
    WHEN d.indcontribicms = 'S'
    THEN 'N'
    ELSE 'S' 
    END                                   AS  consumidorfinal,
    d.indcontribicms                      AS  contribuinte,
    d.email                               AS  email,
    d.emailnfe                            AS  emailnfe,
    CASE
    WHEN d.logradouro IS NULL
    THEN NULL
    ELSE d.logradouro
    END                                   AS  endercom,
    d.uf                                  AS  estcom,
    CASE
    WHEN d.fisicajuridica = 'F'
    THEN NULL
    ELSE d.fantasia
    END                                   AS  fantasia,
    d.faxddd||'-'||d.faxnro               AS  faxcom,
    d.inscricaorg                         AS  ieent,
    d.inscmunicipal                       AS  iment,
    d.indcontribicms                      AS  isentoicms,
    d.indcontribipi                       AS  isentoipi,
    d.cidade                              AS  municcom,
    d.nrologradouro                       AS  numerocom,
    d.orgaopublico                        AS  orgaopub,
    d.orgexp || '-' ||
    d.orgexpuf                            AS  orgaorg,
    d.pais                                AS  paisent,
    CASE 
    WHEN d.fisicajuridica = 'J'
    THEN NULL
    ELSE d.inscricaorg
    END                                   AS  rg,
    d.homepage                            AS  site,
    d.nroinscsuframa                      AS  suframa,
    d.foneddd1 || '-' ||
    d.fonenro1                            AS  telcom,
    d.fisicajuridica                      AS  tipofj,
    CASE
    WHEN e.situacaocredito = 'L'
    THEN 'N'
    ELSE 'S'
    END                                   AS  bloqueio,
    f.bairro                              AS  bairrocob,
    SUBSTR(f.cep, 0, 5) 
    ||'-'||                                
    SUBSTR(f.cep, 5, 3)                   AS  cepcob,
    f.cmpltologradouro                    AS  complementocob,
    CASE 
    WHEN f.logradouro IS NULL
    THEN NULL
    ELSE f.logradouro 
    END                                   AS  endercob,
    f.uf                                  AS  estcob,
    f.cidade                              AS  municcob,
    f.nrologradouro                       AS  numerocob,
    f.foneend                             AS  telcob,
    g.seqrede                             AS  codrede,
    h.latitude                            AS  latitude,
    h.longitude                           AS  longitude,
    NVL(i.calicmsst, 'N')                 AS  calculast,
    codplpag,
    codpraca,
    'S'                                   AS  condvenda1,
    'N'                                   AS  condvenda4,
    'N'                                   AS  condvenda5,
    'N'                                   AS  condvenda7,
    'N'                                   AS  condvenda8,
    'N'                                   AS  condvenda9,
    'N'                                   AS  condvenda11,
    'N'                                   AS  condvenda13,
    'N'                                   AS  condvenda14,
    'N'                                   AS  condvenda20,
    'N'                                   AS  condvenda24,
    'N'                                   AS  usadebcredrca,
    MAX(l.dtaalteracao)                   AS  dtaalteracao    
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
-- Tabela utilizada para pegar os campos: "BAIRRO,CEP,CMPLTOLOGRADOURO,NROLOGRADOURO,LOGRADOURO,UF,CIDADE,FONEEND"
LEFT  JOIN implantacao.ge_pessoaend f 
ON f.seqpessoa = a.seqpessoa AND f.tipoendereco = 'C'
-- Tabela utilizada para pegar o campo: "SEQREDE"
LEFT  JOIN implantacao.ge_redepessoa g 
ON g.seqpessoa = a.seqpessoa
-- Tabela utilizada para pegar os campos: "LATITUDE,LONGITUDE"
LEFT  JOIN (SELECT DISTINCT seqpessoa,latitude,longitude
            FROM implantacao.mad_clienteend) h 
ON h.seqpessoa = a.seqpessoa
-- Tabela utilizada para pegar o campo: "CALICMSST"
LEFT  JOIN (SELECT DISTINCT a.seqpessoa, b.calicmsst
            FROM implantacao.mad_clientecgo a
            INNER JOIN implantacao.max_codgeraloper b 
            ON b.codgeraloper = a.codgeraloper AND b.calicmsst = 'S'
            WHERE 1=1 
            AND a.status = 'A') i 
ON i.seqpessoa = a.seqpessoa
-- Select's utilizada para pegar os campos "NROEMPRESA,NROSEGMENTO,NROCONDPAGTOPADRAO,NROTABVENDAPRINC",
-- para criação do códigos das praças e códigos dos planos de pagamentos
LEFT  JOIN (SELECT 
                DISTINCT 
                b.nroempresa,
                a.seqpessoa,
                MIN(LPAD(b.nroempresa,2,0)||LPAD(a.nrosegmento,3,0)||LPAD(a.nrotabvendaprinc,4,0)) AS codpraca,
                MIN(LPAD(NVL(b.nrocondpagtopadrao,1),3,0)||LPAD(a.nrotabvendaprinc,3,0)) AS codplpag
            FROM implantacao.mrl_clienteseg a
            INNER JOIN implantacao.mrl_cliente b ON b.seqpessoa = a.seqpessoa 
            WHERE a.status = 'A'
            AND a.nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND (nrotabvendaprinc != 'NULL'
            OR (nrotabvendaprinc NOT IN (2,3,7,8,9,10,11,15,20,71,72,73,91,99,100,101,711,998,999)))
            GROUP BY b.nroempresa,a.seqpessoa) J
ON j.nroempresa = a.nroempresa AND j.seqpessoa = a.seqpessoa
-- Select's utilizados para pegar o campo da datas de alterações das tabelas:
-- MRL_CLIENTE,GE_PESSOA,GE_PESSOACADASTRO,GE_PESSOAEND,GE_REDEPESSOA,MAD_CLIENTEEND,MAD_CLIENTECGO,MRL_CLIENTESEG
LEFT  JOIN (SELECT DISTINCT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
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
            GROUP BY seqpessoa
            UNION ALL
            SELECT DISTINCT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.ge_pessoaend
            WHERE tipoendereco = 'C'
            GROUP BY seqpessoa
            UNION ALL
            SELECT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao 
            FROM implantacao.ge_redepessoa
            GROUP BY seqpessoa
            UNION ALL
            SELECT DISTINCT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mad_clienteend
            GROUP BY seqpessoa
            UNION ALL
            SELECT DISTINCT a.seqpessoa,MAX(TO_DATE(a.dtaalteracao)) AS dtaalteracao
            FROM implantacao.mad_clientecgo a
            INNER JOIN implantacao.max_codgeraloper b 
            ON b.codgeraloper = a.codgeraloper AND b.calicmsst = 'S'
            WHERE a.status = 'A'
            GROUP BY seqpessoa
            UNION ALL
            SELECT DISTINCT seqpessoa,MAX(TO_DATE(dtaalteracao)) AS dtaalteracao
            FROM implantacao.mrl_clienteseg
            WHERE status = 'A' 
            AND nrosegmento IN (1,3,4,5,6,7,8,9,10)
            AND seqpessoa NOT IN (1, 22401)
            GROUP BY seqpessoa) l
ON l.seqpessoa = a.seqpessoa
WHERE 1 = 1
AND a.statuscliente = 'A'
AND a.seqpessoa NOT IN (1, 22401)
GROUP BY a.nroempresa,a.seqpessoa,a.nrocondpagtopadrao,a.seqtransportador,a.usualteracao,a.dtainativou,a.dtaultcompra,
         a.statuscliente,d.status,d.cep,d.fisicajuridica,d.nrocgccpf,d.digcgccpf,d.nomerazao,d.atividade,d.seqcidade,
         d.cnae,d.cmpltologradouro,d.indcontribicms,d.indcontribicms,d.email,d.emailnfe,d.logradouro,d.uf,d.fisicajuridica,
         d.fantasia,d.faxddd,d.faxnro,d.inscricaorg,d.inscmunicipal,d.indcontribicms,d.indcontribipi,d.cidade,d.nrologradouro,
         d.orgaopublico,d.orgexp,d.orgexpuf,d.pais,d.fisicajuridica,d.inscricaorg,d.homepage,d.nroinscsuframa,d.foneddd1,
         d.fonenro1,d.fisicajuridica,d.seqbairro,d.bairro,e.situacaocredito,f.bairro,f.cep,f.cmpltologradouro,f.nrologradouro,
         f.logradouro,f.uf,f.cidade,f.nrologradouro,f.foneend,g.seqrede,h.latitude,h.longitude,i.calicmsst,codplpag,codpraca
ORDER BY 1 ASC;
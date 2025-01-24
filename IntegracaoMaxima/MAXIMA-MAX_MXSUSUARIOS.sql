SELECT 
    a.nrorepresentante                        AS    codusur,
    CASE 
    WHEN a.status = 'A'
    THEN 'N'
    ELSE 'S'
    END                                       AS    bloqueio,
    a.nrosegmento                             AS    coddistrib,
    (
    SELECT SUM(t1.nrorepresentante)
    FROM implantacao.mad_representante t1
    WHERE 1 = 1
    AND   t1.seqpessoa not in (1,22401)
    AND   t1.tiprepresentante = 'S'
    AND   t1.nroequipe = a.nroequipe
    )                                         AS    codsupervisor,
    a.nroempresa                              AS    codfilial,
    b.email                                   AS    email,
    b.nomerazao                               AS    nome,
    NVL(a.percmaxacrflex,0)                   AS    peracresfv,
    NVL(a.premvlrvenda,0)                     AS    percent,
    NVL(a.metaqtdprodmix,0)                   AS    percent2,
    NVL(a.percmaxacrflex,0)                   AS    permaxvenda,
    '(' || b.foneddd1 ||') ' || b.fonenro1    AS    telefone1,
    'E'                                       AS    tipovend,
    NVL(a.indgeraflexpreco, 'N')              AS    usadebcredrca,
    'N'                                       AS    validaracrescdescprecofixo,
    NVL(a.vlrminimopedido,0)                  AS    vlvendaminped,
    a.status,
    CASE
    WHEN TO_DATE(a.dtaalteracao) > 
         TO_DATE(b.datahoraalteracao)
    THEN TO_DATE(a.dtaalteracao)
    ELSE TO_DATE(b.datahoraalteracao)
    END                                       AS  dtaalteracao
FROM implantacao.mad_representante a
INNER JOIN implantacao.ge_pessoa b ON b.seqpessoa = a.seqpessoa
WHERE 1 = 1
AND a.seqpessoa not in (1,22401)
AND a.tiprepresentante != 'G'
ORDER BY 1 ASC;
SELECT
    a.seqcidade     AS  codcidade,      --> C�digo
    a.codibge       AS  codibge,        --> C�digo do IBGE
    a.cidade        AS  nomecidade,     --> Nome
    a.uf            AS  uf,             --> Unidade federativa (Estado)
    'A'             AS  status,
    a.dtaalteracao  AS  dtaalteracao
FROM implantacao.ge_cidade a
WHERE 1 = 1
ORDER BY 1 ASC;
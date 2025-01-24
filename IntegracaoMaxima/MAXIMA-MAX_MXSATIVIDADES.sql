SELECT
    REPLACE(
        REPLACE(
            REPLACE(
                a.lista,' ',''
            ),'/',''
        ),'-',''
    )                           AS  codativ,    --> Código
    a.lista                     AS  ramo,       --> Descrição
    0                           AS  percdesc,   --> Percentual acréscimo/desconto no preço de tabela
    'S'                         AS  calculast,  --> Irá calcular ST? (S ou N)
    'A'                         AS  status,
    NULL                        AS  dtaalteracao
FROM implantacao.ge_atributofixo a
WHERE 1 = 1
AND a.atributo = 'ATIVIDADE'
ORDER BY 1 ASC;

SELECT
    REPLACE(
        REPLACE(
            REPLACE(
                a.lista,' ',''
            ),'/',''
        ),'-',''
    )                           AS  codativ,    --> C�digo
    a.lista                     AS  ramo,       --> Descri��o
    0                           AS  percdesc,   --> Percentual acr�scimo/desconto no pre�o de tabela
    'S'                         AS  calculast,  --> Ir� calcular ST? (S ou N)
    'A'                         AS  status,
    NULL                        AS  dtaalteracao
FROM implantacao.ge_atributofixo a
WHERE 1 = 1
AND a.atributo = 'ATIVIDADE'
ORDER BY 1 ASC;

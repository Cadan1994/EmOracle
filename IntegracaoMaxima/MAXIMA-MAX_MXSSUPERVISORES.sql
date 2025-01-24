SELECT
    a.nrorepresentante                AS  codsupervisor,
    a.seqpessoa                       AS  cod_cadrca,
    d.seqpessoa                       AS  codgerente,
    b.nomerazao                       AS  nome,
    a.status                          AS  posicao,
    a.status,
    CASE
    WHEN TO_DATE(a.dtaalteracao) > 
         TO_DATE(b.datahoraalteracao)
    THEN TO_DATE(a.dtaalteracao)
    ELSE TO_DATE(b.datahoraalteracao)
    END                               AS  dtaalteracao
FROM implantacao.mad_representante a
INNER JOIN implantacao.ge_pessoa b ON b.seqpessoa = a.seqpessoa
INNER JOIN implantacao.mad_equipe c ON c.nroequipe = a.nroequipe 
INNER JOIN implantacao.mad_equipe d ON d.nroequipe = c.nroequipesuperior
WHERE 1 = 1
AND a.seqpessoa not in (1,22401)
AND a.tiprepresentante = 'S'
ORDER BY 1 ASC;

SELECT
    seqpessoa,
    NVL(CONCAT(LPAD(nrocgccpf,13,'0'),LPAD(digcgccpf,2,'0')),'0000000000000') nrocgccpf,
    REGEXP_REPLACE(nomerazao, '''', '') nomerazao,
    NVL(REGEXP_REPLACE(fantasia, '''', ''),' ') fantasia,
    NVL(fisicajuridica,'N') fisicajuridica,
    NVL(atividade,'NAO INFORMADA') atividade,
    NVL(cep,'00000000') cep,
    NVL(seqlogradouro,'0') seqlogradouro,
    NVL(seqbairro,'0') seqbairro,
    NVL(seqcidade,'0') seqcidade,
    TO_CHAR(dtainclusao,'DD/MM/YYYY') dtainclusao,
    NVL(TO_CHAR(dtaativacao,'DD/MM/YYYY'),'01/01/1899') dtaativacao,
    status
FROM implantacao.ge_pessoa
WHERE 1=1
AND status != 'P'
AND NVL(dtaalteracao,dtainclusao) >= SYSDATE-1
ORDER BY seqpessoa ASC
CREATE OR REPLACE VIEW POLIBRAS.VWP_DEVOLUCAO AS
SELECT 0 u_pkey,
t.nroempresa u_orgvenda,
CAST(r.nrorepresentante AS VARCHAR2(1000))   s_codvendedor,
CAST(g.seqpessoa AS VARCHAR2(1000))          s_codcliente,
CAST(t.numeronf AS VARCHAR2(1000))           s_numero_nota_dev,
TO_DATE(t.dtahorlancto, 'yyyy-mm-dd hh24:mi:ss') t_data_dev,
g.nomerazao s_nome_cliente,
TRIM (TO_CHAR (SUM ( (i.vlritem - i.vlrdescitem)), '99990.99')) d_valor_dev,
xx.descricao s_motivo_dev,
NVL (t.nfreferencianro, '0') s_nf_origem
FROM   (SELECT   a.lista, a.descricao descricao
 FROM   implantacao.MAX_ATRIBUTOFIXO A
WHERE   A.TIPATRIBUTOFIXO = 'OCORRENCIA DEVOL') xx,
implantacao.mlf_notafiscal t,
implantacao.mad_ocorrenciadevol d,
implantacao.mlf_nfitem i,
implantacao.mad_representante r,
implantacao.ge_pessoa g,
implantacao.mad_clienteend x
WHERE       d.nroempresa = i.nroempresa
AND r.nrorepresentante = i.nrorepresentante
AND t.numeronf = i.numeronf
AND t.seqpessoa = i.seqpessoa
AND t.serienf = i.serienf
AND t.statusnf = 'V'
AND t.codgeraloper IN (SELECT E.CODGERALOPER
                       FROM   implantacao.max_codgeraloper e
                      WHERE   e.tipdocfiscal = 'D')
AND t.ocorrenciadev = d.ocorrenciadev
AND g.seqpessoa = t.seqpessoa
AND t.ocorrenciadev = xx.lista
AND x.seqpessoa = g.seqpessoa
AND r.nroempresa = i.nroempresa
AND t.tipnotafiscal = i.tipnotafiscal

GROUP BY r.nrorepresentante,
t.nroempresa,
xx.descricao,
g.seqpessoa,
t.codgeraloper,
g.nomerazao,
R.NROSEGMENTO,
r.apelido,
t.numeronf,
t.nfreferencianro,
TO_DATE(t.dtahorlancto, 'yyyy-mm-dd hh24:mi:ss')

 

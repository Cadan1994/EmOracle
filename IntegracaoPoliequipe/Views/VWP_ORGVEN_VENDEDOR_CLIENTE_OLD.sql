CREATE OR REPLACE VIEW POLIBRAS.VWP_ORGVEN_VENDEDOR_CLIENTE AS
SELECT DISTINCT 0 u_pkey,
                x.nroempresa u_orgvenda,
                x.nrorepresentante s_codvendedor,
                a.seqpessoa s_codcliente,
                round((xx.LIMITECREDITO -
                      nvl(implantacao.fge_vlrcreduso(xx.SEQPESSOA), 0) -
                      implantacao.fmad_CliVlrPedAberto(xx.SEQPESSOA, null)),
                      2) d_limite_credito,
                0 d_descpetalao,
                2 u_prazoentrega
  FROM implantacao.mrl_cliente       a,
       implantacao.mad_clienterep    b,
       implantacao.mad_representante X,
       implantacao.mad_repsegmento   rs,
       implantacao.ge_pessoacadastro xx
WHERE 1=1
AND a.seqpessoa = b.seqpessoa
AND b.nrorepresentante = x.nrorepresentante
AND b.nrorepresentante = rs.nrorepresentante
AND a.seqpessoa = xx.seqpessoa
AND a.statuscliente = 'A'
AND x.status = 'A'
AND rs.status = 'A'
AND b.status = 'A'


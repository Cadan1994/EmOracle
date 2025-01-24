/*
-------------------------------------------------------------------------------
  Nome da View............: Hos_hos_Neogrid_Colgate
  Data Criação............: 17/03/2022
  Criado por..............: Hilson Santos
  Objetivo................: Utilizar na packages "Pkg_Edi_Neogrid_edit2",
                            onde pega os dados das notas fiscais para ge-
                            ração do arquivo texto para Neogrid.
-------------------------------------------------------------------------------
*/
create or replace view implantacao.hos_neogrid_colgate as
-- VENDAS NORMAIS DO ATACADO - GRAVADAS NA MLF_NOTAFISCAL
select
      a.dtaemissao as dtavda,
      a.nroempresa,
      a.numeronf as nrodocto,
      a.serienf as seriedocto,
      a.codgeraloper,
      b.seqproduto,
      nvl(b.seqprodutobase,b.seqproduto) as seqprodutocusto,
      b.quantidade as qtditem,
      0 as qtddevolitem,
      b.vlritem,
      nvl(b.vlrdescitem,0)+nvl(b.vlrfunruralitem,0) as vlrdesconto,
      0 as vlrdevolitem,
      nvl(b.vlricmsst,0) as vlricmsst,
      0 as vlrdevolicmsst,
      nvl(b.vlrfcpst,0) as vlrfcpst,
      0 as dvlrfcpst,
      d.acmcompravenda,
      d.acmcompravenda as cgoacmcompravenda,
      e.nrodivisao,
      decode(
             nvl(b.nrorepresentante,nvl(p.nroreppadrao,0)),
             0,
             nvl(b.nrosegitem,e.nrosegmentoprinc),
             coalesce(
                      b.nrosegitem,
                      (select nvl(max(r.nrosegmento),e.nrosegmentoprinc)
                       from   implantacao.mad_representante r
                       where  r.nrorepresentante = nvl(b.nrorepresentante,nvl(p.nroreppadrao,0)))
             )
      )
      as nrosegmento,
      'N' as tiptabela
from  implantacao.mlf_notafiscal     a,
      implantacao.mlf_nfitem         b,
      implantacao.max_codgeraloper   d,
      implantacao.max_empresa        e,
      implantacao.mad_segmento       s,
      implantacao.mad_parametro      p,
      implantacao.mrl_produtoempresa m,
      implantacao.ge_pessoa          pe,
      implantacao.max_divisao        v,
      (select nvl(max(x.valor),'N')
      from    implantacao.max_Parametro x
      where   x.nroempresa = 0
      and     x.grupo = 'ABC_DISTRIB'
      and     x.parametro = 'CONSID_ICMS_PRESUMIDO') pd1
where a.numeronf        = b.numeronf
and   a.seqpessoa       = b.seqpessoa
and   a.serienf         = b.serienf
and   a.tipnotafiscal   = b.tipnotafiscal
and   a.nroempresa      = b.nroempresa
and   nvl( a.seqnf, 0 ) = nvl( b.seqnf, nvl( a.seqnf, 0 ) )
and   a.codgeraloper    = d.codgeraloper
and   a.nroempresa      = e.nroempresa
and   s.nrosegmento     = nvl( b.nrosegitem, e.nrosegmentoprinc )
and   p.nroempresa      = a.nroempresa
and   m.seqproduto      = b.seqproduto
and   m.nroempresa      = nvl( e.nroempcustoabc, e.nroempresa )
and   a.seqpessoa       = pe.seqpessoa
and   e.nrodivisao      = v.nrodivisao
and   a.statusnf        = 'V'
/* Comentado, devido a exportação o arquivo da Neogrid_Colgate - desativado em 17/11/2022 por Hilson Santos */
--and   a.tipnotafiscal   = 'S'
--and   b.tipitem         = 'E'
--and   d.tipcgo          = 'S'
and   b.quantidade      != 0
and   (coalesce(a.geralteracaoestq,d.geralteracaoestq) = 'S'
or    d.acmcompravenda in ('S','I'))
/* Incluido os código de CGO de vendas e devoluções » alterado em 25/11/2022 por Hilson Santos */
and   a.codgeraloper in (201, 202, 225, 228, 235, 307, 313, 314, 575, 598, 701, 102, 133, 173, 177, 188, 251, 401, 402, 567, 581, 708)

union all

-- VENDAS NORMAIS DO ATACADO - GRAVADAS NA MFL_DOCTOFISCAL
select
      a.dtamovimento as dtavda,
      a.nroempresa,
      a.numerodf as nrodocto,
      a.seriedf as seriedocto,
      a.codgeraloper,
      b.seqproduto,
      nvl(b.seqprodutobase,b.seqproduto) as seqprodutocusto,
      b.quantidade as qtditem,
      0 as qtddevolitem,
      b.vlritem,
      nvl(b.vlrdesconto,0) - nvl(b.vlrdescbonifabc,0) as vlrdesconto,
      0 as vlrdevolitem,
      nvl(b.vlricmsst,0) as vlricmsst,
      0 as vlrdevolicmsst,
      nvl(b.vlrfcpst,0) as vlrfcpst,
      0 as dvlrfcpst,
      d.acmcompravenda,
      d.acmcompravenda as cgoacmcompravenda,
      e.nrodivisao,
      nvl(nvl(b.nrosegitem,a.nrosegmento),e.nrosegmentoprinc) as nrosegmento,
      'D' as tiptabela
from  implantacao.mfl_doctofiscal    a,
      implantacao.mfl_dfitem         b,
      implantacao.max_codgeraloper   d,
      implantacao.max_empresa        e,
      implantacao.mad_segmento       s,
      implantacao.mad_parametro      x,
      implantacao.mrl_produtoempresa m,
      implantacao.ge_pessoa          pe,

      (select nvl(max(x.valor),'N')
      from   implantacao.max_parametro x
      where  x.nroempresa = 0
      and    x.grupo = 'ABC_DISTRIB'
      and    x.parametro = 'EXIBE_VDA_EQUIPE_ATUAL_REP') pd1,

      (select nvl(max(x.valor),'N')
      from   implantacao.max_parametro x
      where  x.nroempresa(+) = 0
      and    x.grupo(+) = 'ABC_DISTRIB'
      and    x.parametro(+) = 'UTIL_DETALHE_TABELA_VENDA') pd2,

      (select nvl(max(x.valor),'N')
      from   implantacao.max_parametro x
      where  x.nroempresa(+) = 0
      and    x.grupo(+) = 'ACORDO_EST_PDV'
      and    x.parametro(+) = 'UTIL_NOVO_CALC_APURACAO') pd4,

      (select nvl(max(x.valor),'N')
      from   implantacao.max_parametro x
      where  x.nroempresa(+) = 0
      and    x.grupo(+) = 'ACORDO_EST_PDV'
      and    x.parametro(+) = 'VISUALIZA_TODAS_PROMOCOES') pd4,

      (select nvl(max(x.valor),'N')
      from   implantacao.max_parametro x
      where  x.nroempresa(+) = 0
      and    x.grupo(+) = 'ABC_DISTRIB'
      and    x.parametro(+) = 'SUBTRAI_DESC_ACORDO_VERBA_PDV') pd5,

      (select nvl(max(x.valor),'T')
      from   implantacao.max_parametro x
      where  x.nroempresa(+) = 0
      and    x.grupo(+) = 'ABC_DISTRIB'
      and    x.parametro(+) = 'TIPO_REPRESENTANTE_NULO_ITEM') pd6,

      (select nvl(max(x.valor),'N')
      from   implantacao.max_parametro x
      where  x.nroempresa(+) = 0
      and    x.grupo(+) = 'ABC_DISTRIB'
      AND    x.parametro = 'CONSID_ICMS_PRESUMIDO') pd7,
      implantacao.max_divisao v,
      implantacao.max_paramgeral pg,
      implantacao.mfl_promocaopdv pdv
where a.numerodf        = b.numerodf
and   a.seriedf         = b.seriedf
and   a.nroserieecf     = b.nroserieecf
and   a.nroempresa      = b.nroempresa
and   nvl(a.seqnf, 0)   = nvl(b.seqnf, nvl(a.seqnf, 0))
and   a.codgeraloper    = d.codgeraloper
and   a.nroempresa      = e.nroempresa
and   s.nrosegmento     = nvl( nvl( b.nrosegitem, a.nrosegmento ), e.nrosegmentoprinc )
and   x.nroempresa      = a.nroempresa
and   m.seqproduto      = nvl( b.seqprodutobase, b.seqproduto )
and   m.nroempresa      = nvl( e.nroempcustoabc, e.nroempresa )
and   a.seqpessoa       = pe.seqpessoa
and   e.nrodivisao      = v.nrodivisao
and   b.seqpromocpdv    = pdv.seqpromocpdv(+)
and   a.statusdf        = 'V'
and   b.statusitem      = 'V'
/* Comentado, devido a exportação o arquivo da Neogrid_Colgate - desativado em 17/11/2022 por Hilson Santos */
--and   d.tipcgo          = 'S'
and   b.quantidade      != 0
and   nvl(b.indtipodescbonif, 'I') != 'T'
and   (coalesce (a.geralteracaoestq,d.geralteracaoestq) = 'S'
or    d.acmcompravenda in ('S','I'))
/* Incluido os código de CGO de vendas e devoluções » alterado em 25/11/2022 por Hilson Santos */
and   a.codgeraloper in (201, 202, 225, 228, 235, 307, 313, 314, 575, 598, 701, 102, 133, 173, 177, 188, 251, 401, 402, 567, 581, 708)


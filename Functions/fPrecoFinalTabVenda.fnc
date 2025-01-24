CREATE OR REPLACE Function IMPLANTACAO.fPrecoFinalTabVenda(
       pnSeqProduto                   in MRL_PRODEMPSEG.SEQPRODUTO%type,
       pnNroEmpresa                   in MRL_PRODEMPSEG.NROEMPRESA%type,
       pnNroSegmento                  in MRL_PRODEMPSEG.NROSEGMENTO%type,
       pnQtdEmbalagem                 in MRL_PRODEMPSEG.QTDEMBALAGEM%type,
       psNroTabVenda                  in MAD_TABVENDA.NROTABVENDA%type,
       pnNroCondicaoPagto             in MAD_CONDICAOPAGTO.NROCONDICAOPAGTO%type,
       pnSeqPessoa                    in GE_PESSOA.SEQPESSOA%type,
       psUfDestino                    in GE_PESSOA.UF%type,
       pnNroRepresentante             in MAD_REPRESENTANTE.NROREPRESENTANTE%type,
       psIndEntregaRetira             in MAD_PEDVENDA.INDENTREGARETIRA%type,
       psIndTipoPrecoRetorno          in MAD_PEDVENDA.INDENTREGARETIRA%type,
       pnQuantidade                   in mad_pedvendaitem.qtdpedida%type default null,
       psUsaDescComercial             in varchar2 default 'S',
       pnNroPedVenda                  in mad_pedvendaitem.nropedvenda%type default null,
       pnSeqPedVendaItem              in mad_pedvendaitem.seqpedvendaitem%type default null,
       psIndPrecoTabPrecoInformado    in varchar2 default 'I',--Alterado o Default de 'T' para 'I'
       pnCodGeralOper                 in varchar2 default null,
       pnQtdCasasDecimais             in number default null,
       psCalcAjustFiscalIPI           in varchar2 default 'S',
       psCalcVlrEmbTabPrecoSemFrete   in varchar2 default 'S',
       pdDtaBasePreco                 in date     default null,
       psSubtraiIcmsStDoPrecoFinal    in varchar2 default 'N',
       psDesconsideraAcresDesc        in varchar2 default null -- Implementar futuros desvios no cálculo através desse parãmetro
                                                               -- concatenando e criando as novas letras que identificarão as desconsiderações
                                                               -- C - Acréscimo e descontos de Condição de Pagamento
)
return number
is
       vnTemTabPrecoCFA               integer;
       vnTemPrecoDifEmb               integer;
       vnqtdembvendaprecotab          number := 0;
       vnlixo                         number;
       vnPrecoVda                     number := 0;
       vnPrecoPromocCliRep            number := 0;
       vnPrecoVdaCompl                number := 0;
       vnPrecoPartida                 number:=0;
       vnindexformapreco              mad_tabvdatribabc.indexformapreco%type := 0;
       vnNroDivisao                   MAX_DIVISAO.NRODIVISAO%type;
       vsMetodoPrecificacao           MAX_DIVISAO.METODOPRECIFICACAO%type;
       vsTipDivisao                   MAX_DIVISAO.METODOPRECIFICACAO%type;
       vnSeqFamilia                   MAP_FAMDIVISAO.SEQFAMILIA%type;
       vnNroTributacao                MAP_FAMDIVISAO.NROTRIBUTACAO%type;
       vsIndContribIcms               GE_PESSOA.INDCONTRIBICMS%type;
       vsFaixaValidAcrFin             MRL_PRODEMPSEG.FAIXAVALIDACRFIN%type;
       vnPerAcrEntrega                MAD_TABVENDA.PERACRENTREGA%type;
       vnPerAcrFinanceiro             MAD_TABVENDACOND.PERACRFINANCEIRO%type;
       vnPerAcrFinanceiroFornecCond   MAF_FORNECCOND.PERACRFINANCEIRO%type;
       vnPercAcrDesctoTributarioUf    MAD_UFEMPTRIB.PERACRDESCTO%type;
       vnPercAcrDesctoTributarioTab   MAD_TABVENDATRIB.PERACRTRIBUTARIO%type;
       vnCliSegPercAcrDescComerc      mrl_clienteseg.percacrdesccomerc%type;
       vsUfCli                        GE_PESSOA.UF%type;
       vsUfEmpresa                    MAX_EMPRESA.UF%type;
       vsDefaultEntRet                MAX_EMPRESASEG.DEFAULTENTRET%type;
       vsTipAcrDescEntRet             MAX_EMPRESASEG.TIPACRDESCENTRET%type;
       vnPerAcrDescEntrega            MAX_EMPRESASEG.PERACRDESCENTREGA%type;
       vnPerAcrDescRetira             MAX_EMPRESASEG.PERACRDESCRETIRA%type;
       vnPerAcrDescRetiraRepres       MAD_REPRESENTANTE.PERACRDESCRETIRA%type;
       vnPerAcrDescEntregaRepres      MAD_REPRESENTANTE.PERACRDESCENTREGA%type;
       vnVlrComplPrecoUnit            MAD_SEGMENTO.VLRCOMPLPRECOUNIT%type;
       vnPercIncentivoCliente         MFL_REGRAINCENTIVO.PERCINCENTIVO%type;
       vnPercMaxDesctoBloq            MAD_PRODEMPSEGBLOQ.PERCMAXDESCTO%type;
-- novas variaveis (tabela de venda)
       vsIndPrecoBase                 MAD_TABVENDA.INDPRECOBASE%type;
       vsIndSubtraiVerba              MAD_TABVENDA.INDSUBTRAIVERBA%type;
       vsIndSomaVerba                 MAD_TABVENDA.INDSOMAVERBA%type;
       vsIndFormacaoPreco             MAD_TABVENDA.INDFORMACAOPRECO%type;
       vsIndIcmsFormaPreco            MAD_TABVENDA.INDICMSFORMAPRECO%type;
       vsIndIPIFormaPreco             MAD_TABVENDA.INDICMSFORMAPRECO%type;
       vsIndDespFormaPreco            MAD_TABVENDA.INDDESPFORMAPRECO%type;
       vsIndComisFormaPreco           MAD_TABVENDA.INDCOMISFORMAPRECO%type;
       vsIndMargFormaPreco            MAD_TABVENDA.INDMARGFORMAPRECO%type;
       vsIndPerPisFormaPreco          mad_tabvenda.indperpisformapreco%type;
       vsIndPerCofinsFormaPreco       mad_tabvenda.indpercofinsformapreco%type;
       vsIndPerCPMFFormaPreco         mad_tabvenda.indpercpmfformapreco%type;
       vnPerAdicFormaPreco            MAD_TABVENDA.PERADICFORMAPRECO%type;
       vsIndFaturamento               MAD_TABVENDA.INDFATURAMENTO%type;
       vsUfUnica                      MAD_TABVENDA.UFUNICA%type;
       vsTipoTabVenda                 MAD_TABVENDA.TIPOTABVENDA%type;
       vsUsaPromocCliRep              max_divisao.usapromocclirep%type;
       vsTabIndUsaRegraIncentivo      MAD_TABVENDA.INDUSAREGRAINCENTIVO%type;
       vsIndSomaDespForaNf            mad_tabvenda.indsomadespforanf%type;
       vsIndSomaDespNf                mad_tabvenda.indsomadespnf%type;
-- variaveis para calculo do custo do produto
       vnCustoBase                    number :=0;
       vnPerPis                       MAX_EMPRESA.PERPIS%type;
       vnPerCofins                    MAX_EMPRESA.PERCOFINS%type;
       vsIndPisCofinsTabVendaTrib     mad_tabvendatrib.indpiscofinstabvenda%type;
       vnPerPisTabVendaTrib           mad_tabvendatrib.perpis%type;
       vnPerCofinsTabVendaTrib        mad_tabvendatrib.percofins%type;
       vnPerCPMF                      MAX_EMPRESA.PERCPMF%type;
       vnPerIR                        MAX_EMPRESA.PERIR%type;
       vnPerOutroImposto              MAX_EMPRESA.PEROUTROIMPOSTO%type;
       vnPerDespOperacional           MAX_EMPRESA.PERDESPOPERACIONAL%type;
       vsUfFormacaoPreco              MAX_EMPRESA.UFFORMACAOPRECO%type;
       vsIndIsentoPis                 MAP_FAMILIA.INDISENTOPIS%type;
       vnPerAliqIcmsSaida             MAP_TRIBUTACAOUF.PERALIQUOTA%type;
       vnPerComissaoNormal            MAP_CLASSIFABC.PERCOMISSAONORMAL%type;
       vnPerComissaoPromoc            MAP_CLASSIFABC.PERCOMISSAOPROMOC%type;
       vnPerDespClassifAbc            MAP_CLASSIFABC.PERDESPCLASSIFABC%type;
       vnMgmLucroClassifAbc           MAP_CLASSIFABC.MGMLUCROCLASSIFABC%type;
       vsCgcBaseCli                   varchar2(8);
       vsCgcBaseEmpr                  varchar2(8);
       vnNroRegTributacao             max_empresa.nroregtributacao%type;
       vnNroRegTributCli              max_empresa.nroregtributacao%type;
       vnNroEmpresaFatTabVdaTrib      MAD_TABVENDATRIB.NROEMPRESAFAT%type;
       vnPerAcrTributarioTabVdaTrib   MAD_TABVENDATRIB.PERACRTRIBUTARIO%type;
       vsIndUsaDescIncentiv           MAD_CONDICAOPAGTO.INDUSADESCINCENTIV%type;
       vsParamTabVendaCateg           max_divisao.paramtabvendacateg%type;
       vsIndUsaPercAcrTabVenda        map_categoria.indusapercacrtabvenda%type;
       vsUsacompprecounid             mad_famsegmento.usavlrcompprecounid%type;
       vnpercfretetransp              mad_tabvenda.percfretetransp%type;
       vnPercAdicComissaoPreco        mad_tabvdaclassifabc.percomissaonormal%type;
       vnperacresprecoclassabc        mad_tabvdaclassifabc.peracrespreco%type;
       vsindacrtabvendatrib           mad_parametro.indacrtabvendatrib%type;
       vnPerAcrescDescTabFor          mad_tabvdafornec.peracrescdesc%Type;
       vnPerAcrescDescTabForCat       mad_tabvdaforncateg.peracrescdesccateg%Type;
       vsPrecoPromTabVenda            varchAR2(1) :='N' ;
       vnNroEmpresaPreco              mad_tabvenda.nroempresapreco%type;
       vnNroSegmentoPreco             mad_tabvenda.nrosegmentopreco%type;
       vsPromUsaAcrescTabVenda        mrl_promocao.indusaacresctabvenda%type;
       vsPD_IndConsidComissaoPreco    VARCHAR2(1);
       vsPD_IndGerDescVerbComp        max_parametro.valor%type;
       vsPD_GeraCustoVerbaBonif       max_parametro.valor%type;
       vsPD_Util_Acres_Desc_Forn      max_parametro.valor%type;
       vdDtaUltCompraAux              MRL_PRODUTOEMPRESA.DTAULTCOMPRA%type;
       vdDtaUltEntrCusto              mrl_produtoempresa.dtaultentrcusto%type;
       vsIndDeduzVlrIcmsStDistrib     MAD_TABVENDA.INDDEDUZVLRICMSSTDISTRIB%TYPE;
       vnNroFormaPagto                MAD_PEDVENDA.NROFORMAPAGTO%TYPE;
       vsPD_AplicaAcresDescPromoc     MAX_PARAMETRO.VALOR%TYPE;
       vsIndicaPrecoPromocao          VARCHAR(2);
       vnPercFreteCidade               GE_CIDADE.PERCFRETE%TYPE;
       vnpercacrescdesc               mad_classcomacrescdesc.percacrescdesc%type;
       vnQtdeCasasDecRet              integer;
       vsIndUsaPercFreteCidade        MAD_TIPOENTREGA.Indusa_Percfrete_Cidade%type;
       vnPercAbatFrete                MAD_FAMSEGMENTO.PERCABATFRETE%TYPE;
       vsAplicaAbatFrete              MAD_FAMSEGMENTO.APLICAABATFRETE%TYPE;
       vnPD_PercVendaProdSemCusto     number;
       vsIndConsidDescForaNFCalcPreco MAD_TABVENDA.INDCONSIDDESCFORANFCALCPRECO%TYPE;
       vsindapropdescfincusto         max_empresa.indapropdescfincusto%type;
       vsIndPromocCliRep              varchar2(1) := 'N';
       vnPercAcresDescCategProd       mad_periodojurosdescprod.desconto%type;
       vnCliSegPercAcrPrecoVda        mrl_clienteseg.percacrprecovda%type;
       vnCliSegPercRestorno           mrl_clienteseg.percrestorno%type;
       vnVlrIndiceRestorno            mad_pedvendaitem.vlrindicerestorno%type;
       vsPD_TipoCalcFretePreco        max_parametro.valor%type;
       vsTipCalcMargem                max_divisao.tipcalcmargem%type;
       vnPerDespSegmento              mad_famsegmento.perdespesasegmento%type;
       vnPerDespDivisao               map_famdivisao.perdespesadivisao%type;
       vsIndUtilFormPcoVdaAjIPI       map_famdivisao.indutilformpcovdaajipi%type;
       vsindUtilformPcoIPISobMIPC     max_empresa.indutilformpcoipisobmipc%type;
       vnIndImpostoSIPI               number := 0;
       vnIndImpostoCIPI               number := 0;
       vnPerPisIndIPI                 number;
       vnPerCofinsIndIPI              number;
       vnPerICMSIndIPI                number;
       vnMargIndIPI                   number;
       vnPerIPI                       number := 0;
       vnIndFormPCOIPISobMIPC         number := 0;
       vnFatorDivisaoIPI              number := 1;
       vnpercajusteficalipi           MAX_EMPRESA.PERCAJUSTEFICALIPI%TYPE := 0;
       vnNroEmpPcoAjustIPI            MAX_EMPRESA.NROEMPRESA%TYPE;
       vnPcoVendaEmpAjustIPI          number := 0;
       vnCustoConfig                  number := 0;
       vnQtdParcelas                  integer;
       vnCodOrigemTrib                map_famdivisao.codorigemtrib%type;
       vnMgmLucroCategoria            map_categoria.mgmlucrocategoria%type;
       vsindConsDtaUltCompra          MAD_TABVENDA.INDCONSDTAULTCOMPRA%TYPE;
       vsPD_GerDescComFinPromo        VARCHAR2(1);
       vsPDInsereCompProdCompVar      max_parametro.valor%type;
       vnSeqReceitaRendto             mrl_receitarendto.seqreceitarendto%type;
       vnPrecoBaseRestorno            number := 0;
       vsResolucao13IntraUF           max_empresa.indresolucao13intrauf%type;
       vsPDConsNotaTransf             max_parametro.valor%type;
       vsPDQtdCsaDecPcoCsto           max_parametro.valor%type;
       vsPDSomaFunRuralVlrCusto       max_parametro.valor%type;
       vsPDSomaDescClassComercFornec  max_parametro.valor%type;
       vsPDUtilClassComercSegmento    max_parametro.valor%type;
       vnPercAcrescDescClassComercSeg mad_classcomacrescdesc.percacrescdesc%type;
       vnPercAcrescDescFornecSeg      mrl_clientesegfornec.percacrescdesc%type;
       vsIndBuscaCustoEmpPedZerado    mad_tabvenda.indbuscacustoemppedzerado%type;
       vsPDSubIcmsPresum              max_parametro.valor%type;
       vsIndCalcIPISaida              map_familia.indcalcipisaida%type;
       vdDtaUltCompraCusto            mrl_produtoempresa.dtaultcompracusto%type;
       vnAliqUltCompra                mlf_nfitem.peraliquotaicms%type;
       vnCmUltCredIcms                mrl_produtoempresa.cmultcredicms%type;
       vnCmUltIcmsSt                  mrl_produtoempresa.cmulticmsst%type;
       vsPDPermClassifAbcTabVdaSeg    max_parametro.valor%type;
       vsClassifComercAbcTabVenda     mad_famsegtabvenda.classifcomercabc%type;
       vsIndNFEstornoPisCofins        max_codgeraloper.indnfestorno%type;
       vnBasCalcPisCofins             mlf_nfitem.bascalcpis%type;
       vsPDSubDespFixaTransf          max_parametro.valor%type;
       vnPercAcresDescFamilia         mad_tabvdafam.peracrescdesc%type;
       vsIndUsaVlrAdicSetor           MAX_PARAMGERAL.Indusavlradicsetor%type;
       vnPercAdicPrecoSetor           MAP_FAMILIA.PERCADICPRECOSETOR%TYPE;
       vnVlrAdicPrecoSetor            MAD_SETOR.VLRADICPRECO%TYPE;
       vnVlrAdicPrecoRota             MAD_ROTA.VLRADICPRECO%TYPE;
       vsPDUtilAcrDescCateg           max_parametro.valor%type;
       vsPDUtilAcrDescFam             max_parametro.valor%type;
       vnSeqAtribListaClasAtiv        mad_tabvdatipclassativ.seqatribfixocateg%type;
       vsListaAtivCliente             ge_atributofixo.lista%type;
       vnPesoBruto                    map_famembalagem.pesobruto%type;
       vnPesoLiquido                  map_famembalagem.pesoliquido%type;
       vnSeqNf                        mlf_notafiscal.seqnf%type;
       vsTipoNF                       varchar2(1);
       vdDtaEntrada                   mlf_notafiscal.dtaentrada%type;
       vsPercTabVendaCategEmp         MAP_CATEGEMPRESATABVENDA.PERCACRESDESCTO%TYPE;
       vnSeqProdutoBase               map_produto.seqproduto%type;
       vsPDSubtraiIcmsStVlrProd       max_parametro.valor%type;
       vnPmtSubtraiIcmsStVlrProd      varchar2(1);
       vsPDUfClienteSubtrairIcmsSt    max_parametro.valor%type;
       vsPD_PermCadPorEmpresa         max_parametro.valor%type;
       vnPercFCP                      map_tributacaouf.peraliqfcpicms%type;
       vsIndFCPFormaPreco             mad_tabvenda.indfcpicmsformapreco%type;
       vsIndConsImpostoPresum         mad_tabvenda.Indconsimpostopresum%type;
       vsTipoTributacao               varchar2(2);
       vnPrecoRetorno                 number := 0;
       vnPerIcmsDiferidoSaida         MAP_TRIBUTACAOUF.PERDIFERIDO%type;
       vsSituacaoNf                   MAP_TRIBUTACAOUF.SITUACAONF%type;
       vnPercCalcPreco                map_tributacaouf.peraliqicmscalcpreco%type;
       vnQtdeProporcaoProdBase        map_produto.propqtdprodutobase%type;
       vsPDUtilizPercPropBaixaProd    max_parametro.valor%type;
       vsPDUtilPrecoTabVenda          max_parametro.valor%type;
       Vsindexecutarotinaprodutocusto varchar2 (1) default 'S';
       vsIndEstornaIcmsBasePisCofins  max_codgeraloper.indestornaicmsbasepiscofins%type;
       vsIndEstIcmsBasePisCofinsEmp   max_cgoempresa.indestornaicmsbasepiscofins%type;
       vnPerPisCalculo                map_familia.perbasepis%type;
       vnPerCofinsCalculo             map_familia.perbasecofins%type;
       vnPercIcmsSaidaPisCofins       map_tributacaouf.peraliquota%type;
begin
  /*verifica se utiliza perc. acrescimo/desconto associado a cidade da pessoa - RC 64136 */
  SELECT NVL(MAX(A.INDUSA_PERCFRETE_CIDADE), 'N')
  INTO   vsIndUsaPercFreteCidade
  FROM   MAD_TIPOENTREGA A
  WHERE  A.TIPOENTREGA = psIndEntregaRetira
  AND    A.NROEMPRESA = pnNroEmpresa;
  SELECT NVL(MAX(E.NROEMPRESA),pnNroEmpresa)
    INTO vnNroEmpPcoAjustIPI
    FROM MAX_EMPRESA E
   WHERE E.SEQPESSOAEMP = pnSeqPessoa;
  SELECT NVL(MAX(B.PERCFRETE),0)
  INTO   vnPercFreteCidade
  FROM   GE_PESSOA A,
         GE_CIDADE B
  WHERE  A.SEQCIDADE  =   B.SEQCIDADE
  AND    A.SEQPESSOA  IN ( pnSeqPessoa );
-- Verificando se o nropedvenda não é nulo, pois através dele será feita a buscar do nroformapagto
if pnNroPedVenda is not null then
   vnNroFormaPagto := to_number(null);
   select        max(NROFORMAPAGTO)
   into          vnNroFormaPagto
   from          MAD_PEDVENDA
   where         NROPEDVENDA    =   pnNroPedVenda
   and           NROEMPRESA     =   pnNroEmpresa;
end if ;
 -- *** Busca os parametros dinamicos
  -- Parametros dinamicos, nessa função não pode fazer insert do parâmetro tem que apenas verifica o valor dos mesmo
  select nvl(fc5maxparametro('RECEBTO_NF', pnNroEmpresa, 'GERA_DESC_VERB_BONIFIC'), 'N'),
         nvl(fc5maxparametro('RECEBTO_NF', pnNroEmpresa, 'IND_GERA_CUSTO_VERBA_BONIF'), 'N'),
         nvl( fc5maxparametro('TAB_VENDA', pnNroEmpresa, 'UTIL_ACRES_DESC_FORNEC_CATEG'), 'N'),
         nvl( fc5maxparametro('CONSULTA_PROD', 0, 'APLICA_ACRES_DESC_PROMOC'), 'S'),
         to_number(nvl( fc5maxparametro('TAB_VENDA', pnNroEmpresa, 'PERC_VENDA_PROD_SEM_CUSTO'), '100'))/100 /* RC 64642 */,
         nvl( fc5maxparametro('PED_VENDA', 0, 'TIPO_CALC_FRETE_PRECO'), 'S'),
         nvl( fc5maxparametro ('PED_VENDA', pnNroEmpresa, 'GER_DESC_COMER_FINANC_PROMOC'), 'S'),
         nvl( fc5maxparametro('PED_VENDA', pnNroEmpresa, 'INS_COMPONENTES_PROD_COMP_VAR'),'N'),
         nvl( fc5maxparametro('PED_VENDA', pnNroEmpresa, 'CONS_NOTA_TRANSF_ULT_CUSTO'),'N'),
         nvl( fc5maxparametro('PED_VENDA', pnNroEmpresa, 'QTDE_CASAS_DECIMAIS_PCO_CTO'),'2'),
         nvl( fc5maxparametro('PED_VENDA', 0, 'SOMA_FUNRURAL_VLR_CUSTO'),'S'),
         nvl( fc5maxparametro('PED_VENDA', pnNroEmpresa, 'SOMA_DESC_CLASS_COMERC_FORNEC'),'N'),
         nvl( fc5maxparametro('MAX_CLIENTE', 0, 'UTIL_CLASS_COMERC_SEGMENTO'),'N'),
         nvl( fc5maxparametro('PED_VENDA', 0, 'SUB_ICMS_PRES_ULT_CL'),'N'),
         nvl( fc5maxparametro('PED_VENDA', 0, 'SUB_ICMS_PRES_ULT_CL'),'N'),
         nvl( fc5maxparametro('NF_TRANSFERENCIA', 0, 'IND_SUB_DESP_FIXA'), 'N'),
         nvl( fc5maxparametro('TAB_VENDA', 0, 'UTIL_ACRES_DESC_CATEG_ATV'), 'N'),
         nvl( fc5maxparametro('TAB_VENDA', 0, 'UTIL_ACRES_DESC_FAM_ATV'), 'N'),
         nvl( fc5maxparametro('PED_VENDA', pnNroEmpresa, 'SUBTRAIR_ICMSST_VALOR_PRODUTO'),'N'),
         nvl( fc5maxparametro('PED_VENDA', pnNroEmpresa, 'INF_UF_CLIENTE_SUBTRAIR_ICMSST'),'MG'),
         nvl( fc5maxparametro('RECEITA_RENDTO', 0, 'PERM_CAD_POR_EMPRESA'), 'N'),
         nvl( fc5maxparametro('PED_VENDA', 0, 'UTILIZ_PERC_PROP_BAIXA_PROD'), 'N'),
         nvl( fc5maxparametro('PED_VENDA', 0, 'UTIL_PREC_TAB_VENDA_AJ_CRED_PC'), 'N')
  into   vsPD_IndGerDescVerbComp,
         vsPD_GeraCustoVerbaBonif,
         vsPD_Util_Acres_Desc_Forn,
         vsPD_AplicaAcresDescPromoc,
         vnPD_PercVendaProdSemCusto,
         vsPD_TipoCalcFretePreco,
         vsPD_GerDescComFinPromo,
         vsPDInsereCompProdCompVar,
         vsPDConsNotaTransf,
         vsPDQtdCsaDecPcoCsto,
         vsPDSomaFunRuralVlrCusto,
         vsPDSomaDescClassComercFornec,
         vsPDUtilClassComercSegmento,
         vsPDSubIcmsPresum,
         vsPDSubIcmsPresum,
         vsPDSubDespFixaTransf,
         vsPDUtilAcrDescCateg,
         vsPDUtilAcrDescFam,
         vsPDSubtraiIcmsStVlrProd,
         vsPDUfClienteSubtrairIcmsSt,
         vsPD_PermCadPorEmpresa,
         vsPDUtilizPercPropBaixaProd,
         vsPDUtilPrecoTabVenda
  from   dual;
  vsPDPermClassifAbcTabVdaSeg := nvl(fc5maxparametro('CADASTRO_FAMILIA', 0, 'PERM_CLASSIFABC_TABVDASEG'), 'N');
    if vsPDSubtraiIcmsStVlrProd = 'S' AND
       psSubtraiIcmsStDoPrecoFinal = 'S' AND
       INSTR(vsPDUfClienteSubtrairIcmsSt, psUfDestino) > 0
    then
        vnPmtSubtraiIcmsStVlrProd := 'S';
    else
        vnPmtSubtraiIcmsStVlrProd := 'N';
    end if;
  IF vsPD_GerDescComFinPromo != 'S' THEN
       SELECT COUNT(1)
       INTO   vnlixo
       FROM   mrl_prodempseg a
       WHERE  a.seqproduto       =  pnSeqProduto
       AND    a.qtdembalagem     =  pnQtdEmbalagem
       AND    a.nrosegmento      =  pnNroSegmento
       AND    a.nroempresa       =  pnnroempresa
       AND    a.precovalidpromoc >  0;
       IF vnlixo > 0 THEN
          IF vsPD_GerDescComFinPromo = 'C' THEN
             vsPD_GerDescComFinPromo := 'S';
          ELSIF vsPD_GerDescComFinPromo = 'F' THEN
             vsPD_GerDescComFinPromo := 'N';
          END IF;
       ELSE
           vsPD_GerDescComFinPromo := 'S';
       END IF;
  END IF;
-- busca a divisao e outras informações da empresa
select A.NRODIVISAO,
       A.UF,
       A.PERPIS,
       A.PERCOFINS,
       A.PERCPMF,
       A.PERIR,
       A.PEROUTROIMPOSTO,
       A.PERDESPOPERACIONAL,
       nvl(A.UFFORMACAOPRECO, a.uf),
       substr(lpad(A.NROCGC, 12, '0'), 1, 8),
       nvl(a.nroregtributacao, 0),
       B.METODOPRECIFICACAO,
       B.TIPDIVISAO,
       nvl(b.paramtabvendacateg, 'N'),
       nvl(b.usapromocclirep, 'N'),
       nvl(c.indacrtabvendatrib, 'T'),
       nvl(a.indapropdescfincusto, 'S'),
       nvl(b.tipcalcmargem, b.tipdivisao),
       nvl(a.indutilformpcoipisobmipc, 'N'),
       nvl(a.Percajusteficalipi, 0),
       nvl(a.indresolucao13intrauf, 'N')
  into vnNroDivisao,
       vsUfEmpresa,
       vnPerPis,
       vnPerCofins,
       vnPerCPMF,
       vnPerIr,
       vnPerOutroImposto,
       vnPerDespOperacional,
       vsUfFormacaoPreco,
       vsCgcBaseEmpr,
       vnNroRegTributacao,
       vsMetodoPrecificacao,
       vsTipDivisao,
       vsParamTabVendaCateg,
       Vsusapromocclirep,
       vsindacrtabvendatrib,
       vsindapropdescfincusto,
       vsTipCalcMargem,
       vsindUtilformPcoIPISobMIPC,
       vnpercajusteficalipi,
       vsResolucao13IntraUF
  from MAX_EMPRESA A, MAX_DIVISAO B, mad_parametro c
 where A.NROEMPRESA = pnNroEmpresa
   and B.NRODIVISAO = A.NRODIVISAO
   and c.nroempresa = a.nroempresa;
/* 22/jan/08 - comentado por Jota - estava dando erro porque as procedures chamadas dentro da package
   faziam insert quando o parametro não exitia, então dava erro de não poder executar comando DML dentro de um select*/
    -- Busca os parâmetros dinâmicos
/*faz o tratamento da quantidade de retorno das casas decimais (rp 63308), se a varialves vsIndExecutaTransfNf
estiver S retorna 3 casas, senao retorna 2 casas como já é feito da forma atual.
foi necessário esse tratamento pq na transferencia automatica teve problemas com o arrendamento em 2 casas */
If pnQtdCasasDecimais > 0  then -- Tratamento alterado no RC 74214
   vnQtdeCasasDecRet := pnQtdCasasDecimais;
Else
   vnQtdeCasasDecRet := 2;
end if;
/* select que buscará os parametros dinamicos */
select nvl( max( A.VALOR ), 'S' )
into vsPD_IndConsidComissaoPreco
from MAX_PARAMETRO A
where A.PARAMETRO = 'IND_CONSID_COMISSAO_PRECO'
and A.GRUPO = 'TAB_VENDA'
and A.NROEMPRESA = pnNroEmpresa;
-- seleciona a familia do produto
  select B.SEQFAMILIA, nvl(B.INDISENTOPIS, 'N'),
         DECODE(B.INDCALCIPISAIDA,'S',B.PERALIQUOTAIPI,0),
         B.INDCALCIPISAIDA, NVL(B.PERCADICPRECOSETOR, 0),
         NVL(C.PESOBRUTO, 0), NVL(C.PESOLIQUIDO, 0)
    into vnSeqFamilia, vsIndIsentoPis, vnPerIPI,
         vsIndCalcIPISaida, vnPercAdicPrecoSetor,
         vnPesoBruto, vnPesoLiquido
    from MAP_FAMILIA B, MAP_FAMEMBALAGEM C
   where B.SEQFAMILIA in
         (select SEQFAMILIA from MAP_PRODUTO where SEQPRODUTO = pnSeqProduto)
      AND B.SEQFAMILIA = C.SEQFAMILIA
      AND C.QTDEMBALAGEM = pnQtdEmbalagem;
if vsIndCalcIPISaida = 'S' then
    vnPerIPI := nvl(fccalctabelapiscofins(pnSeqProduto, pnSeqPessoa, trunc(sysdate), pnNroEmpresa, 'I', 'C', 'A'), vnPerIPI);
end if;
--
if    vsParamTabVendaCateg           =     'S'        then
      select nvl(max(b.indusapercacrtabvenda), 'S')
      into   vsIndUsaPercAcrTabVenda
      from   map_famdivcateg a,
             map_categoria b
      where  a.seqfamilia    =       vnSeqFamilia
      and    a.nrodivisao    =       Vnnrodivisao
      and    a.status        =       'A'
      and    b.seqcategoria  =       a.seqcategoria
      and    b.nrodivisao    =       a.nrodivisao
      and    b.actfamilia    =       'S'
      and    b.statuscategor !=      'I'
      and    b.tipcategoria  =       'M';
else
      vsIndUsaPercAcrTabVenda :=     'S';
end   if;
select nvl(max(b.mgmlucrocategoria),0)
into   vnMgmLucroCategoria
from   map_famdivcateg a, map_categoria b
where  a.seqfamilia    =       vnSeqFamilia
and    a.nrodivisao    =       Vnnrodivisao
and    a.status        =       'A'
and    b.seqcategoria  =       a.seqcategoria
and    b.nrodivisao    =       a.nrodivisao
and    b.actfamilia    =       'S'
and    b.statuscategor !=      'I'
and    b.tipcategoria  =       'M';
-- seleciona a tributacao do produto
select max( A.NROTRIBUTACAO ), max( A.PERDESPESADIVISAO ), max( A.CODORIGEMTRIB ),
         NVL(max(A.INDUTILFORMPCOVDAAJIPI),'N')
      into vnNroTributacao, vnPerDespDivisao, vnCodOrigemTrib,
         vsIndUtilFormPcoVdaAjIPI
    from MAP_FAMDIVISAO A
   where A.SEQFAMILIA = vnSeqFamilia
     and A.NRODIVISAO = vnNroDivisao;
-- busca a UF do cliente e o indicador de contribuinte de ICMS
if pnSeqPessoa is not null then
   select A.UF, A.INDCONTRIBICMS, substr( lpad( A.NROCGCCPF, 12, '0' ), 1, 8 )
          into vsUfCli, vsIndContribIcms, vsCgcBaseCli
          from GE_PESSOA A
          where A.SEQPESSOA = pnSeqPessoa;
else
   vsUfCli := vsUfEmpresa;
   vsIndContribIcms := 'S';
end if;
if psUfDestino is not null then
   vsUfCli := psUfDestino;
end if;
-- Verifica se utiliza recurso de Custo adicional por kg por setor/rota
SELECT NVL(MAX(INDUSAVLRADICSETOR), 'N')
  INTO vsIndUsaVlrAdicSetor
  FROM MAX_PARAMGERAL;
IF vsIndUsaVlrAdicSetor = 'S' THEN
  SELECT NVL(MAX(e.vlradicpreco), 0), NVL(MAX(d.vlradicpreco), 0)
    INTO vnVlrAdicPrecoSetor, vnVlrAdicPrecoRota
    FROM mad_pedvenda   a,
         mad_clienteend b,
         mad_praca      c,
         mad_rota       d,
         mad_setor      e
   WHERE b.seqpessoa = a.seqpessoa
     AND b.seqpessoaend = nvl(a.seqpessoaend, 0)
     AND c.seqpraca = b.seqpraca
     AND d.seqrota = c.seqrota
     AND e.seqsetor = d.seqsetor
     AND a.nropedvenda = pnNroPedVenda
     AND a.nroempresa = pnNroEmpresa;
END IF;
-- *************************************************************************
-- leitura da tabela de venda
select A.INDPRECOBASE, A.INDSUBTRAIVERBA, A.INDFORMACAOPRECO,
       A.INDICMSFORMAPRECO, A.INDDESPFORMAPRECO,
       A.INDCOMISFORMAPRECO, A.INDMARGFORMAPRECO, A.PERADICFORMAPRECO,
       A.INDFATURAMENTO, A.UFUNICA,
       nvl( TIPOTABVENDA, 'V' ),
       a.indperpisformapreco, a.indpercofinsformapreco,
       a.indpercpmfformapreco, nvl(a.indipiformapreco, 'S'), nvl( A.INDUSAREGRAINCENTIVO, 'S' ),
       a.percfretetransp,
       a.nroempresapreco,
       a.nrosegmentopreco,
       nvl(a.indsomadespforanf,'S'), nvl(a.indsomadespnf,'S'),
       nvl(a.inddeduzvlricmsstdistrib, 'N'), A.INDSOMAVERBA,
       nvl(a.INDCONSIDDESCFORANFCALCPRECO, 'S'), nvl(INDCONSDTAULTCOMPRA,'N'),
       nvl(a.indfcpicmsformapreco,'N'), nvl(a.indconsimpostopresum, 'N')
into   vsIndPrecoBase, vsIndSubtraiVerba, vsIndFormacaoPreco,
       vsIndIcmsFormaPreco, vsIndDespFormaPreco,
       vsIndComisFormaPreco, vsIndMargFormaPreco, vnPerAdicFormaPreco,
       vsIndFaturamento, vsUfUnica,
       vsTipoTabVenda,
       Vsindperpisformapreco, Vsindpercofinsformapreco,
       Vsindpercpmfformapreco, Vsindipiformapreco, vsTabIndUsaRegraIncentivo,
       vnpercfretetransp,
       vnNroEmpresaPreco,
       vnNroSegmentoPreco,
       vsIndSomaDespForaNf, vsIndSomaDespNf,
       vsIndDeduzVlrIcmsStDistrib, vsIndSomaVerba,
       vsIndConsidDescForaNFCalcPreco, vsindConsDtaUltCompra,
       vsIndFCPFormaPreco, vsIndConsImpostoPresum
from   MAD_TABVENDA A
where  A.NROTABVENDA     = psNroTabVenda;
 -- Verifica o percentual de Acrésc. / Desconto - PERACRESDESC da tabela MAD_TABVDAFAM
select NVL(MAX(a.peracrescdesc), 0)
  into vnPercAcresDescFamilia
  from mad_tabvdafam a
 where a.nrotabvenda = psNroTabVenda
   and a.seqfamilia = vnSeqFamilia;
select nvl(max(a.indnfestorno), 'N'), nvl(max(a.indestornaicmsbasepiscofins),'N')
  into vsIndNFEstornoPisCofins, vsIndEstornaIcmsBasePisCofins
  from max_codgeraloper a
 where a.codgeraloper = pnCodGeralOper;
if vsIndEstornaIcmsBasePisCofins in ('I', 'S') then
   select max(a.indestornaicmsbasepiscofins)
     into vsIndEstIcmsBasePisCofinsEmp
     from max_cgoempresa a
    where a.codgeraloper = pnCodGeralOper
      and a.nroempresa   = pnNroEmpresa;
  if vsIndEstIcmsBasePisCofinsEmp is not null then
     vsIndEstornaIcmsBasePisCofins := vsIndEstIcmsBasePisCofinsEmp;
  end if;
end if;
if vsIndNFEstornoPisCofins = 'S' And vsPDUtilPrecoTabVenda != 'S' then
    vdDtaUltCompraAux := null;
    vdDtaUltEntrCusto := null;
    vdDtaUltCompraCusto := null;
    select c.dtaultcompra, c.dtaultentrcusto, c.dtaultcompracusto
    into   vdDtaUltCompraAux, vdDtaUltEntrCusto, vdDtaUltCompraCusto
    from   mrl_produtoempresa c
    where  c.nroempresa       =  pnNroEmpresa
    and    c.seqproduto       =  pnSeqProduto;
    if vdDtaUltCompraAux is not null then
        select sum(b.bascalcpis) / sum(b.quantidade)
        into vnBasCalcPisCofins
        from MLF_NOTAFISCAL A, MLF_NFITEM B, MAX_CODGERALOPER C
        where A.CODGERALOPER = C.CODGERALOPER
        and A.dtaentrada = Decode(vsindConsDtaUltCompra, 'C', vdDtaUltCompraCusto, 'S', vdDtaUltCompraAux, vdDtaUltEntrCusto)
        and A.NROEMPRESA = nvl(vnNroEmpresaPreco, pnNroEmpresa)
        and A.NUMERONF = B.NUMERONF
        and A.SEQPESSOA = B.SEQPESSOA
        and A.SERIENF = B.SERIENF
        and A.TIPNOTAFISCAL = B.TIPNOTAFISCAL
        and A.NROEMPRESA = B.NROEMPRESA
        and (A.SEQNF Is Null Or A.SEQNF = B.SEQNF)
        and B.SEQPRODUTO = pnSeqProduto
        And a.TIPNOTAFISCAL = 'E'
        and A.RECALCUSMEDIO = 'S'
        and C.TIPDOCFISCAL in ('C' ,Decode(vsPDConsNotaTransf,'S','T','C'))
        and C.TIPPEDIDOCOMPRA in ('C', Decode(vsPDConsNotaTransf,'S','T','C'))
        and A.STATUSNF != 'C'
        order by a.seqnf desc;
        if nvl(vnBasCalcPisCofins,0) > 0 then
            vnPrecoRetorno := round( vnBasCalcPisCofins * pnQtdEmbalagem, 4 );
            return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
        end if;
    end if;
end if;
  if vsIndPrecoBase != 'VN' and vsPDQtdCsaDecPcoCsto != '2' then
     vnQtdeCasasDecRet:= to_number(vsPDQtdCsaDecPcoCsto);
  end if;
select max(b.indexformapreco)
into   vnindexformapreco
from   mad_famsegmento a, mad_tabvdatribabc b
where  a.seqfamilia         =    vnseqfamilia
and    a.nrosegmento        =    pnnrosegmento
and    b.nrotabvenda        =    psNroTabVenda
and    b.nrotributacao      =    vnNroTributacao
and    b.classifcomercabc   =    a.classifcomercabc
and    b.nrosegmento        =    a.nrosegmento
and    b.status             =    'A';
select nvl(max(A.PERCABATFRETE), 0), nvl(max(A.APLICAABATFRETE), 'T'), max(A.PERDESPESASEGMENTO)
into   vnPercAbatFrete, vsAplicaAbatFrete, vnPerDespSegmento
from   mad_famsegmento a
where  a.seqfamilia    =  vnSeqFamilia
and    a.nrosegmento   =  pnNroSegmento;
-- se o tipo de aplicação do abatimento de frete for diferente do indicador
-- de entrega ou retira, zera o percentual de abatimento.
if (psIndEntregaRetira = 'E' and vsAplicaAbatFrete = 'R')
    or (psIndEntregaRetira = 'R' and vsAplicaAbatFrete = 'E') then
   vnPercAbatFrete := 0;
end if;
-- Juscelino 08-nov-2002: Se a tabela de venda possuir UF UNICA, será sempre considerada venda para esta UF independentemente de qualquer outro parametro
if vsUfUnica is not null then
   vsUfCli := vsUfUnica;
end if;
--Joguemos o valor do acréscimo/desconto das tabelas de vendas por categoria/empresa para depois
--adicionarmos o acréscimo/desconto(o Percentual pode ser negativo).
--Exemplo: vnPrecoPartida := vnPrecoPartida + ((vsPercTabVendaCategEmp / 100) * vnPrecoPartida);
select nvl(max(x.percacresdescto), 0) Percentual
into   vsPercTabVendaCategEmp
from   (select nvl(e.percacresdescto, 0 ) percacresdescto
        from   map_produto              a,
               map_familia              b,
               map_famdivcateg          c,
               map_categoria            d,
               MAP_CATEGEMPRESATABVENDA e
        where  a.seqfamilia = b.seqfamilia
        and    b.seqfamilia = c.seqfamilia
        and    c.seqcategoria = d.seqcategoria
        and    c.nrodivisao = d.nrodivisao
        and    c.status = 'A'
        and    d.statuscategor = 'A'
        and    d.tipcategoria = 'M'
        and    e.seqcategoria = d.seqcategoria
        and    e.nrodivisao = d.nrodivisao
        and    e.nrotabvenda = psNroTabVenda
        and    e.nroempresa = pnNroEmpresa
        and    e.nrodivisao = vnNroDivisao
        and    a.seqproduto = pnSeqProduto
        order  by d.nivelhierarquia desc) x
where  rownum = 1;
if vsIndPrecoBase = 'UE' or vsIndPrecoBase != 'VN' then
  select max(nvl(a.seqprodutobase, a.seqproduto)), max(a.propqtdprodutobase)
    into vnSeqProdutoBase, vnQtdeProporcaoProdBase
    from map_produto a
   where a.seqproduto = pnSeqProduto;
end if;
if vsIndPrecoBase = 'VN' then
   --- ********************** CALCULO DOS VALORES POR PRECO DE VENDA ( VN )
   -- parametro psIndTipoPrecoRetorno:
     -- NULL = preco final de venda ( opção DEFAULT: preco final para vender, se houver promocao pegará com base na promocao, senão pega como base o normal )
     -- 'N' = preco final NORMAL de venda do produto (retorna sempre o preco com base no normal mesmo se o produto estiver em promoção)
     -- 'P' = preco PROMOCIONAL final de venda do produto ( se não estiver em promocao retorna zero)
     -- 'G' = preco GERADO (utilizado para emitir tabelas de venda)   se houver promocao pegará como base O PRECOGERPROMOC, senão pega como base o PRECOGERNORMAL
   if psIndTipoPrecoRetorno is null then
       -- busca o preco válido atual
       if  Vsusapromocclirep = 'S'  then
           vnPrecoPromocCliRep := fmrl_PrecoPromocEspec(pnSeqProduto, pnQtdEmbalagem,
                                                       nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa), null,
                                                       pnSeqPessoa, pnNroRepresentante, psNroTabVenda, pnNroCondicaoPagto, vnNroFormaPagto );
       end if;
       if  vnPrecoPromocCliRep > 0 then
           --
           vsIndPromocCliRep := 'S';
           --
           vnPrecoPartida := vnPrecoPromocCliRep;
           if vnPmtSubtraiIcmsStVlrProd = 'S' then
               vnPrecoPartida := vnPrecoPartida - fc_calcicmsst_emp(pnNroEmpresa, pnSeqProduto, vnPrecoPartida, pnQtdEmbalagem, pnQtdEmbalagem, pnSeqPessoa );
           end if;
           select max(a.faixaacrfinanceiro), max(a.indusaacresctabvenda)
           into   vsFaixaValidAcrFin, vsPromUsaAcrescTabVenda
           from   mrlv_promocclienteitem a
           where  a.nroempresa           =           nvl(vnNroEmpresaPreco, pnNroEmpresa)
           and    a.nrosegmento          =           nvl(vnNroSegmentoPreco, pnNroSegmento)
           and    a.seqpessoa            =           pnSeqPessoa
           and    trunc(sysdate)         between     a.dtainicio and a.dtafim
           and    a.seqproduto           =           pnSeqProduto;
           if     vsFaixaValidAcrFin is null         then
                  select max(a.faixaacrfinanceiro), max(a.indusaacresctabvenda)
                  into   vsFaixaValidAcrFin, vsPromUsaAcrescTabVenda
                  from   mrlv_promocrepitem a
                  where  a.nroempresa           =           nvl(vnNroEmpresaPreco, pnNroEmpresa)
                  and    a.nrosegmento          =           nvl(vnNroSegmentoPreco, pnNroSegmento)
                  and    a.nrorepresentante     =           pnNroRepresentante
                  and    trunc(sysdate)         between     a.dtainicio and a.dtafim
                  and    a.seqproduto           =           pnSeqProduto;
           end    if;
           if     vsFaixaValidAcrFin is null         then
                  select max(a.faixaacrfinanceiro), max(a.indusaacresctabvenda)
                  into   vsFaixaValidAcrFin, vsPromUsaAcrescTabVenda
                  from   mrlv_promoctabvdaitem a
                  where  a.nroempresa           =           nvl(vnNroEmpresaPreco, pnNroEmpresa)
                  and    a.nrosegmento          =           nvl(vnNroSegmentoPreco, pnNroSegmento)
                  and    a.nrotabvenda          =           psNroTabVenda
                  and    trunc(sysdate)         between     a.dtainicio and a.dtafim
                  and    a.seqproduto           =           pnSeqProduto;
                  if     vsFaixaValidAcrFin is not null     then
                         vsPrecoPromTabVenda   :=   'S';
                  end    if;
           end    if;
       else
           vnPrecoPartida := fPrecoEmbProduto( pnSeqProduto, pnQtdEmbalagem, nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa), pnQuantidade );
           if vnPmtSubtraiIcmsStVlrProd = 'S' then
               vnPrecoPartida := vnPrecoPartida - fc_calcicmsst_emp(pnNroEmpresa, pnSeqProduto, vnPrecoPartida, pnQtdEmbalagem, pnQtdEmbalagem, pnSeqPessoa );
           end if;
           if vnPrecoPartida <= 0 then
                 if vsIndUsaPercFreteCidade != 'N' then
                    vnPrecoPartida   :=   vnPrecoPartida + ( vnPrecoPartida * ( vnPercFreteCidade / 100 ) );
                 end if;
                 ---
                 if vsIndUsaVlrAdicSetor = 'S' then
                    vnPrecoPartida := vnPrecoPartida + ( ROUND( ( ( vnVlrAdicPrecoSetor * ( vnPercAdicPrecoSetor / 100 ) ) + vnVlrAdicPrecoSetor + vnVlrAdicPrecoRota ) * COALESCE( vnPesoBruto, vnPesoLiquido, 0 ), 2 ) );
                 end if;
                 vnPrecoPartida := vnPrecoPartida + ((vsPercTabVendaCategEmp / 100) * vnPrecoPartida);
                 vnPrecoRetorno := vnPrecoPartida;
                 return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
           end if;
           select max(a.precovalidpromoc)
           into   vnlixo
           from   mrl_prodempseg a
           where  a.seqproduto      =         pnSeqProduto
           and    a.nroempresa      =         pnnroempresa
           and    a.nrosegmento     =         pnNroSegmento
           and    a.qtdembalagem    =         pnQtdEmbalagem;
           if     vnlixo            >         0 then
                  select max(a.indusaacresctabvenda)
                  into   vsPromUsaAcrescTabVenda
                  from   mrlv_promocaoitem a
                  where  a.seqproduto      =         pnSeqProduto
                  and    a.nroempresa      =         pnnroempresa
                  and    a.nrosegmento     =         pnNroSegmento
                  and    a.qtdembalagem    =         pnQtdEmbalagem
                  and    trunc(sysdate)    between   a.dtainicio and a.dtafim;
           end    if;
       end if;
   elsif psIndTipoPrecoRetorno = 'N' then
       -- busca o preco válido NORMAL (sempre o normal, mesmo que esteja em promoção)
       if  Vsusapromocclirep = 'S'  then
           vnPrecoPromocCliRep := fmrl_PrecoPromocEspec(pnSeqProduto, pnQtdEmbalagem,
                                                       nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa), null,
                                                       pnSeqPessoa, pnNroRepresentante, psNroTabVenda, pnNroCondicaoPagto, vnNroFormaPagto);
       end if;
       if  vnPrecoPromocCliRep > 0 then
           --
           vsIndPromocCliRep := 'S';
           --
           vnPrecoPartida := vnPrecoPromocCliRep;
           if vnPmtSubtraiIcmsStVlrProd = 'S' then
               vnPrecoPartida := vnPrecoPartida - fc_calcicmsst_emp(pnNroEmpresa, pnSeqProduto, vnPrecoPartida, pnQtdEmbalagem, pnQtdEmbalagem, pnSeqPessoa );
           end if;
           select max(a.faixaacrfinanceiro), max(a.indusaacresctabvenda)
           into   vsFaixaValidAcrFin, vsPromUsaAcrescTabVenda
           from   mrlv_promocclienteitem a
           where  a.nroempresa           =           nvl(vnNroEmpresaPreco, pnNroEmpresa)
           and    a.nrosegmento          =           nvl(vnNroSegmentoPreco, pnNroSegmento)
           and    a.seqpessoa            =           pnSeqPessoa
           and    trunc(sysdate)         between     a.dtainicio and a.dtafim
           and    a.seqproduto           =           pnSeqProduto;
           if     vsFaixaValidAcrFin is null         then
                  select max(a.faixaacrfinanceiro), max(a.indusaacresctabvenda)
                  into   vsFaixaValidAcrFin, vsPromUsaAcrescTabVenda
                  from   mrlv_promocrepitem a
                  where  a.nroempresa           =           nvl(pnNroEmpresa, vnNroEmpresaPreco)
                  and    a.nrosegmento          =           nvl(vnNroSegmentoPreco, pnNroSegmento)
                  and    a.nrorepresentante     =           pnNroRepresentante
                  and    trunc(sysdate)         between     a.dtainicio and a.dtafim
                  and    a.seqproduto           =           pnSeqProduto;
           end    if;
           if     vsFaixaValidAcrFin is null         then
                  select max(a.faixaacrfinanceiro), max(a.indusaacresctabvenda)
                  into   vsFaixaValidAcrFin, vsPromUsaAcrescTabVenda
                  from   mrlv_promoctabvdaitem a
                  where  a.nroempresa           =           nvl(vnNroEmpresaPreco, pnNroEmpresa)
                  and    a.nrosegmento          =           nvl(vnNroSegmentoPreco, pnNroSegmento)
                  and    a.nrotabvenda          =           psNroTabVenda
                  and    trunc(sysdate)         between     a.dtainicio and a.dtafim
                  and    a.seqproduto           =           pnSeqProduto;
                  if     vsFaixaValidAcrFin is not null     then
                         vsPrecoPromTabVenda   :=   'S';
                  end    if;
           end    if;
       else
           vnPrecoPartida := fPrecoEmbNormal( pnSeqProduto, pnQtdEmbalagem, nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa), pnQuantidade );
           if vnPmtSubtraiIcmsStVlrProd = 'S' then
               vnPrecoPartida := vnPrecoPartida - fc_calcicmsst_emp(pnNroEmpresa, pnSeqProduto, vnPrecoPartida, pnQtdEmbalagem, pnQtdEmbalagem, pnSeqPessoa );
           end if;
           select max(a.precovalidpromoc)
           into   vnlixo
           from   mrl_prodempseg a
           where  a.seqproduto      =         pnSeqProduto
           and    a.nroempresa      =         pnnroempresa
           and    a.nrosegmento     =         pnNroSegmento
           and    a.qtdembalagem    =         pnQtdEmbalagem;
           if     vnlixo            >         0 then
                  select max(a.indusaacresctabvenda)
                  into   vsPromUsaAcrescTabVenda
                  from   mrlv_promocaoitem a
                  where  a.seqproduto      =         pnSeqProduto
                  and    a.nroempresa      =         pnnroempresa
                  and    a.nrosegmento     =         pnNroSegmento
                  and    a.qtdembalagem    =         pnQtdEmbalagem
                  and    trunc(sysdate)    between   a.dtainicio and a.dtafim;
           end    if;
       end if;
       if vnPrecoPartida <= 0 then
                 if vsIndUsaPercFreteCidade != 'N' then
                    vnPrecoPartida   :=   vnPrecoPartida + ( vnPrecoPartida * ( vnPercFreteCidade / 100 ) );
                 end if;
                 ---
                 if vsIndUsaVlrAdicSetor = 'S' then
                    vnPrecoPartida := vnPrecoPartida + ( ROUND( ( ( vnVlrAdicPrecoSetor * ( vnPercAdicPrecoSetor / 100 ) ) + vnVlrAdicPrecoSetor + vnVlrAdicPrecoRota ) * COALESCE( vnPesoBruto, vnPesoLiquido, 0 ), 2 ) );
                 end if;
              vnPrecoPartida := vnPrecoPartida + ((vsPercTabVendaCategEmp / 100) * vnPrecoPartida);
              vnPrecoRetorno := vnPrecoPartida;
              return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
       end if;
   elsif psIndTipoPrecoRetorno = 'P' then
       -- busca o preco válido PROMOCIONAL (sempre o promocional, se não estiver em promoção retornará zero)
       if  Vsusapromocclirep = 'S'  then
           vnPrecoPromocCliRep := fmrl_PrecoPromocEspec(pnSeqProduto, pnQtdEmbalagem,
                                                       nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa), null,
                                                       pnSeqPessoa, pnNroRepresentante, psNroTabVenda, pnNroCondicaoPagto, vnNroFormaPagto);
       end if;
       if  vnPrecoPromocCliRep > 0 then
           --
           vsIndPromocCliRep := 'S';
           --
           vnPrecoPartida := vnPrecoPromocCliRep;
           if vnPmtSubtraiIcmsStVlrProd = 'S' then
               vnPrecoPartida := vnPrecoPartida - fc_calcicmsst_emp(pnNroEmpresa, pnSeqProduto, vnPrecoPartida, pnQtdEmbalagem, pnQtdEmbalagem, pnSeqPessoa );
           end if;
           select max(a.faixaacrfinanceiro), max(a.indusaacresctabvenda)
           into   vsFaixaValidAcrFin, vsPromUsaAcrescTabVenda
           from   mrlv_promocclienteitem a
           where  a.nroempresa           =           nvl(vnNroEmpresaPreco, pnNroEmpresa)
           and    a.nrosegmento          =           nvl(vnNroSegmentoPreco, pnNroSegmento)
           and    a.seqpessoa            =           pnSeqPessoa
           and    trunc(sysdate)         between     a.dtainicio and a.dtafim
           and    a.seqproduto           =           pnSeqProduto;
           if     vsFaixaValidAcrFin is null         then
                  select max(a.faixaacrfinanceiro), max(a.indusaacresctabvenda)
                  into   vsFaixaValidAcrFin, vsPromUsaAcrescTabVenda
                  from   mrlv_promocrepitem a
                  where  a.nroempresa           =           nvl(vnNroEmpresaPreco, pnNroEmpresa)
                  and    a.nrosegmento          =           nvl(vnNroSegmentoPreco, pnNroSegmento)
                  and    a.nrorepresentante     =           pnNroRepresentante
                  and    trunc(sysdate)         between     a.dtainicio and a.dtafim
                  and    a.seqproduto           =           pnSeqProduto;
           end    if;
           if     vsFaixaValidAcrFin is null         then
                  select max(a.faixaacrfinanceiro), max(a.indusaacresctabvenda)
                  into   vsFaixaValidAcrFin, vsPromUsaAcrescTabVenda
                  from   mrlv_promoctabvdaitem a
                  where  a.nroempresa           =           nvl(vnNroEmpresaPreco, pnNroEmpresa)
                  and    a.nrosegmento          =           nvl(vnNroSegmentoPreco, pnNroSegmento)
                  and    a.nrotabvenda          =           psNroTabVenda
                  and    trunc(sysdate)         between     a.dtainicio and a.dtafim
                  and    a.seqproduto           =           pnSeqProduto;
                  if     vsFaixaValidAcrFin is not null     then
                         vsPrecoPromTabVenda   :=   'S';
                  end    if;
           end    if;
       else
           vnPrecoPartida := fPrecoEmbPromoc( pnSeqProduto, pnQtdEmbalagem, nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa), pnQuantidade );
           if vnPmtSubtraiIcmsStVlrProd = 'S' then
               vnPrecoPartida := vnPrecoPartida - fc_calcicmsst_emp(pnNroEmpresa, pnSeqProduto, vnPrecoPartida, pnQtdEmbalagem, pnQtdEmbalagem, pnSeqPessoa );
           end if;
           if vnPrecoPartida <= 0 then
                 if vsIndUsaPercFreteCidade != 'N' then
                    vnPrecoPartida   :=   vnPrecoPartida + ( vnPrecoPartida * ( vnPercFreteCidade / 100 ) );
                 end if;
                 ---
                 vnPrecoPartida := vnPrecoPartida + ((vsPercTabVendaCategEmp / 100) * vnPrecoPartida);
                 vnPrecoRetorno := vnPrecoPartida;
                 return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
           end if;
           select max(a.indusaacresctabvenda)
           into   vsPromUsaAcrescTabVenda
           from   mrlv_promocaoitem a
           where  a.seqproduto      =         pnSeqProduto
           and    a.nroempresa      =         pnnroempresa
           and    a.nrosegmento     =         pnNroSegmento
           and    a.qtdembalagem    =         pnQtdEmbalagem
           and    trunc(sysdate)    between   a.dtainicio and a.dtafim;
       end if;
   elsif psIndTipoPrecoRetorno = 'G' then
       -- busca o preco GERADO (PROMOCAO OU NORMAL)
       vnPrecoPartida := fPrecoGerEmbProduto( pnSeqProduto, pnQtdEmbalagem, nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(pnNroEmpresa, vnNroEmpresaPreco), pnQuantidade );
       if vnPmtSubtraiIcmsStVlrProd = 'S' then
           vnPrecoPartida := vnPrecoPartida - fc_calcicmsst_emp(pnNroEmpresa, pnSeqProduto, vnPrecoPartida, pnQtdEmbalagem, pnQtdEmbalagem, pnSeqPessoa );
       end if;
       if vnPrecoPartida <= 0 then
                 if vsIndUsaPercFreteCidade != 'N' then
                    vnPrecoPartida   :=   vnPrecoPartida + ( vnPrecoPartida * ( vnPercFreteCidade / 100 ) );
                 end if;
                 ---
              vnPrecoPartida := vnPrecoPartida + ((vsPercTabVendaCategEmp / 100) * vnPrecoPartida);
              vnPrecoRetorno := vnPrecoPartida;
              return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
       end if;
   elsif psIndTipoPrecoRetorno = 'I' then
       -- busca o preco INDENIZAÇÃO
       vnPrecoPartida := fPrecoIndenizEmbProduto( pnSeqProduto, pnQtdEmbalagem, nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa) );
       if vnPmtSubtraiIcmsStVlrProd = 'S' then
           vnPrecoPartida := vnPrecoPartida - fc_calcicmsst_emp(pnNroEmpresa, pnSeqProduto, vnPrecoPartida, pnQtdEmbalagem, pnQtdEmbalagem, pnSeqPessoa );
       end if;
       if vsIndUsaPercFreteCidade != 'N' then
          vnPrecoPartida   :=   vnPrecoPartida + ( vnPrecoPartida * ( vnPercFreteCidade / 100 ) );
       end if;
       ---
       vnPrecoPartida := vnPrecoPartida + ((vsPercTabVendaCategEmp / 100) * vnPrecoPartida);
       vnPrecoRetorno := vnPrecoPartida;
       return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
   else
       vnPrecoRetorno := 0;
       return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
   end if;
   --RC 55129 - verifica se o preço é o de promoção ou o normal
   if  vsIndPromocCliRep = 'S' then
       vsIndicaPrecoPromocao := 'S';
   else
       select decode( fPrecoEmbPromoc( pnSeqProduto,
                                       pnQtdEmbalagem,
                                       nvl(vnNroSegmentoPreco, pnNroSegmento),
                                       nvl(pnNroEmpresa, vnNroEmpresaPreco),
                                       pnQuantidade ), vnPrecoPartida, 'S', 'N' )
       into   vsIndicaPrecoPromocao
       from   dual;
   end if;
   --setando o indicador q nao u8sao acrescimo da tabela de venda (promocao) para o indicador da categoria para manter o tratamento ja existente
   if  vsPromUsaAcrescTabVenda = 'N' and vsIndicaPrecoPromocao = 'S' then
       vsIndUsaPercAcrTabVenda := 'N';
   end if;
   --*********************************************
   -- Preco de promocao por tab venda nao usa acrescimos da tabela, apenas financeiro
   --*********************************************
   if  vsPrecoPromTabVenda = 'S' then
       vnPrecoVda := vnPrecoPartida;
   else
        -- aplicando indice para formacao do preco base------------------
        if     nvl(vnindexformapreco, 0) !=       0  and vsPrecoPromTabVenda != 'S' then
               vnPrecoPartida := round( vnPrecoPartida * vnindexformapreco, 2 );
        end    if;
        -----------------------------------------------------------------
        -- ============================ APLICACAO DO PERCENTUAL DE ACRESCIMO/DESCONTO DE DISTANCIA DA TABELA DE VENDA
        -- busca o percentual de acrescimo/desconto de entrega da tabela
        if     nvl(vsIndUsaPercAcrTabVenda, 'S')    !=  'N'
               and not ( vsIndicaPrecoPromocao = 'S' and vsPD_AplicaAcresDescPromoc = 'N' ) then
               select max(case
                        /* Verificação do parâmetro dinâmico "TIPO_CALC_FRETE_PRECO" */
                        when vspd_tipocalcfretepreco = 'S' then
                         nvl((nvl(a.peracrentrega, 0) +
                                 (decode(nvl(pscalcvlrembtabprecosemfrete, 'S'), 'S',
                                         nvl(a.percfretetransp, 0), 0) *
                                  (1 - (vnpercabatfrete / 100)))), 0)
                        /* Verificação do divisor - Necessário devido a casos de divisão por zero */
                        when (((100 - (decode(nvl(pscalcvlrembtabprecosemfrete, 'S'), 'S',
                                                nvl(a.percfretetransp, 0), 0) *
                                (1 - (vnpercabatfrete / 100)))) / 100)) > 0 then
                         nvl((nvl(a.peracrentrega, 0) /
                                    ((100 - (decode(nvl(pscalcvlrembtabprecosemfrete, 'S'),
                                                    'S', nvl(a.percfretetransp, 0), 0) *
                                     (1 - (vnpercabatfrete / 100)))) / 100)), 0)
                        /* Se o divisor acima estiver zerado será enviado o valor zerado */
                        else
                         0
                      end)
                 into vnperacrentrega
                 from mad_tabvenda a
                where a.nrotabvenda = psnrotabvenda;
        else
               vnPerAcrEntrega := 0;
        end    if;
        -- calcula o preco, acrescendo o percentual de entrega da tabela
		
        vnPrecoVda := vnPrecoPartida + vnPrecoPartida * vnPerAcrEntrega / 100;
        vnPrecoBaseRestorno := vnPrecoPartida + vnPrecoPartida * vnPerAcrEntrega / 100;
		
        -- =================================================== ACRESCIMO/DESCONTO TRIBUTARIO - MAD_UFEMPTRIB
        -- testar a MAD_UFEMPTRIB ( exemplo: a tributação cesta basica tem desconto quando fatura da empresa nnn para a uf 'SP' )
        select nvl( max( A.PERACRDESCTO ), 0 )
               into vnPercAcrDesctoTributarioUf
               from MAD_UFEMPTRIB A
               where A.NROTRIBUTACAO = vnNroTributacao
               and A.UFDESTINO = vsUfCli
               and A.NROEMPRESA = pnNroEmpresa;
        vnPrecoVda := vnPrecoVda + vnPrecoVda * vnPercAcrDesctoTributarioUf / 100;
        -- ==================================================== ACRESCIMO/DESCONTO TRIBUTARIO - MAD_TABVENDATRIB
        -- testar a MAD_TABVENDATRIB ( exemplo: se o produto da tributação 'BOM-BRIL' for vendido na tabela 'XXX' ele terá aplicado sobre ele o percentual Y )
        select nvl( max( A.PERACRTRIBUTARIO), 0 ),
               nvl( max( a.indpiscofinstabvenda), 'N'),
               max(a.perpis),
               max(a.percofins)
               into vnPercAcrDesctoTributarioTab,
                    Vsindpiscofinstabvendatrib,
                    Vnperpistabvendatrib,
                    Vnpercofinstabvendatrib
               from MAD_TABVENDATRIB A
               where A.NROTRIBUTACAO = vnNroTributacao
               and A.NROTABVENDA = psNroTabVenda
               and A.STATUS = 'A';
        if     Vsindpiscofinstabvendatrib != 'S'      then
               Vnperpistabvendatrib       :=          null;
               Vnpercofinstabvendatrib    :=          null;
        else
               vnPerPis                   :=          nvl(Vnperpistabvendatrib, vnPerPis);
               Vnpercofins                :=          nvl(Vnpercofinstabvendatrib, Vnpercofins);
        end    if;
        if     vsindacrtabvendatrib != 'T'            then
               if     vsindacrtabvendatrib = 'C' and  vsIndContribIcms != 'S' then
                      vnPercAcrDesctoTributarioTab := 0;
               elsif  vsindacrtabvendatrib = 'N' and  vsIndContribIcms != 'N' then
                      vnPercAcrDesctoTributarioTab := 0;
               end    if;
        end    if;
        if     psNroTabVenda between '0' and '999' then
               vnTemTabPrecoCFA := 0;
               vnTemPrecoDifEmb := 0;
               vnqtdembvendaprecotab := null;
               select count(1)
               into   vnTemPrecoDifEmb
               from   mad_segmento a
               where  a.nrosegmento = pnNroSegmento
               and    a.indprecoembalagem = 'S';
               if vnTemPrecoDifEmb > 0 then
                   select count(1)
                     into vnTemTabPrecoCFA
                     from TABPRECOCFA A
                    where a.NUMEROLIVRO = psNroTabVenda
                      and a.qtdembalagem = pnQtdEmbalagem
                      and a.SEQPRODUTO = pnSeqProduto
                      and nvl(a.nroempresa,pnNroEmpresa) = pnNroEmpresa -- DPC (manter o nvl pois a bcr utiliza essa view como tabela)
                      and nvl(a.nrosegmento,pnNroSegmento) = pnNroSegmento;  -- DPC (manter o nvl pois a bcr utiliza essa view como tabela)
                   if vnTemTabPrecoCFA > 0 then
                      select A.PRECOAVISTA
                        into vnPrecoVda
                        from TABPRECOCFA A
                       where a.NUMEROLIVRO = psNroTabVenda
                         and a.qtdembalagem = pnQtdEmbalagem
                         and a.SEQPRODUTO = pnSeqProduto
                         and nvl(a.nroempresa,pnNroEmpresa) = pnNroEmpresa -- DPC (manter o nvl pois a bcr utiliza essa view como tabela)
                         and nvl(a.nrosegmento,pnNroSegmento) = pnNroSegmento; -- DPC (manter o nvl pois a bcr utiliza essa view como tabela)
                   end if;
               else
                   if vnqtdembvendaprecotab is null then
                        select min( a.qtdembalagem )
                        into vnqtdembvendaprecotab
                        from mrl_prodempseg a
                        where a.seqproduto = pnSeqProduto
                        and a.nrosegmento = pnNroSegmento
                        and a.nroempresa = pnNroEmpresa
                        and a.statusvenda = 'A';
                   end if;
                   if vnqtdembvendaprecotab is null then
                        select min( a.padraoembvenda )
                        into vnqtdembvendaprecotab
                        from mad_famsegmento a
                        where a.seqfamilia = ( select seqfamilia
                                           from map_produto
                                           where seqproduto = pnSeqProduto )
                        and a.nrosegmento = pnNroSegmento;
                   end if;
                   select count(1)
                     into vnTemTabPrecoCFA
                     from TABPRECOCFA A
                    where a.NUMEROLIVRO = psNroTabVenda
                      and a.qtdembalagem = vnqtdembvendaprecotab
                      and a.SEQPRODUTO = pnSeqProduto
                      and nvl(a.nroempresa,pnNroEmpresa) = pnNroEmpresa -- DPC (manter o nvl pois a bcr utiliza essa view como tabela)
                      and nvl(a.nrosegmento,pnNroSegmento) = pnNroSegmento;  -- DPC (manter o nvl pois a bcr utiliza essa view como tabela)
                   if vnTemTabPrecoCFA > 0 then
                      select A.PRECOAVISTA / A.QTDEMBALAGEM
                        into vnPrecoVda
                        from TABPRECOCFA A
                       where a.NUMEROLIVRO = psNroTabVenda
                         and a.qtdembalagem = vnqtdembvendaprecotab
                         and a.SEQPRODUTO = pnSeqProduto
                         and nvl(a.nroempresa,pnNroEmpresa) = pnNroEmpresa -- DPC (manter o nvl pois a bcr utiliza essa view como tabela)
                         and nvl(a.nrosegmento,pnNroSegmento) = pnNroSegmento; -- DPC (manter o nvl pois a bcr utiliza essa view como tabela)
                      vnPrecoVda := vnPrecoVda * pnQtdEmbalagem;
                   end if;
               end if;
        end    if;
        vnPrecoVda := vnPrecoVda + vnPrecoVda * vnPercAcrDesctoTributarioTab / 100;
   end  if;
   -- ============================================== DESCONTO OU ACRESCIMO FINANCEIRO DA CONDICAO DE PAGAMENTO
   -- busca faixa de acrescimo do preco (para precos de promocoes por cliente ou repres. ja esta com valor da faixa)
   if   psIndTipoPrecoRetorno = 'G' then
        if   nvl(vnPrecoPromocCliRep, 0)             =        0 then
             vsFaixaValidAcrFin := fFaixaGerAcrEmbProduto( pnSeqProduto, pnQtdEmbalagem, nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa) );
        end  if;
   elsif psIndTipoPrecoRetorno = 'N' then
         vsFaixaValidAcrFin := 'A';
   else
        if   nvl(vnPrecoPromocCliRep, 0)             =        0 then
             vsFaixaValidAcrFin := fFaixaAcrEmbProduto( pnSeqProduto, pnQtdEmbalagem, nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa) );
        end  if;
   end if;
   -- busca o percentual de acrescimo financeiro da tabela conforme a faixa válida
   if (psDesconsideraAcresDesc is null or instr(psDesconsideraAcresDesc, 'C') = 0) and
   not (vsIndicaPrecoPromocao = 'S' and vsPD_AplicaAcresDescPromoc = 'N') then
          select nvl( max( A.PERACRFINANCEIRO ), 0 )
          into vnPerAcrFinanceiro
          from MAD_TABVENDACOND A
          where A.NROTABVENDA = psNroTabVenda
          and A.NROCONDICAOPAGTO = pnNroCondicaoPagto
          and A.FAIXAACRFINANCEIRO = vsFaixaValidAcrFin;
   else
          vnPerAcrFinanceiro := 0;
   end    if;
   -- req.29799 - verificar a tabela MAF_FORNECCOND (caso não utilize ou não exista somará zero, não afetendo o resultado)
   select nvl( max( A.PERACRFINANCEIRO ), 0 )
   into vnPerAcrFinanceiroFornecCond
   from MAF_FORNECCOND A
   where A.SEQFORNECEDOR = ( select nvl( max( F.SEQFORNECEDOR ), 0 )
                             from MAP_FAMFORNEC F
                             where F.SEQFAMILIA = vnSeqFamilia
                             and F.PRINCIPAL = 'S' )
   and A.NROEMPRESA = pnNroEmpresa
   and A.NROCONDICAOPAGTO = pnNroCondicaoPagto
   and A.FAIXAACRFINANCEIRO = vsFaixaValidAcrFin;
   if vnPerAcrFinanceiroFornecCond != 0 then
      vnPerAcrFinanceiro := vnPerAcrFinanceiroFornecCond;
   end if;
   -- calcula o preco, acrescendo o percentual o financeiro da condicao de pagamento
   vnPercAcresDescCategProd := nvl(fc5BuscaJurosDescCategProd(pnNroEmpresa, pnSeqProduto, pnQtdEmbalagem),0);
   if vnPercAcresDescCategProd > 0 then
      if pnNroCondicaoPagto is not null then
         select count(1)
         into   vnQtdParcelas
         from   mad_condpagtovenc a
         where  a.nrocondicaopagto = pnNroCondicaoPagto;
      end if;
      if vnQtdParcelas > 1 and power((1 + (vnPercAcresDescCategProd / 100)), vnQtdParcelas) != 0  then
         if (1 - (1 / (power((1 + (vnPercAcresDescCategProd / 100)), vnQtdParcelas)))) != 0 then
            vnPrecoVda := vnPrecoVda * ((vnPercAcresDescCategProd / 100) / (1 - (1 / (power((1 + (vnPercAcresDescCategProd / 100)), vnQtdParcelas))))) * vnQtdParcelas;
         end if;
      end if;
   elsif vnPercAcresDescCategProd < 0 then
      vnPrecoVda := vnPrecoVda + (vnPrecoVda * (vnPercAcresDescCategProd / 100));
   else
      vnPrecoVda := vnPrecoVda + (vnPrecoVda * (vnPerAcrFinanceiro / 100));
      vnPrecoBaseRestorno := vnPrecoBaseRestorno + (vnPrecoBaseRestorno * (vnPerAcrFinanceiro / 100));
   end if;
   if vnTemTabPrecoCFA > 0 then
         if vsIndUsaPercFreteCidade != 'N' then
            vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( vnPercFreteCidade / 100 ) );
         end if;
         ---
         if vsIndUsaVlrAdicSetor = 'S' then
            vnPrecoVda := vnPrecoVda + ( ROUND( ( ( vnVlrAdicPrecoSetor * ( vnPercAdicPrecoSetor / 100 ) ) + vnVlrAdicPrecoSetor + vnVlrAdicPrecoRota ) * COALESCE( vnPesoBruto, vnPesoLiquido, 0 ), 2 ) );
         end if;
      vnPrecoVda := vnPrecoVda + ((vsPercTabVendaCategEmp / 100) * vnPrecoVda);
      vnPrecoRetorno := vnPrecoVda;
      return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
   end if;
   -- Retornando preco de promocao na tabela de venda aplicado o indice financeiro da faixa de promocao
   if  vsPrecoPromTabVenda = 'S' then
        -- aplica o desconto comercia do cliente no segmento (Req:32562)
        select max(a.percacrdesccomerc),
               max(a.percacrprecovda),
               max(a.percrestorno)
        into   vnCliSegPercAcrDescComerc,
               vnCliSegPercAcrPrecoVda,
               vnCliSegPercRestorno
        from   mrl_clienteseg a
        where  a.seqpessoa    =  pnSeqPessoa
        and    a.nrosegmento  =  pnNroSegmento;
        IF    (nvl(vnCliSegPercAcrDescComerc, 0) < 0 AND
               nvl(psUsaDescComercial, 'S') != 'N'   AND
               vsPD_GerDescComFinPromo = 'S')        OR
               nvl(vnCliSegPercAcrDescComerc, 0) > 0 THEN
               vnPrecoVda := vnPrecoVda + vnPrecoVda * vnCliSegPercAcrDescComerc / 100;
        end    if;
        if     nvl(vnCliSegPercAcrPrecoVda, 0) != 0 and nvl(psIndPrecoTabPrecoInformado, 'T') = 'I' then
               vnPrecoVda := vnPrecoVda + (vnPrecoVda * (vnCliSegPercAcrPrecoVda / 100));
        end    if;
         if vsIndUsaPercFreteCidade  != 'N' then
            vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( vnPercFreteCidade / 100 ) );
         end if;
        if  nvl(vnCliSegPercRestorno, 0) > 0 and
            nvl(psIndPrecoTabPrecoInformado, 'T') = 'I' then
            --
            vnVlrIndiceRestorno := fc5_CalcIndiceRestono(
                                      pnSeqProduto,
                                      pnCodGeralOper,
                                      pnNroEmpresa,
                                      null,
                                      pnSeqPessoa,
                                      pnNroSegmento,
                                      pnQtdEmbalagem,
                                      vnPrecoBaseRestorno,
                                      psNroTabVenda);
            --
            if  vnVlrIndiceRestorno > 0 then
                vnPrecoVda := vnPrecoVda * vnVlrIndiceRestorno;
            end if;
            --
        end if;
        --
        if vsIndUsaVlrAdicSetor = 'S' then
           vnPrecoVda := vnPrecoVda + ( ROUND( ( ( vnVlrAdicPrecoSetor * ( vnPercAdicPrecoSetor / 100 ) ) + vnVlrAdicPrecoSetor + vnVlrAdicPrecoRota ) * COALESCE( vnPesoBruto, vnPesoLiquido, 0 ), 2 ) );
        end if;
        vnPrecoVda := vnPrecoVda + ((vsPercTabVendaCategEmp / 100) * vnPrecoVda);
        vnPrecoRetorno := round(vnPrecoVda, 2);
        return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
   end if;
   -- ======================================================= DESCONTO OU ACRESCIMO DE ENTREGA OU RETIRA
   -- busca informações da MAX_EMPRESASEG
   select MAX(A.DEFAULTENTRET), MAX(nvl( A.TIPACRDESCENTRET, 'D' )), MAX(A.PERACRDESCENTREGA), MAX(A.PERACRDESCRETIRA), MAX(nvl( B.VLRCOMPLPRECOUNIT, 0 ))
          into vsDefaultEntRet, vsTipAcrDescEntRet, vnPerAcrDescEntrega, vnPerAcrDescRetira, vnVlrComplPrecoUnit
          from MAX_EMPRESASEG A, MAD_SEGMENTO B
          where A.NROEMPRESA = pnNroEmpresa
          and A.NROSEGMENTO = pnNroSegmento
          and A.NROSEGMENTO = B.NROSEGMENTO;
   -- busca informações na MAD_REPRESENTANTE
   if pnNroRepresentante is not null then
       select nvl( A.PERACRDESCRETIRA, 0 ), nvl( A.PERACRDESCENTREGA, 0 )
              into vnPerAcrDescRetiraRepres, vnPerAcrDescEntregaRepres
              from MAD_REPRESENTANTE A
              where A.NROREPRESENTANTE = pnNroRepresentante;
   else
       vnPerAcrDescRetiraRepres := 0;
       vnPerAcrDescEntregaRepres := 0;
   end if;
   -- desconto / acrescimo em caso de entrega / retira ser diferente do padrao da empresa ( se o TIPACRDESCENTRET for = 'D' (Direto no preço) )
   if vsTipAcrDescEntRet = 'D' then
       if psIndEntregaRetira is not null then
           if vsDefaultEntRet != psIndEntregaRetira then
                  if vsDefaultEntRet = 'E' then
            			if psIndEntregaRetira = 'R' then
            				vnPrecoVda := vnPrecoVda + vnPrecoVda * ( vnPerAcrDescRetira + vnPerAcrDescRetiraRepres ) / 100;
            		    end if;
                  elsif vsDefaultEntRet = 'R' then
            			if psIndEntregaRetira = 'E' then
            				vnPrecoVda := vnPrecoVda + vnPrecoVda * ( vnPerAcrDescEntrega + vnPerAcrDescEntregaRepres ) / 100;
                        end if;
                  end if;
           elsif psIndEntregaRetira = 'R' then
                 vnPrecoVda := vnPrecoVda + vnPrecoVda * ( vnPerAcrDescRetira + vnPerAcrDescRetiraRepres ) / 100;
           elsif psIndEntregaRetira = 'E' then
                 vnPrecoVda := vnPrecoVda + vnPrecoVda * ( vnPerAcrDescEntrega + vnPerAcrDescEntregaRepres ) / 100;
           end if;
       end if;
   end if;
   -- ============================================================= REGRA INCENTIVO CLIENTE
   -- busca o desconto de incentivo do cliente na MFL_REGRAINCENTIVO ( se houver )
   if pnSeqPessoa is not null
   and vsTabIndUsaRegraIncentivo = 'S'
   then
       select nvl( max( a.percincentivo ), 0 )
       into   vnPercIncentivoCliente
       from   madv_regraincentivo a, mfl_clienteregra b
       where  b.seqregra          =  a.seqregra
       and    a.nrosegmento       =  pnNroSegmento
       and    b.seqpessoa         =  pnSeqPessoa
       and    'S'                 =  (select FVerificaUtilRegra(a.seqregra,
                                                                pnSeqPessoa,
                                                                a.tipoverifcli,
                                                                a.tipoverifprod,
                                                                pnNroPedVenda,
                                                                pnNroEmpresa,
                                                                pnNroSegmento,
                                                                pnSeqProduto)
                                      from    dual)
       and    b.status            =  decode(a.tipoverifcli,'E','I','A')
       and    a.tiporegra         =  'C'
       and    trunc(sysdate)      between  a.dtainicio and a.dtafim;
   else
       vnPercIncentivoCliente := 0;
   end if;
   -- Juscelino - 11-dez-2003 M_A - VERIFICA SE A CONDICAO DE PAGAMENTO PERMITE A UTILIZACAO DE DESCONTO DE REGRA DE INCENTIVO
   select nvl( max(A.INDUSADESCINCENTIV), 'S' )
   into vsIndUsaDescIncentiv
   from MAD_CONDICAOPAGTO A
   where A.NROCONDICAOPAGTO = pnNroCondicaoPagto;
   if vsIndUsaDescIncentiv = 'N' then
         vnPercIncentivoCliente := 0;
   end if;
   -- aplica o desconto de incentivo do cliente na MFL_REGRAINCENTIVO  (até o máximo do item bloq na MFL_PRODUTODESCTO )
   if vnPercIncentivoCliente > 0 then
        -- busca o desconto máximo permitido no item na tabela MAD_PRODEMPSEGBLOQ
        select max( PERCMAXDESCTO )
       	into vnPercMaxDesctoBloq
        from MAD_PRODEMPSEGBLOQ
        where SEQPRODUTO = pnSeqProduto
        and NROEMPRESA = pnNroEmpresa
        and NROSEGMENTO = pnNroSegmento;
        if vnPercMaxDesctoBloq is not null then
              if ( vnPercMaxDesctoBloq < vnPercIncentivoCliente ) then
                    vnPrecoVda := vnPrecoVda - vnPrecoVda * vnPercMaxDesctoBloq / 100;
              else
                    vnPrecoVda := vnPrecoVda - vnPrecoVda * vnPercIncentivoCliente / 100;
              end if;
        else
              vnPrecoVda := vnPrecoVda - vnPrecoVda * vnPercIncentivoCliente / 100;
        end if;
   end if;
   -- aplica o desconto comercia do cliente no segmento
   select max(a.percacrdesccomerc),
          max(a.percacrprecovda),
          max(a.percrestorno)
   into   vnCliSegPercAcrDescComerc,
          vnCliSegPercAcrPrecoVda,
          vnCliSegPercRestorno
   from   mrl_clienteseg a
   where  a.seqpessoa    =  pnSeqPessoa
   and    a.nrosegmento  =  pnNroSegmento;
   IF    (nvl(vnCliSegPercAcrDescComerc, 0) < 0 AND
          nvl(psUsaDescComercial, 'S') != 'N'   AND
          vsPD_GerDescComFinPromo = 'S')        OR
          nvl(vnCliSegPercAcrDescComerc, 0) > 0 THEN
          vnPrecoVda := vnPrecoVda + vnPrecoVda * vnCliSegPercAcrDescComerc / 100;
   end    if;
   if     nvl(vnCliSegPercAcrPrecoVda, 0) != 0 and nvl(psIndPrecoTabPrecoInformado, 'T') = 'I' then
          vnPrecoVda := vnPrecoVda + (vnPrecoVda * (vnCliSegPercAcrPrecoVda / 100));
   end    if;
   -- ============================================================= VALOR COMPLEMENTAR DE PRECO NA UNIDADE
   if nvl( vnVlrComplPrecoUnit, 0 ) > 0
      and pnQtdEmbalagem != 1  then
          select nvl(max(a.usavlrcompprecounid), 'S')
          into   vsUsacompprecounid
          from   mad_famsegmento a
          where  a.seqfamilia    =  vnSeqFamilia
          and    a.nrosegmento   =  pnNroSegmento;
          if     vsUsacompprecounid = 'S' then
                 vnPrecoVdaCompl :=  round( ( trunc( ( vnPrecoVda / pnQtdEmbalagem ), 2 ) + vnVlrComplPrecoUnit ), 4 );
                 vnPrecoVdaCompl := round( ( vnPrecoVdaCompl * pnQtdEmbalagem ), 2 );
                 if vnPrecoVdaCompl > vnPrecoVda then
                       vnPrecoVda := vnPrecoVdaCompl;
                 end if;
          end    if;
   end if;
   --verificando % de comissao a ser incorporado no preco de venda
   if vsPDPermClassifAbcTabVdaSeg = 'S' then
       select max(b.classifcomercabc)
       into   vsClassifComercAbcTabVenda
       from   mad_tabvdaclassifabc a, mad_famsegtabvenda b
       where  a.nrotabvenda      = b.nrotabvenda
       and    a.nrosegmento      = b.nrosegmento
       and    a.classifcomercabc = b.classifcomercabc
       and    b.seqfamilia       = vnSeqFamilia
       and    b.nrosegmento      = pnNroSegmento
       and    b.nrotabvenda      = psNroTabVenda;
   end if;
   if vsClassifComercAbcTabVenda is not null then
       select max(decode(psIndTipoPrecoRetorno, 'P', c.percomissaopromoc, c.percomissaonormal)),
              max(nvl(c.peracrespreco, 0))
       into   vnPercAdicComissaoPreco,
              vnperacresprecoclassabc
       from   mad_tabvdaclassifabc c
       where  c.nrotabvenda      = psNroTabVenda
       and    c.classifcomercabc = vsClassifComercAbcTabVenda
       and    c.nrosegmento      = pnNroSegmento;
   else
       select max(decode(psIndTipoPrecoRetorno, 'P', c.percomissaopromoc, c.percomissaonormal)),
              max(nvl(c.peracrespreco, 0))
       into   vnPercAdicComissaoPreco,
              vnperacresprecoclassabc
       from   mad_famsegmento a, map_classifabc b,
              mad_tabvdaclassifabc c
       where  a.seqfamilia         =    vnSeqFamilia
       and    a.nrosegmento        =    pnNroSegmento
       and    b.classifcomercabc   =    a.classifcomercabc
       and    b.nrosegmento        =    a.nrosegmento
       and    c.nrotabvenda        =    psNroTabVenda
       and    c.classifcomercabc   =    a.classifcomercabc
       and    c.nrosegmento        =    a.nrosegmento;
   end if;
  -- Verifica se o parametro dinamico 'IND_CONSID_COMISSAO_PRECO' está como 'S' para consistir o vnPercAdicComissaoPreco - Req 28996
   if     vnPercAdicComissaoPreco > 0 AND vsPD_IndConsidComissaoPreco = 'S' then
          vnPrecoVda := vnPrecoVda / ((100 - vnPercAdicComissaoPreco) / 100);
   end    if;
   if     vnperacresprecoclassabc != 0 then
          vnPrecoVda := vnPrecoVda + vnPrecoVda * vnperacresprecoclassabc / 100;
   end    if;
   If ( vsPD_Util_Acres_Desc_Forn = 'S' ) Then
       -- Verifica o percentual de Acrésc. / Desconto - PERACRESCDESC da tabela MAD_TABVDAFORNEC
       Select nvl(max(peracrescdesc), 0 )
       into   vnPerAcrescDescTabFor
       From   mad_tabvdafornec a
       Where  a.nrotabvenda    = psNroTabVenda
       And    a.seqfornecedor  = ( select nvl( max( F.SEQFORNECEDOR ), 0 )
                                   from   MAP_FAMFORNEC F
                                   where  F.SEQFAMILIA = vnSeqFamilia
                                   and    F.PRINCIPAL = 'S' );
       If ( vnPerAcrescDescTabFor != 0 ) Then
              vnPrecoVda := vnPrecoVda + ( vnPrecoVda * ( vnPerAcrescDescTabFor / 100 ));
       End If;
       -- Verifica o percentual de Acrésc. / Desconto - PERACRESCDESCCATEG da tabela MAD_TABVDAFORNCATEG
       Select nvl(max(peracrescdesccateg), 0 )
       into   vnPerAcrescDescTabForCat
       From   mad_tabvdaforncateg a
       Where  a.nrotabvenda    = psNroTabVenda
       And    a.seqfornecedor  = ( select nvl( max( F.SEQFORNECEDOR ), 0 )
                                   from   MAP_FAMFORNEC F
                                   where  F.SEQFAMILIA = vnSeqFamilia
                                   and    F.PRINCIPAL = 'S' )
       And   a.seqcategoria    = ( select nvl(Max(a.seqcategoria), 0 )
                                   from   map_famdivcateg a, map_categoria b
                                   where  a.seqcategoria  = b.seqcategoria
                                   and    a.nrodivisao    = b.nrodivisao
                                   and    a.nrodivisao    = vnNroDivisao
                                   and    a.status        = 'A'
                                   and    a.seqfamilia    = vnSeqFamilia
                                   and    b.statuscategor = 'A'
                                   and    b.actfamilia    = 'S'
                                   and    b.tipcategoria  = 'M' )
       And   a.nrodivisao      = vnNroDivisao;
       If ( vnPerAcrescDescTabForCat != 0 ) Then
              vnPrecoVda := vnPrecoVda + ( vnPrecoVda * ( vnPerAcrescDescTabForCat / 100 ));
       End If;
   End If;
   vnPrecoVda := vnPrecoVda + (vnPrecoVda * (vnPercAcresDescFamilia / 100));
   if vsIndUsaPercFreteCidade != 'N' then
      vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( vnPercFreteCidade / 100 ) );
   end if;
   ---
   -- Aplica acréscimo/desconto pela classificação comercial
   select max(b.percacrescdesc)
   into   vnpercacrescdesc
   from   mrl_cliente a, mad_classcomacrescdesc b
   where  a.codclasscomerc = b.codclasscomerc
   and    a.seqpessoa    =  pnSeqPessoa
   and    b.status = 'A';
   -- Percentual de Acresc/Desconto pela Classificação comercial por Segmento
   select max(b.percacrescdesc)
   into   vnPercAcrescDescClassComercSeg
   from   mrl_clienteseg a, mad_classcomacrescdesc b
   where  a.codclasscomerc =  b.codclasscomerc
   and    a.seqpessoa      =  pnSeqPessoa
   and    a.nrosegmento    =  pnNroSegmento
   and    a.status = 'A';
   -- Percentual de Acresc/Desconto por CLI/SEG/FORNEC.
   select sum(a.percacrescdesc)
   into   vnPercAcrescDescFornecSeg
   from   mrl_clientesegfornec a
   where  a.seqpessoa          =   pnSeqPessoa
   and    a.nrosegmento        =   pnNroSegmento
   and    exists  ( select 1
                    from   MAP_FAMFORNEC F
                    where  F.SEQFORNECEDOR = A.SEQFORNECEDOR
                    AND    F.SEQFAMILIA    = vnSeqFamilia );
   if vsPDUtilClassComercSegmento = 'S' and  vsPDSomaDescClassComercFornec = 'N' then
      if nvl(vnPercAcrescDescClassComercSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescClassComercSeg,0)/ 100 ) );
      end if;
      if nvl(vnPercAcrescDescFornecSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescFornecSeg,0)  / 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'S' and  vsPDSomaDescClassComercFornec = 'S' then
      vnPercAcrescDescClassComercSeg := nvl(vnPercAcrescDescClassComercSeg,0) + nvl(vnPercAcrescDescFornecSeg,0) ;
      if nvl(vnPercAcrescDescClassComercSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescClassComercSeg,0)/ 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'A' and  vsPDSomaDescClassComercFornec = 'N' then
      if (nvl(vnPercAcrescDescClassComercSeg, 0) != 0 or  nvl(vnpercacrescdesc, 0) != 0) then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescClassComercSeg,vnpercacrescdesc)/ 100 ) );
      end if;
      if nvl(vnPercAcrescDescFornecSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescFornecSeg,0)  / 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'A' and  vsPDSomaDescClassComercFornec = 'S' then
      vnPercAcrescDescClassComercSeg := nvl(vnPercAcrescDescClassComercSeg,vnpercacrescdesc) + nvl(vnPercAcrescDescFornecSeg,0) ;
      if nvl(vnPercAcrescDescClassComercSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescClassComercSeg,0)/ 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'N' and  vsPDSomaDescClassComercFornec = 'N' then
      if nvl(vnpercacrescdesc, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnpercacrescdesc,0)/ 100 ) );
      end if;
      if nvl(vnPercAcrescDescFornecSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescFornecSeg,0)  / 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'N' and  vsPDSomaDescClassComercFornec = 'S' then
      vnpercacrescdesc := nvl(vnpercacrescdesc,0) + nvl(vnPercAcrescDescFornecSeg,0) ;
      if nvl(vnpercacrescdesc, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnpercacrescdesc,0)/ 100 ) );
      end if;
   end  if;
   if  nvl(vnCliSegPercRestorno, 0) > 0 and
       nvl(psIndPrecoTabPrecoInformado, 'T') = 'I' then
       --
       vnVlrIndiceRestorno := fc5_CalcIndiceRestono(
                                 pnSeqProduto,
                                 pnCodGeralOper,
                                 pnNroEmpresa,
                                 null,
                                 pnSeqPessoa,
                                 pnNroSegmento,
                                 pnQtdEmbalagem,
                                 vnPrecoBaseRestorno,
                                 psNroTabVenda);
       --
       if  vnVlrIndiceRestorno > 0 then
           vnPrecoVda := vnPrecoVda * vnVlrIndiceRestorno;
       end if;
       --
   end if;
   if vsindUtilformPcoIPISobMIPC = 'S' and vsIndUtilFormPcoVdaAjIPI = 'S'
      and vnpercajusteficalipi > 0 and vsTipoTabVenda = 'T'
      and psCalcAjustFiscalIPI = 'S' then
     vnPrecoVda := vnPrecoVda  * ( vnpercajusteficalipi / 100 );
   end if;
   if vsIndUsaVlrAdicSetor = 'S' then
      vnPrecoVda := vnPrecoVda + ( ROUND( ( ( vnVlrAdicPrecoSetor * ( vnPercAdicPrecoSetor / 100 ) ) + vnVlrAdicPrecoSetor + vnVlrAdicPrecoRota ) * COALESCE( vnPesoBruto, vnPesoLiquido, 0 ), 2 ) );
   end if;
    if vsPDInsereCompProdCompVar = 'F' then
        select nvl(max(R.SEQRECEITARENDTO),0)
          into vnSeqReceitaRendto
          from MAP_PRODUTO A, MRL_RECEITARENDTO R, MRL_RRPRODUTOFINAL F
         where A.INDPROCFABRICACAO = 'V'
           and R.SEQRECEITARENDTO = F.SEQRECEITARENDTO
           and F.SEQPRODUTO = A.SEQPRODUTO
           and F.STATUS = 'A'
           and R.STATUSRECRENDTO = 'A'
           and A.SEQPRODUTO = pnSeqProduto
           and (vsPD_PermCadPorEmpresa != 'S' or
                exists (select 1
                        from   MRL_RECEITARENDTOEMP X
                        where  X.SEQRECEITARENDTO = R.SEQRECEITARENDTO
                        and    X.NROEMPRESA       = pnNroEmpresa));
        if vnSeqReceitaRendto > 0 then
             select nvl(sum(case
                              when c.indprecofixo = 'S' then
                               C.PRECOVDACOMPONENTE * c.qtdunidutilizada
                              else
                               fPrecoFinalTabVenda(c.seqproduto,
                                                   pnNroEmpresa,
                                                   pnNroSegmento,
                                                   c.qtdembalagem,
                                                   psNroTabVenda,
                                                   pnNroCondicaoPagto,
                                                   pnSeqPessoa,
                                                   psUfDestino,
                                                   pnNroRepresentante,
                                                   psIndEntregaRetira,
                                                   Null,
                                                   Null,
                                                   'S',
                                                   pnNroPedVenda,
                                                   Null,
                                                   'I',
                                                   pnCodGeralOper,
                                                   Null)* c.qtdunidutilizada
                            end),
                        0)
               into vnPrecoVda
               from MRL_RECEITARENDTO R, MRL_RRCOMPONENTE C
              where C.SEQRECEITARENDTO = R.SEQRECEITARENDTO
                and R.SEQRECEITARENDTO = vnSeqReceitaRendto
                and C.STATUSRRCOMPONENTE = 'A';
        end if;
    end if;
    -- RC 141712: Calcula o acresc. / desc. de acordo com o ramo de atividade do cliente e
    -- tipo de classificação na categoria
    If ( vsPDUtilAcrDescCateg = 'S' ) OR ( vsPDUtilAcrDescFam = 'S' ) then
       begin
         select b.lista
         into   vsListaAtivCliente
         from   ge_pessoa a, ge_atributofixo b
         where  a.atividade  = b.lista
         and    a.seqpessoa = pnSeqPessoa
         and    b.atributo  = 'ATIVIDADE';
         If ( vsPDUtilAcrDescCateg = 'S' ) then
             select atr.seqatributofixo
             into   vnSeqAtribListaClasAtiv
             from   map_categoria a, map_famdivcateg b, max_atributofixo atr
             where  a.seqcategoria   = b.seqcategoria
             and    a.nrodivisao     = b.nrodivisao
             and    b.seqfamilia     = vnSeqFamilia
             and    b.nrodivisao     = vnNroDivisao
             and a.tipcategoria      = 'M'
             and a.statuscategor     = 'A'
             and b.status            = 'A'
             and    a.listaatribclasativ = atr.lista
             and    atr.tipatributofixo  = 'TIP_CLASS_CATEG'
             and    a.nivelhierarquia = ( select max(c.nivelhierarquia)
                                         from   map_categoria c, map_famdivcateg d
                                         where  c.seqcategoria   = d.seqcategoria
                                         and    c.nrodivisao     = d.nrodivisao
                                         and    d.seqfamilia     = vnSeqFamilia
                                         and    d.nrodivisao     = vnNroDivisao
                                         and d.status            = 'A'
                                         and c.tipcategoria      = 'M'
                                         and c.statuscategor     = 'A'
                                         and    c.listaatribclasativ is not null );
         else
             select a.seqatribfixofam
             into   vnSeqAtribListaClasAtiv
             from   map_famtipoclassvda a, max_atributofixo atr
             where  a.seqfamilia        = vnSeqFamilia
             and    a.listaativ         = vsListaAtivCliente
             and    a.atributoativ      = 'ATIVIDADE'
             and    a.seqatribfixofam   = atr.seqatributofixo
             and    a.tipatribfixofam   = atr.tipatributofixo
             and    atr.tipatributofixo = 'TIP_CLASS_CATEG';
         end if;
       exception
         when no_data_found then
              vnSeqAtribListaClasAtiv := NULL;
              vsListaAtivCliente := null;
       end;
       if vnSeqAtribListaClasAtiv is not null then
          select nvl(max(a.peracrescdesc),0)
          into   vnpercacrescdesc
          from   mad_tabvdatipclassativ a
          where  a.nrotabvenda  = psNroTabVenda
          and    a.atributoativ = 'ATIVIDADE'
          and    a.listaativ    = vsListaAtivCliente
          and    a.tipatribfixocateg = 'TIP_CLASS_CATEG'
          and    a.seqatribfixocateg = vnSeqAtribListaClasAtiv;
          vnPrecoVda := vnPrecoVda + ( vnPrecoVda * ( nvl(vnpercacrescdesc,0) / 100 ));
       end if;
    end if;
    --
    vnPrecoVda := vnPrecoVda + ((vsPercTabVendaCategEmp / 100) * vnPrecoVda);
    vnPrecoRetorno := round( vnPrecoVda, 2 );
    return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
elsif vsIndPrecoBase = 'UE' then
   vnSeqNf := fmrl_BuscaSeqNFProdEmpData(vnSeqProdutoBase, nvl(pdDtaBasePreco,trunc(sysdate)), pnNroEmpresa, 'X');
     select sum((nvl(b.vlritem,0) + nvl(b.vlripi,0) + nvl(b.vlricmsst,0))) / sum(b.quantidade)
     into   vnPrecoVda
     from   mlf_notafiscal a, mlf_nfitem b
     where  a.numeronf        = b.numeronf
     and    a.serienf         = b.serienf
     and    a.nroempresa      = b.nroempresa
     and    a.seqpessoa       = b.seqpessoa
     and    a.tipnotafiscal   = b.tipnotafiscal
     and    a.seqnf           = vnSeqNf
     and    a.seqnf           = nvl(b.seqnf, a.seqnf)
     and    nvl(b.seqprodutobase,b.seqproduto)      = vnSeqProdutoBase
     and    b.quantidade      > 0;
   vnPrecoRetorno := round( vnPrecoVda, 2 );
   return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
else
  /* RC 160344 - Sempre que esta função tratar de CUSTOS deve ser utilizado o PRODUTO BASE */
   --- ********************** CALCULO DOS VALORES POR CUSTO (ML/MB/UL/UB)
   -- parametro psIndTipoPrecoRetorno:
     -- NULL = preco final de venda ( opção DEFAULT: preco final para vender, se houver promocao pegará com base na promocao, senão pega como base o normal )
     -- 'N' = preco final NORMAL de venda do produto (retorna sempre o preco com base no normal mesmo se o produto estiver em promoção)
     -- 'P' = preco PROMOCIONAL final de venda do produto ( se não estiver em promocao retorna zero)
   if psIndTipoPrecoRetorno = 'P' then      /* rc 38844 J*/
      vnPrecoRetorno := 0;
      return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
   end if;
    if vsPDInsereCompProdCompVar = 'F' then
        select nvl(max(R.SEQRECEITARENDTO),0)
          into vnSeqReceitaRendto
          from MAP_PRODUTO A, MRL_RECEITARENDTO R, MRL_RRPRODUTOFINAL F
         where A.INDPROCFABRICACAO = 'V'
           and R.SEQRECEITARENDTO = F.SEQRECEITARENDTO
           and F.SEQPRODUTO = A.SEQPRODUTO
           and F.STATUS = 'A'
           and R.STATUSRECRENDTO = 'A'
           and A.SEQPRODUTO = pnSeqProduto
           and (vsPD_PermCadPorEmpresa != 'S' or
                exists (select 1
                        from   MRL_RECEITARENDTOEMP X
                        where  X.SEQRECEITARENDTO = R.SEQRECEITARENDTO
                        and    X.NROEMPRESA       = pnNroEmpresa));
        if vnSeqReceitaRendto > 0 then
             select nvl(sum(case
                              when c.indprecofixo = 'S' then
                               C.PRECOVDACOMPONENTE * c.qtdunidutilizada
                              else
                               fPrecoFinalTabVenda(c.seqproduto,
                                                   pnNroEmpresa,
                                                   pnNroSegmento,
                                                   c.qtdembalagem,
                                                   psNroTabVenda,
                                                   pnNroCondicaoPagto,
                                                   pnSeqPessoa,
                                                   psUfDestino,
                                                   pnNroRepresentante,
                                                   psIndEntregaRetira,
                                                   Null,
                                                   Null,
                                                   'S',
                                                   pnNroPedVenda,
                                                   Null,
                                                   'I',
                                                   pnCodGeralOper,
                                                   Null)* c.qtdunidutilizada
                            end),
                        0)
               into vnPrecoVda
               from MRL_RECEITARENDTO R, MRL_RRCOMPONENTE C
              where C.SEQRECEITARENDTO = R.SEQRECEITARENDTO
                and R.SEQRECEITARENDTO = vnSeqReceitaRendto
                and C.STATUSRRCOMPONENTE = 'A';
              return vnPrecoVda;
        end if;
    end if;
  -- ==================================================== ACRESCIMO/DESCONTO TRIBUTARIO - MAD_TABVENDATRIB
   -- testar a MAD_TABVENDATRIB ( exemplo: se o produto da tributação 'BOM-BRIL' for vendido na tabela 'XXX' ele terá aplicado sobre ele o percentual Y )
   select nvl( max( A.PERACRTRIBUTARIO), 0 ),
          nvl( max( a.indpiscofinstabvenda), 'N'),
          max(a.perpis),
          max(a.percofins)
          into vnPercAcrDesctoTributarioTab,
               Vsindpiscofinstabvendatrib,
               Vnperpistabvendatrib,
               Vnpercofinstabvendatrib
          from MAD_TABVENDATRIB A
          where A.NROTRIBUTACAO = vnNroTributacao
          and A.NROTABVENDA = psNroTabVenda
          and A.STATUS = 'A';
   if     Vsindpiscofinstabvendatrib != 'S'      then
          Vnperpistabvendatrib       :=          null;
          Vnpercofinstabvendatrib    :=          null;
   else
          vnPerPis                   :=          nvl(Vnperpistabvendatrib, vnPerPis);
          Vnpercofins                :=          nvl(Vnpercofinstabvendatrib, Vnpercofins);
   end    if;
   if vsIndPrecoBase = 'MB' OR vsIndPrecoBase = 'MI'
   or vsIndPrecoBase = 'ML' then
       select nvl( max( A.CMULTVLRNF + A.CMULTIPI + A.CMULTICMSST + A.CMULTDESPNF + A.CMULTDESPFORANF
              - decode(vsPDSubDespFixaTransf || vsTipoTabVenda,'ST',nvl(a.cmultvlrdespfixa,0),0) -
              decode( vsIndPrecoBase, 'ML', A.CMULTCREDICMS + NVL(A.CMULTCREDIPI,0) +  nvl(a.cmultcredpis, 0) + nvl(a.cmultcredcofins, 0), 'MI', NVL(A.CMULTCREDIPI,0), 0 )
       - DECODE(vsIndConsidDescForaNFCalcPreco, 'S', (A.CMULTDCTOFORANF - DECODE(vsIndConsImpostoPresum,'N', NVL(A.CMULTIMPOSTOPRESUM,0), 0)), 0) - decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )
       + decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 ) ), 0)
          into vnCustoBase
          from MRL_PRODUTOEMPRESA A
          where A.NROEMPRESA = nvl(vnNroEmpresaPreco, pnNroEmpresa)
          and A.SEQPRODUTO = vnSeqProdutoBase;
       if vsIndPrecoBase in ('ML', 'MB') and vnCustoBase <= 0 then
              select nvl(indBuscaCustoEmpPedZerado, 'N')
                into vsIndBuscaCustoEmpPedZerado
                from mad_tabvenda
               where nrotabvenda = psNroTabVenda;
              if vsIndBuscaCustoEmpPedZerado = 'S' then
                select nvl( max( A.CMULTVLRNF + A.CMULTIPI + A.CMULTICMSST + A.CMULTDESPNF + A.CMULTDESPFORANF -
                    decode( vsIndPrecoBase, 'ML', A.CMULTCREDICMS + NVL(A.CMULTCREDIPI,0) +  nvl(a.cmultcredpis, 0) + nvl(a.cmultcredcofins, 0), 'MI', NVL(A.CMULTCREDIPI,0), 0 )
                    - DECODE(vsIndConsidDescForaNFCalcPreco, 'S', (A.CMULTDCTOFORANF - DECODE(vsIndConsImpostoPresum,'N', NVL(A.CMULTIMPOSTOPRESUM,0), 0)), 0) - decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )
                    + decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 ) ), 0)
                  into vnCustoBase
                  from MRL_PRODUTOEMPRESA A
                 where A.NROEMPRESA = pnNroEmpresa
                   and A.SEQPRODUTO = vnSeqProdutoBase;
              end if;
       end if;
   elsif vsIndPrecoBase = 'BS'        /* CUSTO BRUTO MENOS S.T. req 34933 */
      or vsIndPrecoBase = 'LS'        /* Custo Liquido Menos S.T. */
      or vsIndPrecoBase = 'LU' then   /* Custo Líquido Menos S.T. - % ICMS da última compra */
       select nvl( max( A.CMULTVLRNF + A.CMULTIPI + A.CMULTDESPNF + A.CMULTDESPFORANF - DECODE(vsIndConsidDescForaNFCalcPreco, 'S', (A.CMULTDCTOFORANF - DECODE(vsIndConsImpostoPresum,'N', NVL(A.CMULTIMPOSTOPRESUM,0), 0)), 0)
                   - case when vsIndPrecoBase = 'LS' or vsIndPrecoBase = 'LU' then
                        A.CMULTCREDICMS + NVL(A.CMULTCREDIPI,0) + NVL(A.CMULTCREDPIS, 0) + NVL(A.CMULTCREDCOFINS, 0)
                     else
                        0
                     end
                   - decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )
                   + decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 )
                   - decode( vsIndDeduzVlrIcmsStDistrib, 'S', nvl(a.cmulticmsstdistrib,0), 0 ) ), 0 ),
              nvl(max(A.CMULTCREDICMS), 0),
              nvl(max(A.CMULTICMSST), 0)
       into   vnCustoBase,
              vnCmUltCredIcms,
              vnCmUltIcmsSt
       from   MRL_PRODUTOEMPRESA A
       where  A.NROEMPRESA = nvl(vnNroEmpresaPreco, pnNroEmpresa)
       and    A.SEQPRODUTO = vnSeqProdutoBase;
       if vsIndPrecoBase = 'LU' and vnCmUltCredIcms = 0 and vnCmUltIcmsSt > 0 then
          vnAliqUltCompra := fmrl_buscaseqnfaliqicms('A', vnSeqProdutoBase, pnNroEmpresa, 'C');
          if vnAliqUltCompra is not null then
             vnCustoBase := vnCustoBase * (1 - (vnAliqUltCompra/100));
          end if;
       end if;
   elsif vsIndPrecoBase = 'UL'
   or vsIndPrecoBase = 'UB' OR vsIndPrecoBase = 'UI'
   or vsIndPrecoBase = 'US' or vsIndPrecoBase = 'UT' then
         vnSeqNf := null;
          sp_precofinaltabvendacust(Vsindexecutarotinaprodutocusto,
                                    Vstipotabvenda,
                                    Vsindconsdtaultcompra,
                                    Vnnroempresapreco,
                                    Psnrotabvenda,
                                    Vnseqprodutobase,
                                    Pddtabasepreco,
                                    Vnseqnf,
                                    Vddtaultcompraaux,
                                    Vddtaultentrcusto,
                                    Vddtaultcompracusto);
         if nvl(Vsindexecutarotinaprodutocusto, 'S') = 'S' then
            if(pdDtaBasePreco is not null) then
           /* T -> Última compra com alteração de custo
              C -> Última Compra
              U -> Última entrada com alteração de custo
              E -> Última Entrada */
           select Decode(vsindConsDtaUltCompra, 'C', 'T', -- Última compra com alteração de custo
                                                'S', 'C', -- Última Compra
                                                'U')      -- Última entrada com alteração de custo
             into vsTipoNF
             from dual;
           vnSeqNf := fmrl_BuscaSeqNFProdEmpData(vnSeqProdutoBase, pdDtaBasePreco, pnNroEmpresa, vsTipoNF);
           end if;
         vnCustoBase := 0;
         vdDtaUltCompraAux := null;
         vdDtaUltEntrCusto := null;
         vdDtaUltCompraCusto := null;
         select nvl(c.dtaultcompra,'01-jan-1900'), c.dtaultentrcusto, c.dtaultcompracusto
         into   vdDtaUltCompraAux, vdDtaUltEntrCusto, vdDtaUltCompraCusto
         from   mrl_produtoempresa c
         where  c.nroempresa       =  nvl(vnNroEmpresaPreco, pnNroEmpresa)
         and    c.seqproduto       =  vnSeqProdutoBase;
         end if;
         if vdDtaUltCompraAux is not null then
                  select case when vnSeqNf is null then
                           Decode(vsindConsDtaUltCompra, 'C', vdDtaUltCompraCusto, 'S', vdDtaUltCompraAux, vdDtaUltEntrCusto)
                         else
                           (select a.dtaentrada from mlf_notafiscal a where a.seqnf = vnSeqNf)
                         end
                    into vdDtaEntrada
                    from dual;
                 if vnSeqNf is null then
                  select max(d.seqnfultentrcusto)
                    into vnSeqNf
                    from mrl_custodia d
                   where d.dtaentradasaida = vdDtaEntrada
                     and d.seqproduto = pnSeqproduto
                     and d.nroempresa = nvl(vnNroEmpresaPreco, pnNroEmpresa);
                 end if;
                 -- SENÃO HOUVER SEQNF BUSCA POR INFORMAÇÕES PASSADAS
                 if vnSeqNF is null then
                  select nvl( sum(( ( B.VLRITEM - B.VLRDESCITEM + Decode(vsPDSomaFunRuralVlrCusto,'S',B.VLRFUNRURALITEM,0) + decode(vsIndSomaDespNf,'N',0, (CASE WHEN A.INDCONSIDFRETEDESPTRIB = 'N' THEN
                                                                                                                                                                B.VLRDESPTRIBUTITEM + NVL(B.VLRFRETENANF,0)
                                                                                                                                                            ELSE
                                                                                                                                                                B.VLRDESPTRIBUTITEM
                                                                                                                                                            END) + B.VLRDESPNTRIBUTITEM)
                   + decode(vsIndSomaDespForaNf,'N',0,B.VLRDESPFORANF) + decode( B.INDGERACREDIPI, 'S', 0, B.VLRIPI ) -
                    case when  vsIndPrecoBase in ('UL','UT') then
                               case when vsIndPrecoBase = 'UT' then decode(b.indsuframado, 'S', nvl(b.vlricmscalc, b.vlricms), b.vlricms)
                                    when (b.bascalcicmsst = 0 or vsIndPrecoBase = 'UT') then nvl(nvl(decode(vsPDSubIcmsPresum,'S',b.vlricmspresumido, null), b.vlricmscalc), b.vlricms)
                                    else case when b.lancamentost not in ('C', 'S') then 0
                                              else decode(b.indsuframado, 'S', nvl(b.vlricmscalc, b.vlricms), b.vlricms)
                                          end
                                end
                               + b.Vlrpis + b.Vlrcofins + decode( B.INDGERACREDIPI, 'T',B.VLRIPI, 0)
                         when vsIndPrecoBase = 'UI' then decode( B.INDGERACREDIPI, 'T', B.VLRIPI, 0)
                         else 0
                    end  +
                    case when vsIndPrecoBase in ('US','UT') then 0
                         else
                           case when b.lancamentost in ('C', 'S') then 0
                             else  B.VLRICMSST + NVL(B.VLRFCPST,0)
                           end
                    end -
                          case vsIndConsidDescForaNFCalcPreco when 'S' then
                             (B.VLRDESCFINANCEIRO -
                               case when vsPD_IndGerDescVerbComp = 'S' then
                                       nvl( B.VLRVERBAITEM, 0 )
                                  else
                                     0
                                  end
                              )
                           else 0 end
                               -
                               case when vsPD_GeraCustoVerbaBonif = 'S' and
                                      (vsindapropdescfincusto = 'N' or
                                        (vsindapropdescfincusto = 'S' and vsPD_IndGerDescVerbComp = 'N')) and
                                      vsIndConsidDescForaNFCalcPreco = 'S' then
                                   nvl( B.VLRVERBAITEM, 0 )
                               else
                                  0
                               end
                             ))
                             - (case when vsIndPrecoBase = 'UT' and vsIndDeduzVlrIcmsStDistrib = 'S'
                                                                and nvl(B.BASICMSSTDISTRIB,0) > 0
                                                                and nvl(B.PERALIQUOTAICMSSTDISTRIB,0) > 0
                                                                then (B.BASICMSSTDISTRIB * (B.PERALIQUOTAICMSSTDISTRIB/100))
                                     else 0
                                end)
                             ) / SUM(B.QUANTIDADE) -
                             max(decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( B.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )) +
                             max(decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( B.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 )), 0 )
                         into vnCustoBase
                         from MLF_NOTAFISCAL A, MLF_NFITEM B, MAX_CODGERALOPER C
                         where A.CODGERALOPER = C.CODGERALOPER
                         and A.dtaentrada = vdDtaEntrada
                         and A.NROEMPRESA = nvl(vnNroEmpresaPreco, pnNroEmpresa)
                         and A.NUMERONF = B.NUMERONF
                         and A.SEQPESSOA = B.SEQPESSOA
                         and A.SERIENF = B.SERIENF
                         and A.TIPNOTAFISCAL = B.TIPNOTAFISCAL
                         and A.NROEMPRESA = B.NROEMPRESA
                         and A.SEQNF = coalesce(vnSeqNf, B.SEQNF, A.SEQNF, 0)
                         and B.SEQPRODUTO = vnSeqProdutoBase
                         And a.TIPNOTAFISCAL = 'E'
                         and A.RECALCUSMEDIO = 'S'
                         and C.TIPDOCFISCAL in ('C' ,Decode(vsPDConsNotaTransf,'S','T','C'))
                         and C.TIPPEDIDOCOMPRA in ('C', Decode(vsPDConsNotaTransf,'S','T','C'))
                         and A.STATUSNF != 'C';
                   else
                     -- CASO TENHA SEQNF, FILTRA PELA PRIMARY KEY
                     select nvl( sum(( ( B.VLRITEM - B.VLRDESCITEM + Decode(vsPDSomaFunRuralVlrCusto,'S',B.VLRFUNRURALITEM,0) + decode(vsIndSomaDespNf,'N',0, (CASE WHEN A.INDCONSIDFRETEDESPTRIB = 'N' THEN
                                                                                                                                                                   B.VLRDESPTRIBUTITEM + NVL(B.VLRFRETENANF,0)
                                                                                                                                                               ELSE
                                                                                                                                                                   B.VLRDESPTRIBUTITEM
                                                                                                                                                               END) + B.VLRDESPNTRIBUTITEM)
                      + decode(vsIndSomaDespForaNf,'N',0,B.VLRDESPFORANF) + decode( B.INDGERACREDIPI, 'S', 0, B.VLRIPI ) -
                      case when  vsIndPrecoBase in ('UL','UT') then
                                 case when vsIndPrecoBase = 'UT' then decode(b.indsuframado, 'S', nvl(b.vlricmscalc, b.vlricms), b.vlricms)
                                      when (b.bascalcicmsst = 0 or vsIndPrecoBase = 'UT') then nvl(nvl(decode(vsPDSubIcmsPresum,'S',b.vlricmspresumido, null), b.vlricmscalc), b.vlricms)
                                      else case when b.lancamentost not in ('C', 'S') then 0
                                                else decode(b.indsuframado, 'S', nvl(b.vlricmscalc, b.vlricms), b.vlricms)
                                            end
                                  end
                                 + b.Vlrpis + b.Vlrcofins + decode( B.INDGERACREDIPI, 'T',B.VLRIPI, 0)
                           when vsIndPrecoBase = 'UI' then decode( B.INDGERACREDIPI, 'T', B.VLRIPI, 0)
                           else 0
                      end  +
                      case when vsIndPrecoBase in ('US','UT') then 0
                         else
                           case when b.lancamentost  in ('C', 'S') then 0
                             else  B.VLRICMSST + NVL(B.VLRFCPST,0)
                            end
                      end -
                              -- Alterou o parametro
                              -- Comentado RC 66465
                            case vsIndConsidDescForaNFCalcPreco when 'S' then
                               (B.VLRDESCFINANCEIRO -
                                 case when vsPD_IndGerDescVerbComp = 'S' then
                                         nvl( B.VLRVERBAITEM, 0 )
                                    else
                                       0
                                    end
                                )
                             else 0 end
                                 -
                                 case when vsPD_GeraCustoVerbaBonif = 'S' and
                                        (vsindapropdescfincusto = 'N' or
                                          (vsindapropdescfincusto = 'S' and vsPD_IndGerDescVerbComp = 'N')) and
                                        vsIndConsidDescForaNFCalcPreco = 'S' then
                                     nvl( B.VLRVERBAITEM, 0 )
                                 else
                                    0
                                 end
                               ))
                               - (case when vsIndPrecoBase = 'UT' and vsIndDeduzVlrIcmsStDistrib = 'S'
                                                                and nvl(B.BASICMSSTDISTRIB,0) > 0
                                                                and nvl(B.PERALIQUOTAICMSSTDISTRIB,0) > 0
                                                                then (B.BASICMSSTDISTRIB * (B.PERALIQUOTAICMSSTDISTRIB/100))
                                     else 0
                                end)
                                ) / SUM(B.QUANTIDADE) -
                               max(decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( B.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )) +
                               max(decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( B.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 )), 0 )
                           into vnCustoBase
                           from MLF_NOTAFISCAL A, MLF_NFITEM B, MAX_CODGERALOPER C
                           where A.CODGERALOPER = C.CODGERALOPER
                           and A.SEQNF = B.SEQNF
                           and A.SEQNF = vnSeqNf
                           and B.SEQPRODUTO = vnSeqProdutoBase
                           And a.TIPNOTAFISCAL = 'E'
                           and A.RECALCUSMEDIO = 'S'
                           and C.TIPDOCFISCAL in ('C' ,Decode(vsPDConsNotaTransf,'S','T','C'))
                           and C.TIPPEDIDOCOMPRA in ('C', Decode(vsPDConsNotaTransf,'S','T','C'))
                           and A.STATUSNF != 'C';
                   end if;
                   if  (vdDtaUltEntrCusto > vdDtaUltCompraAux and vsindConsDtaUltCompra = 'N') THEN
                           select nvl(max((
                                  a.centrvlrnf + a.centripi + decode(vsIndPrecoBase, 'US', 0, a.centricmsst ) +
                                  decode(vsIndSomaDespNf,'N',0,a.centrdespnf) + decode(vsIndSomaDespForaNf,'N',0,a.centrdespforanf) -
                                  decode(vsIndConsidDescForaNFCalcPreco, 'S', (a.centrdctoforanf - DECODE(vsIndConsImpostoPresum,'N', nvl(a.centrimpostopresum,0), 0)), 0) - decode(nvl(vsIndPrecoBase, 'UL'), 'UB', 0,'US', 0,
                                                         a.centrcredicms   + nvl(a.centrcredpis, 0) +
                                                         nvl(a.centrcredcofins, 0))) / a.qentrcusto), 0)
                           into   vnCustoBase
                           from   mrl_custodia a,
                                  map_produto b
                           where  b.seqproduto         =    vnSeqProdutoBase
                           and    nvl(b.seqprodutobase,b.seqproduto) = a.seqproduto
                           and    a.nroempresa         =    pnNroEmpresa
                           and    a.dtaentradasaida    =    vdDtaUltEntrCusto
                           and    a.qentrcusto          >    0;
                    end    if;
        end if;
        if  vnCustoBase = 0 then
              if vsIndPrecoBase = 'UT' then
                vsIndPrecoBase:= 'UL';
              end if;
              select nvl( max( A.CMULTVLRNF + A.CMULTIPI -
                       decode( vsIndPrecoBase, 'UL', A.CMULTCREDICMS + NVL(A.CMULTCREDIPI,0) +  nvl(a.cmultcredpis, 0) + nvl(a.cmultcredcofins, 0), 0)
                       + decode( vsIndPrecoBase, 'US', 0, A.CMULTICMSST ) + A.CMULTDESPNF + A.CMULTDESPFORANF
                    - DECODE(vsIndConsidDescForaNFCalcPreco, 'S', (A.CMULTDCTOFORANF - DECODE(vsIndConsImpostoPresum,'N', NVL(A.CMULTIMPOSTOPRESUM,0), 0)), 0) - decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )
                    + decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 ) ), 0 )
                    into vnCustoBase
                    from MRL_PRODUTOEMPRESA A
                    where A.NROEMPRESA = nvl(vnNroEmpresaPreco, pnNroEmpresa)
                    and A.SEQPRODUTO = vnSeqProdutoBase;
            if vsIndPrecoBase in ('UL', 'UB') and vnCustoBase <= 0 then
              select nvl(indBuscaCustoEmpPedZerado, 'N')
                into vsIndBuscaCustoEmpPedZerado
                from mad_tabvenda
               where nrotabvenda = psNroTabVenda;
              if vsIndBuscaCustoEmpPedZerado = 'S' then
                select nvl( max( A.CMULTVLRNF + A.CMULTIPI -
                       decode( vsIndPrecoBase, 'UL', A.CMULTCREDICMS + NVL(A.CMULTCREDIPI,0) +  nvl(a.cmultcredpis, 0) + nvl(a.cmultcredcofins, 0), 0)
                       + decode( vsIndPrecoBase, 'US', 0, A.CMULTICMSST ) + A.CMULTDESPNF + A.CMULTDESPFORANF
                    - DECODE(vsIndConsidDescForaNFCalcPreco, 'S', (A.CMULTDCTOFORANF - DECODE(vsIndConsImpostoPresum,'N', NVL(A.CMULTIMPOSTOPRESUM,0), 0)), 0) - decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )
                    + decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 ) ), 0 )
                    into vnCustoBase
                    from MRL_PRODUTOEMPRESA A
                    where A.NROEMPRESA = pnNroEmpresa
                    and A.SEQPRODUTO = vnSeqProdutoBase;
              end if;
            end if;
         end if;
   elsif vsIndPrecoBase = 'FB' or vsIndPrecoBase = 'FL'  then
         select  nvl(fmsu_custocompraatual(a.seqfamilia, vnNroDivisao, null, 'S', vsUfEmpresa,
                                       decode(vsIndPrecoBase, 'FB', 'B' || Vsindipiformapreco,
                                                                    'L' || Vsindipiformapreco), pnNroEmpresa),0)
         into    vnCustoBase
         from    map_produto a
         where   a.seqproduto               =       vnSeqProdutoBase;
         if      vnCustoBase = 0 then
                 select nvl( max( A.CMULTVLRNF + A.CMULTIPI -
                             decode( vsIndPrecoBase, 'FL',
                                    A.CMULTCREDICMS + NVL(A.CMULTCREDIPI,0) + nvl(a.cmultcredpis, 0) + nvl(a.cmultcredcofins, 0), 0 )
                             + A.CMULTICMSST +
                             A.CMULTDESPNF + A.CMULTDESPFORANF - A.CMULTDCTOFORANF -
                             decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )
                             + decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 ) ), 0 )
                 into   vnCustoBase
                 from   MRL_PRODUTOEMPRESA A
                 where  A.NROEMPRESA = nvl(vnNroEmpresaPreco, pnNroEmpresa)
                 and    A.SEQPRODUTO = vnSeqProdutoBase;
         end if;
   elsif vsIndPrecoBase = 'FS' then
       select  nvl(fmsu_custocompraatual(a.seqfamilia, vnNroDivisao, null, 'S', vsUfEmpresa,
                                     'F' || Vsindipiformapreco, pnNroEmpresa),0)
       into    vnCustoBase
       from    map_produto a
       where   a.seqproduto =  vnSeqProdutoBase;
       --
       if      vnCustoBase   = 0 then
               select nvl( max( A.CMULTVLRNF + A.CMULTIPI
                           + A.CMULTICMSST +  A.CMULTDESPNF + A.CMULTDESPFORANF - A.CMULTDCTOFORANF -
                           decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )
                           + decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 ) ), 0 )
               into   vnCustoBase
               from   MRL_PRODUTOEMPRESA A
               where  A.NROEMPRESA = nvl(vnNroEmpresaPreco, pnNroEmpresa)
               and    A.SEQPRODUTO = vnSeqProdutoBase;
       end if;
   elsif vsIndPrecoBase = 'TF' then
       select  nvl(fmsu_custocompraatual(a.seqfamilia, vnNroDivisao, null, 'S', vsUfEmpresa,
                                     'TF', pnNroEmpresa),0)
       into    vnCustoBase
       from    map_produto a
       where   a.seqproduto =  vnSeqProdutoBase;
       --
       if      vnCustoBase   = 0 then
               select nvl( max( A.CMULTVLRNF + A.CMULTIPI
                           + A.CMULTICMSST +  A.CMULTDESPNF + A.CMULTDESPFORANF - A.CMULTDCTOFORANF -
                           decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )
                           + decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 ) ), 0 )
               into   vnCustoBase
               from   MRL_PRODUTOEMPRESA A
               where  A.NROEMPRESA = nvl(vnNroEmpresaPreco, pnNroEmpresa)
               and    A.SEQPRODUTO = vnSeqProdutoBase;
       end if;
       --
    elsif  vsIndPrecoBase = 'LI'  then
            select nvl( max( A.CMULTVLRNF + A.CMULTIPI + A.CMULTICMSST + A.CMULTDESPNF + A.CMULTDESPFORANF -
               nvl(a.cmultcredpis, 0) - nvl(a.cmultcredcofins, 0)- NVL(A.CMULTCREDIPI,0)
       - DECODE(vsIndConsidDescForaNFCalcPreco, 'S', (A.CMULTDCTOFORANF - DECODE(vsIndConsImpostoPresum,'N', NVL(A.CMULTIMPOSTOPRESUM,0), 0)), 0) - decode( vsIndSubtraiVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem ), 0 ), 0 )
       + decode( vsIndSomaVerba, 'S', nvl( fc5VlrVerba( A.SEQPRODUTO, A.NROEMPRESA, pnNroPedVenda, pnSeqPedVendaItem, 'S' ), 0 ), 0 ) ), 0)
          into vnCustoBase
          from MRL_PRODUTOEMPRESA A
          where A.NROEMPRESA = nvl(vnNroEmpresaPreco, pnNroEmpresa)
          and A.SEQPRODUTO = vnSeqProdutoBase;
       --
    elsif  vsIndPrecoBase = 'LF'  then
    Select  Nvl( A.CMULTCUSLIQUIDOEMP, 0 )- DECODE(vsIndConsidDescForaNFCalcPreco, 'S', (A.CMULTDCTOFORANF - DECODE(vsIndConsImpostoPresum,'N', NVL(A.CMULTIMPOSTOPRESUM,0), 0)), 0)
       Into   vnCustoBase
       From   MRL_PRODUTOEMPRESA A
       Where  A.NROEMPRESA = nvl( vnNroEmpresaPreco, pnNroEmpresa )
       And    A.SEQPRODUTO = vnSeqProdutoBase;
   end if;
   if vsPDUtilizPercPropBaixaProd = 'S' and vnQtdeProporcaoProdBase is not null and vnSeqProdutoBase is not null then
     vnCustoBase:= vnCustoBase * vnQtdeProporcaoProdBase;
   end if;
   -- converte o custo para a embalagem desejada
   vnCustoBase := round( vnCustoBase * pnQtdEmbalagem, vnQtdeCasasDecRet );
   vnCustoConfig := vnCustoBase;
   if vsIndFormacaoPreco = 'S' then
       -- pegar os percentuais de despesas e indices da Classif ABC
       select nvl( max( B.PERCOMISSAONORMAL ), 0 ), nvl( max( B.PERCOMISSAOPROMOC ), 0 ), nvl( max( B.PERDESPCLASSIFABC ), 0 ), nvl( max( B.MGMLUCROCLASSIFABC ), 0 )
               into vnPerComissaoNormal, vnPerComissaoPromoc, vnPerDespClassifAbc, vnMgmLucroClassifAbc
               from MAD_FAMSEGMENTO A, MAP_CLASSIFABC B
               where A.CLASSIFCOMERCABC = B.CLASSIFCOMERCABC
               and A.NROSEGMENTO = B.NROSEGMENTO
               and A.SEQFAMILIA = vnSeqFamilia
               and A.NROSEGMENTO = pnNroSegmento;
       if vsIndICMSFormaPreco = 'S' or vsIndFCPFormaPreco = 'S' then
           -- busca informação da mad_tabvendatrib
           select max( A.NROEMPRESAFAT ), max( A.PERACRTRIBUTARIO )
           into vnNroEmpresaFatTabVdaTrib, vnPerAcrTributarioTabVdaTrib
           from MAD_TABVENDATRIB A
           where A.NROTABVENDA = psNroTabVenda
           and A.NROTRIBUTACAO = vnNroTributacao
           and A.STATUS = 'A';
           if vnNroEmpresaFatTabVdaTrib is not null then
                -- busca informações da empresa de faturamento
                select A.UF
                      into vsUfEmpresa
                      from MAX_EMPRESA A
                      where A.NROEMPRESA = vnNroEmpresaFatTabVdaTrib;
           end if;
           vnNroRegTributCli := fNroRegime_Faturamento(pnNroEmpresa, pnSeqPessoa, null, vnSeqFamilia, vnNroDivisao, pnCodGeralOper, vnNroTributacao,
                                                   vsUfEmpresa, vsUfCli, fmap_tiptributsaida(vsIndContribIcms, null, NULL, NULL, NULL, NULL, pnSeqPessoa ));
           vnNroRegTributacao := vnNroRegTributCli;
            -- seleciona a aliquota de icms de saida do produto
            if pnSeqPessoa is not null then
              vsTipoTributacao := case when vsIndContribIcms = 'S' then 'SC' else 'SN' end;
            else
              vsTipoTributacao := case when vsTipDivisao = 'A' then 'SC' else 'SN' end;
            end if;
            select A.PERALIQUOTAICMS,
                   A.PERALIQFCPICMS,
                   NVL(A.PERALIQICMSDIF,A.PERDIFERIDO),
                   A.SITUACAONF,
                   A.PERALIQICMSCALCPRECO
            into   vnPerAliqIcmsSaida,
                   vnPercFCP,
                   vnPerIcmsDiferidoSaida,
                   vsSituacaoNf,
                   vnPercCalcPreco
            from   TABLE(PKG_CARREGAIMPOSTO.FC_BUSCATRIBUTACAO(pnSeqProduto, 'S', vnNroTributacao,
                                                               vsTipoTributacao, vnNroRegTributacao,
                                                               decode(vsIndFaturamento, 'C', decode(vsUfEmpresa, vsUfCli, vsUFformacaoPreco, vsUfEmpresa), vsUfEmpresa),
                                                               vsUfCli, pnNroEmpresa, 13, NULL)) A;
            if vnPerIcmsDiferidoSaida > 0 and vsSituacaoNf = '051' then
               vnPerAliqIcmsSaida := vnPerAliqIcmsSaida - ( vnPerAliqIcmsSaida * vnPerIcmsDiferidoSaida / 100 );
            end if;
       end if;
       -- se for uma tabela de transferencia e o cliente não tiver sido especificado, será considerado saida para o mesmo cgc (sem PIS.COFINS e CPMF)
       if vsTipoTabVenda = 'T' then
             if pnSeqPessoa is null then
                 vsCgcBaseCli := vsCgcBaseEmpr;
             end if;
       end if;
       if vsindUtilformPcoIPISobMIPC = 'S' and vsIndUtilFormPcoVdaAjIPI = 'S' and vnPerIPI > 0 then
         select decode( vsIndICMSFormaPreco, 'S', vnPerAliqIcmsSaida, 0 ),
                decode( vsIndIsentoPis, 'S', 0, decode( vsIndPerPisFormaPreco, 'S',
                                                                      nvl(NVL(fmap_piscofinstribut(
                                                                      vnNroTributacao,vsUfEmpresa,
                                                                      vsUfCli,decode( vsTipDivisao, 'A', 'SC', 'SN' ),
                                                                      vnNroRegTributacao,pnNroEmpresa,
                                                                      vnNroDivisao, pnSeqPessoa,
                                                                      'P','S', 'N', vnSeqFamilia ),
                                                                      fmap_piscofinsfamilia(
                                                                      pnnroempresa, vnNroDivisao,
                                                                      ( select nvl( max( F.SEQFORNECEDOR ), 0 )
                                                                           from   MAP_FAMFORNEC F
                                                                           where  F.SEQFAMILIA = vnSeqFamilia
                                                                           and    F.PRINCIPAL = 'S' ), vnSeqFamilia,
                                                                      'P')),vnPerPis), 'N', 0,
                                                                      decode( vsCgcBaseEmpr, vsCgcBaseCli, 0, vnPerPis ) ) ),
                decode( vsIndIsentoPis, 'S', 0, decode( vsIndPerCofinsFormaPreco, 'S',
                                                                      nvl(NVL(fmap_piscofinstribut(
                                                                      vnNroTributacao,vsUfEmpresa,
                                                                      vsUfCli,decode( vsTipDivisao, 'A', 'SC', 'SN' ),
                                                                      vnNroRegTributacao,pnNroEmpresa,
                                                                      vnNroDivisao, pnSeqPessoa,
                                                                      'C','S', 'N', vnSeqFamilia ),
                                                                      fmap_piscofinsfamilia(
                                                                      pnnroempresa, vnNroDivisao,
                                                                      ( select nvl( max( F.SEQFORNECEDOR ), 0 )
                                                                           from   MAP_FAMFORNEC F
                                                                           where  F.SEQFAMILIA = vnSeqFamilia
                                                                           and    F.PRINCIPAL = 'S' ), vnSeqFamilia,
                                                                      'C')), vnPerCofins), 'N', 0,
                                                                      decode( vsCgcBaseEmpr, vsCgcBaseCli, 0, vnPerCofins ) ) ),
                decode( vsIndMargFormaPreco, 'S', vnMgmLucroClassifAbc, 0 )
           into vnPerICMSIndIPI,
                vnPerPisIndIPI,
                vnPerCofinsIndIPI ,
                vnMargIndIPI
           from dual;
       --
         vnIndImpostoSIPI       :=  vnMargIndIPI + vnPerICMSIndIPI + vnPerPisIndIPI + vnPerCofinsIndIPI;
         vnIndImpostoCIPI       :=  (vnMargIndIPI + vnPerICMSIndIPI + vnPerPisIndIPI + vnPerCofinsIndIPI) / ( 1 - (vnPerIPI / 100));
         vnIndFormPCOIPISobMIPC :=  vnIndImpostoCIPI - vnIndImpostoSIPI;
         vnFatorDivisaoIPI      :=  ( 1 - (vnPerIPI / 100));
       else
         vnFatorDivisaoIPI      := 1;
         vnIndFormPCOIPISobMIPC := 0;
       end if;
       select decode(vsIndIsentoPis, 'S', 0,
                decode(vsIndPerPisFormaPreco, 'S', nvl(NVL(fmap_piscofinstribut(
                                                             vnNroTributacao,
                                                             vsUfEmpresa,
                                                             vsUfCli,
                                                             decode(vsTipDivisao, 'A', 'SC', 'SN'),
                                                             vnNroRegTributacao,
                                                             pnNroEmpresa,
                                                             vnNroDivisao,
                                                             pnSeqPessoa,
                                                             'P',
                                                             'S',
                                                             'N',
                                                             vnSeqFamilia),
                                                           fmap_piscofinsfamilia(pnnroempresa,
                                                             vnNroDivisao,
                                                             (select nvl(max(F.SEQFORNECEDOR), 0)
                                                                from MAP_FAMFORNEC F
                                                               where F.SEQFAMILIA = vnSeqFamilia
                                                                 and F.PRINCIPAL = 'S'),
                                                             vnSeqFamilia,
                                                             'P')),vnPerPis),
                        'N', 0,
                          decode(vsCgcBaseEmpr, vsCgcBaseCli, 0, vnPerPis)
                      )
                    ),
              decode(vsIndIsentoPis, 'S', 0,
                decode(vsIndPerCofinsFormaPreco, 'S', nvl(NVL(fmap_piscofinstribut(
                                                                vnNroTributacao,
                                                                vsUfEmpresa,
                                                                vsUfCli,
                                                                decode(vsTipDivisao, 'A', 'SC', 'SN'),
                                                                vnNroRegTributacao,
                                                                pnNroEmpresa,
                                                                vnNroDivisao,
                                                                pnSeqPessoa,
                                                                'C',
                                                                'S',
                                                                'N',
                                                                vnSeqFamilia),
                                                              fmap_piscofinsfamilia(
                                                                pnnroempresa,
                                                                vnNroDivisao,
                                                                (select nvl(max(F.SEQFORNECEDOR), 0)
                                                                   from MAP_FAMFORNEC F
                                                                  where F.SEQFAMILIA = vnSeqFamilia
                                                                    and F.PRINCIPAL = 'S'),
                                                                vnSeqFamilia,
                                                                'C')), vnPerCofins),
                        'N', 0,
                          decode( vsCgcBaseEmpr, vsCgcBaseCli, 0, vnPerCofins )
                      )
                    )
         into vnPerPisCalculo, vnPerCofinsCalculo
         from dual;
       if vsIndEstornaIcmsBasePisCofins != 'N' then
         if vsIndEstornaIcmsBasePisCofins = 'S' then
           vnPercIcmsSaidaPisCofins:= vnPerAliqIcmsSaida + vnPercFCP;
         else
           vnPercIcmsSaidaPisCofins:= vnPerAliqIcmsSaida;
         end if;
         vnPerPisCalculo:= vnPerPisCalculo - (vnPerPisCalculo * (vnPercIcmsSaidaPisCofins/100));
         vnPerCofinsCalculo:= vnPerCofinsCalculo - (vnPerCofinsCalculo * (vnPercIcmsSaidaPisCofins/100));
       end if;
       -- realiza o calculo dos acrescimos em cima do preco de venda conforme parametros
       select round( ( vnCustoBase / ( 100
            - decode( vsIndICMSFormaPreco, 'S', vnPerAliqIcmsSaida, 0 )
            - decode( vsIndDespFormaPreco, 'S', decode(vsTipCalcMargem, 'A', vnPerDespClassifAbc, nvl(vnPerDespSegmento, nvl(vnPerDespDivisao, nvl(vnPerDespOperacional, 0)))), 0 )
            - decode( vsIndComisFormaPreco, 'S', vnPerComissaoNormal, 'P', vnPerComissaoPromoc, 0 )
            - decode( vsIndMargFormaPreco, 'S', decode(vsTipCalcMargem, 'A', vnMgmLucroClassifAbc, vnMgmLucroCategoria), 0 )
            - decode( vsIndPerCPMFFormaPreco, 'S', vnPerCPMF, 'N', 0,
                      decode( vsCgcBaseEmpr, vsCgcBaseCli, 0, vnPerCPMF ))
            - vnIndFormPCOIPISobMIPC
            - nvl(vnPerPisCalculo, 0)
            - nvl(vnPerCofinsCalculo, 0)
            - vnPerAdicFormaPreco
            - decode(vsIndFCPFormaPreco,'S', decode(vnPercCalcPreco, null, nvl(vnPercFCP,0), 0),0)) * 100 ) / vnFatorDivisaoIPI, vnQtdeCasasDecRet )
       into vnPrecoVda
       from dual;
   else
       vnPrecoVda :=vnCustoBase;
   end if;
   -- ============================ APLICACAO DO PERCENTUAL DE ACRESCIMO/DESCONTO DE DISTANCIA DA TABELA DE VENDA
   -- busca o percentual de acrescimo/desconto de entrega da tabela
   if     nvl(vsIndUsaPercAcrTabVenda, 'S')    !=  'N'     then
          select
           case when vsPD_TipoCalcFretePreco = 'S' then
                           nvl(max(nvl(a.peracrentrega, 0) +
                                  (decode(nvl(psCalcVlrEmbTabPrecoSemFrete,'S'),'S',nvl(a.percfretetransp, 0),0) * (1 - (vnPercAbatFrete/100))) ), 0)
                       else
                           nvl(max(nvl(a.peracrentrega, 0) / ((100 - (decode(nvl(psCalcVlrEmbTabPrecoSemFrete,'S'),'S',nvl(a.percfretetransp, 0),0) * (1 - (vnPercAbatFrete/100)))) /100)) , 0)
                       end
                 into vnperacrentrega
                 from mad_tabvenda a
                 where a.nrotabvenda = psnrotabvenda;
   else
          vnPerAcrEntrega := 0;
   end    if;
   
   -- calcula o preco, acrescendo o percentual de entrega da tabela
   vnPrecoVda := vnPrecoVda + vnPrecoVda * vnPerAcrEntrega / 100;
   
   if     vsindacrtabvendatrib != 'T'            then
          if     vsindacrtabvendatrib = 'C' and  vsIndContribIcms != 'S' then
                 vnPercAcrDesctoTributarioTab := 0;
          elsif  vsindacrtabvendatrib = 'N' and  vsIndContribIcms != 'N' then
                 vnPercAcrDesctoTributarioTab := 0;
          end    if;
   end    if;
   
   vnPrecoVda := vnPrecoVda + vnPrecoVda * vnPercAcrDesctoTributarioTab / 100;
   
   -- ============================================== DESCONTO OU ACRESCIMO FINANCEIRO DA CONDICAO DE PAGAMENTO
   -- busca o percentual de acrescimo financeiro da tabela sempre na faixa 'A'
   if (psDesconsideraAcresDesc is null or instr(psDesconsideraAcresDesc, 'C') = 0) then
       select nvl(max(A.PERACRFINANCEIRO), 0)
              into vnPerAcrFinanceiro
              from MAD_TABVENDACOND A
              where A.NROTABVENDA = psNroTabVenda
              and A.NROCONDICAOPAGTO = pnNroCondicaoPagto
              and A.FAIXAACRFINANCEIRO = 'A';
   else
       vnPerAcrFinanceiro := 0;
   end if;
   -- calcula o preco, acrescendo o percentual o financeiro da condicao de pagamento
   vnPercAcresDescCategProd := fc5BuscaJurosDescCategProd(pnNroEmpresa, vnSeqProdutoBase, pnQtdEmbalagem);
   if vnPercAcresDescCategProd != 0 then
      vnPrecoVda := vnPrecoVda + (vnPrecoVda * (vnPercAcresDescCategProd / 100));
   else
      vnPrecoVda := vnPrecoVda + (vnPrecoVda * (vnPerAcrFinanceiro / 100));
   end if;
   -- se o preco for maior ou igual a 1 centavo retornará assim mesmo...
   --verificando % de comissao a ser incorporado no preco de venda
   if vsPDPermClassifAbcTabVdaSeg = 'S' then
       select max(b.classifcomercabc)
       into   vsClassifComercAbcTabVenda
       from   mad_tabvdaclassifabc a, mad_famsegtabvenda b
       where  a.nrotabvenda      = b.nrotabvenda
       and    a.nrosegmento      = b.nrosegmento
       and    a.classifcomercabc = b.classifcomercabc
       and    b.seqfamilia       = vnSeqFamilia
       and    b.nrosegmento      = pnNroSegmento
       and    b.nrotabvenda      = psNroTabVenda;
   end if;
   if vsClassifComercAbcTabVenda is not null then
       select max(decode(psIndTipoPrecoRetorno, 'P', c.percomissaopromoc, c.percomissaonormal)),
              max(nvl(c.peracrespreco, 0))
       into   vnPercAdicComissaoPreco,
              vnperacresprecoclassabc
       from   mad_tabvdaclassifabc c
       where  c.nrotabvenda      = psNroTabVenda
       and    c.classifcomercabc = vsClassifComercAbcTabVenda
       and    c.nrosegmento      = pnNroSegmento;
   else
       select max(decode(psIndTipoPrecoRetorno, 'P', c.percomissaopromoc, c.percomissaonormal)),
              max(nvl(c.peracrespreco, 0))
       into   vnPercAdicComissaoPreco,
              vnperacresprecoclassabc
       from   mad_famsegmento a, map_classifabc b,
              mad_tabvdaclassifabc c
       where  a.seqfamilia         =    vnSeqFamilia
       and    a.nrosegmento        =    pnNroSegmento
       and    b.classifcomercabc   =    a.classifcomercabc
       and    b.nrosegmento        =    a.nrosegmento
       and    c.nrotabvenda        =    psNroTabVenda
       and    c.classifcomercabc   =    a.classifcomercabc
       and    c.nrosegmento        =    a.nrosegmento;
   end if;
   -- Verifica se o parametro dinamico 'IND_CONSID_COMISSAO_PRECO' está como 'S' para consistir o vnPercAdicComissaoPreco - req 28996
   if     vnPercAdicComissaoPreco > 0 AND vsPD_IndConsidComissaoPreco = 'S' then
          vnPrecoVda := vnPrecoVda / ((100 - vnPercAdicComissaoPreco) / 100);
   end    if;
   If ( vsPD_Util_Acres_Desc_Forn = 'S' ) Then
       -- Verifica o percentual de Acrésc. / Desconto - PERACRESCDESC da tabela MAD_TABVDAFORNEC
       Select nvl(max(peracrescdesc), 0 )
       into   vnPerAcrescDescTabFor
       From   mad_tabvdafornec a
       Where  a.nrotabvenda    = psNroTabVenda
       And    a.seqfornecedor  = ( select nvl( max( F.SEQFORNECEDOR ), 0 )
                                   from   MAP_FAMFORNEC F
                                   where  F.SEQFAMILIA = vnSeqFamilia
                                   and    F.PRINCIPAL = 'S' );
       If ( vnPerAcrescDescTabFor != 0 ) Then
              vnPrecoVda := vnPrecoVda + ( vnPrecoVda * ( vnPerAcrescDescTabFor / 100 ));
       End If;
       -- Verifica o percentual de Acrésc. / Desconto - PERACRESCDESCCATEG da tabela MAD_TABVDAFORNCATEG
       Select nvl(max(peracrescdesccateg), 0 )
       into   vnPerAcrescDescTabForCat
       From   mad_tabvdaforncateg a
       Where  a.nrotabvenda    = psNroTabVenda
       And    a.seqfornecedor  = ( select nvl( max( F.SEQFORNECEDOR ), 0 )
                                   from   MAP_FAMFORNEC F
                                   where  F.SEQFAMILIA = vnSeqFamilia
                                   and    F.PRINCIPAL = 'S' )
       And   a.seqcategoria    = ( select nvl(Max(a.seqcategoria), 0 )
                                   from   map_famdivcateg a, map_categoria b
                                   where  a.seqcategoria  = b.seqcategoria
                                   and    a.nrodivisao    = b.nrodivisao
                                   and    a.nrodivisao    = vnNroDivisao
                                   and    a.status        = 'A'
                                   and    a.seqfamilia    = vnSeqFamilia
                                   and    b.statuscategor = 'A'
                                   and    b.actfamilia    = 'S'
                                   and    b.tipcategoria  = 'M' )
       And   a.nrodivisao      = vnNroDivisao;
       If ( vnPerAcrescDescTabForCat != 0 ) Then
              vnPrecoVda := vnPrecoVda + ( vnPrecoVda * ( vnPerAcrescDescTabForCat / 100 ));
       End If;
   End If;
   -- Aplica acréscimo/desconto pela tabela de venda / família
   vnPrecoVda := vnPrecoVda + (vnPrecoVda * (vnPercAcresDescFamilia / 100));
   -- Aplica acréscimo/desconto pela classificação comercial
   select max(b.percacrescdesc)
   into   vnpercacrescdesc
   from   mrl_cliente a, mad_classcomacrescdesc b
   where  a.codclasscomerc = b.codclasscomerc
   and    a.seqpessoa    =  pnSeqPessoa
   and    b.status = 'A';
   -- Percentual de Acresc/Desconto pela Classificação comercial por Segmento
   select max(b.percacrescdesc)
   into   vnPercAcrescDescClassComercSeg
   from   mrl_clienteseg a, mad_classcomacrescdesc b
   where  a.codclasscomerc =  b.codclasscomerc
   and    a.seqpessoa      =  pnSeqPessoa
   and    a.nrosegmento    =  pnNroSegmento
   and    b.status = 'A';
   -- Percentual de Acresc/Desconto por CLI/SEG/FORNEC.
   select sum(a.percacrescdesc)
   into   vnPercAcrescDescFornecSeg
   from   mrl_clientesegfornec a
   where  a.seqpessoa          =   pnSeqPessoa
   and    a.nrosegmento        =   pnNroSegmento
   and    exists  ( select 1
                    from   MAP_FAMFORNEC F
                    where  F.SEQFORNECEDOR = A.SEQFORNECEDOR
                    AND    F.SEQFAMILIA    = vnSeqFamilia );
   if vsPDUtilClassComercSegmento = 'S' and  vsPDSomaDescClassComercFornec = 'N' then
      if nvl(vnPercAcrescDescClassComercSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescClassComercSeg,0)/ 100 ) );
      end if;
      if nvl(vnPercAcrescDescFornecSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescFornecSeg,0)  / 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'S' and  vsPDSomaDescClassComercFornec = 'S' then
      vnPercAcrescDescClassComercSeg := nvl(vnPercAcrescDescClassComercSeg,0) + nvl(vnPercAcrescDescFornecSeg,0) ;
      if nvl(vnPercAcrescDescClassComercSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescClassComercSeg,0)/ 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'A' and  vsPDSomaDescClassComercFornec = 'N' then
      if (nvl(vnPercAcrescDescClassComercSeg, 0) != 0 or  nvl(vnpercacrescdesc, 0) != 0) then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescClassComercSeg,vnpercacrescdesc)/ 100 ) );
      end if;
      if nvl(vnPercAcrescDescFornecSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescFornecSeg,0)  / 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'A' and  vsPDSomaDescClassComercFornec = 'S' then
      vnPercAcrescDescClassComercSeg := nvl(vnPercAcrescDescClassComercSeg,vnpercacrescdesc) + nvl(vnPercAcrescDescFornecSeg,0) ;
      if nvl(vnPercAcrescDescClassComercSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescClassComercSeg,0)/ 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'N' and  vsPDSomaDescClassComercFornec = 'N' then
      if nvl(vnpercacrescdesc, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnpercacrescdesc,0)/ 100 ) );
      end if;
      if nvl(vnPercAcrescDescFornecSeg, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnPercAcrescDescFornecSeg,0)  / 100 ) );
      end if;
   elsif vsPDUtilClassComercSegmento = 'N' and  vsPDSomaDescClassComercFornec = 'S' then
      vnpercacrescdesc := nvl(vnpercacrescdesc,0) + nvl(vnPercAcrescDescFornecSeg,0) ;
      if nvl(vnpercacrescdesc, 0) != 0 then
         vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( nvl(vnpercacrescdesc,0)/ 100 ) );
      end if;
   end  if;
   if round( vnPrecoVda, vnQtdeCasasDecRet ) > 0 then
         if vsindUtilformPcoIPISobMIPC = 'S' and vsIndUtilFormPcoVdaAjIPI = 'S'
            and vnpercajusteficalipi > 0 and vsTipoTabVenda = 'T'
            and psCalcAjustFiscalIPI = 'S' then
           vnPcoVendaEmpAjustIPI := fminprecoprodemp( vnSeqProdutoBase,nvl(vnNroEmpPcoAjustIPI,vnNroEmpresaPreco)) *  pnQtdEmbalagem;
           vnPcoVendaEmpAjustIPI := vnPcoVendaEmpAjustIPI * ( vnpercajusteficalipi / 100 );
           vnPrecoVda            := vnPrecoVda  * ( vnpercajusteficalipi / 100 );
           if vnPrecoVda < vnPcoVendaEmpAjustIPI then
             vnPrecoVda := vnPcoVendaEmpAjustIPI;
           end if;
           if vnPrecovda < vnCustoConfig then
              vnPrecovda := vnCustoConfig;
         end if;
        end if;
         if vsIndUsaPercFreteCidade != 'N' then
            vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( vnPercFreteCidade / 100 ) );
         end if;
         --
         if vsIndUsaVlrAdicSetor = 'S' then
            vnPrecoVda := vnPrecoVda + ( ROUND( ( ( vnVlrAdicPrecoSetor * ( vnPercAdicPrecoSetor / 100 ) ) + vnVlrAdicPrecoSetor + vnVlrAdicPrecoRota ) * COALESCE( vnPesoBruto, vnPesoLiquido, 0 ), 2 ) );
         end if;
          vnPrecoVda := vnPrecoVda + ((vsPercTabVendaCategEmp / 100) * vnPrecoVda);
          vnPrecoRetorno := round( vnPrecoVda, vnQtdeCasasDecRet );
          return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
   -- A partir do RC 64642 o percentual fixo de 75% foi substituído pelo parâmetro dinâmico vnPD_PercVendaProdSemCusto.
   else
       vnPrecoVda   := round( fPrecoEmbProduto( vnSeqProdutoBase, pnQtdEmbalagem, nvl(vnNroSegmentoPreco, pnNroSegmento), nvl(vnNroEmpresaPreco, pnNroEmpresa) ) * vnPD_PercVendaProdSemCusto, 2 );
       if vsindUtilformPcoIPISobMIPC = 'S' and vsIndUtilFormPcoVdaAjIPI = 'S'
          and vnpercajusteficalipi > 0 and vsTipoTabVenda = 'T'
          and psCalcAjustFiscalIPI = 'S' then
         vnPcoVendaEmpAjustIPI := fminprecoprodemp( vnSeqProdutoBase,nvl(vnNroEmpPcoAjustIPI,vnNroEmpresaPreco)) *  pnQtdEmbalagem;
         vnPcoVendaEmpAjustIPI := vnPcoVendaEmpAjustIPI * ( vnpercajusteficalipi / 100 );
         vnPrecoVda            := vnPrecoVda  * ( vnpercajusteficalipi / 100 );
         --
         --
         if vnPrecoVda < vnPcoVendaEmpAjustIPI then
           vnPrecoVda := vnPcoVendaEmpAjustIPI;
         end if;
         --
         if vnPrecovda < vnCustoConfig then
            vnPrecovda := vnCustoConfig;
         end if;
       end if;
       if vsIndUsaPercFreteCidade != 'N' then
             vnPrecoVda   :=   vnPrecoVda + ( vnPrecoVda * ( vnPercFreteCidade / 100 ) );
       end if;
       if vsIndUsaVlrAdicSetor = 'S' then
          vnPrecoVda := vnPrecoVda + ( ROUND( ( ( vnVlrAdicPrecoSetor * ( vnPercAdicPrecoSetor / 100 ) ) + vnVlrAdicPrecoSetor + vnVlrAdicPrecoRota ) * COALESCE( vnPesoBruto, vnPesoLiquido, 0 ), 2 ) );
       end if;
        if vsPDInsereCompProdCompVar = 'F' then
            select nvl(max(R.SEQRECEITARENDTO),0)
              into vnSeqReceitaRendto
              from MAP_PRODUTO A, MRL_RECEITARENDTO R, MRL_RRPRODUTOFINAL F
             where A.INDPROCFABRICACAO = 'V'
               and R.SEQRECEITARENDTO = F.SEQRECEITARENDTO
               and F.SEQPRODUTO = A.SEQPRODUTO
               and F.STATUS = 'A'
               and R.STATUSRECRENDTO = 'A'
               and A.SEQPRODUTO = vnSeqProdutoBase
               and (vsPD_PermCadPorEmpresa != 'S' or
                    exists (select 1
                            from   MRL_RECEITARENDTOEMP X
                            where  X.SEQRECEITARENDTO = R.SEQRECEITARENDTO
                            and    X.NROEMPRESA       = pnNroEmpresa));
            if vnSeqReceitaRendto > 0 then
                 select nvl(sum(case
                                  when c.indprecofixo = 'S' then
                                   C.PRECOVDACOMPONENTE * c.qtdunidutilizada
                                  else
                                   fPrecoFinalTabVenda(c.seqproduto,
                                                       pnNroEmpresa,
                                                       pnNroSegmento,
                                                       c.qtdembalagem,
                                                       psNroTabVenda,
                                                       pnNroCondicaoPagto,
                                                       pnSeqPessoa,
                                                       psUfDestino,
                                                       pnNroRepresentante,
                                                       psIndEntregaRetira,
                                                       Null,
                                                       Null,
                                                       'S',
                                                       pnNroPedVenda,
                                                       Null,
                                                       'I',
                                                       pnCodGeralOper,
                                                       Null) * c.qtdunidutilizada
                                end),
                            0)
                   into vnPrecoVda
                   from MRL_RECEITARENDTO R, MRL_RRCOMPONENTE C
                  where C.SEQRECEITARENDTO = R.SEQRECEITARENDTO
                    and R.SEQRECEITARENDTO = vnSeqReceitaRendto
                    and C.STATUSRRCOMPONENTE = 'A';
            end if;
        end if;
    -- RC 141712: Calcula o acresc. / desc. de acordo com o ramo de atividade do cliente e
    -- tipo de classificação na categoria ou na familia
    If ( vsPDUtilAcrDescCateg = 'S' ) OR ( vsPDUtilAcrDescFam = 'S' ) then
       begin
         select b.lista
         into   vsListaAtivCliente
         from   ge_pessoa a, ge_atributofixo b
         where  a.atividade  = b.lista
         and    a.seqpessoa = pnSeqPessoa
         and    b.atributo  = 'ATIVIDADE';
         If ( vsPDUtilAcrDescCateg = 'S' ) then
             select atr.seqatributofixo
             into   vnSeqAtribListaClasAtiv
             from   map_categoria a, map_famdivcateg b, max_atributofixo atr
             where  a.seqcategoria   = b.seqcategoria
             and    a.nrodivisao     = b.nrodivisao
             and    b.seqfamilia     = vnSeqFamilia
             and    b.nrodivisao     = vnNroDivisao
             and a.tipcategoria      = 'M'
             and a.statuscategor     = 'A'
             and b.status            = 'A'
             and    a.listaatribclasativ = atr.lista
             and    atr.tipatributofixo  = 'TIP_CLASS_CATEG'
             and    a.nivelhierarquia = ( select max(c.nivelhierarquia)
                                         from   map_categoria c, map_famdivcateg d
                                         where  c.seqcategoria   = d.seqcategoria
                                         and    c.nrodivisao     = d.nrodivisao
                                         and    d.seqfamilia     = vnSeqFamilia
                                         and    d.nrodivisao     = vnNroDivisao
                                         and d.status            = 'A'
                                         and c.tipcategoria      = 'M'
                                         and c.statuscategor     = 'A'
                                         and    c.listaatribclasativ is not null );
         else
             select a.seqatribfixofam
             into   vnSeqAtribListaClasAtiv
             from   map_famtipoclassvda a, max_atributofixo atr
             where  a.seqfamilia        = vnSeqFamilia
             and    a.listaativ         = vsListaAtivCliente
             and    a.atributoativ      = 'ATIVIDADE'
             and    a.seqatribfixofam   = atr.seqatributofixo
             and    a.tipatribfixofam   = atr.tipatributofixo
             and    atr.tipatributofixo = 'TIP_CLASS_CATEG';
         end if;
       exception
         when no_data_found then
              vnSeqAtribListaClasAtiv := NULL;
              vsListaAtivCliente := null;
       end;
       if vnSeqAtribListaClasAtiv is not null then
          select nvl(max(a.peracrescdesc),0)
          into   vnpercacrescdesc
          from   mad_tabvdatipclassativ a
          where  a.nrotabvenda  = psNroTabVenda
          and    a.atributoativ = 'ATIVIDADE'
          and    a.listaativ    = vsListaAtivCliente
          and    a.tipatribfixocateg = 'TIP_CLASS_CATEG'
          and    a.seqatribfixocateg = vnSeqAtribListaClasAtiv;
          vnPrecoVda := vnPrecoVda + ( vnPrecoVda * ( nvl(vnpercacrescdesc,0) / 100 ));
       end if;
    end if;
    --
       vnPrecoVda := vnPrecoVda + ((vsPercTabVendaCategEmp / 100) * vnPrecoVda);
       vnPrecoRetorno := vnPrecoVda; --round(vnPrecoVda, vnQtdeCasasDecRet)
       return fPrecoFinalTabVendaCust(vnPrecoRetorno, pnSeqProduto, pnSeqpessoa, psNroTabVenda, pnNroPedVenda);
   end if;
end if;
exception
    when  no_data_found then
          return 0;
    when  others then
              raise_application_error (-20200, sqlerrm );
end fPrecoFinalTabVenda;
/

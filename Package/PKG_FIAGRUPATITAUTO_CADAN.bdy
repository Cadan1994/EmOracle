CREATE OR REPLACE PACKAGE IMPLANTACAO.PKG_FIAGRUPATITAUTO_cadan IS
  -- Procedure principal de processamento
  PROCEDURE FIP_AGRUPAUTTITULOS(psUsuario    IN GE_USUARIO.CODUSUARIO%TYPE, -- Usuário usado para registro das transações e log, em caso de nulo será usado o nome AUTOMATICO
                                pdDtaInicial IN FI_TITULO.DTAEMISSAO%TYPE, -- Data inicial para busca dos títulos, caso não seja informado serão filtrados todas as datas
                                pdDtaFinal   IN FI_TITULO.DTAEMISSAO%TYPE, -- Data final para busca dos títulos, caso não seja informado serão filtrados todas as datas
                                psTipoData   IN VARCHAR2 -- Tipo de data usada E-Emissão V-Vencimento, este filtro é usado em conjunto com os filtros de data
                                );
  /* Baixa os títulos */
  FUNCTION FIF_BAIXATITULOS(psTitulos        IN CLOB,
                            pnCodOpeQuit     IN FI_OPERACAO.CODOPERACAO%TYPE,
                            pnCodOpeMulta    IN FI_OPERACAO.CODOPERACAO%TYPE,
                            pnCodOpeJuros    IN FI_OPERACAO.CODOPERACAO%TYPE,
                            pnCodOpeDesc     IN FI_OPERACAO.CODOPERACAO%TYPE,
                            pnNroEmpresaMae  IN GE_EMPRESA.NROEMPRESA%TYPE,
                            psUtilizaDesc    IN FI_PARAMBAIXATITAUTO.DESCONTO%TYPE,
                            psMultaJuros     IN FI_PARAMBAIXATITAUTO.UTILIZAMULTAJUROS%TYPE,
                            pnNroProcessoExe IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                            pnNroProcessoTit IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                            psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE,
                            pnTotalBaixa     OUT FI_TITULO.VLRNOMINAL%TYPE)
    RETURN BOOLEAN;
  /* Faz o lançamento das operações */
  FUNCTION FIF_LANCAOPERACAO(pnCodOperacao    IN FI_OPERACAO.CODOPERACAO%TYPE,
                             pnSeqTitulo      IN FI_TITULO.SEQTITULO%TYPE,
                             pnNroEmpresaMae  IN GE_EMPRESA.NROEMPRESA%TYPE,
                             pnNroEmpresa     IN GE_EMPRESA.NROEMPRESA%TYPE,
                             pnValor          IN FI_TITOPERACAO.VLROPERACAO%TYPE,
                             pnNroProcessoExe IN FI_LOGBAIXATITAUTO.NROPROCESSOEXE%TYPE,
                             pnNroProcessoTit IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                             psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE,
                             psCanOcrQuitTit  IN FI_PARAMETRO.CANOCRQUITTIT%TYPE,
                             pnSeqTitDesconto IN FI_TITOPERACAO.SEQTITDESCONTO%TYPE)
    RETURN BOOLEAN;
  /* Gera o número da empresa */
  FUNCTION FIF_RETORNAEMPRESA(psEmpresasAgrupadas IN CLOB,
                              pnNroEmpresaMae     IN GE_EMPRESA.NROEMPRESA%TYPE,
                              psEmpresaGeradora   IN FI_PARAMBAIXATITAUTO.EMPRESAGERACAO%TYPE)
    RETURN NUMBER;
  /* Gera o número do novo título */
  FUNCTION FIF_RETORNANROTITULO(psNroTitulosAgrupados IN CLOB,
                                pdDtaVencimento       IN FI_TITULO.DTAVENCIMENTO%TYPE,
                                psNumeroGeracao       IN FI_PARAMBAIXATITAUTO.NUMEROGERACAO%TYPE)
    RETURN NUMBER;
  /* Gera data do desconto do novo título */
  FUNCTION FIF_RETORNADTALIMDESC(psDtaLimDescFin       IN CLOB,
                                 pdDtaVencimento       IN FI_TITULO.DTAVENCIMENTO%TYPE,
                                 psParamUsaDesconto    IN FI_PARAMBAIXATITAUTO.DESCONTO%TYPE,
                                 psParamDataLimiteDesc IN FI_PARAMBAIXATITAUTO.DATALIMITEDESC%TYPE)
    RETURN DATE;
  /* Consiste a espécie e operação */
  FUNCTION FIF_CONSISTEESPOPER(pdDtaContabil    IN FI_TITOPERACAO.DTACONTABILIZA%TYPE,
                               psCodEspecie     IN FI_ESPECIE.CODESPECIE%TYPE,
                               pnCodOperacao    IN FI_OPERACAO.CODOPERACAO%TYPE,
                               pnNroEmpresa     IN GE_EMPRESA.NROEMPRESA%TYPE,
                               pnNroEmpresaMae  IN GE_EMPRESA.NROEMPRESA%TYPE,
                               pnNroProcessoExe IN FI_LOGBAIXATITAUTO.NROPROCESSOEXE%TYPE,
                               psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE)
    RETURN BOOLEAN;
  /* Gera Log */
  PROCEDURE FIP_GRAVALOG(psMensagem       IN FI_LOGBAIXATITAUTO.DESCRICAO%TYPE,
                         pnSeqTitulo      IN FI_TITULO.SEQTITULO%TYPE,
                         pnNroProcessoExe IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                         pnNroProcessoTit IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                         psCategoria      IN FI_LOGBAIXATITAUTO.CATEGORIA%TYPE,
                         psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE);
  /* Monta a data de vencimento do Título agrupado */
  FUNCTION FIF_DTAVENCIMENTO(pdFechamento   IN DATE,
                             pdVencimento   IN FI_TITULO.DTAVENCIMENTO%TYPE,
                             pnSeqPessoa    IN FI_TITULO.SEQPESSOA%TYPE,
                             psObrigDireito IN FI_TITULO.OBRIGDIREITO%TYPE)
    RETURN DATE;
  /* Monta a data a partir do dia, mês e ano de execução */
  FUNCTION FIF_MONTADATA(pnDia    IN FI_PERIODOAGRUPAUTO.DIAINI%TYPE,
                         pnMes    IN FI_PERIODOAGRUPAUTO.MESINI%TYPE,
                         pnMesExe IN FI_PERIODOAGRUPAUTO.MESEXE%TYPE,
                         pnAnoExe IN NUMBER,
                         psTipo   IN VARCHAR) -- P - Periodo   V - Vencimento
   RETURN DATE;
  /* Duplica Periodo */
  PROCEDURE FIP_DUPLICARPERIODO(pnSeqPessoa       IN FI_PERIODOAGRUPAUTO.SEQPESSOA%TYPE,
                                psObrigdireito    IN FI_PERIODOAGRUPAUTO.OBRIGDIREITO%TYPE,
                                pnSeqPessoaDup    IN FI_PERIODOAGRUPAUTO.SEQPESSOA%TYPE,
                                psObrigdireitoDup IN FI_PERIODOAGRUPAUTO.OBRIGDIREITO%TYPE,
                                psUsuario         IN FI_PERIODOAGRUPAUTO.USUALTERACAO%TYPE);
END PKG_FIAGRUPATITAUTO_cadan;
/
CREATE OR REPLACE PACKAGE BODY IMPLANTACAO.PKG_FIAGRUPATITAUTO_cadan IS
  -- Procedure principal de processamento
  PROCEDURE FIP_AGRUPAUTTITULOS(psUsuario    IN GE_USUARIO.CODUSUARIO%TYPE, -- Usuário usado para registro das transações e log, em caso de nulo será usado o nome AUTOMATICO
                                pdDtaInicial IN FI_TITULO.DTAEMISSAO%TYPE, -- Data inicial para busca dos títulos, caso não seja informado serão filtrados todas as datas
                                pdDtaFinal   IN FI_TITULO.DTAEMISSAO%TYPE, -- Data final para busca dos títulos, caso não seja informado serão filtrados todas as datas
                                psTipoData   IN VARCHAR2 -- Tipo de data usada E-Emissão V-Vencimento, este filtro é usado em conjunto com os filtros de data
                                ) IS
    -- Cursor
    TYPE CursorRefType IS REF CURSOR;
    Cursor_Titulo CursorRefType;
    -- Campos do loop
    vtnNroEmpresaMae    FI_TITULO.NROEMPRESAMAE%TYPE;
    vtnNroEmpresa       FI_TITULO.NROEMPRESA%TYPE;
    vtnSeqPessoa        FI_TITULO.SEQPESSOA%TYPE;
    vtsObrigacaoDireito FI_TITULO.OBRIGDIREITO%TYPE;
    vtdDtaVencimento    FI_TITULO.DTAVENCIMENTO%TYPE;
    vtsCodEspecie       FI_TITULO.CODESPECIE%TYPE;
    vtnQtdTitulos       INTEGER;
    vtnVlrDescFin       FI_COMPLTITULO.VLRDSCFINANC%TYPE;
    vtnVlrDescContrato  FI_COMPLTITULO.VLRDESCCONTRATO%TYPE;
    vtcInSeqTitulos     CLOB;
    vtcInNroEmpresa     CLOB;
    vtcInNroTitulo      CLOB;
    vtcInDtaLimDescFin  CLOB;
    -- Montagem da consulta
    vsSqlColunas     VARCHAR2(6000);
    vsSqlWhere       VARCHAR2(12000);
    vsSqlGroupBy     VARCHAR2(3000);
    vsSqlOrderBy     VARCHAR2(3000);
    vsSqlConsulta    VARCHAR2(30000);
    vsSqlAgrupamento VARCHAR2(6000);
    -- Parâmetros
    vsEmpresaGeracao       FI_PARAMBAIXATITAUTO.EMPRESAGERACAO%TYPE;
    vsUtilizaMultaJuros    FI_PARAMBAIXATITAUTO.UTILIZAMULTAJUROS%TYPE;
    vsPermAgrupTitVencido  FI_PARAMBAIXATITAUTO.PERMAGRUPTITVENCIDO%TYPE;
    vsPermAgrupTitAgrupado FI_PARAMBAIXATITAUTO.PERMAGRUPTITAGRUP%TYPE;
    vsDesconto             FI_PARAMBAIXATITAUTO.DESCONTO%TYPE;
    vsDataLimiteDesc       FI_PARAMBAIXATITAUTO.DATALIMITEDESC%TYPE;
    vsSeriePadrao          FI_PARAMBAIXATITAUTO.SERIEPADRAO%TYPE;
    vsNumeroGeracao        FI_PARAMBAIXATITAUTO.NUMEROGERACAO%TYPE;
    vsAgrupaEspecieDestino FI_PARAMBAIXATITAUTO.AGRUPAESPECIEDESTINO%TYPE;
    vsAgrupaEmpresa        FI_PARAMBAIXATITAUTO.AGRUPAEMPRESA%TYPE;
    vsTransfCartTitGer     FI_PARAMBAIXATITAUTO.TRANSFCARTTITGER%TYPE;
    vnCodOpeQuitDir        FI_OPERACAO.CODOPERACAO%TYPE;
    vnCodOpeMultaDir       FI_OPERACAO.CODOPERACAO%TYPE;
    vnCodOpeJurosDir       FI_OPERACAO.CODOPERACAO%TYPE;
    vnCodOpeDescDir        FI_OPERACAO.CODOPERACAO%TYPE;
    vnCodOpeInclusaoDir    FI_OPERACAO.CODOPERACAO%TYPE;
    vnCodOpeQuitObrig      FI_OPERACAO.CODOPERACAO%TYPE;
    vnCodOpeMultaObrig     FI_OPERACAO.CODOPERACAO%TYPE;
    vnCodOpeJurosObrig     FI_OPERACAO.CODOPERACAO%TYPE;
    vnCodOpeDescObrig      FI_OPERACAO.CODOPERACAO%TYPE;
    vnCodOpeInclusaoObrig  FI_OPERACAO.CODOPERACAO%TYPE;
    -- Títulos
    vnNroProcessoExe   FI_TITOPERACAO.NROPROCESSO%TYPE;
    vnNroProcessoTit   FI_TITOPERACAO.NROPROCESSO%TYPE;
    vnSeqTitNovo       FI_TITULO.SEQTITULO%TYPE;
    vnNroTitulo        FI_TITULO.SEQTITULO%TYPE;
    vdDtaLimDescFinanc FI_COMPLTITULO.DTALIMDSCFINANC%TYPE;
    vsObservacao       FI_TITULO.OBSERVACAO%TYPE;
    vnNroEmpresa       GE_EMPRESA.NROEMPRESA%TYPE;
    vnVlrTotal         FI_TITULO.VLRNOMINAL%TYPE;
    vnPercDescContrato FI_COMPLTITULO.PERCDESCCONTRATO%TYPE;
    --
    vsCodEspecieNovoTit   FI_ESPECIE.CODESPECIE%TYPE;
    vnDepositarioNovoTit  FI_TITULO.SEQDEPOSITARIO%TYPE;
    vnCodOperacaoNovoTit  FI_OPERACAO.CODOPERACAO%TYPE;
    vbOk                  BOOLEAN;
    vdDtaInicial          FI_TITULO.DTAEMISSAO%TYPE;
    vdDtaFinal            FI_TITULO.DTAEMISSAO%TYPE;
    vsTipoData            VARCHAR2(1);
    vsUsuario             GE_USUARIO.CODUSUARIO%TYPE;
    vdDtaExecucao         DATE;
    vnAnoExe              NUMBER;
    vnSeqTituloOrigem     FI_TITCOMPRADORDET.SEQTITULOORIGEM%TYPE;
    vnSeqTituloBase       FI_TITCOMPRADORDET.SEQTITULOBASE%TYPE;
    vsIndReplicaComprador FI_PARAMETRO.INDREPLICACOMPRADOR%TYPE;
    vsLancaOpTxAdm        FI_PARAMETRO.LANCAOPTXADMQUIT%TYPE;
    vnCount               NUMBER(15);
    S_FITIMPORT           NUMBER(15);
  BEGIN
    -- Consiste os filtros
    vdDtaInicial  := NULL;
    vdDtaFinal    := NULL;
    vsTipoData    := NULL;
    vsUsuario     := NVL(psUsuario, 'ECOMMERCE');
    vdDtaExecucao := TRUNC(SYSDATE);
    vnAnoExe      := EXTRACT(YEAR FROM vdDtaExecucao);
    IF pdDtaInicial IS NOT NULL AND pdDtaFinal IS NOT NULL THEN
      IF pdDtaFinal >= pdDtaInicial THEN
        IF NVL(psTipoData, 'X') IN ('E', 'V') THEN
          vdDtaInicial := pdDtaInicial;
          vdDtaFinal   := pdDtaFinal;
          vsTipoData   := psTipoData;
        END IF;
      END IF;
    END IF;
    -- Busca os parâmetros
    SELECT EMPRESAGERACAO,
           UTILIZAMULTAJUROS,
           PERMAGRUPTITVENCIDO,
           PERMAGRUPTITAGRUP,
           DATALIMITEDESC,
           DESCONTO,
           SERIEPADRAO,
           NUMEROGERACAO,
           AGRUPAESPECIEDESTINO,
           AGRUPAEMPRESA,
           CODOPERQUITDIR,
           CODOPERMULTADIR,
           CODOPERJUROSDIR,
           CODOPERDESCDIR,
           CODOPERINCLUSAODIR,
           CODOPERQUITOBRIG,
           CODOPERMULTAOBRIG,
           CODOPERJUROSOBRIG,
           CODOPERDESCOBRIG,
           CODOPERINCLUSAOOBRIG,
           NVL(TRANSFCARTTITGER, 'N')
      INTO vsEmpresaGeracao,
           vsUtilizaMultaJuros,
           vsPermAgrupTitVencido,
           vsPermAgrupTitAgrupado,
           vsDataLimiteDesc,
           vsDesconto,
           vsSeriePadrao,
           vsNumeroGeracao,
           vsAgrupaEspecieDestino,
           vsAgrupaEmpresa,
           vnCodOpeQuitDir,
           vnCodOpeMultaDir,
           vnCodOpeJurosDir,
           vnCodOpeDescDir,
           vnCodOpeInclusaoDir,
           vnCodOpeQuitObrig,
           vnCodOpeMultaObrig,
           vnCodOpeJurosObrig,
           vnCodOpeDescObrig,
           vnCodOpeInclusaoObrig,
           vsTransfCartTitGer
      FROM FI_PARAMBAIXATITAUTO;
    -- Busca o processo global
    SELECT S_FILOGBAIXATITAUTO.NEXTVAL INTO vnNroProcessoExe FROM DUAL;
    -- Monta o agrupamento
    vsSqlAgrupamento := ' FI_TITULO.NROEMPRESAMAE, ';
    IF vsAgrupaEmpresa = 'S' THEN
      vsSqlAgrupamento := vsSqlAgrupamento || ' FI_TITULO.NROEMPRESA, ';
    ELSE
      vsSqlAgrupamento := vsSqlAgrupamento || ' NULL, ';
    END IF;
    -- Fixo ( manter nesta posição )
    vsSqlAgrupamento := vsSqlAgrupamento ||
                        ' FI_TITULO.OBRIGDIREITO,
                                       FI_TITULO.SEQPESSOA, ';
    IF vsAgrupaEspecieDestino = 'S' THEN
      vsSqlAgrupamento := vsSqlAgrupamento ||
                          ' FI_ESPECIE.CODESPECIEAGRUP, ';
    ELSE
      vsSqlAgrupamento := vsSqlAgrupamento || ' FI_ESPECIE.CODESPECIE, ';
    END IF;
    -- Fixo ( manter nesta posição )
    vsSqlAgrupamento := vsSqlAgrupamento ||
                        ' PKG_FIAGRUPATITAUTO.FIF_DTAVENCIMENTO(''' ||
                        vdDtaExecucao ||
                        ''' , FI_TITULO.DTAVENCIMENTO , FI_TITULO.SEQPESSOA , FI_TITULO.OBRIGDIREITO ) ';
    -- Monta as colunas
    -- Cuidado ao alterar a ordem das colunas, eles devem estar na mesma ordem das variáveis do into
    vsSqlColunas := ' SELECT ' || vsSqlAgrupamento ||
                    ', NVL(COUNT(1),0)                                                                                               QTDTITULOS,
                                                          NVL(SUM(FI_COMPLTITULO.VLRDSCFINANC),0)                                                                       VLRDESCFINANC,
                                                          NVL(SUM(FI_COMPLTITULO.VLRDESCCONTRATO),0)                                                                    VLRDESCCONTRATO,
                                                          C5_COMPLEXIN.C5INCLOB(CAST(COLLECT(TO_CHAR(FI_TITULO.SEQTITULO)) AS C5INSTRTABLE))                            TITULOS,
                                                          C5_COMPLEXIN.C5INCLOB(CAST(COLLECT(TO_CHAR(FI_TITULO.NROEMPRESA)) AS C5INSTRTABLE))                           EMPRESAS,
                                                          C5_COMPLEXIN.C5INCLOB(CAST(COLLECT(TO_CHAR(FI_TITULO.NROTITULO)) AS C5INSTRTABLE))                            NUMEROS,
                                                          C5_COMPLEXIN.C5INCLOB(CAST(COLLECT(TO_CHAR(FI_COMPLTITULO.DTALIMDSCFINANC,''DD-MON-YYYY'')) AS C5INSTRTABLE)) DTADESCONTO ';
    -- Monta as tabelas e as condições
    vsSqlWhere := ' FROM  FI_TITULO,
                           FI_COMPLTITULO,
                           FI_ESPECIE
                     WHERE FI_TITULO.SEQTITULO     = FI_COMPLTITULO.SEQTITULO
                     AND   FI_TITULO.CODESPECIE    = FI_ESPECIE.CODESPECIE
                     AND   FI_TITULO.NROEMPRESAMAE = FI_ESPECIE.NROEMPRESAMAE
                     AND   FI_TITULO.SITUACAO != ''S''
                     AND   FI_TITULO.ABERTOQUITADO = ''A''
                     AND   FI_ESPECIE.INDAGRUPATITULO = ''S''
                     
                     and fi_titulo.SEQTITULO in (select 
   A.SEQTITULO

  from IMPLANTACAO.FI_TITULO A, IMPLANTACAO.MAX_EMPRESA B

 where B.NROEMPRESA = A.NROEMPRESA
   and A.ABERTOQUITADO = ''A''
   and A.OBRIGDIREITO = ''D''
   AND A.CODESPECIE = ''CARTAO''
   and A.NRODOCUMENTO IN
       (SELECT H.NUMERODF
          FROM IMPLANTACAO.MFL_DOCTOFISCAL H
          JOIN IMPLANTACAO.MAD_PEDVENDA B
            ON (B.NROPEDVENDA = H.NROPEDIDOVENDA)
         WHERE H.NROPEDIDOVENDA IN
               (select distinct t.nropedvenda
                  from implantacao.CADAN_VENDAS_AGILE t
                  having count(t.nsu) > 1
                  group by t.nropedvenda))
   and A.SERIETITULO is not null)
       and (EXISTS (SELECT 1
                   FROM FI_CLIENTE
                  WHERE FI_CLIENTE.SEQPESSOA = FI_TITULO.Seqpessoanota
                    AND FI_CLIENTE.INDAGRUPATITULO = ''S'') AND
        FI_TITULO.OBRIGDIREITO = ''D'')
                     
                     
                     
                     
                      ';
    /* Filtro por periodo de apuração
    Primeiro verifica se o Cliente/Fornecedor Usa o parâmetro de periodo
    se usar filtra o pelo periodo referente a data de execução*/
    vsSqlWhere := vsSqlWhere || '
    AND (NVL( CASE WHEN FI_TITULO.OBRIGDIREITO = ''O'' THEN
               (SELECT A.INDUSAPERIODOAGRUPAUTO FROM FI_FORNECEDOR A WHERE A.SEQPESSOA = FI_TITULO.Seqpessoanota)
              ELSE
               (SELECT A.INDUSAPERIODOAGRUPAUTO FROM FI_CLIENTE A WHERE A.SEQPESSOA = FI_TITULO.Seqpessoanota)
              END, ''N'') = ''N''
         OR
         EXISTS (SELECT A.SEQPERIODO
                   FROM FI_PERIODOAGRUPAUTO A
                  WHERE A.SEQPESSOA = FI_TITULO.Seqpessoanota
                    AND A.OBRIGDIREITO = FI_TITULO.OBRIGDIREITO
                    AND PKG_FIAGRUPATITAUTO.FIF_MONTADATA(A.DIAEXE, A.MESEXE, A.MESEXE, ' ||
                  vnAnoExe || ', NULL)
                        = ''' || vdDtaExecucao || '''
                    AND FI_TITULO.DTAEMISSAO BETWEEN
                        PKG_FIAGRUPATITAUTO.FIF_MONTADATA(A.DIAINI, A.MESINI, A.MESEXE, ' ||
                  vnAnoExe ||
                  ', ''P'')
                        AND
                        PKG_FIAGRUPATITAUTO.FIF_MONTADATA(A.DIAFIM, A.MESFIM, A.MESEXE, ' ||
                  vnAnoExe || ', ''P'')
                    ))';
    --
    IF vsPermAgrupTitVencido = 'N' THEN
      vsSqlWhere := vsSqlWhere ||
                    ' AND FI_TITULO.DTAPROGRAMADA >= TRUNC(SYSDATE) ';
    END IF;
    --
    IF vsPermAgrupTitAgrupado = 'N' THEN
      vsSqlWhere := vsSqlWhere ||
                    ' AND NVL(FI_TITULO.APPORIGEM,''X'') != ''AGRUPTITAUTO'' ';
    END IF;
    --
    IF vsTipoData = 'E' THEN
      vsSqlWhere := vsSqlWhere || ' AND FI_TITULO.DTAEMISSAO >= ''' ||
                    vdDtaInicial || '''
                                      AND FI_TITULO.DTAEMISSAO <= ''' ||
                    vdDtaFinal || '''';
    ELSIF vsTipoData = 'V' THEN
      vsSqlWhere := vsSqlWhere || ' AND FI_TITULO.DTAVENCIMENTO >= ''' ||
                    vdDtaInicial || '''
                                      AND FI_TITULO.DTAVENCIMENTO <= ''' ||
                    vdDtaFinal || '''';
    END IF;
    -- Monta o agrupamento
    vsSqlGroupBy := ' GROUP BY ' || vsSqlAgrupamento;
    vsSqlGroupBy := vsSqlGroupBy ||
                    ' HAVING ( ( COUNT(1) > 1 ) OR ( MAX(FI_ESPECIE.INDGERATITAGRUPAUT) = ''S'' ) )';
    -- Monta a ordenação
    vsSqlOrderBy := ' ORDER BY ' || vsSqlAgrupamento;
    -- Monta a consulta
    vsSqlConsulta := vsSqlColunas || vsSqlWhere || vsSqlGroupBy ||
                     vsSqlOrderBy;
    -- Executa o loop
    OPEN Cursor_Titulo FOR vsSqlConsulta;
    LOOP
      FETCH Cursor_Titulo
      -- Cuidado ao alterar a ordem das variáveis do into, eles devem estar na mesma ordem das colunas montadas
        INTO vtnNroEmpresaMae,
             vtnNroEmpresa,
             vtsObrigacaoDireito,
             vtnSeqPessoa,
             vtsCodEspecie,
             vtdDtaVencimento,
             vtnQtdTitulos,
             vtnVlrDescFin,
             vtnVlrDescContrato,
             vtcInSeqTitulos,
             vtcInNroEmpresa,
             vtcInNroTitulo,
             vtcInDtaLimDescFin;
      -- Condição de parada
      EXIT WHEN Cursor_Titulo%NOTFOUND;
      vbOk                 := TRUE;
      vnNroTitulo          := NULL;
      vnNroEmpresa         := NULL;
      vdDtaLimDescFinanc   := NULL;
      vsCodEspecieNovoTit  := NULL;
      vnDepositarioNovoTit := NULL;
      vnCodOperacaoNovoTit := NULL;
      vnPercDescContrato   := NULL;
      -- Busca o processo do título
      PKG_FINANCEIRO.FIP_BUSCASEQFI(vnNroProcessoTit);
      -- Log de registro
      FIP_GRAVALOG('Inicio do agrupamento dos títulos da sequência: ' ||
                   SUBSTR(vtcInSeqTitulos, 1, 450),
                   NULL,
                   vnNroProcessoExe,
                   vnNroProcessoTit,
                   'I',
                   vsUsuario);
      -- Baixa os títulos
      IF vtsObrigacaoDireito = 'O' THEN
        vbOk := FIF_BAIXATITULOS(vtcInSeqTitulos,
                                 vnCodOpeQuitObrig,
                                 vnCodOpeMultaObrig,
                                 vnCodOpeJurosObrig,
                                 vnCodOpeDescObrig,
                                 vtnNroEmpresaMae,
                                 vsDesconto,
                                 vsUtilizaMultaJuros,
                                 vnNroProcessoExe,
                                 vnNroProcessoTit,
                                 vsUsuario,
                                 vnVlrTotal);
      ELSE
        vbOk := FIF_BAIXATITULOS(vtcInSeqTitulos,
                                 vnCodOpeQuitDir,
                                 vnCodOpeMultaDir,
                                 vnCodOpeJurosDir,
                                 vnCodOpeDescDir,
                                 vtnNroEmpresaMae,
                                 vsDesconto,
                                 vsUtilizaMultaJuros,
                                 vnNroProcessoExe,
                                 vnNroProcessoTit,
                                 vsUsuario,
                                 vnVlrTotal);
      END IF;
      -- Novo título
      IF vbOk THEN
        -- Busca o número do título
        vnNroTitulo := FIF_RETORNANROTITULO(vtcInNroTitulo,
                                            vtdDtaVencimento,
                                            vsNumeroGeracao);
        -- Busca o número da empresa
        vnNroEmpresa := FIF_RETORNAEMPRESA(vtcInNroEmpresa,
                                           vtnNroEmpresaMae,
                                           vsEmpresaGeracao);
        -- Busca a data de limite de desconto
        vdDtaLimDescFinanc := FIF_RETORNADTALIMDESC(vtcInDtaLimDescFin,
                                                    vtdDtaVencimento,
                                                    vsDesconto,
                                                    vsDataLimiteDesc);
        -- Busca a nova espécie
        IF vsAgrupaEspecieDestino = 'S' THEN
          vsCodEspecieNovoTit := vtsCodEspecie;
        ELSE
          SELECT NVL(MAX(A.CODESPECIEAGRUP), vtsCodEspecie)
            INTO vsCodEspecieNovoTit
            FROM FI_ESPECIE A
           WHERE A.CODESPECIE = vtsCodEspecie
             AND A.NROEMPRESAMAE = vtnNroEmpresaMae;
        END IF;
        -- Consiste a espécie e operação do novo título
        IF vtsObrigacaoDireito = 'O' THEN
          vbOk := FIF_CONSISTEESPOPER(TRUNC(SYSDATE),
                                      vsCodEspecieNovoTit,
                                      vnCodOpeInclusaoObrig,
                                      vnNroEmpresa,
                                      vtnNroEmpresaMae,
                                      vnNroProcessoExe,
                                      vsUsuario);
        ELSE
          vbOk := FIF_CONSISTEESPOPER(TRUNC(SYSDATE),
                                      vsCodEspecieNovoTit,
                                      vnCodOpeInclusaoDir,
                                      vnNroEmpresa,
                                      vtnNroEmpresaMae,
                                      vnNroProcessoExe,
                                      vsUsuario);
        END IF;
        -- Verifica valor de inclusão do novo título
        IF vnVlrTotal <= 0 THEN
          vbOk := FALSE;
          FIP_GRAVALOG('O valor do novo título ' || vnNroTitulo ||
                       ' deve ser maior que zero. ( Valor ' ||
                       PKG_FINANCEIRO.FIF_FORMATAVALOR(vnVlrTotal) ||
                       ' ) : ' || SQLERRM || ' - ' ||
                       DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       vnSeqTitNovo,
                       vnNroProcessoExe,
                       vnNroProcessoTit,
                       'E',
                       vsUsuario);
        END IF;
        -- Geração do novo título
        IF vbOk THEN
          IF vtsObrigacaoDireito = 'O' THEN
            vnDepositarioNovoTit := 2;
            vnCodOperacaoNovoTit := vnCodOpeInclusaoObrig;
          ELSE
            vnDepositarioNovoTit := 1;
            vnCodOperacaoNovoTit := vnCodOpeInclusaoDir;
          END IF;
          -- Se não for transferir os descontos, zera seu valor
          IF vsDesconto != 'T' THEN
            vtnVlrDescFin      := 0;
            vtnVlrDescContrato := 0;
          END IF;
          -- Se não houver desconto financeiro, remove a data limite
          IF vtnVlrDescFin = 0 THEN
            vdDtaLimDescFinanc := NULL;
          END IF;
          --
          IF vtnVlrDescContrato = 0 THEN
            vnPercDescContrato := NULL;
          ELSE
            vnPercDescContrato := (vtnVlrDescContrato * 100) / vnVlrTotal;
          END IF;
          -- Inclui o novo título
          BEGIN
            vsObservacao := 'Título gerado pelo processo de agrupamento automático.';
            vnSeqTitNovo := NULL;
            PKG_FINANCEIRO.FIP_INCLUITITULO(vtnSeqPessoa,
                                            vnNroTitulo,
                                            vsSeriePadrao,
                                            1,
                                            1,
                                            vnNroTitulo,
                                            vsSeriePadrao,
                                            TRUNC(SYSDATE),
                                            vtdDtaVencimento,
                                            vnVlrTotal,
                                            vtnVlrDescFin,
                                            vdDtaLimDescFinanc,
                                            vsCodEspecieNovoTit,
                                            vnCodOperacaoNovoTit,
                                            vnDepositarioNovoTit,
                                            NULL,
                                            null,
                                            vnNroProcessoTit,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            vnNroEmpresa,
                                            NULL,
                                            vnSeqTitNovo,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            NULL,
                                            vsObservacao,
                                            vtnNroEmpresaMae,
                                            vsUsuario,
                                            TRUNC(SYSDATE),
                                            vtnVlrDescContrato,
                                            vnPercDescContrato,
                                            NULL,
                                            NULL);
            -- Marca o título como gerado automaticamente
            UPDATE FI_TITULO
               SET FI_TITULO.APPORIGEM = 'AGRUPTITAUTO'
             WHERE FI_TITULO.SEQTITULO = vnSeqTitNovo;
          
            SELECT NVL(MAX(A.INDREPLICACOMPRADOR), 'N'),
                   NVL(MAX(A.LANCAOPTXADM), 'N')
              INTO vsIndReplicaComprador, vsLancaOpTxAdm
              FROM FI_PARAMETRO A
             WHERE A.NROEMPRESA = vnNroEmpresa;
          
            IF vsTransfCartTitGer = 'S' AND vsLancaOpTxAdm = 'N' THEN
              --------
              SELECT implantacao.S_FITITNSU.Nextval
                INTO S_FITIMPORT
                FROM DUAL;
            
              insert into implantacao.FI_TITULONSU
                select S_FITIMPORT,
                       vnSeqTitNovo,
                       max(NSU),
                       max(trunc(DTAMOVIMENTO)),
                       sum(VALOR),
                       max(REDE),
                       max(BANDEIRA),
                       max(QTDPARCELA),
                       max(BIN),
                       max(CONCILIADO),
                       max(trunc(DTACONCILIADO)),
                       max(NOMEARQCONCILIADO),
                       max(NRONOTAFISCAL),
                       max(NROCARTAO),
                       sum(VLRTOTAL),
                       max(TIPO),
                       max(CODAUTORIZACAO),
                       max(NROPDVOPERADORA),
                       'AGRUPTITAUTO',
                       max(ORIGEMATUALIZACAO),
                       max(GEROUARQUIVO),
                       max(NOMEARQGERADOREM),
                       max(DTAGEROUARQUIVOREM),
                       max(INDTRANSACAOQUIT),
                       max(NROPROCESSOQUIT)
                  from implantacao.FI_TITULONSU
                 WHERE FI_TITULONSU.SEQTITULO IN
                       (SELECT TO_NUMBER(COLUMN_VALUE)
                          FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLECLOB(vtcInSeqTitulos) AS
                                          C5INCLOBTABLE)))
                   AND NOT EXISTS
                 (SELECT 1
                          FROM FIV_LINHAARQUIVOTITNUS B
                         WHERE B.SEQTITULO IN
                               (SELECT TO_NUMBER(COLUMN_VALUE)
                                  FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLECLOB(vtcInSeqTitulos) AS
                                                  C5INCLOBTABLE)))
                           AND B.STATUS IN ('C', 'Q', 'P'));
              --------
              update FI_TITULO
                 SET FI_TITULO.SEQPESSOANOTA = implantacao.CADAN_GETpessoanota(vnNroProcessoTit)
               WHERE FI_TITULO.NROTITULO IN (vnSeqTitNovo);
              
             
                           delete  from implantacao.FI_TITULONSU
                WHERE FI_TITULONSU.SEQTITULO IN
                       (SELECT TO_NUMBER(COLUMN_VALUE)
                          FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLECLOB(vtcInSeqTitulos) AS
                                          C5INCLOBTABLE)));              
            
            END IF;
          
            IF vsDesconto = 'T' THEN
              --Lança desconto detalhado
              INSERT INTO FI_TITDESCONTODETALHE
                (SEQTITDESCONTO,
                 SEQTITULO,
                 LINKERP,
                 CODOPERACAO,
                 DTALIMITE,
                 VALOR,
                 OBSERVACAO,
                 DTAINCLUSAO,
                 DTAALTERACAO,
                 USUINCLUSAO,
                 USUALTERACAO,
                 ORIGEM)
                SELECT S_SEQTITDESCONTO.NEXTVAL,
                       vnseqTitNovo,
                       A.LINKERP,
                       A.CODOPERACAO,
                       A.DTALIMITE,
                       A.VALOR - A.VALORUTILIZADO,
                       A.OBSERVACAO,
                       TRUNC(SYSDATE),
                       TRUNC(SYSDATE),
                       psUsuario,
                       psUsuario,
                       A.ORIGEM
                  FROM FI_TITDESCONTODETALHE A
                 WHERE A.SEQTITULO IN
                       (SELECT X.SEQTITULO FROM FIX_SEQTITULOS X)
                   AND A.SITUACAO = 'I'
                   AND A.VALOR > A.VALORUTILIZADO;
            END IF;
            -- Registra o lançamento
            FIP_GRAVALOG('Inclusão do título ' || vnNroTitulo ||
                         ' no valor de ' ||
                         PKG_FINANCEIRO.FIF_FORMATAVALOR(vnVlrTotal) ||
                         ' para a espécie ' || vsCodEspecieNovoTit ||
                         ' efetuado com sucesso!',
                         vnSeqTitNovo,
                         vnNroProcessoExe,
                         vnNroProcessoTit,
                         'R',
                         vsUsuario);
            IF vsIndReplicaComprador = 'S' THEN
              -- Inserindo compradores dos títulos quitados para o novo título
              FOR vtTitComp IN (SELECT C.SEQTITULO,
                                       C.SEQCOMPRADOR,
                                       D.SEQTITULOORIGEM,
                                       D.SEQTITULOBASE
                                  FROM FI_TITCOMPRADOR    C,
                                       FI_TITCOMPRADORDET D,
                                       FIX_SEQTITULOS     X
                                 WHERE C.SEQTITULO = D.SEQTITULO(+)
                                   AND C.SEQCOMPRADOR = D.SEQCOMPRADOR(+)
                                   AND C.SEQTITULO = X.SEQTITULO) LOOP
                vnCount := 0;
                SELECT COUNT(1)
                  INTO vnCount
                  FROM FI_TITCOMPRADOR R
                 WHERE R.SEQTITULO = vnSeqTitNovo
                   AND R.SEQCOMPRADOR = vtTitComp.SEQCOMPRADOR;
                IF vnCount = 0 THEN
                  INSERT INTO FI_TITCOMPRADOR
                    (SEQTITULO, SEQCOMPRADOR, VALOR, INDREPLICADOR)
                  VALUES
                    (vnSeqTitNovo, vtTitComp.SEQCOMPRADOR, 0, 'S');
                END IF;
                IF vtTitComp.SEQTITULOORIGEM IS NULL THEN
                  vnSeqTituloOrigem := vtTitComp.SEQTITULO;
                  vnSeqTituloBase   := vtTitComp.SEQTITULO;
                ELSE
                  vnSeqTituloOrigem := vtTitComp.SEQTITULOORIGEM;
                  vnSeqTituloBase   := vtTitComp.SEQTITULO;
                END IF;
                INSERT INTO FI_TITCOMPRADORDET
                  (SEQTITULO, SEQCOMPRADOR, SEQTITULOORIGEM, SEQTITULOBASE)
                VALUES
                  (vnSeqTitNovo,
                   vtTitComp.SEQCOMPRADOR,
                   vnSeqTituloOrigem,
                   vnSeqTituloBase);
              END LOOP;
            END IF;
            -- Tratamento em caso de erro dentro das procedures
          EXCEPTION
            WHEN OTHERS THEN
              vbOk := FALSE;
              FIP_GRAVALOG('Erro ao inserir o título ' || vnNroTitulo ||
                           ' no valor de ' ||
                           PKG_FINANCEIRO.FIF_FORMATAVALOR(vnVlrTotal) ||
                           ' para a espécie ' || vsCodEspecieNovoTit ||
                           ' : ' || SQLERRM || ' - ' ||
                           DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                           vnSeqTitNovo,
                           vnNroProcessoExe,
                           vnNroProcessoTit,
                           'E',
                           vsUsuario);
          END;
        END IF;
      END IF;
      -- Dispara processo de comissão
      IF vbOk THEN
        BEGIN
          PKG_FINANCEIRO.FIP_COMISSAO(vnNroProcessoTit);
          -- RC 188585
          Fip_Calccompradortitsubst(vnNroProcessoTit, vtnNroEmpresa);
          -- Tratamento em caso de erro dentro das procedures
        EXCEPTION
          WHEN OTHERS THEN
            vbOk := FALSE;
            FIP_GRAVALOG('Erro ao executar processo de comissão para o título ' ||
                         vnNroTitulo || ' : ' || SQLERRM || ' - ' ||
                         DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                         vnSeqTitNovo,
                         vnNroProcessoExe,
                         vnNroProcessoTit,
                         'E',
                         vsUsuario);
        END;
      END IF;
      -- Finaliza o processo de baixa e inclusão
      IF vbOk THEN
        --
        COMMIT;
        -- Log de registro
        FIP_GRAVALOG('Agrupamento finalizado com sucesso, processo: ' ||
                     vnNroProcessoTit,
                     NULL,
                     vnNroProcessoExe,
                     vnNroProcessoTit,
                     'I',
                     vsUsuario);
        -- vnNroProcessoTit
      
      ELSE
        --
        ROLLBACK;
        -- Log de registro
        FIP_GRAVALOG('Houve erros no agrupamentos dos títulos do processo: ' ||
                     vnNroProcessoTit ||
                     ' . Os lançamentos gerados serão desfeitos!',
                     NULL,
                     vnNroProcessoExe,
                     vnNroProcessoTit,
                     'I',
                     vsUsuario);
      END IF;
    END LOOP;
    -- Fecha o cursor
    CLOSE Cursor_Titulo;
    -- Erro geral
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      --
      FIP_GRAVALOG('Ocorreu um erro ao executar o agrupamento automático referente ao processo : ' ||
                   vnNroProcessoExe ||
                   ' . Os lançamentos gerados serão desfeitos! : ' ||
                   SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                   NULL,
                   vnNroProcessoExe,
                   vnNroProcessoTit,
                   'E',
                   vsUsuario);
  END FIP_AGRUPAUTTITULOS;
  /* Baixa os títulos */
  FUNCTION FIF_BAIXATITULOS(psTitulos        IN CLOB,
                            pnCodOpeQuit     IN FI_OPERACAO.CODOPERACAO%TYPE,
                            pnCodOpeMulta    IN FI_OPERACAO.CODOPERACAO%TYPE,
                            pnCodOpeJuros    IN FI_OPERACAO.CODOPERACAO%TYPE,
                            pnCodOpeDesc     IN FI_OPERACAO.CODOPERACAO%TYPE,
                            pnNroEmpresaMae  IN GE_EMPRESA.NROEMPRESA%TYPE,
                            psUtilizaDesc    IN FI_PARAMBAIXATITAUTO.DESCONTO%TYPE,
                            psMultaJuros     IN FI_PARAMBAIXATITAUTO.UTILIZAMULTAJUROS%TYPE,
                            pnNroProcessoExe IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                            pnNroProcessoTit IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                            psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE,
                            pnTotalBaixa     OUT FI_TITULO.VLRNOMINAL%TYPE)
    RETURN BOOLEAN IS
    vbOk             BOOLEAN;
    vnValor          FI_TITULO.VLRNOMINAL%TYPE;
    vnValorTotal     FI_TITULO.VLRNOMINAL%TYPE;
    vnVlrDesconto    FI_COMPLTITULO.VLRDSCFINANC%TYPE;
    vnVlrDescontoDet FI_COMPLTITULO.VLRDSCFINANC%TYPE;
    vnVlrMulta       FI_TITOPERACAO.VLROPERACAO%TYPE;
    vnVlrJuros       FI_TITOPERACAO.VLROPERACAO%TYPE;
    vsJurosNegocCalc VARCHAR2(1);
    vsMultaNegocCalc VARCHAR2(1);
    vsCancOcrQuitTit FI_PARAMETRO.CANOCRQUITTIT%TYPE;
  BEGIN
    vbOk         := TRUE;
    vnValorTotal := 0;
    -- Gera a temporária com os títulos relacionados
    DELETE FIX_SEQTITULOS;
    --
    INSERT INTO FIX_SEQTITULOS
      (NROPROCESSO, SEQTITULO)
      SELECT pnNroProcessoExe, TO_NUMBER(COLUMN_VALUE)
        FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLECLOB(psTitulos) AS
                        C5INCLOBTABLE));
    -- Consiste as espécies envolvidas
    FOR vtConsistTit IN (SELECT DISTINCT A.CODESPECIE CODESPECIE,
                                         A.NROEMPRESA
                           FROM FI_TITULO A, FIX_SEQTITULOS B
                          WHERE A.SEQTITULO = B.SEQTITULO) LOOP
      -- Consiste a espécie e operação de quitação
      IF vbOk THEN
        vbOk := FIF_CONSISTEESPOPER(TRUNC(SYSDATE),
                                    vtConsistTit.CODESPECIE,
                                    pnCodOpeQuit,
                                    vtConsistTit.NROEMPRESA,
                                    pnNroEmpresaMae,
                                    pnNroProcessoExe,
                                    psUsuario);
      END IF;
      -- Consiste a espécie e operação de desconto
      IF vbOk THEN
        IF psUtilizaDesc = 'Q' THEN
          vbOk := FIF_CONSISTEESPOPER(TRUNC(SYSDATE),
                                      vtConsistTit.CODESPECIE,
                                      pnCodOpeDesc,
                                      vtConsistTit.NROEMPRESA,
                                      pnNroEmpresaMae,
                                      pnNroProcessoExe,
                                      psUsuario);
          --DESCONTO DETALHADO
          /*PERCORRE TODAS AS OPERAÇÕES DOS DESCONTOS DETALHADOS DOS TITULOS
          SEPARANDO POR CODESPECIE QUE É O DISTINCT DO FOR EM CIMA*/
          FOR vtDescDet IN (SELECT DISTINCT A.CODOPERACAO
                              FROM FI_TITDESCONTODETALHE A
                             WHERE A.SITUACAO = 'I'
                               AND A.VALOR > A.VALORUTILIZADO
                               AND A.SEQTITULO IN
                                   (SELECT X.SEQTITULO FROM FIX_SEQTITULOS X)
                               AND EXISTS
                             (SELECT 1
                                      FROM FI_TITULO Z
                                     WHERE Z.SEQTITULO = A.SEQTITULO
                                       AND Z.CODESPECIE =
                                           vtConsistTit.CODESPECIE)) LOOP
            vbOk := FIF_CONSISTEESPOPER(TRUNC(SYSDATE),
                                        vtConsistTit.CODESPECIE,
                                        vtDescDet.Codoperacao,
                                        vtConsistTit.NROEMPRESA,
                                        pnNroEmpresaMae,
                                        pnNroProcessoExe,
                                        psUsuario);
            -- Força saída do loop se encontrar um erro
            EXIT WHEN NOT vbOk;
          END LOOP;
        END IF;
      END IF;
      -- Consiste a espécie e operação de Multa
      IF vbOk THEN
        IF psMultaJuros = 'S' THEN
          vbOK := FIF_CONSISTEESPOPER(TRUNC(SYSDATE),
                                      vtConsistTit.CODESPECIE,
                                      pnCodOpeMulta,
                                      vtConsistTit.NROEMPRESA,
                                      pnNroEmpresaMae,
                                      pnNroProcessoExe,
                                      psUsuario);
        END IF;
      END IF;
      -- Consiste a espécie e operação de Juros
      IF vbOk THEN
        IF psMultaJuros = 'S' THEN
          vbOK := FIF_CONSISTEESPOPER(TRUNC(SYSDATE),
                                      vtConsistTit.CODESPECIE,
                                      pnCodOpeJuros,
                                      vtConsistTit.NROEMPRESA,
                                      pnNroEmpresaMae,
                                      pnNroProcessoExe,
                                      psUsuario);
        END IF;
      END IF;
      -- Força saída do loop se encontrar um erro
      EXIT WHEN NOT vbOk;
    END LOOP;
    -- Faz os lançamentos
    IF vbOk THEN
      -- Busca os títulos
      FOR vtQuitaTit IN (SELECT A.SEQTITULO,
                                A.CODESPECIE,
                                A.NROEMPRESA,
                                A.NROTITULO || '-' || A.SERIETITULO || '/' ||
                                A.NROPARCELA TITULO,
                                NVL(A.VLRNOMINAL - A.VLRPAGO, 0) VLRABERTO
                           FROM FI_TITULO A, FIX_SEQTITULOS B
                          WHERE A.SEQTITULO = B.SEQTITULO
                          ORDER BY A.NROEMPRESA, A.CODESPECIE) LOOP
        -- Verifica se cancela ocorrência de atraso
        SELECT NVL(C.CANOCRQUITTIT, 'N')
          INTO vsCancOcrQuitTit
          FROM FI_PARAMETRO C
         WHERE C.NROEMPRESA = vtQuitaTit.NROEMPRESA;
        -- Log de registro
        FIP_GRAVALOG('Inicio da baixa do título ' || vtQuitaTit.TITULO,
                     vtQuitaTit.SEQTITULO,
                     pnNroProcessoExe,
                     pnNroProcessoTit,
                     'R',
                     psUsuario);
        -- Valor a pagar/receber
        vnValor := vtQuitaTit.VLRABERTO;
        -- Calcula o desconto
        IF vbOk THEN
          IF psUtilizaDesc = 'Q' THEN
            BEGIN
              vnVlrDesconto    := NVL(PKG_FINANCEIRO.FIF_DESCONTO(vtQuitaTit.SEQTITULO,
                                                                  TRUNC(SYSDATE),
                                                                  'S'),
                                      0);
              vnVlrDescontoDet := NVL(PKG_FINANCEIRO.FIF_DESCONTO(vtQuitaTit.SEQTITULO,
                                                                  TRUNC(SYSDATE),
                                                                  'D'),
                                      0);
            EXCEPTION
              WHEN OTHERS THEN
                vbOk := FALSE;
                FIP_GRAVALOG('Erro no cálculo do desconto do título ' ||
                             vtQuitaTit.TITULO || ' sequencial do título ' ||
                             vtQuitaTit.SEQTITULO || ' : ' || SQLERRM ||
                             ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                             vtQuitaTit.SEQTITULO,
                             pnNroProcessoExe,
                             pnNroProcessoTit,
                             'E',
                             psUsuario);
            END;
          END IF;
        END IF;
        -- Calcula a multa e o juros
        IF vbOk THEN
          IF psMultaJuros = 'S' THEN
            BEGIN
              PKG_FINANCEIRO.FIP_CALCULAMULTAJUROS(vtQuitaTit.SEQTITULO,
                                                   TRUNC(SYSDATE),
                                                   'P',
                                                   vnVlrJuros,
                                                   vnVlrMulta,
                                                   vsJurosNegocCalc,
                                                   vsMultaNegocCalc);
              vnVlrMulta := NVL(vnVlrMulta, 0);
              vnVlrJuros := NVL(vnVlrJuros, 0);
            EXCEPTION
              WHEN OTHERS THEN
                vbOk := FALSE;
                FIP_GRAVALOG('Erro no cálculo de multa e juros do título ' ||
                             vtQuitaTit.TITULO || ' sequencial do título ' ||
                             vtQuitaTit.SEQTITULO || ' : ' || SQLERRM ||
                             ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                             vtQuitaTit.SEQTITULO,
                             pnNroProcessoExe,
                             pnNroProcessoTit,
                             'E',
                             psUsuario);
            END;
          END IF;
        END IF;
        -- Quita o título
        IF vbOk THEN
          vnValor := vnValor - NVL(vnVlrDesconto, 0) -
                     NVL(vnVlrDescontoDet, 0);
          IF vnValor > 0 THEN
            vbOk := FIF_LANCAOPERACAO(pnCodOpeQuit,
                                      vtQuitaTit.SEQTITULO,
                                      pnNroEmpresaMae,
                                      vtQuitaTit.NROEMPRESA,
                                      vnValor,
                                      pnNroProcessoExe,
                                      pnNroProcessoTit,
                                      psUsuario,
                                      vsCancOcrQuitTit,
                                      NULL);
            -- Registra o lançamento
            IF vbOk THEN
              FIP_GRAVALOG('Operação de quitação ' || pnCodOpeQuit ||
                           ' no valor de ' ||
                           PKG_FINANCEIRO.FIF_FORMATAVALOR(vnValor) ||
                           ' para o título ' || vtQuitaTit.TITULO ||
                           ' lançada com sucesso!',
                           vtQuitaTit.SEQTITULO,
                           pnNroProcessoExe,
                           pnNroProcessoTit,
                           'R',
                           psUsuario);
            END IF;
          ELSE
            vnValor := 0;
          END IF;
        END IF;
        -- Lança a multa
        IF vbOk THEN
          IF vnVlrMulta > 0 THEN
            vbOk := FIF_LANCAOPERACAO(pnCodOpeMulta,
                                      vtQuitaTit.SEQTITULO,
                                      pnNroEmpresaMae,
                                      vtQuitaTit.NROEMPRESA,
                                      vnVlrMulta,
                                      pnNroProcessoExe,
                                      pnNroProcessoTit,
                                      psUsuario,
                                      vsCancOcrQuitTit,
                                      NULL);
            -- Registra o lançamento
            IF vbOk THEN
              FIP_GRAVALOG('Operação de multa ' || pnCodOpeMulta ||
                           ' no valor de ' ||
                           PKG_FINANCEIRO.FIF_FORMATAVALOR(vnVlrMulta) ||
                           ' para o título ' || vtQuitaTit.TITULO ||
                           ' lançada com sucesso!',
                           vtQuitaTit.SEQTITULO,
                           pnNroProcessoExe,
                           pnNroProcessoTit,
                           'R',
                           psUsuario);
            END IF;
          ELSE
            vnVlrMulta := 0;
          END IF;
        END IF;
        -- Lança os juros
        IF vbOk THEN
          IF vnVlrJuros > 0 THEN
            vbOk := FIF_LANCAOPERACAO(pnCodOpeJuros,
                                      vtQuitaTit.SEQTITULO,
                                      pnNroEmpresaMae,
                                      vtQuitaTit.NROEMPRESA,
                                      vnVlrJuros,
                                      pnNroProcessoExe,
                                      pnNroProcessoTit,
                                      psUsuario,
                                      vsCancOcrQuitTit,
                                      NULL);
            -- Registra o lançamento
            IF vbOk THEN
              FIP_GRAVALOG('Operação de juros ' || pnCodOpeJuros ||
                           ' no valor de ' ||
                           PKG_FINANCEIRO.FIF_FORMATAVALOR(vnVlrJuros) ||
                           ' para o título ' || vtQuitaTit.TITULO ||
                           ' lançada com sucesso!',
                           vtQuitaTit.SEQTITULO,
                           pnNroProcessoExe,
                           pnNroProcessoTit,
                           'R',
                           psUsuario);
            END IF;
          ELSE
            vnVlrJuros := 0;
          END IF;
        END IF;
        -- Lança o desconto
        IF vbOk THEN
          IF vnVlrDesconto > 0 THEN
            vbOk := FIF_LANCAOPERACAO(pnCodOpeDesc,
                                      vtQuitaTit.SEQTITULO,
                                      pnNroEmpresaMae,
                                      vtQuitaTit.NROEMPRESA,
                                      vnVlrDesconto,
                                      pnNroProcessoExe,
                                      pnNroProcessoTit,
                                      psUsuario,
                                      vsCancOcrQuitTit,
                                      NULL);
            -- Registra o lançamento
            IF vbOk THEN
              FIP_GRAVALOG('Operação de desconto ' || pnCodOpeDesc ||
                           ' no valor de ' ||
                           PKG_FINANCEIRO.FIF_FORMATAVALOR(vnVlrDesconto) ||
                           ' para o título ' || vtQuitaTit.TITULO ||
                           ' lançada com sucesso!',
                           vtQuitaTit.SEQTITULO,
                           pnNroProcessoExe,
                           pnNroProcessoTit,
                           'R',
                           psUsuario);
            END IF;
          ELSE
            vnVlrDesconto := 0;
          END IF;
          IF vbOK THEN
            --Lança Desconto Detalhado
            IF vnVlrDescontoDet > 0 THEN
              FOR vtDescDet IN (SELECT A.SEQTITDESCONTO,
                                       A.CODOPERACAO,
                                       (A.VALOR - A.VALORUTILIZADO) VLRDISPONIVEL
                                  FROM FI_TITDESCONTODETALHE A, FI_TITULO B
                                 WHERE A.SEQTITULO = B.SEQTITULO
                                   AND A.SEQTITULO = vtQuitaTit.SEQTITULO
                                   AND A.SITUACAO = 'I'
                                   AND A.VALOR > A.VALORUTILIZADO
                                   AND (A.DTALIMITE IS NULL OR
                                       FIF_DATAUTIL(A.DTALIMITE,
                                                     B.SEQPESSOA,
                                                     0,
                                                     0,
                                                     'P',
                                                     B.NROEMPRESA) >=
                                       TRUNC(SYSDATE))) LOOP
                vbOk := FIF_LANCAOPERACAO(vtDescDet.CODOPERACAO,
                                          vtQuitaTit.SEQTITULO,
                                          pnNroEmpresaMae,
                                          vtQuitaTit.NROEMPRESA,
                                          vtDescDet.VLRDISPONIVEL,
                                          pnNroProcessoExe,
                                          pnNroProcessoTit,
                                          psUsuario,
                                          vsCancOcrQuitTit,
                                          vtDescDet.Seqtitdesconto);
                -- Registra o lançamento
                IF vbOk THEN
                  FIP_GRAVALOG('Operação de desconto detalhado ' ||
                               vtDescDet.CODOPERACAO || ' no valor de ' ||
                               PKG_FINANCEIRO.FIF_FORMATAVALOR(vtDescDet.VLRDISPONIVEL) ||
                               ' para o título ' || vtQuitaTit.TITULO ||
                               ' lançada com sucesso!',
                               vtQuitaTit.SEQTITULO,
                               pnNroProcessoExe,
                               pnNroProcessoTit,
                               'R',
                               psUsuario);
                END IF;
                -- Força saída do loop se encontrar um erro
                EXIT WHEN NOT vbOk;
              END LOOP;
            ELSE
              vnVlrDescontoDet := 0;
            END IF;
          END IF;
        END IF;
        -- Log de registro e valor para retorno
        IF vbOk THEN
          FIP_GRAVALOG('Baixa do título ' || vtQuitaTit.TITULO ||
                       ' finalizada.',
                       vtQuitaTit.SEQTITULO,
                       pnNroProcessoExe,
                       pnNroProcessoTit,
                       'R',
                       psUsuario);
          -- Soma todos os valores lançados pois será o valor do novo título
          vnValorTotal := vnValorTotal + vnValor + vnVlrMulta + vnVlrJuros;
        ELSE
          FIP_GRAVALOG('Baixa do título ' || vtQuitaTit.TITULO ||
                       ' sequencial do título ' || vtQuitaTit.SEQTITULO ||
                       ' não realizada.',
                       vtQuitaTit.SEQTITULO,
                       pnNroProcessoExe,
                       pnNroProcessoTit,
                       'R',
                       psUsuario);
          --
          pnTotalBaixa := 0;
        END IF;
      END LOOP;
    END IF;
    -- Retorno
    pnTotalBaixa := vnValorTotal;
    RETURN(vbOk);
  END FIF_BAIXATITULOS;
  /* Faz o lançamento das operações */
  FUNCTION FIF_LANCAOPERACAO(pnCodOperacao    IN FI_OPERACAO.CODOPERACAO%TYPE,
                             pnSeqTitulo      IN FI_TITULO.SEQTITULO%TYPE,
                             pnNroEmpresaMae  IN GE_EMPRESA.NROEMPRESA%TYPE,
                             pnNroEmpresa     IN GE_EMPRESA.NROEMPRESA%TYPE,
                             pnValor          IN FI_TITOPERACAO.VLROPERACAO%TYPE,
                             pnNroProcessoExe IN FI_LOGBAIXATITAUTO.NROPROCESSOEXE%TYPE,
                             pnNroProcessoTit IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                             psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE,
                             psCanOcrQuitTit  IN FI_PARAMETRO.CANOCRQUITTIT%TYPE,
                             pnSeqTitDesconto IN FI_TITOPERACAO.SEQTITDESCONTO%TYPE)
    RETURN BOOLEAN IS
    vnSeqTitOperacao   FI_TITOPERACAO.SEQTITOPERACAO%TYPE;
    vbOk               BOOLEAN;
    vsAbertoQuitadoDep FI_TITULO.ABERTOQUITADO%TYPE;
    vnTemTela          INTEGER;
  BEGIN
    vbOk      := TRUE;
    vnTemTela := 0;
    PKG_FINANCEIRO.FIP_BUSCASEQFI(vnSeqTitOperacao);
    -- Lança a operação
    PKG_FINANCEIRO.FIP_TITOPERACAO(pnCodOperacao,
                                   pnSeqTitulo,
                                   Null,
                                   pnNroEmpresaMae,
                                   pnNroEmpresa,
                                   pnValor,
                                   pnNroProcessoTit,
                                   vnSeqTitOperacao,
                                   Null,
                                   TRUNC(SYSDATE),
                                   TRUNC(SYSDATE),
                                   Null,
                                   Null,
                                   psUsuario,
                                   Null,
                                   Null,
                                   Null,
                                   Null,
                                   'N',
                                   'S',
                                   Null);
    IF pnSeqTitDesconto IS NOT NULL THEN
      --RC 121930
      --Atualiza a coluna SEQTITDESCONTO da tabela FI_TITOPERACAO.
      UPDATE FI_TITOPERACAO A
         SET A.SEQTITDESCONTO = pnSeqTitDesconto
       WHERE A.SEQTITOPERACAO = vnSeqTitOperacao;
      --Atualiza a coluna VALORUTILIZADO da tabela FI_TITDESCONTODETALHE.
      UPDATE FI_TITDESCONTODETALHE A
         SET A.VALORUTILIZADO = A.VALORUTILIZADO + NVL(pnValor, 0)
       WHERE A.SEQTITDESCONTO = pnSeqTitDesconto;
    END IF;
    -- Contabiliza
    PKG_FINANCEIRO.FIP_CONTABILIZA(vnSeqTitOperacao,
                                   'TIT',
                                   psUsuario,
                                   TRUNC(SYSDATE),
                                   pnNroEmpresaMae,
                                   pnNroEmpresa,
                                   vnTemTela,
                                   pnNroProcessoTit);
    -- Verifica se o lançamento quitou o título
    SELECT A.ABERTOQUITADO
      INTO vsAbertoQuitadoDep
      FROM FI_TITULO A
     WHERE A.SEQTITULO = pnSeqTitulo;
    -- Cancela ocorrência de atraso se o título for quitado e estiver parametrizado
    IF vsAbertoQuitadoDep = 'Q' AND psCanOcrQuitTit = 'S' Then
      PKG_FINANCEIRO.FIP_BLOQUEIOCREDITO(pnSeqTitulo, psUsuario);
    END IF;
    -- Retorno
    RETURN(vbOk);
    -- Tratamento em caso de erro dentro das procedures
  EXCEPTION
    WHEN OTHERS THEN
      vbOk := FALSE;
      FIP_GRAVALOG('Erro no lançamento da operação ' || pnCodOperacao ||
                   ' no valor de ' ||
                   PKG_FINANCEIRO.FIF_FORMATAVALOR(pnValor) ||
                   ' para o sequencial do título ' || pnSeqTitulo || ' : ' ||
                   SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                   pnSeqTitulo,
                   pnNroProcessoExe,
                   pnNroProcessoTit,
                   'E',
                   psUsuario);
      --
      RETURN(vbOk);
  END FIF_LANCAOPERACAO;
  /* Gera o número da empresa */
  FUNCTION FIF_RETORNAEMPRESA(psEmpresasAgrupadas IN CLOB,
                              pnNroEmpresaMae     IN GE_EMPRESA.NROEMPRESA%TYPE,
                              psEmpresaGeradora   IN FI_PARAMBAIXATITAUTO.EMPRESAGERACAO%TYPE)
    RETURN NUMBER IS
    vnRetorno GE_EMPRESA.NROEMPRESA%TYPE;
  BEGIN
    -- Valor padrão
    vnRetorno := pnNroEmpresaMae;
    -- Busca o número da empresa que tem mais títulos envolvidos
    IF psEmpresaGeradora = 'N' THEN
      SELECT A.EMPRESA
        INTO vnRetorno
        FROM (SELECT TO_NUMBER(COLUMN_VALUE) EMPRESA, COUNT(1) QUANTIDADE
                FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLECLOB(psEmpresasAgrupadas) AS
                                C5INCLOBTABLE))
               GROUP BY TO_NUMBER(COLUMN_VALUE)
               ORDER BY QUANTIDADE DESC, EMPRESA) A
       WHERE ROWNUM = 1;
    END IF;
    RETURN(vnRetorno);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN pnNroEmpresaMae;
  END FIF_RETORNAEMPRESA;
  /* Gera o número do novo título */
  FUNCTION FIF_RETORNANROTITULO(psNroTitulosAgrupados IN CLOB,
                                pdDtaVencimento       IN FI_TITULO.DTAVENCIMENTO%TYPE,
                                psNumeroGeracao       IN FI_PARAMBAIXATITAUTO.NUMEROGERACAO%TYPE)
    RETURN NUMBER IS
    vnRetorno FI_TITULO.NROTITULO%TYPE;
  BEGIN
    -- Valor padrão
    vnRetorno := TO_NUMBER(TO_CHAR(TRUNC(SYSDATE), 'DDMMYYYY'));
    -- Verifica se o número do título será gerado pelo vencimento
    IF psNumeroGeracao = 'V' THEN
      vnRetorno := TO_NUMBER(TO_CHAR(pdDtaVencimento, 'DDMMYYYY'));
    ELSE
      -- Busca o número que mais se repete para usá-lo
      SELECT NVL(A.NUMERO, 0)
        INTO vnRetorno
        FROM (SELECT TO_NUMBER(COLUMN_VALUE) NUMERO, COUNT(1) QUANTIDADE
                FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLECLOB(psNroTitulosAgrupados) AS
                                C5INCLOBTABLE))
               GROUP BY TO_NUMBER(COLUMN_VALUE)
               ORDER BY QUANTIDADE DESC, NUMERO) A
       WHERE ROWNUM = 1;
    END IF;
    RETURN(vnRetorno);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN TO_NUMBER(TO_CHAR(TRUNC(SYSDATE), 'DDMMYYYY'));
  END FIF_RETORNANROTITULO;
  /* Gera data do desconto do novo título */
  FUNCTION FIF_RETORNADTALIMDESC(psDtaLimDescFin       IN CLOB,
                                 pdDtaVencimento       IN FI_TITULO.DTAVENCIMENTO%TYPE,
                                 psParamUsaDesconto    IN FI_PARAMBAIXATITAUTO.DESCONTO%TYPE,
                                 psParamDataLimiteDesc IN FI_PARAMBAIXATITAUTO.DATALIMITEDESC%TYPE)
    RETURN DATE IS
    vdRetorno FI_COMPLTITULO.DTALIMDSCFINANC%TYPE;
  BEGIN
    -- Valor padrão
    vdRetorno := NULL;
    -- Verifica se irá transportar o desconto
    IF psParamUsaDesconto = 'T' THEN
      IF psParamDataLimiteDesc = 'T' THEN
        -- Maior data
        SELECT MAX(TO_DATE(COLUMN_VALUE))
          INTO vdRetorno
          FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLECLOB(psDtaLimDescFin) AS
                          C5INCLOBTABLE));
      ELSIF psParamDataLimiteDesc = 'M' THEN
        -- Média de datas
        -- ( Regra : Encontra a maior data e a menor data, extrai a quantidade de dias entre elas, divide por dois e aplica a menor data )
        SELECT MIN(TO_DATE(COLUMN_VALUE)) +
               ROUND(TO_NUMBER(MAX(TO_DATE(COLUMN_VALUE)) -
                               MIN(TO_DATE(COLUMN_VALUE))) / 2,
                     0)
          INTO vdRetorno
          FROM TABLE(CAST(C5_COMPLEXIN.C5INTABLECLOB(psDtaLimDescFin) AS
                          C5INCLOBTABLE));
      ELSE
        -- Data de vencimento
        vdRetorno := pdDtaVencimento;
      END IF;
    END IF;
    RETURN(vdRetorno);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(vdRetorno);
  END FIF_RETORNADTALIMDESC;
  /* Consiste a espécie e operação */
  FUNCTION FIF_CONSISTEESPOPER(pdDtaContabil    IN FI_TITOPERACAO.DTACONTABILIZA%TYPE,
                               psCodEspecie     IN FI_ESPECIE.CODESPECIE%TYPE,
                               pnCodOperacao    IN FI_OPERACAO.CODOPERACAO%TYPE,
                               pnNroEmpresa     IN GE_EMPRESA.NROEMPRESA%TYPE,
                               pnNroEmpresaMae  IN GE_EMPRESA.NROEMPRESA%TYPE,
                               pnNroProcessoExe IN FI_LOGBAIXATITAUTO.NROPROCESSOEXE%TYPE,
                               psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE)
    RETURN BOOLEAN IS
    vbOk  BOOLEAN;
    vsMsg FI_LOGBAIXATITAUTO.DESCRICAO%TYPE;
  BEGIN
    vbOk := PKG_FINANCEIRO.FIF_CONSISTEESPOPER(pdDtaContabil,
                                               psCodEspecie,
                                               pnCodOperacao,
                                               pnNroEmpresa,
                                               pnNroEmpresaMae,
                                               psUsuario,
                                               'B',
                                               'N',
                                               'N',
                                               vsMsg);
    -- Se houve erro gera o log
    IF NOT vbOk THEN
      FIP_GRAVALOG(vsMsg, NULL, pnNroProcessoExe, NULL, 'E', psUsuario);
    END IF;
    -- Retorno
    RETURN(vbOk);
  END FIF_CONSISTEESPOPER;
  /* Gera Log */
  PROCEDURE FIP_GRAVALOG(psMensagem       IN FI_LOGBAIXATITAUTO.DESCRICAO%TYPE,
                         pnSeqTitulo      IN FI_TITULO.SEQTITULO%TYPE,
                         pnNroProcessoExe IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                         pnNroProcessoTit IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                         psCategoria      IN FI_LOGBAIXATITAUTO.CATEGORIA%TYPE,
                         psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    -- Tipos de categorias
    -- I - INFORMATIVO - Informa o que foi executado, inicio e fim de cada processo.
    -- R - REGISTRO - Registra um processamento efetuado, inclusão, quitação, operações.
    -- E - ERRO - Erro ocorrido. No caso de erro os lançamentos serão desfeitos e os logs do tipo R serão apagados.
    INSERT INTO FI_LOGBAIXATITAUTO
      (SEQLOG,
       DATAHORA,
       DATA,
       USUARIO,
       DESCRICAO,
       SEQTITULO,
       NROPROCESSOEXE,
       NROPROCESSOTIT,
       CATEGORIA)
    VALUES
      (S_FILOGBAIXATITAUTO.NEXTVAL,
       SYSDATE,
       TRUNC(SYSDATE),
       psUsuario,
       SUBSTR(psMensagem, 1, 500),
       pnSeqTitulo,
       pnNroProcessoExe,
       pnNroProcessoTit,
       psCategoria);
    -- Apaga os logs de registro de lançamentos em caso de erro
    IF psCategoria = 'E' AND pnNroProcessoTit IS NOT NULL THEN
      DELETE FI_LOGBAIXATITAUTO A
       WHERE A.CATEGORIA = 'R'
         AND A.NROPROCESSOTIT = pnNroProcessoTit;
    END IF;
    -- Faz o commit por usar o pragma
    COMMIT;
  END FIP_GRAVALOG;
  /* Monta a data de vencimento do Título agrupado */
  FUNCTION FIF_DTAVENCIMENTO(pdFechamento   IN DATE,
                             pdVencimento   IN FI_TITULO.DTAVENCIMENTO%TYPE,
                             pnSeqPessoa    IN FI_TITULO.SEQPESSOA%TYPE,
                             psObrigDireito IN FI_TITULO.OBRIGDIREITO%TYPE)
    RETURN DATE IS
    vsIndUsaPeriodoAgrupauto FI_FORNECEDOR.INDUSAPERIODOAGRUPAUTO%TYPE;
    vdRetorno                DATE;
  BEGIN
    IF psObrigDireito = 'O' THEN
      SELECT NVL(A.INDUSAPERIODOAGRUPAUTO, 'N')
        INTO vsIndUsaPeriodoAgrupauto
        FROM FI_FORNECEDOR A
       WHERE A.SEQPESSOA = pnSeqPessoa;
    ELSE
      SELECT NVL(A.INDUSAPERIODOAGRUPAUTO, 'N')
        INTO vsIndUsaPeriodoAgrupauto
        FROM FI_CLIENTE A
       WHERE A.SEQPESSOA = pnSeqPessoa;
    END IF;
    --SE USA PERIODO PARA AGRUPAMENTO
    IF vsIndUsaPeriodoAgrupauto = 'N' THEN
      vdRetorno := pdVencimento;
    ELSE
      BEGIN
        SELECT PKG_FIAGRUPATITAUTO.FIF_MONTADATA(A.DIAVENC,
                                                 A.MESVENC,
                                                 EXTRACT(MONTH FROM
                                                         pdFechamento),
                                                 EXTRACT(YEAR FROM
                                                         pdFechamento),
                                                 'V')
          INTO vdRetorno
          FROM FI_PERIODOAGRUPAUTO A
         WHERE A.SEQPESSOA = pnSeqPessoa
           AND A.OBRIGDIREITO = psObrigDireito
           AND A.DIAEXE = EXTRACT(DAY FROM pdFechamento)
           AND A.MESEXE = EXTRACT(MONTH FROM pdFechamento);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vdRetorno := pdVencimento;
      END;
    END IF;
    RETURN vdRetorno;
  END FIF_DTAVENCIMENTO;
  /* Monta a data a partir do dia, mês e ano de execução */
  FUNCTION FIF_MONTADATA(pnDia    IN FI_PERIODOAGRUPAUTO.DIAINI%TYPE,
                         pnMes    IN FI_PERIODOAGRUPAUTO.MESINI%TYPE,
                         pnMesExe IN FI_PERIODOAGRUPAUTO.MESEXE%TYPE,
                         pnAnoExe IN NUMBER,
                         psTipo   IN VARCHAR) -- P - Periodo   V - Vencimento
   RETURN DATE IS
    vdRetorno  DATE;
    vnAno      NUMBER;
    vnDia      NUMBER;
    vbBissexto BOOLEAN;
  BEGIN
    vnAno := pnAnoExe;
    vnDia := pnDia;
    IF psTipo = 'P' THEN
      --MES MAIOR QUE MES DE EXECUÇÃO, Periodo do ano anterior.
      IF pnMes > pnMesExe THEN
        vnAno := pnAnoExe - 1;
      END IF;
    ELSIF psTipo = 'V' THEN
      --MES MENOR QUE MES DE EXECUÇÃO, Vencimento para ano posterior.
      IF pnMes < pnMesExe THEN
        vnAno := pnAnoExe + 1;
      END IF;
    END IF;
    IF pnMes = 2 AND vnDia = 29 THEN
      vbBissexto := (MOD(vnAno, 4) = 0 AND
                    (MOD(vnAno, 400) = 0 OR MOD(vnAno, 100) != 0));
      --SE NÃO FOR BISSEXTO joga o dia como 28
      IF NOT vbBissexto THEN
        vnDia := 28;
      END IF;
    END IF;
    vdRetorno := TO_DATE(vnDia || '/' || pnMes || '/' || vnAno,
                         'DD/MM/YYYY');
    RETURN vdRetorno;
  END FIF_MONTADATA;
  /* Duplica Periodo */
  PROCEDURE FIP_DUPLICARPERIODO(pnSeqPessoa       IN FI_PERIODOAGRUPAUTO.SEQPESSOA%TYPE,
                                psObrigdireito    IN FI_PERIODOAGRUPAUTO.OBRIGDIREITO%TYPE,
                                pnSeqPessoaDup    IN FI_PERIODOAGRUPAUTO.SEQPESSOA%TYPE,
                                psObrigdireitoDup IN FI_PERIODOAGRUPAUTO.OBRIGDIREITO%TYPE,
                                psUsuario         IN FI_PERIODOAGRUPAUTO.USUALTERACAO%TYPE) IS
  BEGIN
    --DELETA PERIODO DA PESSOA QUE VAI DUPLICAR
    DELETE FROM FI_PERIODOAGRUPAUTO
     WHERE SEQPESSOA = pnSeqPessoaDup
       AND OBRIGDIREITO = psObrigdireitoDup;
    --INSERE PERIODO
    INSERT INTO FI_PERIODOAGRUPAUTO
      (SEQPERIODO,
       SEQPESSOA,
       OBRIGDIREITO,
       DIAINI,
       MESINI,
       DIAFIM,
       MESFIM,
       DIAEXE,
       MESEXE,
       DIAVENC,
       MESVENC,
       USUALTERACAO)
      SELECT S_FILOGBAIXATITAUTO.NEXTVAL,
             pnSeqPessoaDup,
             psObrigdireitoDup,
             A.DIAINI,
             A.MESINI,
             A.DIAFIM,
             A.MESFIM,
             A.DIAEXE,
             A.MESEXE,
             A.DIAVENC,
             A.MESVENC,
             psUsuario
        FROM FI_PERIODOAGRUPAUTO A
       WHERE SEQPESSOA = pnSeqPessoa
         AND OBRIGDIREITO = psObrigdireito;
  END FIP_DUPLICARPERIODO;
END PKG_FIAGRUPATITAUTO_cadan;
/

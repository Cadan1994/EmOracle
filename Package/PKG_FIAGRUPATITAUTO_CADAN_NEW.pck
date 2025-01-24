CREATE OR REPLACE PACKAGE IMPLANTACAO.PKG_FIAGRUPATITAUTO_CADAN IS
-- Procedure principal de processamento
PROCEDURE FIP_AGRUPAUTTITULOS( psUsuario           IN GE_USUARIO.CODUSUARIO%TYPE, -- Usuário usado para registro das transações e log, em caso de nulo será usado o nome AUTOMATICO
                               pdDtaInicial        IN FI_TITULO.DTAEMISSAO%TYPE,  -- Data inicial para busca dos títulos, caso não seja informado serão filtrados todas as datas
                               pdDtaFinal          IN FI_TITULO.DTAEMISSAO%TYPE,  -- Data final para busca dos títulos, caso não seja informado serão filtrados todas as datas
                               psTipoData          IN VARCHAR2                    -- Tipo de data usada E-Emissão V-Vencimento, este filtro é usado em conjunto com os filtros de data
                             );
/* Baixa os títulos */
FUNCTION FIF_BAIXATITULOS( pnSeqTitulo        IN  CLOB,
                           pnCodOpeQuit       IN  FI_OPERACAO.CODOPERACAO%TYPE,
                           pnCodOpeMulta      IN  FI_OPERACAO.CODOPERACAO%TYPE,
                           pnCodOpeJuros      IN  FI_OPERACAO.CODOPERACAO%TYPE,
                           pnCodOpeDesc       IN  FI_OPERACAO.CODOPERACAO%TYPE,
                           pnNroEmpresaMae    IN  GE_EMPRESA.NROEMPRESA%TYPE,
                           psUtilizaDesc      IN  FI_PARAMBAIXATITAUTO.DESCONTO%TYPE,
                           psMultaJuros       IN  FI_PARAMBAIXATITAUTO.UTILIZAMULTAJUROS%TYPE,
                           pnNroProcessoExe   IN  FI_TITOPERACAO.NROPROCESSO%TYPE,
                           pnNroProcessoTit   IN  FI_TITOPERACAO.NROPROCESSO%TYPE,
                           psUsuario          IN  GE_USUARIO.CODUSUARIO%TYPE,
                           pnTotalBaixa       OUT FI_TITULO.VLRNOMINAL%TYPE )
RETURN BOOLEAN;
/* Faz o lançamento das operações */
FUNCTION FIF_LANCAOPERACAO( pnCodOperacao    IN  FI_OPERACAO.CODOPERACAO%TYPE,
                            pnSeqTitulo      IN  FI_TITULO.SEQTITULO%TYPE,
                            pnNroEmpresaMae  IN  GE_EMPRESA.NROEMPRESA%TYPE,
                            pnNroEmpresa     IN  GE_EMPRESA.NROEMPRESA%TYPE,
                            pnValor          IN  FI_TITOPERACAO.VLROPERACAO%TYPE,
                            pnNroProcessoExe IN  FI_LOGBAIXATITAUTO.NROPROCESSOEXE%TYPE,
                            pnNroProcessoTit IN  FI_TITOPERACAO.NROPROCESSO%TYPE,
                            psUsuario        IN  GE_USUARIO.CODUSUARIO%TYPE,
                            psCanOcrQuitTit  IN  FI_PARAMETRO.CANOCRQUITTIT%TYPE,
                            pnSeqTitDesconto IN  FI_TITOPERACAO.SEQTITDESCONTO%TYPE )
RETURN BOOLEAN;
/* Gera o número da empresa */
FUNCTION FIF_RETORNAEMPRESA( psEmpresasAgrupadas IN CLOB,
                             pnNroEmpresaMae     IN GE_EMPRESA.NROEMPRESA%TYPE,
                             psEmpresaGeradora   IN FI_PARAMBAIXATITAUTO.EMPRESAGERACAO%TYPE )
RETURN NUMBER;
/* Gera o número do novo título */
FUNCTION FIF_RETORNANROTITULO( psNroTitulosAgrupados IN CLOB,
                               pdDtaVencimento       IN FI_TITULO.DTAVENCIMENTO%TYPE,
                               psNumeroGeracao       IN FI_PARAMBAIXATITAUTO.NUMEROGERACAO%TYPE )
RETURN NUMBER;
/* Gera data do desconto do novo título */
FUNCTION FIF_RETORNADTALIMDESC( psDtaLimDescFin       IN CLOB,
                                pdDtaVencimento       IN FI_TITULO.DTAVENCIMENTO%TYPE,
                                psParamUsaDesconto    IN FI_PARAMBAIXATITAUTO.DESCONTO%TYPE,
                                psParamDataLimiteDesc IN FI_PARAMBAIXATITAUTO.DATALIMITEDESC%TYPE )
RETURN DATE;
/* Consiste a espécie e operação */
FUNCTION FIF_CONSISTEESPOPER( pdDtaContabil     IN FI_TITOPERACAO.DTACONTABILIZA%TYPE,
                              psCodEspecie      IN FI_ESPECIE.CODESPECIE%TYPE,
                              pnCodOperacao     IN FI_OPERACAO.CODOPERACAO%TYPE,
                              pnNroEmpresa      IN GE_EMPRESA.NROEMPRESA%TYPE,
                              pnNroEmpresaMae   IN GE_EMPRESA.NROEMPRESA%TYPE,
                              pnNroProcessoExe  IN FI_LOGBAIXATITAUTO.NROPROCESSOEXE%TYPE,
                              psUsuario         IN GE_USUARIO.CODUSUARIO%TYPE)
RETURN BOOLEAN;
/* Gera Log */
PROCEDURE FIP_GRAVALOG( psMensagem       IN FI_LOGBAIXATITAUTO.DESCRICAO%TYPE,
                        pnSeqTitulo      IN FI_TITULO.SEQTITULO%TYPE,
                        pnNroProcessoExe IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                        pnNroProcessoTit IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                        psCategoria      IN FI_LOGBAIXATITAUTO.CATEGORIA%TYPE,
                        psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE );
/* Monta a data de vencimento do Título agrupado */
FUNCTION FIF_DTAVENCIMENTO  ( pdFechamento      IN  DATE,
                              pdVencimento      IN  FI_TITULO.DTAVENCIMENTO%TYPE,
                              pnSeqPessoa       IN  FI_TITULO.SEQPESSOA%TYPE,
                              psObrigDireito    IN  FI_TITULO.OBRIGDIREITO%TYPE )
RETURN DATE;
/* Monta a data a partir do dia, mês e ano de execução */
FUNCTION FIF_MONTADATA  ( pnDia         IN  FI_PERIODOAGRUPAUTO.DIAINI%TYPE,
                          pnMes         IN  FI_PERIODOAGRUPAUTO.MESINI%TYPE,
                          pnMesExe      IN  FI_PERIODOAGRUPAUTO.MESEXE%TYPE,
                          pnAnoExe      IN  NUMBER,
                          psTipo        IN  VARCHAR ) -- P - Periodo   V - Vencimento
RETURN DATE;
/* Duplica Periodo */
PROCEDURE FIP_DUPLICARPERIODO( pnSeqPessoa       IN FI_PERIODOAGRUPAUTO.SEQPESSOA%TYPE,
                               psObrigdireito    IN FI_PERIODOAGRUPAUTO.OBRIGDIREITO%TYPE,
                               pnSeqPessoaDup    IN FI_PERIODOAGRUPAUTO.SEQPESSOA%TYPE,
                               psObrigdireitoDup IN FI_PERIODOAGRUPAUTO.OBRIGDIREITO%TYPE,
                               psUsuario         IN FI_PERIODOAGRUPAUTO.USUALTERACAO%TYPE );
END PKG_FIAGRUPATITAUTO_CADAN;
/
CREATE OR REPLACE PACKAGE BODY IMPLANTACAO.PKG_FIAGRUPATITAUTO_cadan IS
/*
///////////////////////////////////////////////////////////////////
//---------------------------------------------------------------//
// Objeto modificado por Hilson Santos em 28/11/2023             //
//---------------------------------------------------------------//
// O objetivo dessa alteração, foi para o agrupamento  dos títu- //
// los referente as compras realizadas pelo ECOMMERCE, onde esse //
// processo dar baixa nos títulos dos clientes e cria um novo em //
// nome da getnet com o código do cliente 37266                  //
///////////////////////////////////////////////////////////////////
*/

/* Procedure principal de processamento */
PROCEDURE FIP_AGRUPAUTTITULOS( psUsuario           IN GE_USUARIO.CODUSUARIO%TYPE, -- Usuário usado para registro das transações e log, em caso de nulo será usado o nome AUTOMATICO
                               pdDtaInicial        IN FI_TITULO.DTAEMISSAO%TYPE,  -- Data inicial para busca dos títulos, caso não seja informado serão filtrados todas as datas
                               pdDtaFinal          IN FI_TITULO.DTAEMISSAO%TYPE,  -- Data final para busca dos títulos, caso não seja informado serão filtrados todas as datas
                               psTipoData          IN VARCHAR2                    -- Tipo de data usada E-Emissão V-Vencimento, este filtro é usado em conjunto com os filtros de data
                             )
IS
  /* Cursor */
  TYPE CursorRefType IS REF CURSOR;
  Cursor_Titulo CursorRefType;
  Cursor_Baixa CursorRefType;
  
  /* Campos do loop */
  vtnNroEmpresaMae       FI_TITULO.NROEMPRESAMAE%TYPE;
  vtnNroEmpresa          FI_TITULO.NROEMPRESA%TYPE;
  vtnSeqPessoa           FI_TITULO.SEQPESSOA%TYPE;
  vtdDtaVencimento       FI_TITULO.DTAVENCIMENTO%TYPE;
  vtsCodEspecie          FI_TITULO.CODESPECIE%TYPE;
  vtdDtaMovimento        FI_TITULONSU.DTAMOVIMENTO%TYPE;
  vtnRede                FI_TITULONSU.REDE%TYPE;
  vtnBandeira            FI_TITULONSU.BANDEIRA%TYPE;
  vtsNsu                 FI_TITULONSU.NSU%TYPE;      
  vtnvlroriginal         FI_TITULO.VLRORIGINAL%TYPE;
  vtnVlrDescFin          FI_COMPLTITULO.VLRDSCFINANC%TYPE;
  vtnVlrDescContrato     FI_COMPLTITULO.VLRDESCCONTRATO%TYPE;
  
  /* Montagem da consulta */
  vsSqlAnd               VARCHAR2(12000);
  vsSqlConsultatitagr    VARCHAR2(30000);
  vsSqlConsultatitind    VARCHAR2(30000);

  
  /* Parâmetros */
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
  
  /* Títulos */
  vnNroProcessoExe       FI_TITOPERACAO.NROPROCESSO%TYPE;
  vnNroProcessoTit       FI_TITOPERACAO.NROPROCESSO%TYPE;
  vnSeqTitNovo           FI_TITULO.SEQTITULO%TYPE;
  vnSeqTitBaixa          FI_TITULO.SEQTITULO%TYPE;
  vnNroTituloNew         FI_TITULO.NROTITULO%TYPE;
  vnSeqTitulo            CLOB;
  vnNroTitulo            FI_TITULO.SEQTITULO%TYPE;
  vdDtaLimDescFinanc     FI_COMPLTITULO.DTALIMDSCFINANC%TYPE;
  vsObservacao           FI_TITULO.OBSERVACAO%TYPE;
  vnNroEmpresa           FI_TITULO.NROEMPRESA%TYPE;
  vnNroEmpresaMae        FI_TITULO.NROEMPRESAMAE%TYPE;
  vnVlrTotal             FI_TITULO.VLRNOMINAL%TYPE;
  vnPercDescContrato     FI_COMPLTITULO.PERCDESCCONTRATO%TYPE;
  vnSeqTituloNsu         FI_TITULONSU.SEQTITULONSU%TYPE;
  
  /* Outros */
  vsCodEspecieNovoTit    FI_ESPECIE.CODESPECIE%TYPE;
  vnDepositarioNovoTit   FI_TITULO.SEQDEPOSITARIO%TYPE;
  vnCodOperacaoNovoTit   FI_OPERACAO.CODOPERACAO%TYPE;
  vbOk                   BOOLEAN;
  vdDtaInicial           FI_TITULO.DTAEMISSAO%TYPE;
  vdDtaFinal             FI_TITULO.DTAEMISSAO%TYPE;
  vsTipoData             VARCHAR2(1);
  vsUsuario              GE_USUARIO.CODUSUARIO%TYPE;
  vnSeqTituloOrigem      FI_TITCOMPRADORDET.SEQTITULOORIGEM%TYPE;
  vnSeqTituloBase        FI_TITCOMPRADORDET.SEQTITULOBASE%TYPE;
  vsIndReplicaComprador  FI_PARAMETRO.INDREPLICACOMPRADOR%TYPE;
  vsLancaOpTxAdm         FI_PARAMETRO.LANCAOPTXADMQUIT%TYPE;
  vnCount                NUMBER(15);
  vdDtaExecucao          DATE;
  
BEGIN
     /* Busca os parâmetros */
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
     INTO   vsEmpresaGeracao,
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
     FROM   FI_PARAMBAIXATITAUTO;
     
     /* Busca o processo global */
     SELECT S_FILOGBAIXATITAUTO.NEXTVAL
     INTO   vnNroProcessoExe
     FROM   DUAL;
     
     /* Consiste os filtros */
     vdDtaInicial  := NULL;
     vdDtaFinal    := NULL;
     vsTipoData    := NULL;
     vsUsuario     := NVL(psUsuario,'ECOMMERCE');
     
     IF pdDtaInicial IS NOT NULL AND pdDtaFinal IS NOT NULL THEN
        IF pdDtaFinal >= pdDtaInicial THEN
           vdDtaInicial := pdDtaInicial;
           vdDtaFinal   := pdDtaFinal;
           IF psTipoData = 'E' THEN
              vsTipoData:= 'E';
           ELSE
               vsTipoData:= 'V';
           END IF;
        END IF;
     END IF;

     /* Verifica qual o tipo de data vai ter a consulta */
     IF vsTipoData = 'E' THEN
        vsSqlAnd := 'AND c.dtaemissao BETWEEN ''' || vdDtaInicial || ''' AND ''' || vdDtaFinal || ''' ';
     ELSIF vsTipoData = 'V' THEN
        vsSqlAnd := 'AND c.dtavencimento BETWEEN ''' || vdDtaInicial || ''' AND ''' || vdDtaFinal || ''' ';
     END IF;

     /* Monta a query de consulta */     
     vsSqlConsultatitagr:= 'SELECT 
                                c.nroempresamae,
                                c.nroempresa,
                                c.seqpessoa,
                                c.codespecie,
                                c.dtainclusao,
                                d.rede,
                                d.bandeira,
                                d.nsu,
                                NVL(SUM(c.vlroriginal),0) vlroriginal,
                                NVL(SUM(g.vlrdscfinanc),0) vlrdscfinanc,
                                NVL(SUM(g.vlrdesccontrato),0) vlrdesccontrato
                            FROM implantacao.mad_pedvenda a 
                            INNER JOIN implantacao.mfl_doctofiscal b ON b.nropedidovenda IN a.nropedvenda
                            INNER JOIN implantacao.fi_titulo c ON c.nrotitulo = b.numerodf
                            INNER JOIN implantacao.mad_pedvendansu d ON d.nropedvenda = a.nropedvenda
                            LEFT JOIN implantacao.fi_titulonsu e ON e.seqtitulo = c.seqtitulo
                            INNER JOIN implantacao.fi_especie f ON f.codespecie = c.codespecie AND f.nroempresamae = c.nroempresamae
                            INNER JOIN implantacao.fi_compltitulo g ON g.seqtitulo = c.seqtitulo
                            WHERE 1=1 
                            AND a.situacaoped = ''F'' 
                            AND a.usuinclusao = ''ECOMMERCE'' 
                            AND c.abertoquitado = ''A'' 
                            AND c.obrigdireito = ''D''
                            AND c.codespecie IN (''CARDEB'', ''CARTAO'', ''TICKET'')
                            AND c.seqpessoa != ''37266'' ' || 
                            vsSqlAnd || '
                            GROUP BY c.nroempresamae,c.nroempresa,c.seqpessoa,c.codespecie,a.dtainclusao,d.rede,d.bandeira,d.nsu
                            ORDER BY c.seqpessoa ASC';
                   
     
     /* Executa o loop */
     OPEN Cursor_Titulo FOR vsSqlConsultatitagr;
     LOOP
         FETCH Cursor_Titulo
         
         /* Cuidado ao alterar a ordem das variáveis do into, eles devem estar na mesma ordem das colunas montadas */
         INTO  vtnNroEmpresaMae,
               vtnNroEmpresa,
               vtnSeqPessoa,
               vtsCodEspecie,
               vtdDtaVencimento,
               vtnRede,
               vtnBandeira,
               vtsNsu,
               vtnvlroriginal,
               vtnVlrDescFin,
               vtnVlrDescContrato;
               
         /* Condição de parada */
         EXIT  WHEN Cursor_Titulo%NOTFOUND;
         vbOk := TRUE;
         vnNroTitulo := NULL;
         vnNroEmpresa := NULL;
         vdDtaLimDescFinanc := NULL;
         vsCodEspecieNovoTit := NULL;
         vnDepositarioNovoTit := NULL;
         vnCodOperacaoNovoTit := NULL;
         vnPercDescContrato := NULL;
         
         /* Busca o processo do título */
         PKG_FINANCEIRO.FIP_BUSCASEQFI( vnNroProcessoTit );
         
         /* Verifica qual o tipo de data vai ter a consulta */
         IF vsTipoData = 'E' THEN
            vsSqlAnd := 'AND a.dtaemissao BETWEEN ''' || vdDtaInicial || ''' AND ''' || vdDtaFinal || ''' ';
         ELSIF vsTipoData = 'V' THEN
            vsSqlAnd := 'AND a.dtavencimento BETWEEN ''' || vdDtaInicial || ''' AND ''' || vdDtaFinal || ''' ';
         END IF;
                  
         /* Monta a query de consulta */
         vsSqlConsultatitind := 'SELECT 
                                     a.seqtitulo,
                                     b.seqtitulo,
                                     a.nrotitulo,
                                     a.vlroriginal
                                 FROM  fi_titulo a
                                 INNER JOIN IMPLANTACAO.fi_compltitulo b ON b.seqtitulo = a.seqtitulo
                                 WHERE 1 = 1
                                 AND   a.abertoquitado = ''A''
                                 AND   a.obrigdireito = ''D''
                                 AND   a.codespecie IN (''CARDEB'', ''CARTAO'', ''TICKET'')
                                 AND   a.seqpessoa = ''' || vtnSeqPessoa || ''' ' || 
                                 vsSqlAnd || '
                                 ORDER BY a.seqtitulo ASC';
                                 
         OPEN Cursor_Baixa FOR vsSqlConsultatitind;
         LOOP
             FETCH Cursor_Baixa
             
             /* Cuidado ao alterar a ordem das variáveis do into, eles devem estar na mesma ordem das colunas montadas */
             INTO  vnSeqTitulo,
                   vnSeqTitBaixa,
                   vnNroTituloNew,
                   vnVlrTotal;
                   
             /* Condição de parada */
             EXIT  WHEN Cursor_Baixa%NOTFOUND;
             
             /* Log de registro */
             FIP_GRAVALOG(
                  'Inicio do agrupamento dos títulos da sequência: ' || SUBSTR(vnSeqTitulo, 1, 450),
                  NULL,
                  vnNroProcessoExe,
                  vnNroProcessoTit,
                  'I',
                  vsUsuario 
             );

             /* Verifica se pode dar baixa nos títulos */
             vbOk := FIF_BAIXATITULOS(
                         vnSeqTitulo,
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
                         vnVlrTotal
                     );

             /* Realiza a quitação do titulo */
             IF vbOk THEN
                vdDtaExecucao := TRUNC(SYSDATE);
                UPDATE FI_TITULO A
                SET    A.ABERTOQUITADO = 'Q',
                       A.DTAQUITACAO = vdDtaExecucao
                WHERE  A.SEQTITULO = vnSeqTitBaixa;
             END IF;
         END LOOP;
         CLOSE Cursor_Baixa;

-------------------------------------------------------------------------------------------------------------------------------------------------------         
         
         /* Novo título */
         IF vbOk THEN
            /* Sequência do título */
            vnSeqTitNovo := vnSeqTitBaixa;
            
            /* Número do novo título */
            vnNroTitulo := vnNroTituloNew;
            
            /* Código da Empresa Mãe*/
            vnNroEmpresaMae := vtnNroEmpresaMae;
           
            /* Código da empresa */
            vnNroEmpresa := vtnNroEmpresa;
            
            /* Data do Movimento */
            vtdDtaMovimento := TRUNC(vtdDtaVencimento);
         
            /*Data de Vencimento */
            vtdDtaVencimento := TRUNC(vtdDtaVencimento) + 31;
            
            /* Valor Total dos Titulos */
            vnVlrTotal := vtnvlroriginal;
                            
            /* Nova espécie */
            vsCodEspecieNovoTit := vtsCodEspecie;
            
            /* Verifica valor de inclusão do novo título */
            IF vnVlrTotal <= 0 THEN
               vbOk := FALSE;
               FIP_GRAVALOG( 
                   'O valor do novo título ' || vnNroTitulo || ' deve ser maior que zero. ( Valor ' || PKG_FINANCEIRO.FIF_FORMATAVALOR( vnVlrTotal ) || ' ) : ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                   vnSeqTitNovo,
                   vnNroProcessoExe,
                   vnNroProcessoTit,
                   'E',
                   vsUsuario
               );
            END IF;
            
            /* Geração do novo título */
            IF vbOk THEN
               vnDepositarioNovoTit := 1;
               vnCodOperacaoNovoTit := vnCodOpeInclusaoDir;
               
               /* Se não for transferir os descontos, zera seu valor */
               IF vsDesconto != 'T' THEN
                  vtnVlrDescFin := 0;
                  vtnVlrDescContrato := 0;
               END IF;
               
               /* Inclui o novo título */
               BEGIN
                    vsObservacao := 'Título gerado pelo processo de agrupamento automático.';
                    PKG_FINANCEIRO.FIP_INCLUITITULO( 
                                       37266,
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
                                       vnNroEmpresaMae,
                                       vsUsuario,
                                       TRUNC(SYSDATE),
                                       vtnVlrDescContrato,
                                       vnPercDescContrato,
                                       NULL,
                                       NULL 
                                       );
                                       
               /* Marca o título como gerado automaticamente */
               UPDATE FI_TITULO
               SET    FI_TITULO.APPORIGEM = 'AGRUPTITAUTO'
               WHERE  FI_TITULO.SEQTITULO = vnSeqTitNovo;
               SELECT NVL(MAX(A.INDREPLICACOMPRADOR),'N'),NVL(MAX(A.LANCAOPTXADM),'N')
               INTO   vsIndReplicaComprador, vsLancaOpTxAdm
               FROM   FI_PARAMETRO A
               WHERE  A.NROEMPRESA = vnNroEmpresa;
               
               
               IF vsTransfCartTitGer = 'S' AND vsLancaOpTxAdm = 'N' THEN
                  /* Inclui o NSU referente ao título criado automáticamente */
                  SELECT	S_FITITNSU.NEXTVAL INTO vnSeqTituloNsu FROM DUAL;
                  INSERT INTO FI_TITULONSU(FI_TITULONSU.SEQTITULONSU, 
                                           FI_TITULONSU.SEQTITULO, 
                                           FI_TITULONSU.REDE, 
                                           FI_TITULONSU.BANDEIRA, 
                                           FI_TITULONSU.DTAMOVIMENTO, 
                                           FI_TITULONSU.NSU, 
                                           FI_TITULONSU.CODAUTORIZACAO, 
                                           FI_TITULONSU.QTDPARCELA, 
                                           FI_TITULONSU.VALOR, 
                                           FI_TITULONSU.VLRTOTAL, 
                                           FI_TITULONSU.NRONOTAFISCAL, 
                                           FI_TITULONSU.NROCARTAO, 
                                           FI_TITULONSU.CONCILIADO, 
                                           FI_TITULONSU.DTACONCILIADO, 
                                           FI_TITULONSU.NOMEARQCONCILIADO, 
                                           FI_TITULONSU.TIPO, 
                                           FI_TITULONSU.ORIGEM, 
                                           FI_TITULONSU.ORIGEMATUALIZACAO)
                  VALUES(vnSeqTituloNsu,
                         vnSeqTitNovo,
                         vtnRede,
                         vtnBandeira,
                         vtdDtaMovimento,
                         vtsNsu,
                         NULL,
                         1,
                         vnVlrTotal,
                         vnVlrTotal,
                         NULL,
                         NULL,
                         'N',
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         'M');
               END IF;
               
               IF vsDesconto = 'T' THEN
                 /* Lança desconto detalhado */
                 INSERT INTO FI_TITDESCONTODETALHE
                 (SEQTITDESCONTO, SEQTITULO, LINKERP, CODOPERACAO, DTALIMITE,
                  VALOR, OBSERVACAO, DTAINCLUSAO, DTAALTERACAO, USUINCLUSAO, USUALTERACAO, ORIGEM)
                  SELECT S_SEQTITDESCONTO.NEXTVAL, vnseqTitNovo, A.LINKERP, A.CODOPERACAO, A.DTALIMITE,
                         A.VALOR - A.VALORUTILIZADO, A.OBSERVACAO, TRUNC(SYSDATE), TRUNC(SYSDATE), psUsuario, psUsuario, A.ORIGEM
                  FROM   FI_TITDESCONTODETALHE A
                  WHERE  A.SEQTITULO IN (SELECT X.SEQTITULO FROM FIX_SEQTITULOS X)
                  AND    A.SITUACAO = 'I'
                  AND    A.VALOR > A.VALORUTILIZADO;
               END IF;
               
               /* Registra o lançamento */
               FIP_GRAVALOG( 
                   'Inclusão do título ' || vnNroTitulo || ' no valor de ' || PKG_FINANCEIRO.FIF_FORMATAVALOR( vnVlrTotal ) || ' para a espécie ' || vsCodEspecieNovoTit || ' efetuado com sucesso!',
                   vnSeqTitNovo,
                   vnNroProcessoExe,
                   vnNroProcessoTit,
                   'R',
                   vsUsuario 
               );
               
               IF vsIndReplicaComprador = 'S' THEN
                  /* Inserindo compradores dos títulos quitados para o novo título */
                  FOR vtTitComp IN (
                      SELECT C.SEQTITULO,
                             C.SEQCOMPRADOR,
                             D.SEQTITULOORIGEM,
                             D.SEQTITULOBASE
                      FROM   FI_TITCOMPRADOR C,
                             FI_TITCOMPRADORDET D,
                             FIX_SEQTITULOS X
                      WHERE  C.SEQTITULO = D.SEQTITULO(+)
                      AND    C.SEQCOMPRADOR = D.SEQCOMPRADOR(+)
                      AND    C.SEQTITULO = X.SEQTITULO )
                  LOOP
                      vnCount := 0;
                      SELECT COUNT(1)
                      INTO   vnCount
                      FROM   FI_TITCOMPRADOR R
                      WHERE  R.SEQTITULO = vnSeqTitNovo
                      AND    R.SEQCOMPRADOR = vtTitComp.SEQCOMPRADOR;
                      IF vnCount = 0 THEN
                         INSERT INTO FI_TITCOMPRADOR(
                                SEQTITULO,
                                SEQCOMPRADOR,
                                VALOR,
                                INDREPLICADOR)
                         VALUES (vnSeqTitNovo,
                                vtTitComp.SEQCOMPRADOR,
                                0,
                                'S');
                      END IF;
                      IF vtTitComp.SEQTITULOORIGEM IS NULL THEN
                         vnSeqTituloOrigem := vtTitComp.SEQTITULO;
                         vnSeqTituloBase := vtTitComp.SEQTITULO;
                      ELSE
                         vnSeqTituloOrigem := vtTitComp.SEQTITULOORIGEM;
                         vnSeqTituloBase := vtTitComp.SEQTITULO;
                      END IF;
                      INSERT INTO FI_TITCOMPRADORDET(
                             SEQTITULO,
                             SEQCOMPRADOR,
                             SEQTITULOORIGEM,
                             SEQTITULOBASE)
                      VALUES (vnSeqTitNovo,
                             vtTitComp.SEQCOMPRADOR,
                             vnSeqTituloOrigem,
                             vnSeqTituloBase);
                  END LOOP;
               END IF;
               
               /* Tratamento em caso de erro dentro das procedures */
               EXCEPTION
                        WHEN OTHERS THEN
                             vbOk := FALSE;
                             FIP_GRAVALOG( 
                                 'Erro ao inserir o título ' || vnNroTitulo || ' no valor de ' || PKG_FINANCEIRO.FIF_FORMATAVALOR( vnVlrTotal ) || ' para a espécie ' || vsCodEspecieNovoTit || ' : ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                                 vnSeqTitNovo,
                                 vnNroProcessoExe,
                                 vnNroProcessoTit,
                                 'E',
                                 vsUsuario
                             );
               END;
            END IF;
         END IF;
         
         /* Dispara processo de comissão */
         IF vbOk THEN
            BEGIN
                 PKG_FINANCEIRO.FIP_COMISSAO( vnNroProcessoTit );
                 -- RC 188585
                 Fip_Calccompradortitsubst(vnNroProcessoTit, vtnNroEmpresa);
            -- Tratamento em caso de erro dentro das procedures
            EXCEPTION
                     WHEN OTHERS THEN
                          vbOk := FALSE;
                          FIP_GRAVALOG( 
                              'Erro ao executar processo de comissão para o título ' || vnNroTitulo || ' : ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                              vnSeqTitNovo,
                              vnNroProcessoExe,
                              vnNroProcessoTit,
                              'E',
                              vsUsuario
                          );
            END;
         END IF;
         
         /* Finaliza o processo de baixa e inclusão */
         IF vbOk THEN
            --
            COMMIT;
            -- Log de registro
            FIP_GRAVALOG( 
                'Agrupamento finalizado com sucesso, processo: ' || vnNroProcessoTit,
                NULL,
                vnNroProcessoExe,
                vnNroProcessoTit,
                'I',
                vsUsuario 
            );
         ELSE
            --
            ROLLBACK;
            /* Log de registro */
            FIP_GRAVALOG( 
                'Houve erros no agrupamentos dos títulos do processo: ' || vnNroProcessoTit || ' . Os lançamentos gerados serão desfeitos!',
                NULL,
                vnNroProcessoExe,
                vnNroProcessoTit,
                'I',
                vsUsuario
            );
         END IF;
     END LOOP;
     
     /* Fecha o cursor */
     CLOSE Cursor_Titulo;
     
     /* Erro geral */
     EXCEPTION
             WHEN OTHERS THEN
                  ROLLBACK;
                  --
                  FIP_GRAVALOG( 
                      'Ocorreu um erro ao executar o agrupamento automático referente ao processo : ' || vnNroProcessoExe || ' . Os lançamentos gerados serão desfeitos! : ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                      NULL,
                      vnNroProcessoExe,
                      vnNroProcessoTit,
                      'E',
                      vsUsuario
                  );
END FIP_AGRUPAUTTITULOS;

/* Baixa os títulos */
FUNCTION FIF_BAIXATITULOS( 
             pnSeqTitulo        IN  CLOB,
             pnCodOpeQuit       IN  FI_OPERACAO.CODOPERACAO%TYPE,
             pnCodOpeMulta      IN  FI_OPERACAO.CODOPERACAO%TYPE,
             pnCodOpeJuros      IN  FI_OPERACAO.CODOPERACAO%TYPE,
             pnCodOpeDesc       IN  FI_OPERACAO.CODOPERACAO%TYPE,
             pnNroEmpresaMae    IN  GE_EMPRESA.NROEMPRESA%TYPE,
             psUtilizaDesc      IN  FI_PARAMBAIXATITAUTO.DESCONTO%TYPE,
             psMultaJuros       IN  FI_PARAMBAIXATITAUTO.UTILIZAMULTAJUROS%TYPE,
             pnNroProcessoExe   IN  FI_TITOPERACAO.NROPROCESSO%TYPE,
             pnNroProcessoTit   IN  FI_TITOPERACAO.NROPROCESSO%TYPE,
             psUsuario          IN  GE_USUARIO.CODUSUARIO%TYPE,
             pnTotalBaixa       OUT FI_TITULO.VLRNOMINAL%TYPE 
          )
RETURN BOOLEAN
IS
    vbOk              BOOLEAN;
    vnValor           FI_TITULO.VLRNOMINAL%TYPE;
    vnValorTotal      FI_TITULO.VLRNOMINAL%TYPE;
    vnVlrDesconto     FI_COMPLTITULO.VLRDSCFINANC%TYPE;
    vnVlrDescontoDet  FI_COMPLTITULO.VLRDSCFINANC%TYPE;
    vnVlrMulta        FI_TITOPERACAO.VLROPERACAO%TYPE;
    vnVlrJuros        FI_TITOPERACAO.VLROPERACAO%TYPE;
    vsJurosNegocCalc  VARCHAR2(1);
    vsMultaNegocCalc  VARCHAR2(1);
    vsCancOcrQuitTit  FI_PARAMETRO.CANOCRQUITTIT%TYPE;
BEGIN
     vbOk := TRUE;
     vnValorTotal := 0;
     
     /* Gera a temporária com os títulos relacionados */
     DELETE FIX_SEQTITULOS;
     INSERT INTO FIX_SEQTITULOS(NROPROCESSO,SEQTITULO)
     SELECT pnNroProcessoExe,TO_NUMBER(COLUMN_VALUE)
     FROM   TABLE(CAST(C5_COMPLEXIN.C5INTABLECLOB(pnSeqTitulo) AS C5INCLOBTABLE));
     
     /* Consiste as espécies envolvidas */
     FOR vtConsistTit IN (SELECT DISTINCT A.CODESPECIE CODESPECIE,A.NROEMPRESA
                          FROM   FI_TITULO A,FIX_SEQTITULOS B
                          WHERE  A.SEQTITULO = B.SEQTITULO)
     LOOP
         /* Consiste a espécie e operação de quitação */
         IF vbOk THEN
            vbOk := FIF_CONSISTEESPOPER(
                        TRUNC(SYSDATE),
                        vtConsistTit.CODESPECIE,
                        pnCodOpeQuit,
                        vtConsistTit.NROEMPRESA,
                        pnNroEmpresaMae,
                        pnNroProcessoExe,
                        psUsuario 
                    );
         END IF;
         
         /* Consiste a espécie e operação de desconto */
         IF vbOk THEN
            IF psUtilizaDesc = 'Q' THEN
               vbOk := FIF_CONSISTEESPOPER(
                           TRUNC(SYSDATE),
                           vtConsistTit.CODESPECIE,
                           pnCodOpeDesc,
                           vtConsistTit.NROEMPRESA,
                           pnNroEmpresaMae,
                           pnNroProcessoExe,
                           psUsuario 
                        );
                        
               --DESCONTO DETALHADO
               /* PERCORRE TODAS AS OPERAÇÕES DOS DESCONTOS DETALHADOS DOS TITULOS SEPARANDO POR CODESPECIE QUE É O DISTINCT DO FOR EM CIMA */
               FOR vtDescDet IN (SELECT DISTINCT A.CODOPERACAO
                                 FROM   FI_TITDESCONTODETALHE A
                                 WHERE  A.SITUACAO = 'I'
                                 AND    A.VALOR > A.VALORUTILIZADO
                                 AND    A.SEQTITULO IN (SELECT X.SEQTITULO FROM FIX_SEQTITULOS X)
                                 AND    EXISTS(SELECT 1 FROM FI_TITULO Z
                                               WHERE  Z.SEQTITULO = A.SEQTITULO
                                               AND  Z.CODESPECIE = vtConsistTit.CODESPECIE )
                                 )
               LOOP
                 vbOk := FIF_CONSISTEESPOPER(
                             TRUNC(SYSDATE),
                             vtConsistTit.CODESPECIE,
                             vtDescDet.Codoperacao,
                             vtConsistTit.NROEMPRESA,
                             pnNroEmpresaMae,
                             pnNroProcessoExe,
                             psUsuario 
                         );
                         
                 /* Força saída do loop se encontrar um erro */
                 EXIT WHEN NOT vbOk;
               END LOOP;
            END IF;
         END IF;
         
         /* Consiste a espécie e operação de Multa */
         IF vbOk THEN
            IF psMultaJuros = 'S' THEN
               vbOK := FIF_CONSISTEESPOPER(
                           TRUNC(SYSDATE),
                           vtConsistTit.CODESPECIE,
                           pnCodOpeMulta,
                           vtConsistTit.NROEMPRESA,
                           pnNroEmpresaMae,
                           pnNroProcessoExe,
                           psUsuario 
                       );
            END IF;
         END IF;
         
         /* Consiste a espécie e operação de Juros */
         IF vbOk THEN
            IF psMultaJuros = 'S' THEN
               vbOK := FIF_CONSISTEESPOPER(
                           TRUNC(SYSDATE),
                           vtConsistTit.CODESPECIE,
                           pnCodOpeJuros,
                           vtConsistTit.NROEMPRESA,
                           pnNroEmpresaMae,
                           pnNroProcessoExe,
                           psUsuario 
                       );
            END IF;
         END IF;
         
         /* Força saída do loop se encontrar um erro */
         EXIT WHEN NOT vbOk;
     END LOOP;
     
     /* Faz os lançamentos */
     IF vbOk THEN
        -- Busca os títulos
        FOR vtQuitaTit IN (SELECT A.SEQTITULO,
                                  A.CODESPECIE,
                                  A.NROEMPRESA,
                                  A.NROTITULO || '-' || A.SERIETITULO || '/' || A.NROPARCELA TITULO,
                                  NVL(A.VLRNOMINAL - A.VLRPAGO,0) VLRABERTO
                           FROM   FI_TITULO A, FIX_SEQTITULOS B
                           WHERE  A.SEQTITULO = B.SEQTITULO
                           ORDER  BY A.NROEMPRESA, A.CODESPECIE)
        LOOP
            /* Verifica se cancela ocorrência de atraso */
            SELECT NVL(C.CANOCRQUITTIT,'N')
            INTO   vsCancOcrQuitTit
            FROM   FI_PARAMETRO C
            WHERE  C.NROEMPRESA = vtQuitaTit.NROEMPRESA;
            
            /* Log de registro */
            FIP_GRAVALOG( 
                'Inicio da baixa do título ' || vtQuitaTit.TITULO,
                vtQuitaTit.SEQTITULO,
                pnNroProcessoExe,
                pnNroProcessoTit,
                'R',
                psUsuario 
            );
            
            /* Valor a pagar/receber */
            vnValor := vtQuitaTit.VLRABERTO;
            
            /* Calcula o desconto */
            IF vbOk THEN
               IF psUtilizaDesc = 'Q' THEN
                  BEGIN
                       vnVlrDesconto := NVL(PKG_FINANCEIRO.FIF_DESCONTO(vtQuitaTit.SEQTITULO, TRUNC(SYSDATE), 'S'), 0);
                       vnVlrDescontoDet := NVL(PKG_FINANCEIRO.FIF_DESCONTO(vtQuitaTit.SEQTITULO, TRUNC(SYSDATE), 'D'), 0);
                  EXCEPTION
                           WHEN OTHERS THEN
                                vbOk := FALSE;
                                FIP_GRAVALOG(
                                    'Erro no cálculo do desconto do título ' || vtQuitaTit.TITULO || ' sequencial do título ' || vtQuitaTit.SEQTITULO || ' : ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                                    vtQuitaTit.SEQTITULO,
                                    pnNroProcessoExe,
                                    pnNroProcessoTit,
                                    'E',
                                    psUsuario 
                                );
                  END;
               END IF;
            END IF;
            
            /* Calcula a multa e o juros */
            IF vbOk THEN
               IF psMultaJuros = 'S' THEN
                  BEGIN
                       PKG_FINANCEIRO.FIP_CALCULAMULTAJUROS( 
                                          vtQuitaTit.SEQTITULO,
                                          TRUNC(SYSDATE),
                                          'P',
                                          vnVlrJuros,
                                          vnVlrMulta,
                                          vsJurosNegocCalc,
                                          vsMultaNegocCalc 
                                       );
                       vnVlrMulta := NVL(vnVlrMulta,0);
                       vnVlrJuros := NVL(vnVlrJuros,0);
                  EXCEPTION
                           WHEN OTHERS THEN
                                vbOk := FALSE;
                                FIP_GRAVALOG( 
                                    'Erro no cálculo de multa e juros do título ' || vtQuitaTit.TITULO || ' sequencial do título ' || vtQuitaTit.SEQTITULO || ' : ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                                    vtQuitaTit.SEQTITULO,
                                    pnNroProcessoExe,
                                    pnNroProcessoTit,
                                    'E',
                                    psUsuario 
                                 );
                  END;
               END IF;
            END IF;
            
            /* Quita o título */
            IF vbOk THEN
               vnValor := vnValor - NVL(vnVlrDesconto,0) - NVL(vnVlrDescontoDet, 0);
               IF vnValor > 0 THEN
                  vbOk := FIF_LANCAOPERACAO( 
                              pnCodOpeQuit,
                              vtQuitaTit.SEQTITULO,
                              pnNroEmpresaMae,
                              vtQuitaTit.NROEMPRESA,
                              vnValor,
                              pnNroProcessoExe,
                              pnNroProcessoTit,
                              psUsuario,
                              vsCancOcrQuitTit,
                              NULL 
                          );
                  -- Registra o lançamento
                  IF vbOk THEN
                     FIP_GRAVALOG( 
                         'Operação de quitação ' || pnCodOpeQuit || ' no valor de ' || PKG_FINANCEIRO.FIF_FORMATAVALOR( vnValor ) || ' para o título ' || vtQuitaTit.TITULO || ' lançada com sucesso!',
                         vtQuitaTit.SEQTITULO,
                         pnNroProcessoExe,
                         pnNroProcessoTit,
                         'R',
                         psUsuario 
                     );
                  END IF;
               ELSE
                  vnValor := 0;
               END IF;
            END IF;
            
            /* Lança a multa */
            IF vbOk THEN
               IF vnVlrMulta > 0 THEN
                  vbOk := FIF_LANCAOPERACAO( 
                              pnCodOpeMulta,
                              vtQuitaTit.SEQTITULO,
                              pnNroEmpresaMae,
                              vtQuitaTit.NROEMPRESA,
                              vnVlrMulta,
                              pnNroProcessoExe,
                              pnNroProcessoTit,
                              psUsuario,
                              vsCancOcrQuitTit,
                              NULL 
                           );
                  -- Registra o lançamento
                  IF vbOk THEN
                     FIP_GRAVALOG( 
                         'Operação de multa ' || pnCodOpeMulta || ' no valor de ' || PKG_FINANCEIRO.FIF_FORMATAVALOR( vnVlrMulta ) || ' para o título ' || vtQuitaTit.TITULO || ' lançada com sucesso!',
                         vtQuitaTit.SEQTITULO,
                         pnNroProcessoExe,
                         pnNroProcessoTit,
                         'R',
                         psUsuario 
                     );
                  END IF;
               ELSE
                  vnVlrMulta := 0;
               END IF;
            END IF;
            
            /* Lança os juros */
            IF vbOk THEN
               IF vnVlrJuros > 0 THEN
                  vbOk := FIF_LANCAOPERACAO( 
                              pnCodOpeJuros,
                              vtQuitaTit.SEQTITULO,
                              pnNroEmpresaMae,
                              vtQuitaTit.NROEMPRESA,
                              vnVlrJuros,
                              pnNroProcessoExe,
                              pnNroProcessoTit,
                              psUsuario,
                              vsCancOcrQuitTit,
                              NULL 
                          );
                          
                  /* Registra o lançamento */
                  IF vbOk THEN
                     FIP_GRAVALOG( 
                         'Operação de juros ' || pnCodOpeJuros || ' no valor de ' || PKG_FINANCEIRO.FIF_FORMATAVALOR( vnVlrJuros ) || ' para o título ' || vtQuitaTit.TITULO || ' lançada com sucesso!',
                         vtQuitaTit.SEQTITULO,
                         pnNroProcessoExe,
                         pnNroProcessoTit,
                         'R',
                         psUsuario 
                     );
                  END IF;
               ELSE
                  vnVlrJuros := 0;
               END IF;
            END IF;
            
            /* Lança o desconto */
            IF vbOk THEN
               IF vnVlrDesconto > 0 THEN
                  vbOk := FIF_LANCAOPERACAO( 
                              pnCodOpeDesc,
                              vtQuitaTit.SEQTITULO,
                              pnNroEmpresaMae,
                              vtQuitaTit.NROEMPRESA,
                              vnVlrDesconto,
                              pnNroProcessoExe,
                              pnNroProcessoTit,
                              psUsuario,
                              vsCancOcrQuitTit,
                              NULL 
                          );
                          
                  /* Registra o lançamento */
                  IF vbOk THEN
                     FIP_GRAVALOG( 
                         'Operação de desconto ' || pnCodOpeDesc || ' no valor de ' || PKG_FINANCEIRO.FIF_FORMATAVALOR( vnVlrDesconto ) || ' para o título ' || vtQuitaTit.TITULO || ' lançada com sucesso!',
                         vtQuitaTit.SEQTITULO,
                         pnNroProcessoExe,
                         pnNroProcessoTit,
                         'R',
                         psUsuario 
                     );
                  END IF;
               ELSE
                  vnVlrDesconto := 0;
               END IF;
               
               /* Lança Desconto Detalhado */
               IF vbOK THEN
                 IF vnVlrDescontoDet > 0 THEN
                    FOR vtDescDet IN (SELECT A.SEQTITDESCONTO, A.CODOPERACAO, (A.VALOR - A.VALORUTILIZADO) VLRDISPONIVEL
                                      FROM   FI_TITDESCONTODETALHE A, FI_TITULO B
                                      WHERE  A.SEQTITULO = B.SEQTITULO
                                      AND    A.SEQTITULO = vtQuitaTit.SEQTITULO
                                      AND    A.SITUACAO = 'I'
                                      AND    A.VALOR > A.VALORUTILIZADO
                                      AND    (A.DTALIMITE IS NULL OR FIF_DATAUTIL(A.DTALIMITE, B.SEQPESSOA, 0, 0, 'P', B.NROEMPRESA) >= TRUNC(SYSDATE)))
                    LOOP
                         vbOk := FIF_LANCAOPERACAO( 
                                     vtDescDet.CODOPERACAO,
                                     vtQuitaTit.SEQTITULO,
                                     pnNroEmpresaMae,
                                     vtQuitaTit.NROEMPRESA,
                                     vtDescDet.VLRDISPONIVEL,
                                     pnNroProcessoExe,
                                     pnNroProcessoTit,
                                     psUsuario,
                                     vsCancOcrQuitTit,
                                     vtDescDet.Seqtitdesconto 
                                 );
                                 
                         /* Registra o lançamento */
                         IF vbOk THEN
                            FIP_GRAVALOG( 
                                'Operação de desconto detalhado ' || vtDescDet.CODOPERACAO || ' no valor de ' || PKG_FINANCEIRO.FIF_FORMATAVALOR( vtDescDet.VLRDISPONIVEL ) || ' para o título ' || vtQuitaTit.TITULO || ' lançada com sucesso!',
                                vtQuitaTit.SEQTITULO,
                                pnNroProcessoExe,
                                pnNroProcessoTit,
                                'R',
                                psUsuario 
                            );
                         END IF;
                         
                         /* Força saída do loop se encontrar um erro */
                         EXIT WHEN NOT vbOk;
                    END LOOP;
                 ELSE
                    vnVlrDescontoDet := 0;
                 END IF;
               END IF;
            END IF;
            
            /* Log de registro e valor para retorno */
            IF vbOk THEN
               FIP_GRAVALOG( 
                   'Baixa do título ' || vtQuitaTit.TITULO || ' finalizada.',
                   vtQuitaTit.SEQTITULO,
                   pnNroProcessoExe,
                   pnNroProcessoTit,
                   'R',
                   psUsuario 
               );
               
               /* Soma todos os valores lançados pois será o valor do novo título */
               vnValorTotal := vnValorTotal + vnValor + vnVlrMulta + vnVlrJuros;
            ELSE
               FIP_GRAVALOG( 
                   'Baixa do título ' || vtQuitaTit.TITULO || ' sequencial do título ' || vtQuitaTit.SEQTITULO || ' não realizada.',
                   vtQuitaTit.SEQTITULO,
                   pnNroProcessoExe,
                   pnNroProcessoTit,
                   'R',
                   psUsuario 
               );
               
               pnTotalBaixa := 0;
            END IF;
        END LOOP;
     END IF;
     
     /* Retorno */
     pnTotalBaixa := vnValorTotal;
     RETURN(vbOk);
END FIF_BAIXATITULOS;

/* Faz o lançamento das operações */
FUNCTION FIF_LANCAOPERACAO( 
             pnCodOperacao    IN  FI_OPERACAO.CODOPERACAO%TYPE,
             pnSeqTitulo      IN  FI_TITULO.SEQTITULO%TYPE,
             pnNroEmpresaMae  IN  GE_EMPRESA.NROEMPRESA%TYPE,
             pnNroEmpresa     IN  GE_EMPRESA.NROEMPRESA%TYPE,
             pnValor          IN  FI_TITOPERACAO.VLROPERACAO%TYPE,
             pnNroProcessoExe IN  FI_LOGBAIXATITAUTO.NROPROCESSOEXE%TYPE,
             pnNroProcessoTit IN  FI_TITOPERACAO.NROPROCESSO%TYPE,
             psUsuario        IN  GE_USUARIO.CODUSUARIO%TYPE,
             psCanOcrQuitTit  IN  FI_PARAMETRO.CANOCRQUITTIT%TYPE,
             pnSeqTitDesconto IN  FI_TITOPERACAO.SEQTITDESCONTO%TYPE 
         )
RETURN BOOLEAN
IS
  vnSeqTitOperacao        FI_TITOPERACAO.SEQTITOPERACAO%TYPE;
  vbOk                    BOOLEAN;
  vsAbertoQuitadoDep      FI_TITULO.ABERTOQUITADO%TYPE;
  vnTemTela               INTEGER;
BEGIN
     vbOk := TRUE;
     vnTemTela := 0;
     PKG_FINANCEIRO.FIP_BUSCASEQFI(vnSeqTitOperacao);
     
     /* Lança a operação */
     PKG_FINANCEIRO.FIP_TITOPERACAO( 
                        pnCodOperacao,
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
                        Null 
                    );
     IF pnSeqTitDesconto IS NOT NULL THEN
        --RC 121930
        /* Atualiza a coluna SEQTITDESCONTO da tabela FI_TITOPERACAO. */
        UPDATE FI_TITOPERACAO A
        SET 	  A.SEQTITDESCONTO = pnSeqTitDesconto
        WHERE  A.SEQTITOPERACAO = vnSeqTitOperacao;
        
        /* Atualiza a coluna VALORUTILIZADO da tabela FI_TITDESCONTODETALHE. */
        UPDATE FI_TITDESCONTODETALHE A
        SET    A.VALORUTILIZADO = A.VALORUTILIZADO + NVL(pnValor,0)
        WHERE  A.SEQTITDESCONTO = pnSeqTitDesconto;
     END IF;
     
     /* Contabiliza */
     PKG_FINANCEIRO.FIP_CONTABILIZA( 
                        vnSeqTitOperacao,
                        'TIT',
                        psUsuario,
                        TRUNC(SYSDATE),
                        pnNroEmpresaMae,
                        pnNroEmpresa,
                        vnTemTela,
                        pnNroProcessoTit 
                    );
                    
     /* Verifica se o lançamento quitou o título */
     SELECT A.ABERTOQUITADO
     INTO   vsAbertoQuitadoDep
     FROM   FI_TITULO A
     WHERE  A.SEQTITULO = pnSeqTitulo;
     
     /* Cancela ocorrência de atraso se o título for quitado e estiver parametrizado */
     IF vsAbertoQuitadoDep = 'Q' AND psCanOcrQuitTit = 'S' Then
        PKG_FINANCEIRO.FIP_BLOQUEIOCREDITO(pnSeqTitulo, psUsuario);
     END IF;
     
     /* Retorno */
     RETURN(vbOk);
     
     /* Tratamento em caso de erro dentro das procedures */
     EXCEPTION
              WHEN OTHERS THEN
                   vbOk := FALSE;
                   FIP_GRAVALOG( 
                       'Erro no lançamento da operação ' || pnCodOperacao || ' no valor de ' || PKG_FINANCEIRO.FIF_FORMATAVALOR( pnValor ) || ' para o sequencial do título ' || pnSeqTitulo || ' : ' || SQLERRM || ' - ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
                       pnSeqTitulo,
                       pnNroProcessoExe,
                       pnNroProcessoTit,
                       'E',
                       psUsuario 
                   );
                   --
                   RETURN(vbOk);
END FIF_LANCAOPERACAO;

/* Gera o número da empresa */
FUNCTION FIF_RETORNAEMPRESA( psEmpresasAgrupadas IN CLOB,
                             pnNroEmpresaMae     IN GE_EMPRESA.NROEMPRESA%TYPE,
                             psEmpresaGeradora   IN FI_PARAMBAIXATITAUTO.EMPRESAGERACAO%TYPE )
RETURN NUMBER
IS
   vnRetorno      GE_EMPRESA.NROEMPRESA%TYPE;
BEGIN
     -- Valor padrão
     vnRetorno := pnNroEmpresaMae;
     -- Busca o número da empresa que tem mais títulos envolvidos
     IF psEmpresaGeradora = 'N' THEN
        SELECT A.EMPRESA
        INTO   vnRetorno
        FROM   ( SELECT TO_NUMBER(COLUMN_VALUE) EMPRESA,
                        COUNT(1)                QUANTIDADE
                 FROM   TABLE( CAST( C5_COMPLEXIN.C5INTABLECLOB( psEmpresasAgrupadas ) AS C5INCLOBTABLE ) )
                 GROUP  BY TO_NUMBER(COLUMN_VALUE)
                 ORDER  BY QUANTIDADE DESC,
                           EMPRESA ) A
       WHERE   ROWNUM = 1;
     END IF;
     RETURN(vnRetorno);
     EXCEPTION
              WHEN OTHERS THEN
                   RETURN pnNroEmpresaMae;
END FIF_RETORNAEMPRESA;

/* Gera o número do novo título */
FUNCTION FIF_RETORNANROTITULO( psNroTitulosAgrupados IN CLOB,
                               pdDtaVencimento       IN FI_TITULO.DTAVENCIMENTO%TYPE,
                               psNumeroGeracao       IN FI_PARAMBAIXATITAUTO.NUMEROGERACAO%TYPE )
RETURN NUMBER
IS
  vnRetorno FI_TITULO.NROTITULO%TYPE;
BEGIN
     -- Valor padrão
     vnRetorno := TO_NUMBER(TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY'));
     -- Verifica se o número do título será gerado pelo vencimento
     IF psNumeroGeracao = 'V' THEN
        vnRetorno := TO_NUMBER(TO_CHAR(pdDtaVencimento,'DDMMYYYY'));
     ELSE
     -- Busca o número que mais se repete para usá-lo
        SELECT NVL(A.NUMERO,0)
        INTO   vnRetorno
        FROM   ( SELECT TO_NUMBER(COLUMN_VALUE) NUMERO,
                        COUNT(1)                QUANTIDADE
                 FROM   TABLE( CAST( C5_COMPLEXIN.C5INTABLECLOB( psNroTitulosAgrupados ) AS C5INCLOBTABLE ) )
                 GROUP  BY TO_NUMBER(COLUMN_VALUE)
                 ORDER  BY QUANTIDADE DESC,
                           NUMERO ) A
        WHERE ROWNUM = 1;
     END IF;
     RETURN(vnRetorno);
     EXCEPTION
              WHEN OTHERS THEN
                   RETURN TO_NUMBER(TO_CHAR(TRUNC(SYSDATE),'DDMMYYYY'));
END FIF_RETORNANROTITULO;

/* Gera data do desconto do novo título */
FUNCTION FIF_RETORNADTALIMDESC( psDtaLimDescFin       IN CLOB,
                                pdDtaVencimento       IN FI_TITULO.DTAVENCIMENTO%TYPE,
                                psParamUsaDesconto    IN FI_PARAMBAIXATITAUTO.DESCONTO%TYPE,
                                psParamDataLimiteDesc IN FI_PARAMBAIXATITAUTO.DATALIMITEDESC%TYPE )
RETURN DATE
IS
  vdRetorno FI_COMPLTITULO.DTALIMDSCFINANC%TYPE;
BEGIN
     -- Valor padrão
     vdRetorno := NULL;
     -- Verifica se irá transportar o desconto
     IF psParamUsaDesconto = 'T' THEN
        IF psParamDataLimiteDesc = 'T' THEN
           -- Maior data
           SELECT MAX(TO_DATE(COLUMN_VALUE, 'DD/MM/YYYY'))
           INTO   vdRetorno
           FROM   TABLE( CAST( C5_COMPLEXIN.C5INTABLECLOB( psDtaLimDescFin ) AS C5INCLOBTABLE ) );
        ELSIF psParamDataLimiteDesc = 'M' THEN
           -- Média de datas
           -- ( Regra : Encontra a maior data e a menor data, extrai a quantidade de dias entre elas, divide por dois e aplica a menor data )
           SELECT MIN(TO_DATE(COLUMN_VALUE, 'DD/MM/YYYY')) + ROUND(TO_NUMBER(MAX(TO_DATE(COLUMN_VALUE, 'DD/MM/YYYY')) - MIN(TO_DATE(COLUMN_VALUE, 'DD/MM/YYYY'))) / 2,0)
           INTO   vdRetorno
           FROM   TABLE( CAST( C5_COMPLEXIN.C5INTABLECLOB( psDtaLimDescFin ) AS C5INCLOBTABLE ) );
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
FUNCTION FIF_CONSISTEESPOPER(
         pdDtaContabil     IN FI_TITOPERACAO.DTACONTABILIZA%TYPE,
         psCodEspecie      IN FI_ESPECIE.CODESPECIE%TYPE,
         pnCodOperacao     IN FI_OPERACAO.CODOPERACAO%TYPE,
         pnNroEmpresa      IN GE_EMPRESA.NROEMPRESA%TYPE,
         pnNroEmpresaMae   IN GE_EMPRESA.NROEMPRESA%TYPE,
         pnNroProcessoExe  IN FI_LOGBAIXATITAUTO.NROPROCESSOEXE%TYPE,
         psUsuario         IN GE_USUARIO.CODUSUARIO%TYPE )
RETURN BOOLEAN
IS
       vbOk        BOOLEAN;
       vsMsg       FI_LOGBAIXATITAUTO.DESCRICAO%TYPE;
BEGIN
     vbOk := PKG_FINANCEIRO.FIF_CONSISTEESPOPER(
                                pdDtaContabil,
                                psCodEspecie,
                                pnCodOperacao,
                                pnNroEmpresa,
                                pnNroEmpresaMae,
                                psUsuario,
                                'B',
                                'N',
                                'N',
                                vsMsg
                            );
                            
     /* Se houve erro gera o log */
     IF NOT vbOk THEN
        FIP_GRAVALOG(  
            vsMsg,
            NULL,
            pnNroProcessoExe,
            NULL,
            'E',
            psUsuario 
        );
     END IF;
     
     /* Retorno */
     RETURN(vbOk);
END FIF_CONSISTEESPOPER;

/* Gera Log */
PROCEDURE FIP_GRAVALOG( psMensagem       IN FI_LOGBAIXATITAUTO.DESCRICAO%TYPE,
                        pnSeqTitulo      IN FI_TITULO.SEQTITULO%TYPE,
                        pnNroProcessoExe IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                        pnNroProcessoTit IN FI_TITOPERACAO.NROPROCESSO%TYPE,
                        psCategoria      IN FI_LOGBAIXATITAUTO.CATEGORIA%TYPE,
                        psUsuario        IN GE_USUARIO.CODUSUARIO%TYPE )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
     -- Tipos de categorias
     -- I - INFORMATIVO - Informa o que foi executado, inicio e fim de cada processo.
     -- R - REGISTRO - Registra um processamento efetuado, inclusão, quitação, operações.
     -- E - ERRO - Erro ocorrido. No caso de erro os lançamentos serão desfeitos e os logs do tipo R serão apagados.
     INSERT INTO FI_LOGBAIXATITAUTO( SEQLOG,
                                     DATAHORA,
                                     DATA,
                                     USUARIO,
                                     DESCRICAO,
                                     SEQTITULO,
                                     NROPROCESSOEXE,
                                     NROPROCESSOTIT,
                                     CATEGORIA )
     VALUES ( S_FILOGBAIXATITAUTO.NEXTVAL,
              SYSDATE,
              TRUNC(SYSDATE),
              psUsuario,
              SUBSTR(psMensagem, 1, 500),
              pnSeqTitulo,
              pnNroProcessoExe,
              pnNroProcessoTit,
              psCategoria );
     -- Apaga os logs de registro de lançamentos em caso de erro
     IF psCategoria = 'E' AND pnNroProcessoTit IS NOT NULL THEN
        DELETE FI_LOGBAIXATITAUTO A
        WHERE  A.CATEGORIA = 'R'
        AND    A.NROPROCESSOTIT = pnNroProcessoTit;
     END IF;
     -- Faz o commit por usar o pragma
     COMMIT;
END FIP_GRAVALOG;

/* Monta a data de vencimento do Título agrupado */
FUNCTION FIF_DTAVENCIMENTO  ( pdFechamento      IN  DATE,
                              pdVencimento      IN  FI_TITULO.DTAVENCIMENTO%TYPE,
                              pnSeqPessoa       IN  FI_TITULO.SEQPESSOA%TYPE,
                              psObrigDireito    IN  FI_TITULO.OBRIGDIREITO%TYPE )
RETURN DATE
IS
  vsIndUsaPeriodoAgrupauto    FI_FORNECEDOR.INDUSAPERIODOAGRUPAUTO%TYPE;
  vdRetorno                   DATE;
BEGIN
  IF psObrigDireito = 'O' THEN
    SELECT NVL(A.INDUSAPERIODOAGRUPAUTO, 'N')
    INTO   vsIndUsaPeriodoAgrupauto
    FROM   FI_FORNECEDOR A
    WHERE  A.SEQPESSOA = pnSeqPessoa;
  ELSE
    SELECT NVL(A.INDUSAPERIODOAGRUPAUTO, 'N')
    INTO   vsIndUsaPeriodoAgrupauto
    FROM   FI_CLIENTE A
    WHERE  A.SEQPESSOA = pnSeqPessoa;
  END IF;
  --SE USA PERIODO PARA AGRUPAMENTO
  IF vsIndUsaPeriodoAgrupauto = 'N' THEN
    vdRetorno := pdVencimento;
  ELSE
    BEGIN
    SELECT PKG_FIAGRUPATITAUTO_cadan.FIF_MONTADATA(A.DIAVENC,
                                             A.MESVENC,
                                             EXTRACT(MONTH FROM pdFechamento),
                                             EXTRACT(YEAR FROM pdFechamento),
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
FUNCTION FIF_MONTADATA  ( pnDia         IN  FI_PERIODOAGRUPAUTO.DIAINI%TYPE,
                          pnMes         IN  FI_PERIODOAGRUPAUTO.MESINI%TYPE,
                          pnMesExe      IN  FI_PERIODOAGRUPAUTO.MESEXE%TYPE,
                          pnAnoExe      IN  NUMBER,
                          psTipo        IN  VARCHAR ) -- P - Periodo   V - Vencimento
RETURN DATE
IS
  vdRetorno   DATE;
  vnAno       NUMBER;
  vnDia       NUMBER;
  vbBissexto  BOOLEAN;
BEGIN
  vnAno := pnAnoExe;
  vnDia  := pnDia;
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
    vbBissexto := (MOD(vnAno, 4) = 0 AND (MOD(vnAno, 400) = 0 OR MOD(vnAno, 100) != 0));
    --SE NÃO FOR BISSEXTO joga o dia como 28
    IF NOT vbBissexto THEN
      vnDia := 28;
    END IF;
  END IF;
  vdRetorno := TO_DATE(vnDia || '/' || pnMes || '/' || vnAno, 'DD/MM/YYYY');
  RETURN vdRetorno;
END FIF_MONTADATA;

/* Duplica Periodo */
PROCEDURE FIP_DUPLICARPERIODO( pnSeqPessoa       IN FI_PERIODOAGRUPAUTO.SEQPESSOA%TYPE,
                               psObrigdireito    IN FI_PERIODOAGRUPAUTO.OBRIGDIREITO%TYPE,
                               pnSeqPessoaDup    IN FI_PERIODOAGRUPAUTO.SEQPESSOA%TYPE,
                               psObrigdireitoDup IN FI_PERIODOAGRUPAUTO.OBRIGDIREITO%TYPE,
                               psUsuario         IN FI_PERIODOAGRUPAUTO.USUALTERACAO%TYPE )
IS
BEGIN
  /* DELETA PERIODO DA PESSOA QUE VAI DUPLICAR */
  DELETE FROM FI_PERIODOAGRUPAUTO
   WHERE SEQPESSOA = pnSeqPessoaDup
     AND OBRIGDIREITO = psObrigdireitoDup;
  --INSERE PERIODO
  INSERT INTO FI_PERIODOAGRUPAUTO
  (SEQPERIODO, SEQPESSOA, OBRIGDIREITO, DIAINI, MESINI, DIAFIM,
   MESFIM, DIAEXE, MESEXE, DIAVENC, MESVENC, USUALTERACAO)
  SELECT S_FILOGBAIXATITAUTO.NEXTVAL, pnSeqPessoaDup, psObrigdireitoDup, A.DIAINI, A.MESINI, A.DIAFIM,
         A.MESFIM, A.DIAEXE, A.MESEXE, A.DIAVENC, A.MESVENC, psUsuario
    FROM FI_PERIODOAGRUPAUTO A
   WHERE SEQPESSOA = pnSeqPessoa
     AND OBRIGDIREITO = psObrigdireito;
END FIP_DUPLICARPERIODO;
END PKG_FIAGRUPATITAUTO_cadan;
/

SELECT a.*
FROM implantacao.edi_pedvenda a
WHERE a.usuinclusao = 'AFV'
--AND a.statuspedido != 'F'
AND a.seqedipedvenda >= 50852790
ORDER BY 1 DESC
--FOR UPDATE;

SELECT a.*
FROM implantacao.edi_pedvendaitem a
INNER JOIN implantacao.edi_pedvenda b 
ON b.seqedipedvenda = a.seqedipedvenda AND b.usuinclusao = 'AFV'
WHERE 1 = 1
AND a.seqedipedvenda = 50852842
ORDER BY 1 ASC
--FOR UPDATE;

SELECT nropedvenda,a.seqpessoa,a.nropedidoafv,a.codsistemaafv,a.dtaalteracao,a.dtahorsituacaopedalt,a.situacaoped,a.obspedido,a.obsnotafiscal
FROM implantacao.mad_pedvenda a
WHERE 1=1
--AND a.usuinclusao = 'AFV'
AND a.nropedvenda BETWEEN 4158693 AND 4158693
--AND a.dtahorsituacaopedalt >= TRUNC(ADD_MONTHS(SYSDATE,0),'DD')
ORDER BY 1 DESC
--FOR UPDATE;

SELECT a.*--a.seqproduto,a.qtdcortewm,a.qtdpedida,a.qtdcorteestq,b.dtaalteracao,b.dtahorsituacaopedalt
FROM implantacao.mad_pedvendaitem a
INNER JOIN implantacao.mad_pedvenda b 
ON b.nropedvenda = a.nropedvenda --AND b.usuinclusao = 'AFV'
WHERE 1 = 1
AND a.nropedvenda = 4158693
ORDER BY 1 ASC
--FOR UPDATE


SELECT b.*
FROM implantacao.edi_pedvenda a
INNER JOIN implantacao.max_logalteracao b
ON b.seqidentifica = a.seqedipedvenda
AND b.usualteracao = 'USUARIOAD'
WHERE 1 = 1
AND a.usuinclusao = 'AFV'
--AND a.statuspedido = 'R'
--AND a.codsistemaafv = 1866
--AND a.nropedidoafv = 276
ORDER BY 1 DESC
2462508

--UPDATE implantacao.edi_pedvenda a SET a.statuspedido = 'F' WHERE a.seqedipedvenda = 2462581
--UPDATE implantacao.mad_pedvenda a SET a.dtaalteracao = '20-Jul-2023' WHERE a.nropedvenda IN (4069808,4069820,4069821)

--SELECT MAX(seqedipedvenda) seqedipedvenda FROM IMPLANTACAO.edi_pedvenda WHERE CODGERALOPER IN (201,207,314)

--DELETE implantacao.edi_pedvenda WHERE seqedipedvenda IN (2462580,2462581,2462582)
--DELETE implantacao.edi_pedvendaitem WHERE seqedipedvenda IN (2462580,2462581,2462582)
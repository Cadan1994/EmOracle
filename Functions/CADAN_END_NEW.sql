CREATE OR REPLACE FUNCTION POLIBRAS.cadan_end(codpedi polibras_observacao.codigo_pedido%TYPE)
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
-- Essa função pega o código de endereço do cliente para entrega no campo "seqpessoaend" da tabela "mad_clienteend" --
-- OBSERVAÇÃO: Essa função foi alterada por HILSON SANTOS no dia 19-10-2023                                         --
--//////////////////////////////////////////////////////////////////////////////////////////////////////////////////--
RETURN NUMBER IS
    vsCodAcesso IMPLANTACAO.mad_clienteend.seqpessoaend%TYPE;

BEGIN
    SELECT c.seqpessoaend
    INTO vsCodAcesso
    FROM POLIBRAS.polibras_pedcab2 a
    INNER JOIN POLIBRAS.polibras_observacao b 
    ON b.codigo_pedido = a.codigo_pedido 
    AND b.indice = 7
    INNER JOIN IMPLANTACAO.mad_clienteend c 
    ON c.seqpessoa = a.codigo_cliente 
    AND TO_NUMBER(LTRIM(SUBSTR(b.valor,1,INSTR(b.valor,'-')-1))) = c.seqpessoaend
    WHERE a.codigo_pedido = codpedi;
    
    /*
    SELECT max(C.SEQPESSOAEND)
    INTO vsCodAcesso
    FROM POLIBRAS_PEDCAB2 A
  
    INNER JOIN POLIBRAS_OBSERVACAO B
      ON (A.CODIGO_PEDIDO = B.CODIGO_PEDIDO AND b.indice = 7)
  
    INNER JOIN IMPLANTACAO.MAD_CLIENTEEND C
      ON (A.CODIGO_CLIENTE = C.SEQPESSOA AND
         decode(e_numero(to_char(LPAD(b.VALOR, 1))),
                 0,
                 0,
                 TO_NUMBER(LPAD(B.VALOR, 1))) = C.SEQPESSOAEND)
    WHERE A.CODIGO_PEDIDO = codpedi;
    */
    
    RETURN vsCodAcesso;

END cadan_end;

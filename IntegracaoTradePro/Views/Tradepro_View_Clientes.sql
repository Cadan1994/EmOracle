CREATE OR REPLACE VIEW implantacao.Tradepro_View_Clientes AS
SELECT 
		DISTINCT
    CASE
    WHEN b.fisicajuridica = 'F'
    THEN CONCAT(LPAD(b.nrocgccpf, 9, '0'),LPAD(b.digcgccpf, 2, '0'))
    ELSE CONCAT(LPAD(b.nrocgccpf, 12, '0'),LPAD(b.digcgccpf, 2, '0'))
    END AS cnpj,
		a.seqpessoa AS codigo,
		b.nomerazao AS razaosocial,
		b.fantasia,
		CASE
		WHEN b.cmpltologradouro IS NOT NULL 
		THEN b.logradouro || ', ' || b.nrologradouro || ', ' || b.cmpltologradouro
		ELSE b.logradouro || ', ' || b.nrologradouro
		END AS endereco,
		b.uf,
		b.cidade,
		b.bairro,
		b.cep,
		0 as longitude,
		0 as latitude,
		NVL(NVL(b.foneddd1 || ' ' || b.fonenro1, b.foneddd2 || ' ' || b.fonenro2), b.foneddd3 || ' ' || b.fonenro3) AS telefone,
		TRIM(
		CASE
		WHEN b.fonecmpl2 IS NOT NULL
		THEN b.fonecmpl1 || ' ' || b.fonecmpl2
		WHEN b.fonecmpl3 IS NOT NULL
		THEN b.fonecmpl1 || ' ' || b.fonecmpl2 || ' ' || b.fonecmpl3
		ELSE b.fonecmpl1
		END) AS contato,
		b.email,
		TO_CHAR(b.dtanascfund, 'DD/MM/YYYY') AS aniversario,
		1 AS cod_representante,
		'PADRAO' AS nome_representante,
		TO_CHAR(NVL(e.seqrede, 0)) AS cod_rede,
		REPLACE(REPLACE(REPLACE(d.lista,' ',''),'/',''),'-','') AS cod_ramo_atividade,
		b.atividade AS desc_ramo_atividade
FROM implantacao.mrl_cliente a
INNER JOIN implantacao.ge_pessoa b ON b.seqpessoa = a.seqpessoa AND b.status = 'A'
INNER JOIN implantacao.mrl_clienteseg c ON c.seqpessoa = b.seqpessoa AND c.nrosegmento IN (1,3,4,5,6,7,8,9,10) AND c.status = 'A'
INNER JOIN implantacao.ge_atributofixo d ON d.lista = b.atividade AND d.atributo = 'ATIVIDADE'
LEFT JOIN implantacao.ge_redepessoa e ON e.seqpessoa = a.seqpessoa 
WHERE 1=1
AND a.seqpessoa NOT IN (1, 22401)
AND a.statuscliente = 'A'
ORDER BY 2 ASC 

/*******************************************************************************************************************************/
/* CRIADO POR HILSON SANTOS 19/12/2024																																												 */
/* LOCAL: P:\EmOracle\IntegracaoTradePro-VIEW																																									 */
/* NOME DO ARQUIVO: Tradepro_View_Clientes.sql																																								 */
/*******************************************************************************************************************************/
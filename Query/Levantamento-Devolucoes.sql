SELECT a.*
FROM implantacao.mlf_notafiscal a
WHERE 1=1
AND a.codgeraloper IN (102, 133, 173, 177, 188, 251, 401, 402, 567, 581, 708)
AND a.dtaemissao >= '10-JAN-2024'
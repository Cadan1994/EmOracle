/*
UPDATE implantacao.mad_famsegmento a 
SET    a.margemlucrosegmento = a.margemlucrosegmento + 1.00
WHERE  1 = 1
AND    a.margemlucrosegmento is not null
*/
SELECT a.seqfamilia,a.margemlucrosegmento
FROM   implantacao.mad_famsegmento a 
WHERE  1 = 1
AND    a.seqfamilia = 811
--AND    a.nrosegmento = 1
--AND    a.margemlucrosegmento is not null

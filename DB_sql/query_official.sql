/* Query estratto conto annuale con differenza rispetto all'anno precedente di TUTTE le associazioni */
DROP VIEW IF EXISTS saldo_annuale;
CREATE VIEW saldo_annuale AS
	SELECT codass, sum(importo) as saldo
	FROM pagamento P
	WHERE extract(year from P.data) = (extract(year from CURRENT_DATE)-1)
	GROUP BY codass;

DROP VIEW IF EXISTS saldo_anno_prec;
CREATE VIEW saldo_anno_prec AS
	SELECT codass, sum(importo) as saldo
	FROM pagamento P
	WHERE extract(year from P.data) = (extract(year from CURRENT_DATE)-2)
	GROUP BY codass;

SELECT A.codice, A.ragsoc, SA.saldo as "Saldo Anno Corrente", SP.saldo as "Saldo Anno Precedente",
CASE
    WHEN SA.saldo > SP.saldo THEN 'POSITIVO'
	WHEN SA.saldo = SP.saldo THEN 'PARI'
	WHEN SA.saldo IS NULL OR SP.saldo IS NULL THEN 'non disponibile'
    ELSE 'NEGATIVO'
END AS Stato,
CASE
	WHEN SA.saldo > SP.saldo AND SP.saldo > 0::money THEN CONCAT('+',ROUND((((SA.saldo-SP.saldo)/SP.saldo)*100)::numeric, 2))
	WHEN SA.saldo > SP.saldo AND SP.saldo < 0::money THEN CONCAT('+',ROUND((((SA.saldo-SP.saldo)/SP.saldo)*100)::numeric, 2)*-1)
	WHEN SA.saldo IS NULL OR SP.saldo IS NULL THEN 'non calcolabile'
	ELSE CONCAT('-',ROUND((((SA.saldo-SP.saldo)/SP.saldo)*100)::numeric, 2))
END AS Percentuale
FROM associazione A 
LEFT JOIN saldo_annuale as SA ON SA.codass = A.codice
LEFT JOIN saldo_anno_prec as SP ON SP.codass = A.codice
GROUP BY A.codice, A.ragsoc, SA.saldo, SP.saldo
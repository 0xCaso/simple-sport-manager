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

/* 
	Indicare per ogni associazione, le sedi che hanno registrato il maggior numero di prenotazioni lo scorso anno e
	indicare la media delle prenotazioni mensili
	
	Spiegazione:
	Utile ad esempio per avere una statistica delle prenotazioni medie mensili registrate sulla base di dati da tutte le
	associazioni.
	Es. pensa a server con inserimenti mensili o annuali
*/
DROP VIEW IF EXISTS prenotazioni_per_sede;
CREATE VIEW prenotazioni_per_sede AS
	SELECT P.codass, P.sede as cod_sede, count(P.sede) as num, ROUND(count(P.sede)/12.0,2) as prenotazioni_mensili
	FROM prenotazioni P
	JOIN Sede S ON P.sede = S.codice AND P.codass = S.codass
	JOIN Associazione A ON A.codice = S.codass
	JOIN Citta C 		ON C.istat = S.cod_citta
	WHERE extract(year from P.data) = (extract(year from CURRENT_DATE)-1)
	GROUP BY P.codass, P.sede;

SELECT A.ragsoc as associazione, S.nome as nome_sede, C.nome as citta, S.via, M.max as prenotazioni_totali, prenotazioni_mensili
FROM prenotazioni_per_sede P
JOIN (SELECT codass, max(num) as max
		FROM prenotazioni_per_sede
		group by codass) M 		ON P.codass = M.codass AND num = max
JOIN Associazione A				ON A.codice = P.codass
JOIN Sede S 					ON S.codass = P.codass AND S.codice = cod_sede
JOIN Citta C 					ON C.istat = S.cod_citta;


/*
	La Polisportiva Romana (codice POLRM) vuole organizzare un evento calcistico per i suoi tesserati. Deve decidere in quale sede, quale campo e
	quale fascia oraria siano i più adatti per organizzare l'evento. Nella query si indica il nome della sede, il numero del campo, il relativo
	terreno e il numero di prenotazioni totali in cui compare nelle due fasce orarie mattino (dalle 8 alle 12) e pomeriggio (dalle 13 alle 21).
*/
DROP VIEW IF EXISTS utilizzo_campi_pomeriggio;
CREATE VIEW utilizzo_campi_pomeriggio AS
	SELECT p.codass, p.sede, p.id_campo, count(*) as tot_p_pomeriggio
	FROM prenotazioni p
	JOIN campo c ON c.codass = p.codass AND c.id = p.id_campo
	WHERE date_part('hour', p.data) between 13 AND 21
	GROUP BY p.codass, p.id_campo, p.sede
	ORDER BY p.codass, p.sede;

DROP VIEW IF EXISTS utilizzo_campi_mattino;
CREATE VIEW utilizzo_campi_mattino AS
	SELECT p.codass, p.sede, p.id_campo, count(*) as tot_p_mattino
	FROM prenotazioni p
	JOIN campo c ON c.codass = p.codass AND c.id = p.id_campo
	WHERE date_part('hour', p.data) between 8 AND 12
	GROUP BY p.codass, p.id_campo, p.sede
	ORDER BY p.codass, p.sede;

SELECT s.nome as nome_sede, c.id as num_campo, t.sport, t.terreno, tot_p_mattino, tot_p_pomeriggio
FROM campo c
LEFT JOIN tipologia_campo t 
	ON t.codass = c.codass AND t.id = c.tipologia
LEFT JOIN sede s 
	ON s.codass = c.codass AND s.codice = c.cod_sede
LEFT JOIN utilizzo_campi_pomeriggio ucp 
	ON ucp.codass = c.codass AND ucp.sede = c.cod_sede AND ucp.id_campo = c.id
LEFT JOIN utilizzo_campi_mattino ucm 
	ON ucm.codass = c.codass AND ucm.sede = c.cod_sede AND ucm.id_campo = c.id
WHERE c.codass = 'POLRM' AND c.attrezzatura AND t.sport like '_alcio%' 
AND (tot_p_mattino IS NOT NULL OR tot_p_pomeriggio IS NOT NULL)


/* Saldo sedi associazione Calciatori Mestrini (codice CAME), dipendenti attualmente attivi e totale prenotazioni relative a quella sede nell'anno precendente */
SELECT s.nome as nome_sede, sum(importo) as saldo, attivi as dipendenti_attivi, prenotazioni_anno
FROM sede s
LEFT JOIN dipendente d ON d.codass = s.codass AND d.cod_sede = s.codice
LEFT JOIN pagamento p ON p.codass = s.codass AND p.id_dipendente = d.cf
LEFT JOIN (SELECT codass, cod_sede, count(*) as attivi
			FROM dipendente d
			WHERE data_fine IS NULL
			GROUP BY codass, cod_sede
			ORDER BY codass, cod_sede) as ta ON ta.codass = s.codass AND ta.cod_sede = s.codice
LEFT JOIN (SELECT codass, sede, count(*) as prenotazioni_anno
			FROM prenotazioni
			WHERE extract(year from data) = extract(year from CURRENT_DATE)-1
			GROUP BY codass, sede) as pr ON pr.codass = s.codass AND pr.sede = s.codice
WHERE 
s.codass = 'CAME' AND 
(extract(year from p.data) = extract(year from CURRENT_DATE)-1 or importo is null)
GROUP BY s.codice, s.nome, s.codass, attivi, prenotazioni_anno

/* 
	Mostrare i campi disponibili presso tutte le sedi della Polisportiva Romana (codice POLRM) in data 20/05/2020 
	filtrato per la fascia oraria dalle 13:30 alle 21:30 e nel caso ci fossero prenotazioni pendenti su quel campo
	indicare quando è occupato.
*/ 
SELECT s.nome as nome_sede, s.via, s.cod_civico, up.id as num_campo, t.sport, t.terreno, 
	CASE
		WHEN up.da IS NULL THEN 'DISPONIBILE'
		ELSE 'OCCUPATO'
	END as stato,
	to_char(up.da, 'HH24:MI:SS') as da, to_char(up.a, 'HH24:MI:SS') as a
FROM sede s
JOIN associazione a 
	ON a.codice = s.codass
JOIN ((SELECT c.codass, c.cod_sede , c.id, c.tipologia, NULL as da, NULL as a
		FROM campo c
		LEFT JOIN prenotazioni p ON p.codass = c.codass AND p.id_campo = c.id AND p.sede = c.cod_sede
		WHERE (c.codass, c.id) NOT IN (
			SELECT DISTINCT c.codass, id
			FROM campo c
			LEFT JOIN prenotazioni p ON p.codass = c.codass AND p.sede = c.cod_sede AND p.id_campo = c.id
			WHERE data between '2020-5-20 13:30' AND '2020-05-20 21:30'
		)
		GROUP BY c.cod_sede , c.id, c.codass, c.tipologia)
		union
		(SELECT c.codass, c.cod_sede, c.id, c.tipologia, data as da, data + (ore * INTERVAL '1 hour') as a
		FROM campo c
		JOIN prenotazioni p ON p.codass = c.codass AND p.sede = c.cod_sede AND p.id_campo = c.id
		WHERE data between '2020-5-20 13:30' AND '2020-05-20 21:30'
		GROUP BY c.codass, c.id, c.cod_sede, c.tipologia, data, ore)) as up
	ON up.codass = s.codass AND up.cod_sede = s.codice
JOIN tipologia_campo t
	ON t.codass = a.codice AND t.id = up.tipologia
WHERE a.codice = 'POLRM'
ORDER BY a.codice, s.codice, s.nome, up.id, up.da

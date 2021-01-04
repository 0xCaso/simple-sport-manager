
/* Query estratto conto o simile */
SELECT A.codice, A.ragsoc, saldo 
FROM associazione A
LEFT JOIN (
	SELECT codass, sum(importo) as saldo
	FROM pagamento P
	WHERE extract(year from P.data) = 2020
	GROUP BY codass
) as P ON P.codass = A.codice
GROUP BY A.codice, A.ragsoc, saldo

/* Saldo stagione estiva per esempio */
SELECT A.codice, A.ragsoc, sum(importo) as saldo
FROM associazione A, pagamento P
WHERE 
	P.codass = A.codice AND extract(MONTH from P.data) between 4 AND 9 AND extract(YEAR from P.data) = 2020
GROUP BY A.codice, A.ragsoc

select *
from pagamento

/* Bilancio delle spese FAIL! */
SELECT sum(P1.importo) as spese_stipendi, sum(P2.importo) as spese_esborsi,  sum(P3.importo) as spese_arbitri
FROM pagamento P1, pagamento P2, pagamento P3, Stipendi S, Esborsi E, Fatture F
WHERE
	P1.codass = S.codass AND P1.id_dipendente = S.id_dipendente AND P1.data = S.data 
/*	AND
	P2.codass = E.codass AND P2.id_dipendente = E.id_dipendente AND P2.data = E.data AND
	P3.codass = F.codass AND P3.id_dipendente = F.id_dipendente AND P3.data = F.data 
	AND P1.codass = 'JSDB' AND P2.codass = 'JSDB' AND P3.codass = 'JSDB'
*/

/* Query per la visualizzazione degli stipendi */
select P.codass, P.importo*(-1) as importo, D1.nome as Nome_Emissivo, D1.cognome as Cognome_Emissivo, D2.nome as Nome_Ricevente, D2.cognome as Cognome_Ricevente, P.data
from Pagamento as P
join dipendente D1 on 
	D1.codass = P.codass AND D1.cf = P.id_dipendente
join stipendi S on
	S.codass = P.codass AND S.data = P.data AND S.id_dipendente = P.id_dipendente
join dipendente D2 on
	S.soggetto = D2.cf AND S.codass = D2.codass
where tipo_operazione = 'S';

/* Sport più ricercato */
SELECT sport, count(sport)
FROM prenotazioni P
JOIN campo C ON P.codass = C.codass AND P.id_campo = C.id AND P.sede = C.cod_sede
JOIN tipologia_campo T ON T.codass = C.codass AND T.id = C.tipologia
GROUP BY (sport)

/* Tesserati che hanno fatto almeno 2 prenotazioni nel 2020 */
SELECT T.cf as codice_fiscale, T.cognome, T.nome, count(data), T.codass
FROM prenotazioni P
JOIN tesserino T ON P.codass = T.codass AND P.id_tesserino = T.cf
WHERE extract(YEAR from P.data) = 2020 --AND T.codass = 'POLRM'
GROUP BY T.cf, T.cognome, T.nome, T.codass
HAVING count(data) > 2

select *
from campo

select *
from prenotazioni

select *
from tipologia_Campo

select *
from campo

/*
	IDEE:
	- Volendo calcolare anche la media di inserimenti al giorno.
	- Mese in cui ha registrato il maggior numero di registrazioni di nuovi tesserati
*/

SELECT codass, cod_sede, count(*) as attivi
FROM dipendente d
WHERE data_fine IS NULL
GROUP BY codass, cod_sede
ORDER BY codass, cod_sede





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


SELECT codass, sede, count(*) as prenotazioni_anno
FROM prenotazioni
WHERE extract(year from data) = extract(year from CURRENT_DATE)-1
GROUP BY codass, sede

select cod_sede, s.nome, cf, sum(importo)
from pagamento p
join dipendente d ON d.codass = p.codass
join sede s ON s.codass = p.codass AND s.codice = d.cod_sede
where p.codass = 'CAME' and extract(year from P.data) = 2020
group by p.codass, cod_sede, cf, s.nome


UPDATE dipendente
SET cod_sede = 1
WHERE codass='CAME' AND cf='SCCTCR93M24L183J'; 

select *
from dipendente
where cf = 'SCCTCR93M24L183J'

SELECT date_part('hour', now())




















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
	- Mese in cui ha registrato il maggior numero di registrazioni di nuovi tesserati.
	- Sport, terreno e Fascia oraria in cui vengono usati i campi
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
WHERE c.codass = 'POLRM' AND c.attrezzatura

select id_campo, count(*)
from prenotazioni
where codass = 'POLRM'
GROUP BY codass, id_campo, sede
order by id_campo






SELECT date_part('hour', now())


















